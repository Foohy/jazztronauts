AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.AutomaticFrameAdvance = true
ENT.Model			= "models/sunabouzu/jazzportal.mdl"

local IDLE_HUM_SOUND        = Sound("ambient/machines/thumper_amb.wav")
local FAIL_SOUND            = Sound("coast.thumper_shutdown")
local DOWNLOAD_START_SOUND  = Sound("coast.thumper_startup")
local SUCCESS_SOUND         = Sound("coast.thumper_hit")

local SCAN_FAILED_NOMAP     = -3
local SCAN_FAILED_NOSPACE   = -2
local SCAN_FAILED_NETWORK   = -1
local SCAN_IDLE             =  0
local SCAN_SCANNING         =  1
local SCAN_COMPLETE         =  2

local outputs =
{
	"OnMapSelected",
	"OnMapDownloaded",
	"OnMapAnalyzed",
	"OnMapDeselected",
	"OnMapFailure"
}

function ENT:Initialize()
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:EnableMotion( false )
	end

	-- Hook into map change events
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:SetPortalSequence(seqName, noreset)
	local sequence = self:LookupSequence(seqName)

	if (self:GetSequence() != sequence ) then
		if not noreset then
			self:ResetSequence(sequence)
		end

		self:SetPlaybackRate(1.0)
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "SelectedDestinationID")
	self:NetworkVar("Int", 0, "ScanState")
	self:NetworkVar("Int", 1, "FreezeTime")
	self:NetworkVar("Int", 2, "Facing")
end

function ENT:KeyValue( key, value )

	if key == "facing" then
		self:SetFacing(tonumber(value) or 0)
	end

	if table.HasValue(outputs, key) then
		self:StoreOutput(key, value)
	end
end

function ENT:AcceptInput( name, activator, caller, data )

	if name == "SelectAddon" then
		//self:SelectAddon()
		return true
	end
	if name == "CancelAddon" then
		self:CancelAddon()
		return true
	end

	return false
end

function ENT:CancelAddon()
	self:SelectDestination(nil)
	self:SetPortalSequence("Close")
	self:StopSound(IDLE_HUM_SOUND)
	self:TriggerOutput("OnMapDeselected",self)

	/*
	for _, v in pairs(ents.FindByClass("jazz_hub_browser")) do
		v:SetOn(true)
	end
	*/
end

function ENT:BuildMapFacts(map, wsid)
	self.FactTask = factgen.GetMapFacts(map, wsid)
	self.FactMap = map

	function self.FactTask.OnFinished(tself, time, facts)
		if not IsValid(self) or map != self.FactMap then return end

		factgen.SetFacts(facts)
	end
end

function ENT:MapFinishedEffects(success, ermsg)
	if success then
		self:EmitSound(IDLE_HUM_SOUND, 65, 80, 0.5)
		self:EmitSound(SUCCESS_SOUND)
		util.ScreenShake(self:GetPos(), 2, 10, 1, 1500)
	else
		factgen.SetFailure(self:GetScanStateString() .. (ermsg and ("," .. ermsg) or ""))
		self:EmitSound(FAIL_SOUND)
		self:TriggerOutput("OnMapFailure",self)
	end
end

function ENT:SelectDestination(dest)
	mapcontrol.SetSelectedMap(nil) -- Tell the current bus to leave
	factgen.ClearFacts() -- No more facts

	self:SetSelectedDestinationID(dest or "")

	if not dest or #dest == 0 then
		self:SetScanState(SCAN_IDLE)
		self.CurrentlyScanning = nil
		self:TriggerOutput("OnMapDownloaded", self, 0)
		return
	end

	self:SetScanState(SCAN_SCANNING)
	self:SetPortalSequence("Open")
	self:TriggerOutput("OnMapSelected", self)

	local function onPreDecompress()
		self:SetFreezeTime(CurTime() + 4 + FrameTime())
		return 4.0 + FrameTime()
	end

	local function setActiveMap(mapname, wsid)
		mapcontrol.SetSelectedMap(mapname)

		self:TriggerOutput("OnMapDownloaded", self, mapname and 1 or 0)
		self:SetPortalSequence("Settle")

		-- At this point we'd start analyzing the map (bsp magic)
		-- Not implemented, but yknow, let em dream
		if mapname then
			self:TriggerOutput("OnMapAnalyzed", self)

			-- Start grabbing Map Facts:tm:
			self:BuildMapFacts(mapname, wsid)
		end
	end

	local function onMounted(files, msg)
		if self.CurrentlyScanning != dest then return end
		local wsid = tonumber(dest)
		self.CurrentlyScanning = nil
		self:SetFreezeTime(0)

		local success = false
		local newMaps = {}
		if files then
			-- Store the workshop id association for every map contained in this addon
			for _, v in pairs(files) do
				if not string.match(v, "maps/.*.bsp") then continue end
				local filename = string.GetFileFromFilename(string.StripExtension(v))

				progress.StoreMap(filename, wsid)
				table.insert(newMaps, filename)
			end

			-- Make sure there was actually maps added!!
			if #newMaps > 0 then
				success = true
			else
				print("Addon id " .. wsid .. " contains no maps at all!!")
			end
			self:SetScanState(#newMaps > 0 and SCAN_COMPLETE or SCAN_FAILED_NOMAP)
		else
			self:SetScanState(SCAN_FAILED_NETWORK)
		end

		self:MapFinishedEffects(success, msg)

		setActiveMap(table.Random(newMaps), wsid)
	end

	-- Attempt to mount the given addon (cache-aware)
	self.CurrentlyScanning = dest
	local wsid = tonumber(dest)
	if wsid then
		if (not workshop.IsAddonCached(wsid)) then
			self:EmitSound(DOWNLOAD_START_SOUND)
		end
		mapcontrol.InstallAddon(tostring(wsid), onMounted, onPreDecompress)
	else
		self:SetScanState(SCAN_COMPLETE)
		self:MapFinishedEffects(true)
		setActiveMap(dest)
	end

end

function ENT:Use(activator, caller)

	timer.Simple(0, function()
		if #self:GetSelectedDestinationID() > 0 then
			self:CancelAddon()
		else
			ents.FindByClass("jazz_hub_browser")[1]:SelectCurrentAddon()
		end
	end)

end

function ENT:GetScanStateString()
	local state = self:GetScanState()
	if state == SCAN_IDLE then return "jazz.levelselect.idle"
	elseif state == SCAN_SCANNING then return "jazz.levelselect.scan"
	elseif state == SCAN_COMPLETE then return "jazz.levelselect.done"
	elseif state == SCAN_FAILED_NOMAP then return "jazz.levelselect.fail.nomap"
	elseif state == SCAN_FAILED_NETWORK then return "jazz.levelselect.fail.network"
	elseif state == SCAN_FAILED_NOSPACE then return "jazz.levelselect.fail.nospace"
	end

	return "jazz.levelselect.fail"
end

if SERVER then return end

ENT.ScreenScale = 0.09

local noThumbMat = Material("vgui/black")

local sizeX = 1024
local sizeY = 1024
local rt = irt.New("jazz_thumbnail_selector_screen", sizeX, sizeY)

function ENT:UpdateRenderTarget()

	rt:Render(function()
		render.Clear(0, 0, 0, 255)

		cam.Start2D()

			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(self.ThumbnailMat or noThumbMat)
			surface.DrawTexturedRect(0, 0, sizeX, sizeY)

			local title = self.AddonTitle or ""
			draw.SimpleTextOutlined( title, "JazzTVChannel", sizeX/2, sizeY * 0.3, Color(60,255,60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black )

			local scanstate = jazzloc.Localize(self:GetScanStateString())
			draw.SimpleTextOutlined( scanstate, "JazzTVChannel", sizeX/2, sizeY/2, Color(60,255,60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black )
		cam.End2D()

	end)
end

function ENT:IntermissionThink()
	LocalPlayer().JazzInterFreeze = self:GetFreezeTime()

	if self:GetFreezeTime() == 0 then
		self.PlayedSpinup = false
		if self.SoundChannel then
			self.LastSoundPos = self.SoundChannel:GetTime()
			self.SoundChannel:Stop()
			self.SoundChannel = nil
		end
		return
	end

	local time = self:GetFreezeTime() - CurTime()

	if time < 2.5 then
		if not self.PlayedSpinup then
			self.PlayedSpinup = true
			LocalPlayer():EmitSound("ambient/levels/labs/teleport_preblast_suckin1.wav")
		end
	end

	if time <= 0 and not self.WaitingSoundChannel and not self.SoundChannel then
		self.WaitingSoundChannel = true -- Queued, but no channel yet
		RunConsoleCommand("stopsound")
		timer.Simple(0, function()
			sound.PlayFile("sound/jazztronauts/music/intermission_music.mp3", "noblock", function(channel, err, errstr)
				self.WaitingSoundChannel = nil
				if self:GetFreezeTime() == 0 then
					channel:Stop()
					return
				end

				channel:EnableLooping(true)
				if self.LastSoundPos then
					channel:SetTime(self.LastSoundPos)
				end
				self.SoundChannel = channel -- Queued, but no channel yet
			end )
		end )
	end
end

function ENT:Think()
	self:IntermissionThink()

	local dest = self:GetSelectedDestinationID()
	if self.LastDestinationID != dest then
		self.LastDestinationID = dest
		self:RefreshThumbnail(dest)
	end

	local facing = self:GetFacing()
	if facing >= 1 and facing <= 3 then
		local rGoal = (EyePos() - self:GetPos()):Angle()
		if not self.LastRot then self.LastRot = rGoal end
		local r = LerpAngle(FrameTime(), self.LastRot, rGoal)
		self.LastRot = r

		--todo: work on getting these rotations okay.
		--[[local target = self:GetAngles()
		target[facing] = r[facing] + target[facing]
		self:SetAngles(target)]]

		local m = Matrix()
		m:Scale(Vector(1, 1, 1))
		m:Rotate(Angle(0, r.y - self:GetAngles().y, 0))
		self:EnableMatrix("RenderMultiply", m)

		self:UpdateRenderTarget()
	end
end

function ENT:RefreshThumbnail(dest)
	self.ThumbnailMat = nil
	self.AddonTitle = ""
	local wsid = tonumber(dest)
	if wsid then
		steamworks.FileInfo( wsid, function( result )
			if !IsValid(self) or !result then return end

			self.AddonTitle = result.title

			workshop.FetchThumbnail(result, function(material)
				if !self then return end

				self.ThumbnailMat = material
			end )
		end )
	else
		self.ThumbnailMat = nil
	end
end

function ENT:Draw()
	local goal = self:GetScanState() == SCAN_COMPLETE and 1.0 or 0
	self.LastOpacity = self.LastOpacity or goal
	self.LastOpacity = math.Approach(self.LastOpacity, goal, FrameTime())

	render.SetBlend(self.LastOpacity)
	render.MaterialOverrideByIndex(0, rt:GetUnlitMaterial(true))
	self:DrawModel()
	render.MaterialOverrideByIndex(0, nil)
	render.SetBlend(1)
end

surface.CreateFont( "JazzIntermissionCountdown", {
	font	  = "KG Shake it Off Chunky",
	size	  = ScreenScale(32),
	weight	= 700,
	antialias = true
})

local interMat = Material("materials/ui/jazztronauts/intermission.png", "smooth")
hook.Add("HUDPaint", "JazzDrawIntermissionFreeze", function()
	local freezeTime = LocalPlayer().JazzInterFreeze
	if not freezeTime or freezeTime == 0 then return end
	local time = freezeTime - CurTime()
	local timeStr = math.max(0, math.Round(time))
	if timeStr < 1 then timeStr = jazzloc.Localize("jazz.levelselect.merge") end

	draw.SimpleText(timeStr, "JazzIntermissionCountdown", ScrW() / 2, ScrH() / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if time < 0 then
		local size = ScreenScale(250)
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(interMat)
		surface.DrawTexturedRect(ScrW() / 2 - size / 2, ScrH() / 2 - size / 2, size, size)
	end
end )