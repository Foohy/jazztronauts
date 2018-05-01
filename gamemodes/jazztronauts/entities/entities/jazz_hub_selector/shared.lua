AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.AutomaticFrameAdvance = true 
ENT.Model			= "models/sunabouzu/jazzportal.mdl"

local SCAN_FAILED_NOMAP 	= -3
local SCAN_FAILED_NOSPACE 	= -2
local SCAN_FAILED_NETWORK 	= -1
local SCAN_IDLE		= 0
local SCAN_SCANNING = 1
local SCAN_COMPLETE = 2

local outputs =
{
	"OnMapSelected",
	"OnMapDownloaded",
	"OnMapAnalyzed"
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
	self:NetworkVar("Int", 0, "SelectedWorkshopID")
	self:NetworkVar("Int", 1, "ScanState")
end

function ENT:KeyValue( key, value )

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
	self:SelectAddon(nil)
	self:SetPortalSequence("Close")
	/*
	for _, v in pairs(ents.FindByClass("jazz_hub_browser")) do
		v:SetOn(true)
	end
	*/
end

function ENT:SelectAddon(wsid)

	mapcontrol.SetSelectedMap(nil) -- Tell the current bus to leave
	self:SetSelectedWorkshopID(wsid or 0)

	if not wsid or wsid == 0 then
		self:SetScanState(SCAN_IDLE)
		self.CurrentlyScanning = nil
		return 
	end

	self:SetScanState(SCAN_SCANNING)
	self:SetPortalSequence("Open")
	self:TriggerOutput("OnMapSelected", self)

	-- Attempt to mount the given addon (cache-aware)
	self.CurrentlyScanning = wsid
	mapcontrol.InstallAddon(wsid, function(files, msg)
		if self.CurrentlyScanning != wsid then return end
		self.CurrentlyScanning = nil

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
				mapcontrol.SetSelectedMap(table.Random(newMaps))
			else
				print("Addon id " .. wsid .. " contains no maps at all!!")
			end
			self:SetScanState(#newMaps > 0 and SCAN_COMPLETE or SCAN_FAILED_NOMAP)
		else
			self:SetScanState(SCAN_FAILED_NETWORK)
		end

		self:TriggerOutput("OnMapDownloaded", self, success and 1 or 0)
		self:SetPortalSequence("Settle")

		-- At this point we'd start analyzing the map (bsp magic)
		-- Not implemented, but yknow, let em dream
		if success then
			self:TriggerOutput("OnMapAnalyzed", self)
		end
	end)
end

function ENT:Use(activator, caller)

	timer.Simple(0, function() 
		if self:GetSelectedWorkshopID() != 0 then
			self:CancelAddon() 
		else
			ents.FindByClass("jazz_hub_browser")[1]:SelectCurrentAddon()
		end
	end)
	
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

			local scanstate = self:GetScanStateString()
			draw.SimpleTextOutlined( scanstate, "JazzTVChannel", sizeX/2, sizeY/2, Color(60,255,60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black )
		cam.End2D()
	
	end)
end

function ENT:Think()

	local wsid = self:GetSelectedWorkshopID()
	if self.LastWorkshopID != wsid then
		self.LastWorkshopID = wsid
		self:RefreshThumbnail(wsid)
	end

	local rGoal = (EyePos() - self:GetPos()):Angle()
	if not self.LastRot then self.LastRot = rGoal end
	local r = LerpAngle(FrameTime(), self.LastRot, rGoal)
	self.LastRot = r

	local m = Matrix()
	m:Scale(Vector(1, 1, 1))
	m:Rotate(Angle(0, r.y + 90, 0))
	self:EnableMatrix("RenderMultiply", m)

	self:UpdateRenderTarget()
end

function ENT:RefreshThumbnail(wsid)
	self.ThumbnailMat = nil
	self.AddonTitle = ""

	steamworks.FileInfo( wsid, function( result ) 
		if !IsValid(self) or !result then return end

		self.AddonTitle = result.title

		workshop.FetchThumbnail(result, function(material)
			if !self then return end

			self.ThumbnailMat = material
		end )
	end )
end

function ENT:GetScanStateString()
	local state = self:GetScanState()
	if state == SCAN_IDLE then return "IDLE"
	elseif state == SCAN_SCANNING then return "SCANNING"
	elseif state == SCAN_COMPLETE then return "SCAN COMPLETE"
	elseif state == SCAN_FAILED_NOMAP then return "SCAN FAILURE - NO MAP"
	elseif state == SCAN_FAILED_NETWORK then return "SCAN FAILURE - FAILED TO DOWNLOAD"
	elseif state == SCAN_FAILED_NOSPACE then return "SCAN FAILURE - DISK FULL"
	end
	
	return "SCAN FAILURE"
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
