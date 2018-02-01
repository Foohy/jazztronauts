include( "shared.lua" )

include( "missions/cl_init.lua" )
include( "map/cl_init.lua")
include( "ui/cl_init.lua" )
include( "workshop/workshop.lua" )


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