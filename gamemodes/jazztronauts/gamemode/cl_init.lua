include( "shared.lua" )
include( "cl_scoreboard.lua" )
include( "cl_hud.lua" )
include( "map/mapcontrol.lua" )

GM.HideHUD = {
	"CHudHealth",
	"CHudBattery",
	"CHudCrosshair",
	"CHudAmmo",
	"CHudSecondaryAmmo",
}

function GM:HUDShouldDraw( name )
	return !table.HasValue(self.HideHUD, name)
end