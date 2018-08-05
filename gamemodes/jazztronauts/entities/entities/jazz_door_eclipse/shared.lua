ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true

ENT.DelayTime = 0.75 //how long until the screen begins to fade
ENT.FadeTime = 0.80 //how long it takes to fade completely
ENT.WaitTime = 0.10 //period for it to stay completely black

ENT.DEST_ENCOUNTER  = 1
ENT.DEST_ENDGAME	= 2

function ENT:GetDestination()
	if newgame.GetResetCount() == 0 then return nil end

	local bshardcount, bshardreq = mapgen.GetTotalCollectedBlackShards(), mapgen.GetTotalRequiredBlackShards()
	local hasreq = bshardcount >= bshardreq
	local seenEclipse = newgame.GetGlobal("encounter_1")

	-- If they haven't encountered the cat, talk to them first
	if not seenEclipse then return self.DEST_ENCOUNTER end

	-- Else, they have encountered AND have enough shards to end the game
	if hasreq then return self.DEST_ENDGAME end

	-- Nah
	return nil
end
