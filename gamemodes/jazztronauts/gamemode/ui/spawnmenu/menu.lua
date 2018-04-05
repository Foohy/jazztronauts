local PANEL = {}

function PANEL:Init()

	self:Dock( FILL )

	self.HorizontalDivider = vgui.Create( "DHorizontalDivider", self )
	self.HorizontalDivider:Dock( FILL )
	self.HorizontalDivider:SetLeftWidth( ScrW() )
	self.HorizontalDivider:SetDividerWidth( 6 )

	self.HorizontalDivider:SetRightMin( 390 )
	if ( ScrW() > 1280 ) then
		self.HorizontalDivider:SetRightMin( 460 )
	end

	self.VerticalDivider = vgui.Create( "DVerticalDivider", self )


	self.CreateMenu = vgui.Create( "JazzCreationMenu", self.HorizontalDivider )
	self.Radar = vgui.Create( "JazzRadarPanel", self.VerticalDivider )
	self.Info = vgui.Create( "JazzInfoPanel", self.VerticalDivider )

	self.HorizontalDivider:SetLeft( self.CreateMenu )
	self.HorizontalDivider:SetRight( self.VerticalDivider )

	self.VerticalDivider:SetTop( self.Radar )
	self.VerticalDivider:SetBottom( self.Info )

end

function PANEL:Open()

	RestoreCursorPosition()

	if self:IsVisible() then return end

	CloseDermaMenus()

	self:MakePopup()
	self:SetVisible( true )
	self:SetKeyboardInputEnabled( false )
	self:SetMouseInputEnabled( true )
	self:SetAlpha( 255 )


end

function PANEL:Close( bSkipAnim )

	RememberCursorPosition()

	CloseDermaMenus()

	self:SetKeyboardInputEnabled( false )
	self:SetMouseInputEnabled( false )
	self:SetVisible( false )

end

function PANEL:PerformLayout()

	local spawnmenu_border = 0.1
	local MarginX = math.Clamp( ( ScrW() - 1024 ) * spawnmenu_border, 25, 256 )
	local MarginY = math.Clamp( ( ScrH() - 768 ) * spawnmenu_border, 25, 256 )

	self:DockPadding( 0, 0, 0, 0 )
	self.HorizontalDivider:DockMargin( MarginX, MarginY, MarginX, MarginY )
	self.HorizontalDivider:SetLeftMin( self.HorizontalDivider:GetWide() / 3 )

	--self.ToolToggle:AlignRight( 6 )
	--self.ToolToggle:AlignTop( 6 )

end

vgui.Register( "JazzSpawnMenu", PANEL, "EditablePanel" )

local function CreateJazzMenu()

	-- If we have an old spawn menu remove it.
	if ( IsValid( g_JazzSpawnMenu ) ) then

		g_JazzSpawnMenu:Remove()
		g_JazzSpawnMenu = nil

	end

	-- Start Fresh
	--spawnmenu.ClearToolMenus()

	-- Add defaults for the gamemode. In sandbox these defaults
	-- are the Main/Postprocessing/Options tabs.
	-- They're added first in sandbox so they're always first
	--hook.Run( "AddGamemodeToolMenuTabs" )

	-- Use this hook to add your custom tools
	-- This ensures that the default tabs are always
	-- first.
	--hook.Run( "AddToolMenuTabs" )

	-- Use this hook to add your custom tools
	-- We add the gamemode tool menu categories first
	-- to ensure they're always at the top.
	--hook.Run( "AddGamemodeToolMenuCategories" )
	--hook.Run( "AddToolMenuCategories" )

	-- Add the tabs to the tool menu before trying
	-- to populate them with tools.
	--hook.Run( "PopulateToolMenu" )

	g_JazzSpawnMenu = vgui.Create( "JazzSpawnMenu" )
	g_JazzSpawnMenu:SetVisible( false )

	--hook.Run( "PostReloadToolsMenu" )

end

hook.Add( "InitPostEntity", "CreateJazzMenu", CreateJazzMenu )
--CreateJazzMenu()

function GM:OnSpawnMenuOpen()

	-- Let the gamemode decide whether we should open or not..
	if ( !hook.Run( "SpawnMenuOpen" ) ) then return end

	if ( IsValid( g_JazzSpawnMenu ) ) then

		g_JazzSpawnMenu:Open()
		--menubar.ParentTo( g_JazzSpawnMenu )

	end

end

function GM:OnSpawnMenuClose()

	if ( IsValid( g_JazzSpawnMenu ) ) then g_JazzSpawnMenu:Close() end

end