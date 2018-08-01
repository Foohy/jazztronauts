include( "creation.lua")
include( "radar.lua")
include( "info.lua")
include( "menu.lua" )

function GM:SpawnMenuOpen()
	if cvars.Bool("jazz_debug_allow_gmspawn") then return true end
	if mapcontrol.IsInGamemodeMap() then return false end

	GAMEMODE:SuppressHint( "OpeningMenu" )
	GAMEMODE:AddHint( "OpeningContext", 20 )

	return true
end