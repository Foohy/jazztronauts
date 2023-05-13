-- Register upgrade that allows them to buy back their spawn menu
jstore.Register("spawnmenu", 100000, {
	cat = "tools",
	name = jazzloc.Localize("jazz.gmod_spawn"),
	desc = jazzloc.Localize("jazz.gmod_spawn.desc"),
	thirdparty = true
})

if SERVER then return end

local PANEL = {}

function PANEL:Init()

	self:Populate()
	self:SetFadeTime( 0 )
	self:SetSkin( "Jazz" )

end

function PANEL:AddUnlockedProp( model )

	if not string.find(model, ".mdl") then return end

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

function PANEL:AddLegacySpawnMenu()
	self.HasLegacyMenu = true

	if IsValid(self.LegacySpawnMenuTab) then
		self.LegacySpawnMenuTab:Show()
	end
end

function PANEL:Populate()

	-- Prop Panel
	local pnl = vgui.Create( "Panel", self )
	self:AddSheet( "#jazz.gmodspawn.props", pnl, "icon16/application_view_tile.png", nil, nil, "#jazz.gmodspawn.props.desc" )

	self.content = vgui.Create( "ContentContainer", pnl )
	self.content:Dock( FILL )
	self.content:SetSkin( "Jazz" )
	self.content.VBar:SetWide(30)

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
	//self:AddSheet( "#spawnmenu.tools_tab", pnl, "icon16/exclamation.png", nil, nil, "Select tools" )


	-- Weapons Panel
	local pnl = vgui.Create( "DPanel" )
	self:AddSheet( "#spawnmenu.category.weapons", pnl, "icon16/gun.png", nil, nil, "#jazz.gmodspawn.weapons.desc" )

	self.weapons = vgui.Create( "ContentContainer", pnl )
	self.weapons:Dock( FILL )
	self.weapons:SetSkin( "Jazz" )

	-- Go through every registered jazz weapon and try to add them
	for k, v in pairs(list.Get("Weapon")) do
		if v.Category == "Jazztronauts" and GAMEMODE:JazzCanSpawnWeapon(LocalPlayer(), k) then
			self:AddUnlockedWeapon( k )
		end
	end

	hook.Add("OnUnlocked", "weapons_panel_unlock", function( list, key )
		if list == "store" then
			self:AddUnlockedWeapon( key )

			if key == "spawnmenu" then
				self:AddLegacySpawnMenu()
			end
		end
	end)

	local function addSpawnMenu()
		local pnl = g_SpawnMenu
		if not IsValid(pnl) then return end

		-- Add the entire spawnmenu as a sheet on the jazz spawnmenu
		local sheet = self:AddSheet( "#jazz.gmodspawn.sandbox", pnl, "icon16/clock.png", nil, nil, "#jazz.gmodspawn.sandbox.desc" )

		-- Hook into when it's removed so we can handle that gracefully
		oldremove = pnl.OnRemove
		local function OnRemove(pnl)
			if oldremove then oldremove(pnl) end

			if self.LegacySpawnMenuTab == sheet.Tab then
				self.LegacySpawnMenuTab = nil
			end

			self:CloseTab(sheet.Tab)
		end
		pnl.OnRemove = OnRemove

		self.LegacySpawnMenuTab = sheet.Tab
		if not self.HasLegacyMenu then
			sheet.Tab:Hide()
		end
	end

	-- Hook into when the spawnmenu is created so we can control it
	addSpawnMenu()
	hook.Add( "PostReloadToolsMenu", "JazzHijackSpawnMenu", function()
		addSpawnMenu()
	end )

	-- Backup spawnmenu just in case
	--local createSpawnmenu = concommand.GetTable()["spawnmenu_reload"]
	--local pnl = vgui.Create( "SpawnMenu" )


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