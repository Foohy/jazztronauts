
-- Board that displays currently selected map's factoids
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Model =  "models/sunabouzu/jazz_tv01.mdl"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "FactID")
	self:NetworkVar("Float", 0, "ToggleDelay")
	self:NetworkVar("Entity", 0, "Selector")
end

if SERVER then
	function ENT:Initialize()

		self:SetModel(self.Model)
		--self:PhysicsInit(SOLID_VPHYSICS)
		--self:SetMoveType(MOVETYPE_NONE)
		self:SetSelector(ents.FindByClass("jazz_hub_selector")[1])

		local id = math.random(1, 1000)
		if self.FactName then
			id = factgen.GetFactIDByName(self.FactName, true)
		else
			id = self:EntIndex()
		end

		self:SetFactID(id)
	end

	function ENT:KeyValue(key, value)
		if key == "model" then
			self.Model = value
		end

		if key == "factname" then
			self.FactName = value
		end
	end

	local function UpdateToggleDelay()
		local screens = ents.FindByClass("jazz_factscreen")
		table.sort(screens, function(a, b)
			local apos, bpos = a:GetPos(), b:GetPos()
			return apos.x < bpos.x
		end )

		for k, v in ipairs(screens) do
			v:SetToggleDelay(k * 0.05)
		end
	end

	-- Setup toggle delay on all fact screens
	hook.Add("InitPostEntity", "InitFactscreenDelays", UpdateToggleDelay)
	hook.Add("OnReloaded", "InitFactscreenDelaysReload", UpdateToggleDelay)
	UpdateToggleDelay()
end

if SERVER then return end

include("jazz_localize.lua")

local function randomlocalization(strang)
	
	if strang == nil then return nil end
	
	--TODO (maybe): all screens use the same instance of their fail text, this commented out code would want them all called individually

	--[[if string.find(strang,"jazz.levelselect.fail",1,true) == nil then return strang end --we're not randomizing any other strings
	strang = tostring(strang)
	local localizationtable = {
		".en",
		".es",
		".fr",
		".jp",
		".uk",
	}
	local localizationstrs = setmetatable(localizationtable, {__index = function() return "" end} )

	return JazzLocalize(strang..localizationstrs[math.random(#localizationstrs+3)]) -- 3 (or more if it's present) times more likely to display our language, with others mixed in for flavor]]
	
	return JazzLocalize(strang)
end

local RTWidth = 512
local RTHeight = 512
local VisibleHeight = 0.5

local LoadingMaterial = Material("ui/jazztronauts/testpattern")

local lastFactUpdate = 0

surface.CreateFont( "FactScreenFont", {
	font	  = "VCR OSD Mono",
	size	  = 35,
	weight	= 700,
	antialias = true
})
surface.CreateFont( "FactScreenTitle", {
	font	  = "VCR OSD Mono",
	size	  = 55,
	weight	= 700,
	antialias = true
})
surface.CreateFont( "FactScreenError", {
	font	  = "VCR OSD Mono",
	size	  = 25,
	weight	= 700,
	antialias = true
})

-- Render a test pattern that actually fits on these monitors
local TestSize = 64
local loadRT = irt.New("jazzfact_testpattern", TestSize, TestSize)
	:EnablePointSample(true)
loadRT:Render( function()
	cam.Start2D()
		surface.SetMaterial(LoadingMaterial)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawTexturedRect(0, TestSize * 0.2, TestSize, TestSize * 0.6)
	cam.End2D()
end )
local loadMaterial = loadRT:GetUnlitMaterial()

-- Render a specific fact
local factMaterials = {}
local isOn = false
local function renderFact(rt, f, title, bgcolor, font)

	rt:Render( function()
		local mostr = "<font=" .. (font or "FactScreenFont") ..">" .. randomlocalization(f.fact) .. "</font>"
		local mo = markup.Parse(mostr, RTWidth * 0.98)

		cam.Start2D()

			surface.SetDrawColor(bgcolor or Color(205, 20, 105))
			surface.DrawRect(0, 0, 512, 512)
			surface.SetTextColor(0, 0, 0)
			surface.SetFont("FactScreenFont")
			draw.SimpleText(randomlocalization(title) or "", "FactScreenTitle", RTWidth/2, RTHeight * 0.28, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			mo:Draw(RTWidth/2 - mo:GetWidth()/2, VisibleHeight * RTHeight - mo:GetHeight()/2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		cam.End2D()
	end )
end

local function setDHTMLPic(dhtml, pic)
	local str =[[
		<head>
		<style>
			body
			{
				background-image: url("%s");
				background-color: #000000;
				background-size: contain;
				background-repeat: no-repeat;
				background-position: center center;
			}
		</style>
		</head>
		<body></body>
	]]

	dhtml:SetHTML(string.format(str, pic))
end

-- Specific rendering for a slideshow of pictures
local slideshowRT = nil
local slideshowPics = {}
jazzSlideshowDHTML = jazzSlideshowDHTML or nil --#TODO MAKE LOCAL YOU FUCK
local lastPic = nil
local function renderSlideshow()
	if not isOn or not slideshowRT or not jazzSlideshowDHTML then return end

	local pic = slideshowPics[(math.Round(CurTime()) % #slideshowPics) + 1]
	if lastPic != pic then
		lastPic = pic
		setDHTMLPic(jazzSlideshowDHTML, pic)
	end
	jazzSlideshowDHTML:UpdateHTMLTexture()
	slideshowRT:Render(function()
		local slideMat = jazzSlideshowDHTML:GetHTMLMaterial()
		if not slideMat then return end

		cam.Start2D()
			surface.SetDrawColor(255, 1, 255)
			surface.DrawRect(0, 0, RTWidth, RTHeight)

			surface.SetMaterial(slideMat)
			surface.DrawTexturedRectUV(0, RTHeight * 0.25, RTWidth,  RTHeight * 0.75,0,0,1,1.525)

		cam.End2D()
	end)
end

hook.Add("Think", "UpdateJazzSlideshow", renderSlideshow)

local function loadMapScreenshots(rt, f)
	slideshowRT = rt
	slideshowPics = string.Split(f.fact, "|")
	jazzSlideshowDHTML = jazzSlideshowDHTML or vgui.Create("DHTML")
	jazzSlideshowDHTML:SetSize(512, 512)
	jazzSlideshowDHTML:SetAlpha(0)
end

local function loadOwner(rt, f)
	steamworks.RequestPlayerInfo(f.fact, function(name)
		f.fact = name or f.fact
		renderFact(rt, f, "Owner")
	end )
end

-- Allow some fact names to override what it does when it would otherwise render
local factOverrides = {
	ws_screenshots = loadMapScreenshots,
	ws_owner = loadOwner,
	comment = function(rt, f) renderFact(rt, f) end,
	failure = function(rt, f) renderFact(rt, f, nil, Color(136, 12, 12), "FactScreenError") end
}

local function updateFactMaterials()
	local facts = factgen.GetFacts()
	isOn = false
	for k, v in pairs(facts) do
		local factMat = factMaterials[k] or irt.New("jazz_factscreen_" .. k, RTWidth, RTHeight)
		factMaterials[k] = factMat

		-- Only re-render if there's a new fact, not for clearing
		if #v.fact == 0 then continue end

		-- Allow certain facts to do fancy things
		local loadFunc = factOverrides[v.name] or function(rt, f)
			local title = string.Split(string.Split(f.fact, "\n")[1], ":")[1]
			f.fact = string.sub(f.fact, (title and #title + 3 or 0))
			renderFact(rt, f, title)
		end
		loadFunc(factMat, v)

		isOn = true
	end
end

-- Whenever the facts update, trigger a re-render of fact materials
-- Additionally activates the screen sweep animation
timer.Simple(0, function()
	factgen.Hook("updateBrowserFactScreens", function()
		lastFactUpdate = CurTime()
		updateFactMaterials()
	end )
end)

function ENT:Initialize()

end

function ENT:ShouldShowTestPattern()
	return not self.CurrentFactMaterial
end

function ENT:Think()
	if not self.LastUpdate or self.LastUpdate < lastFactUpdate then
		local actualUpdateTime = lastFactUpdate + self:GetToggleDelay()
		if CurTime() > actualUpdateTime then
			self.LastUpdate = lastFactUpdate

			self:UpdateFactMaterial()
		end
	end
end

function ENT:GetRealFactID()
	local active = factgen.GetActiveFactIDs()
	if active[self:GetFactID()] then
		return self:GetFactID()
	end

	for i=1, table.Count(active) do
		local k = 1 + (self:GetFactID() + i) % #active
		if active[k] then return k end
	end

	return 0
end

function ENT:UpdateFactMaterial()
	self.CurrentFactMaterial = isOn and factMaterials[self:GetRealFactID()]
	self:EmitSound("ui/buttonclick.wav", 75, 200, 1)
end

function ENT:Draw()
	local curMat = self.CurrentFactMaterial and self.CurrentFactMaterial:GetUnlitMaterial() or nil
	if self:ShouldShowTestPattern() then
		curMat = loadMaterial
	end
	render.MaterialOverrideByIndex(1, curMat)
	self:DrawModel()
	render.MaterialOverrideByIndex(1, nil)
end
