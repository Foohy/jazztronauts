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
include( "cl_texturelocs.lua" )
include( "cl_hud.lua" )

local shouldHide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudCrosshair"] = true,
}

local isInSpecialMap = mapcontrol.IsInHub() or mapcontrol.IsInEncounter()

jazzHideHUD = false
jazzHideHUDSpecial = false
hook.Add( "PreDrawHUD", "JazzCheckToHideHUD", function()
	local playerwep = LocalPlayer():GetActiveWeapon()

	if (IsValid(playerwep) and playerwep:GetClass() == "gmod_camera")
	or !GetConVar("cl_drawhud"):GetBool()
	or GAMEMODE:IsWaitingForPlayers() then
		jazzHideHUD = true
	else
		jazzHideHUD = false
	end

	if isInSpecialMap or dialog.IsInDialog() or jazzHideHUD then
		jazzHideHUDSpecial = true
	else
		jazzHideHUDSpecial = false
	end
end )

function GM:HUDShouldDraw( name )
	if jazzHideHUDSpecial then
		if shouldHide[name] then return false end
	end

	return self.BaseClass.HUDShouldDraw(self, name)
end
