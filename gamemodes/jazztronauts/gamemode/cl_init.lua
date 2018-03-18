include( "shared.lua" )

include( "map/cl_init.lua")
include( "ui/cl_init.lua" )
include( "missions/cl_init.lua" )
include( "workshop/workshop.lua" )
include( "store/cl_init.lua" )
include( "snatch/cl_init.lua" )

include( "cl_scoreboard.lua" )
include( "cl_hud.lua" )

GM.HideHUD = {
	"CHudHealth",
	"CHudBattery",
	"CHudAmmo",
	"CHudSecondaryAmmo",
}

function GM:HUDShouldDraw( name )
	
	return !mapcontrol.IsInHub() or !table.HasValue(self.HideHUD, name)
end