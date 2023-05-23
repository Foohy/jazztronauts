AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Model			= "models/sunabouzu/jazzbigtv.mdl"

ENT.OnSound = Sound("jazztronauts/tv_on.wav")
ENT.OffSound = Sound("buttons/lightswitch2.wav")
ENT.History = {}

local historyslots = 5 --the number of previously rolled addons we'll remember/be able to access

local outputs =
{
	"OnMapRolled",
	"OnAddonSelected"
}

if SERVER then
	
	concommand.Add("jazz_debug_browse", function(ply, cmd, args)
		for _, v in pairs(ents.FindByClass("jazz_hub_browser")) do
			v:BrowseToDestination(args[1])
		end
	end, nil, nil, { FCVAR_CHEAT }  )

end

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

		-- Turn on the tv
		self:SetOn(true)

		-- Set current map to whatever the last one we visited was
		-- Delay because ISteamHTTP may not be initialized yet 
		timer.Simple(1, function()
			local m = progress.GetLastMapSession()
			if m then
				local wsid = workshop.FindOwningAddon(m.filename)
				if wsid then
					self:BrowseToDestination(wsid)
				--TODO: add and else here and handle local addons/maps
				end
			end
		end )
	end

end

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "DestinationID")
	self:NetworkVar("Bool", 0, "IsOn")
end

function ENT:KeyValue( key, value )

	if table.HasValue(outputs, key) then
		self:StoreOutput(key, value)
	end
end

function ENT:RollWorkshop()
	if not self:GetIsOn() then return end

	local addon = mapcontrol.GetRandomAddon() or ""
	self:BrowseToDestination(addon)
end

function ENT:BrowseToDestination(dest)
	self:SetDestinationID("")
	self:EmitSound("buttons/lever7.wav", 75, 200)
	print(dest)


	--put the currently selected map in our history, if it isn't already (history is current map + last historyslots)
	if (dest ~= "" and not tonumber(dest)) or (tonumber(dest) and tonumber(dest) > 0) then
		local inlist = false
		for _, v in ipairs(self.History) do
			if string.lower(tostring(v)) == string.lower(tostring(dest)) then
				inlist = true
				break
			end
		end
		if not inlist then
			table.insert(self.History,1,tostring(dest))
			while #self.History > historyslots + 1 do table.remove(self.History) end
		end

		--("History:")
		--PrintTable(self.History)
	end


	local function setBrowsedTo(dest)
		self:TriggerOutput("OnMapRolled", self)
		self:SetDestinationID(dest or "-1")
	end

	if mapcontrol.IsWorkshopAddon(dest) then
		workshop.FileInfo(dest, function(body, err)
			if err then print("Failed to get addon information: " .. err) end

			setBrowsedTo(dest)
		end)
	else
		dest = file.Exists("maps/" .. dest .. ".bsp", "GAME") and dest or ""
		setBrowsedTo(dest)
	end
end

function ENT:SelectCurrentAddon()
	--if not self:GetIsOn() or #self:GetDestinationID() == 0 then return end

	self:TriggerOutput("OnAddonSelected", self)

	local sel = ents.FindByClass("jazz_hub_selector")
	for _, v in pairs(sel) do
		v:SelectDestination(self:GetDestinationID())
	end

	if #sel > 0 then
		self:SetOn(false)
	end
end

function ENT:AcceptInput( name, activator, caller, data )
	if name == "RollAddon" then
		self:RollWorkshop()
		return true
	elseif name == "SelectCurrentAddon" then
		self:SelectCurrentAddon()
		return true
	elseif string.find(name,"SwitchToHistory%d") then
		if not self:GetIsOn() then return false end
		--[[ Note: our first slot in History is whatever is currently selected, so always add 1 from here
		(i.e. if we're looking to SwitchToHistory1, that'll be at History[2], etc.) ]]

		local historynum = tonumber(string.match(name,"%d"))

		--make sure the number provided is both within our range, and our table is currently that big
		if historynum and historynum >= 1 and historynum <= historyslots and historynum + 1 <= #self.History then
			local pick = tostring(self.History[historynum + 1])
			--remove this from our history (it'll be re-added to the top of the list when we browse to it)
			table.remove(self.History,historynum + 1)

			self:BrowseToDestination(pick)
			return true
		end
	elseif name== "HistoryUp" then
		if not self:GetIsOn() then return false end
		local move = tostring(self.History[1])
		table.insert(self.History,move)
		table.remove(self.History,1)
		self:BrowseToDestination(self.History[1])
		--print("UP ^")
		return true
	elseif name== "HistoryDown" then
		if not self:GetIsOn() then return false end
		local move = tostring(self.History[#self.History])
		table.insert(self.History,1,move)
		table.remove(self.History,#self.History)
		self:BrowseToDestination(self.History[1])
		--print("DOWN v")
		return true
	elseif name == "TurnOn" then
		self:SetOn(true)
	elseif name == "TurnOff" then
		self:SetOn(false)
	end

	return false
end

function ENT:SetOn(isOn)
	local snd = isOn and self.OnSound or self.OffSound
	self:EmitSound(snd)
	self:SetIsOn(isOn)
end

function ENT:Use(activator, caller)

	self:RollWorkshop()
end

if SERVER then return end

ENT.ScreenScale = 0.09
ENT.NoiseSpeed = 3
ENT.WhiteNoiseSound = Sound("jazztronauts/tv_noise.wav")
ENT.HumSound = Sound("jazztronauts/tv_hum.wav")

ENT.ImageOffset = 0
ENT.TVNoiseAmount = 1
ENT.GoalNoise = 0
ENT.OnAmount = 0

surface.CreateFont( "JazzTVChannel", {
	font	  = "VCR OSD Mono",
	size	  = 30,
	weight	= 500,
	antialias = false,
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
local rt_pass = irt.New("jazz_thumbnail_screen_passthrough", sizeX, sizeY)

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

function ENT:DrawScreenContents(rt)
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
			drawColorParams["$pp_colour_brightness"] = (1 - self.OnAmount)
			DrawColorModifyRT(drawColorParams, rt:GetTarget())

			noiseMat:SetFloat("$alpha", noiseamt)
			surface.SetMaterial(noiseMat)
			surface.DrawTexturedRect(0, 0, sizeX, sizeY)

			draw.SimpleTextOutlined( self.AddonName, "JazzTVChannel", sizeX - 20, 100, Color(60,255,60), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, color_black )

			if self.ErrorChannel then
				draw.SimpleTextOutlined( "NO SIGNAL", "JazzTVChannel", sizeX/2, sizeY/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black )
			end
		cam.End2D()
end

function ENT:UpdateRenderTarget()
	//self.OnAmount = math.Clamp(math.sin(CurTime() * 0.5) * 2, 0, 1)
	local isTurningOff = self.OnAmount < 1

	if isTurningOff then
		rt:Render(function()
			self:DrawScreenContents(rt)
		end)
	end

	rt_pass:Render(function()
		if isTurningOff then
			cam.Start2D()
				render.Clear(0, 0, 0, 0)
				surface.SetMaterial(rt:GetUnlitMaterial(true))
				local hx, hy = sizeX/2, sizeY/2
				local vsquish = math.Clamp(math.Remap(self.OnAmount, 1, 0, 1, -0.2), 0.01, 1)
				local hsquish = math.Clamp(math.Remap(self.OnAmount, 1, 0, 2.5, 0), 0.00, 1)
				surface.DrawTexturedRect(hx - hsquish * hx, hy - vsquish * hy, hx * hsquish* 2, hy * vsquish* 2)
			cam.End2D()
		else
			self:DrawScreenContents(rt_pass)
		end
	end)
end

function ENT:UpdateNoiseAudio()
	if not self.TVNoise then
		self.TVNoise = CreateSound(self, self.WhiteNoiseSound)
		self.TVNoise:Play()
	end

	if self.TVNoise then
		self.TVNoise:ChangeVolume(self.TVNoiseAmount * self.OnAmount)
	end

	if not self.TVHum then
		self.TVHum = CreateSound(self, self.HumSound)
		self.TVHum:SetSoundLevel(65)
		self.TVHum:Play()
	end

	if self.TVHum then
		self.TVHum:ChangeVolume(self.OnAmount)
	end
end

function ENT:Think()

	local dest = self:GetDestinationID()
	if self.LastDestinationID != dest then
		self.LastDestinationID = dest
		self:ChangeChannel(dest)
	end


	-- Fade 'on' amount
	local goalOn = self.GetIsOn and self:GetIsOn() and 1.0 or 0.0
	self.OnAmount = math.Approach(self.OnAmount, goalOn, FrameTime() * 3)

	-- Fade between noise amounts
	local goal = self.GoalNoise + math.sin(CurTime() * 0.1) * 0.01 + 0.02
	self.TVNoiseAmount = math.Approach(self.TVNoiseAmount, goal, FrameTime() * self.NoiseSpeed)


	self:UpdateNoiseAudio()
	self:UpdateRenderTarget()
end

function ENT:ChangeChannel(dest)
	self.GoalNoise = 1.0
	self.AddonName = ""
	if #dest == 0 then return end

	local wsid = tonumber(dest)
	if wsid then
		steamworks.FileInfo( wsid, function( result )

			if !IsValid(self) then return end
			self.ErrorChannel = result == nil
			if self.ErrorChannel then
				print("Failed to get file info for wsid: " .. wsid)
				return
			end

			self.AddonName = result.title
			workshop.FetchThumbnail(result, function(material)
				if !self then return end

				self.ErrorChannel = material == nil
				self.AddonThumb = material
				self.GoalNoise = self.ErrorChannel and 1 or 0
			end )
		end )
	else
		self.ErrorChannel = true
		self.AddonName = dest
	end
end

function ENT:Draw()
	render.MaterialOverrideByIndex(1, rt_pass:GetUnlitMaterial())
	self:DrawModel()
	render.MaterialOverrideByIndex(1, nil)
end
