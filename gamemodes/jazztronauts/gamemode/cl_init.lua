include( "shared.lua" )

include( "newgame/cl_init.lua")
include( "map/cl_init.lua")
include( "store/cl_init.lua" )
include( "ui/cl_init.lua" )
include( "missions/cl_init.lua" )
include( "snatch/cl_init.lua" )
include( "playerwait/cl_init.lua")

include( "player.lua" )

include( "cl_scoreboard.lua" )
include( "cl_jazzphysgun.lua")
include( "cl_hud.lua" )

GM.HideHUD = {
	"CHudHealth",
	"CHudBattery",
	"CHudAmmo",
	"CHudSecondaryAmmo",
	"CHudCrosshair",
}

local isInSpecialMap = mapcontrol.IsInHub() or mapcontrol.IsInEncounter()

function GM:HUDShouldDraw( name )
	if isInSpecialMap or dialog.IsInDialog() then
		return !table.HasValue(self.HideHUD, name)
	end
	return true
end
