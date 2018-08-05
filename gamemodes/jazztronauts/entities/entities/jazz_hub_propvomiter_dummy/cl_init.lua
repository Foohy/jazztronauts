include("shared.lua")

ENT.TurboMusicFile = "sound/jazztronauts/music/trash_chute_turbo.mp3"
ENT.TurboMusicEndFile = "jazztronauts/music/trash_chute_music_stop.wav"

function ENT:Think()
	if not self.GetIsVomiting then return end

	local isVomiting = self:GetIsVomiting()
	if self.WasVomiting != isVomiting then
		if isVomiting then
			self:OnStartVomiting()
		elseif self.WasVomiting then
			self:OnStopVomiting()
		end

		self.WasVomiting = isVomiting
	end

	-- Mute if alt tabbed
	if IsValid(self.MusicChannel) then
		self.MusicChannel:SetVolume(system.HasFocus() and 1.0 or 0.0)
	end
end

function ENT:OnStartVomiting()
	sound.PlayFile(self.TurboMusicFile, "noblock", function(channel, errid, errstr)
		if not IsValid(channel) then return end
		if not self:GetIsVomiting() or IsValid(self.MusicChannel) then
			channel:Stop()
			return
		end

		channel:EnableLooping(true)
		self.MusicChannel = channel
	end )
end

function ENT:OnStopVomiting()
	if true then return end -- it's funnier if we hard-cut music

	if IsValid(self.MusicChannel) then
		self.MusicChannel:Stop()
		self.MusicChannel = nil
	end

	-- Play finale sound
	surface.PlaySound(self.TurboMusicEndFile)
end