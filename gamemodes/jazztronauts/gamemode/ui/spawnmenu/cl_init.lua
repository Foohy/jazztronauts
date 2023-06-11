include( "creation.lua")
include( "radar.lua")
include( "info.lua")
include( "menu.lua" )

function GM:SpawnMenuOpen()
	if cvars.Bool("jazz_debug_allow_gmspawn") then return true end
	if mapcontrol.IsInGamemodeMap() then return false end

	GAMEMODE:SuppressHint( "OpeningMenu" )

	return true
end

function GM:ContextMenuOpened()
	GAMEMODE:SuppressHint( "OpeningContext" )
end
