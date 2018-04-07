AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Model			= "models/sunabouzu/jazzbigtv.mdl"

local outputs =
{
	"OnMapRolled"
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

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "AddonName")
	self:NetworkVar("Int", 0, "AddonWorkshopID")
end

function ENT:KeyValue( key, value )

	if table.HasValue(outputs, key) then
		self:StoreOutput(key, value)
	end
end

function ENT:RollAddon()
	local addon = mapcontrol.GetRandomAddon()
	workshop.FileInfo(addon, function(body, err)
		if err then print("Failed to get addon information: " .. err) end

		self:TriggerOutput("OnMapRolled", self)
		self:SetAddonName(body and body.title or addon)
		self:SetAddonWorkshopID(addon)
	end)
end

function ENT:AcceptInput( name, activator, caller, data )
	if name == "RollAddon" then 
		self:RollAddon() 
		return true 
	end

	return false
end


function ENT:Use(activator, caller)
	self:RollAddon()
end

if SERVER then return end

ENT.ScreenScale = 0.09

surface.CreateFont( "JazzTVChannel", {
	font      = "VCR OSD Mono",
	size      = 30,
	weight    = 500,
	//antialias = true,
	additive  = false,
	blursize  = 1,
	scanlines = 3
})


local overlayScanMat = Material("effects/map_monitor")

local sizeX = 512
local sizeY = 512
local rt = irt.New("jazz_thumbnail_screen", sizeX, sizeY)

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

			local title = self:GetAddonName()
			draw.SimpleTextOutlined( title, "JazzTVChannel", sizeX - 20, 100, Color(60,255,60), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, color_black )
		cam.End2D()
	
	end)
end

function ENT:Think()

	local wsid = self:GetAddonWorkshopID()
	if self.LastWorkshopID != wsid then
		self.LastWorkshopID = wsid
		self:RefreshThumbnail(wsid)
	end

	self:UpdateRenderTarget()
end

function ENT:RefreshThumbnail(wsid)
	steamworks.FileInfo( wsid, function( result ) 
		if !IsValid(self) or !result then return end

		workshop.FetchThumbnail(result, function(material)
			if !self then return end

			self.ThumbnailMat = material
		end )
	end )
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

		local title = self:GetAddonName()
		local x = 58 / self.ScreenScale
		local y = -27 / self.ScreenScale
		//draw.SimpleTextOutlined( title, "JazzTVChannel", x, y, Color(60,255,60), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, color_black )


	cam.End3D2D()
end
