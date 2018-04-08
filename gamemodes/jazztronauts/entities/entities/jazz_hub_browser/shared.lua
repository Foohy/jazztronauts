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
	self:NetworkVar("Int", 0, "AddonWorkshopID")
end

function ENT:KeyValue( key, value )

	if table.HasValue(outputs, key) then
		self:StoreOutput(key, value)
	end
end

function ENT:RollAddon()
	self:SetAddonWorkshopID(0)
	self:EmitSound("buttons/lever7.wav", 75, 200)

	local addon = mapcontrol.GetRandomAddon()
	workshop.FileInfo(addon, function(body, err)
		if err then print("Failed to get addon information: " .. err) end

		self:TriggerOutput("OnMapRolled", self)
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
ENT.NoiseSpeed = 2
ENT.WhiteNoiseSound = Sound("jazztronauts/tv_noise.wav")

ENT.ImageOffset = 0
ENT.TVNoiseAmount = 1
ENT.GoalNoise = 0

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
local noiseMat = Material("effects/map_monitor_noise")
local colormodMat = Material( "effects/map_monitor_colour" )

local sizeX = 512
local sizeY = 512
local rt = irt.New("jazz_thumbnail_screen", sizeX, sizeY)

local drawColorParams =
{
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_colour"] = 1,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local function DrawColorModifyRT(params, texture)
	colormodMat:SetTexture("$fbtexture", texture)
	for k, v in pairs(params) do
		colormodMat:SetFloat(k, v)
	end

	render.SetMaterial(colormodMat)
	render.DrawScreenQuad()
end

function ENT:UpdateRenderTarget()
	
	rt:Render(function()
		render.Clear(0, 0, 0, 255)

		cam.Start2D()

			if self.AddonThumb then
				overlayScanMat:SetTexture("$basetexture", self.AddonThumb:GetTexture("$basetexture"))
			end

			local noiseamt = self.TVNoiseAmount
			
			local offset = math.random() * 2 <= noiseamt and sizeY * 0.05 or 0
			self.ImageOffset = math.Approach(self.ImageOffset, offset, FrameTime() * 550)

			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(overlayScanMat)
			surface.DrawTexturedRect(0, self.ImageOffset, sizeX, sizeY)
			
			drawColorParams["$pp_colour_colour"] = math.max(0, 1 - noiseamt*8)
			drawColorParams["$pp_colour_contrast"] = noiseamt + 1
			DrawColorModifyRT(drawColorParams, rt:GetTarget())

			noiseMat:SetFloat("$alpha", noiseamt)
			surface.SetMaterial(noiseMat)
			surface.DrawTexturedRect(0, 0, sizeX, sizeY)

			draw.SimpleTextOutlined( self.AddonName, "JazzTVChannel", sizeX - 20, 100, Color(60,255,60), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, color_black )

			if self.ErrorChannel then
				draw.SimpleTextOutlined( "NO SIGNAL", "JazzTVChannel", sizeX/2, sizeY/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black )
			end
		cam.End2D()
	
	end)
end

function ENT:UpdateNoiseAudio()
	if not self.TVNoise then
		self.TVNoise = CreateSound(self, self.WhiteNoiseSound)
		self.TVNoise:Play()
	end

	if self.TVNoise then
		self.TVNoise:ChangeVolume(self.TVNoiseAmount)
	end
end

function ENT:Think()

	local wsid = self:GetAddonWorkshopID()
	if self.LastWorkshopID != wsid then
		self.LastWorkshopID = wsid
		self:ChangeChannel(wsid)
	end

	-- Fade between noise amounts
	local goal = self.GoalNoise + math.sin(CurTime() * 0.1) * 0.01 + 0.02
	self.TVNoiseAmount = math.Approach(self.TVNoiseAmount, goal, FrameTime() * self.NoiseSpeed)

	self:UpdateNoiseAudio()
	self:UpdateRenderTarget()
end

function ENT:ChangeChannel(wsid)
	self.GoalNoise = 1.0
	self.AddonName = ""
	if wsid == 0 then return end

	steamworks.FileInfo( wsid, function( result ) 
		if !IsValid(self) then return end
		self.ErrorChannel = result == nil
		if self.ErrorChannel then 
			print("Failed to get file info for wsid: " .. wsid)
			return 
		end

		workshop.FetchThumbnail(result, function(material)
			if !self then return end

			self.AddonThumb = material -- ThumbnailMat
			self.AddonName = result.title

			self.GoalNoise = 0.0
		end )
	end )
end

function ENT:Draw()
	render.MaterialOverrideByIndex(1, rt:GetUnlitMaterial())
	self:DrawModel()
	render.MaterialOverrideByIndex(1, nil)
end
