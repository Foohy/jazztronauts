local PANEL = {}

function PANEL:Init()

	self:Populate()
	self:SetFadeTime( 0 )

end

function PANEL:AddUnlockedProp( model )

	local icon = spawnmenu.CreateContentIcon( "model", self.content, 
		{ 
			model = model, 
			wide = 128, 
			tall = 128 
		} )

	icon.OpenMenu = function() end
	--local icon = vgui.Create("ContentIcon")
	--[[icon:SetName("Large Dildo")
	icon.DoClick = function()
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	end]]
	self.content:Add( icon )

end

function PANEL:AddUnlockedWeapon( weapon )
	local wepinfo = list.Get("Weapon")[weapon]
	if not wepinfo then return false end

	local icon = spawnmenu.CreateContentIcon( wepinfo.ScriptedEntityType or "weapon", self.content, 
		{ 
			nicename = wepinfo.PrintName or wepinfo.ClassName or weapon,
			spawnname = wepinfo.ClassName or weapon,
			material = "entities/" .. (wepinfo.ClassName or weapon) .. ".png",
			admin = wepinfo.AdminOnly
		} )

	icon.OpenMenu = function() end
	self.weapons:Add( icon )
	return true
end

function PANEL:Populate()

	-- Prop Panel
	local pnl = vgui.Create( "Panel", self )
	self:AddSheet( "Props", pnl, "icon16/exclamation.png", nil, nil, "Spawn your props" )

	self.content = vgui.Create( "ContentContainer", pnl )
	self.content:Dock( FILL )

	if unlocks.IsValid( "props" ) then

		for _, prop in pairs( unlocks.GetAll( "props" ) ) do
			self:AddUnlockedProp( prop )
		end

	end
	hook.Add("OnUnlocked", "creation_panel_unlock", function( list, key )
		if list == "props" then
			self:AddUnlockedProp( key )
		end
	end)

	//local pnl = vgui.Create( "DPanel" )
	//self:AddSheet( "Tools", pnl, "icon16/exclamation.png", nil, nil, "Select tools" )


	-- Weapons Panel
	local pnl = vgui.Create( "DPanel" )
	self:AddSheet( "Weapons", pnl, "icon16/exclamation.png", nil, nil, "Guns" )
	
	self.weapons = vgui.Create( "ContentContainer", pnl )
	self.weapons:Dock( FILL )

	-- Go through every registered jazz weapon and try to add them
	for k, v in pairs(list.Get("Weapon")) do
		if v.Category == "Jazztronauts" and GAMEMODE:JazzCanSpawnWeapon(LocalPlayer(), k) then
			self:AddUnlockedWeapon( k )
		end
	end

	hook.Add("OnUnlocked", "weapons_panel_unlock", function( list, key )
		if list == "store" then
			self:AddUnlockedWeapon( key )
		end
	end)


	-- Backup spawnmenu just in case
	local pnl = vgui.Create( "CreationMenu" )
	self:AddSheet( "Dogs", pnl, "icon16/exclamation.png", nil, nil, "Dogs?" )

	--[[local tabs = spawnmenu.GetCreationTabs()

	for k, v in SortedPairsByMemberValue( tabs, "Order" ) do

		--
		-- Here we create a panel and populate it on the first paint
		-- that way everything is created on the first view instead of
		-- being created on load.
		--
		local pnl = vgui.Create( "Panel" )

		self:AddSheet( k, pnl, v.Icon, nil, nil, v.Tooltip )

		-- Populate the panel
		-- We have to add the timer to make sure g_Spawnmenu is available
		-- in case some addon needs it ready when populating the creation tab.
		timer.Simple( 0, function()
			local childpnl = v.Function()
			childpnl:SetParent( pnl )
			childpnl:Dock( FILL )
		end )

	end]]

end

vgui.Register( "JazzCreationMenu", PANEL, "DPropertySheet" )