include( "creation.lua")
include( "radar.lua")
include( "info.lua")
include( "menu.lua" )

function GM:SpawnMenuOpen()

	GAMEMODE:SuppressHint( "OpeningMenu" )
	GAMEMODE:AddHint( "OpeningContext", 20 )

	return true

end