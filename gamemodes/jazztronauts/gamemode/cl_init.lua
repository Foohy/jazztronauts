include( "shared.lua" )
include( "cl_scoreboard.lua" )
include( "cl_hud.lua" )
include( "ui/cl_init.lua" )
include( "map/cl_init.lua")
include( "workshop/workshop.lua" )

GM.HideHUD = {
	"CHudHealth",
	"CHudBattery",
	"CHudCrosshair",
	"CHudAmmo",
	"CHudSecondaryAmmo",
}

function GM:HUDShouldDraw( name )
	
	return !mapcontrol.IsInHub() or !table.HasValue(self.HideHUD, name)
end