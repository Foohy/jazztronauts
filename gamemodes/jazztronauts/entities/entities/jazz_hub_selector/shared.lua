AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Model			= "models/sunabouzu/jazz_tv02.mdl"

local SCAN_IDLE		= 0
local SCAN_SCANNING = 1
local SCAN_COMPLETE = 2
local SCAN_FAILED 	= 3

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

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "SelectedWorkshopID")
	self:NetworkVar("Int", 1, "ScanState")
end

function ENT:SelectAddon(wsid)
	self:SetScanState(SCAN_SCANNING)
	self:SetSelectedWorkshopID(wsid)
	mapcontrol.SetSelectedMap(nil)
	workshop.DownloadAndMountGMA(wsid, function(files)
		self:SetScanState(files and SCAN_COMPLETE or SCAN_FAILED)
		
		local newMaps = {}
		if files then
			for _, v in pairs(files) do
				if not string.match(v, "maps/.*.bsp") then continue end
				local filename = string.GetFileFromFilename(string.StripExtension(v))

				progress.StoreMap(filename, wsid)
				table.insert(newMaps, filename)
			end

			if #newMaps > 0 then
				mapcontrol.SetSelectedMap(table.Random(newMaps))
			else
				print("Addon id " .. wsid .. " contains no maps at all!!")
			end
		end

		self:SetScanState(#newMaps > 0 and SCAN_COMPLETE or SCAN_FAILED)

		//progress.StoreMap()
	end)
end

function ENT:Use(activator, caller)
	-- TODO: Not here
	local browser = ents.FindByClass("jazz_hub_browser")[1]
	if not IsValid(browser) then
		print("No active browser found!!!")
		return
	end

	self:SelectAddon(browser:GetAddonWorkshopID())
end

if SERVER then return end

ENT.ScreenScale = 0.09

local overlayScanMat = Material("effects/map_monitor")

local sizeX = 512
local sizeY = 512
local rt = irt.New("jazz_thumbnail_selector_screen", sizeX, sizeY)

function ENT:UpdateRenderTarget()
	
	rt:Render(function()
		render.Clear(0, 0, 0, 255)

		cam.Start2D()

			if self.ThumbnailMat then
				overlayScanMat:SetTexture("$basetexture", self.ThumbnailMat:GetTexture("$basetexture"))
			end

			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(overlayScanMat)
			surface.DrawTexturedRect(0, 0, sizeX, sizeY)

			surface.SetDrawColor(255, 255, 255)
			surface.SetTextPos(128, 128)
			surface.DrawText("Tiddy")

			//local title = self:GetAddonName()
			//draw.SimpleTextOutlined( title, "JazzTVChannel", 128, 128, Color(60,255,60), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, color_black )
		cam.End2D()
	
	end)
end

function ENT:Think()

	local wsid = self:GetSelectedWorkshopID()
	if self.LastWorkshopID != wsid then
		self.LastWorkshopID = wsid
		self:RefreshThumbnail(wsid)
	end

	self:UpdateRenderTarget()
end

function ENT:RefreshThumbnail(wsid)
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
	end
	
	return "SCAN FAILURE"
end

function ENT:Draw()
	render.MaterialOverrideByIndex(1, rt:GetUnlitMaterial())
	self:DrawModel()
	render.MaterialOverrideByIndex(1, nil)

	local ang = self.Entity:GetAngles()
	local pos = self.Entity:GetPos()
	
	ang:RotateAroundAxis( ang:Up(), 90 )
	ang:RotateAroundAxis( ang:Forward(), 90 )

	//Push outward just a tad
	pos = pos - ang:Up() * -1

	cam.Start3D2D(pos, ang, self.ScreenScale)
		if false and self.ThumbnailMat then
			surface.SetMaterial(self.ThumbnailMat)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(-256, -70, 456, 456)
		end

		local title = self.AddonTitle or ""
		local x = 58 / self.ScreenScale
		local y = -27 / self.ScreenScale
		draw.SimpleTextOutlined( title, "JazzTVChannel", x, y, Color(60,255,60), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, color_black )

		local scanstate = self:GetScanStateString()
		draw.SimpleTextOutlined( scanstate, "JazzTVChannel", 0, 0, Color(60,255,60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black )



	cam.End3D2D()
end
