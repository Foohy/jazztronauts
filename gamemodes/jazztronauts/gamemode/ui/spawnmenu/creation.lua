local PANEL = {}

function PANEL:Init()

	self:Populate()
	self:SetFadeTime( 0 )

end

function PANEL:Populate()

	local pnl = vgui.Create( "Panel" )

	self:AddSheet( "Props", pnl, "icon16/exclamation.png", nil, nil, "Spawn your props" )

	local child = vgui.Create( "ContentContainer", pnl )
	for i=1, 100 do
		local icon = spawnmenu.CreateContentIcon( "model", child, 
			{ 
				model = "models/props_c17/chair02a.mdl", 
				wide = 128, 
				tall = 128 
			} )

		icon.OpenMenu = function() end
		--local icon = vgui.Create("ContentIcon")
		--[[icon:SetName("Large Dildo")
		icon.DoClick = function()
			surface.PlaySound( "ui/buttonclickrelease.wav" )
		end]]
		child:Add( icon )
	end
	child:Dock(FILL)

	local pnl = vgui.Create( "ToolMenu" )

	self:AddSheet( "Tools", pnl, "icon16/exclamation.png", nil, nil, "Select tools" )

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