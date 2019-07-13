ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true

ENT.DelayTime = 0.75 //how long until the screen begins to fade
ENT.FadeTime = 0.80 //how long it takes to fade completely
ENT.WaitTime = 0.10 //period for it to stay completely black

ENT.DEST_ENCOUNTER  = 1
ENT.DEST_ENDGAME	= 2

function ENT:GetDestination()
	local dest, changelevel = mapcontrol.GetNextEncounter()
	return dest 
end
