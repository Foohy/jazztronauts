
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

local RTWidth = 512
local RTHeight = 512
local VisibleHeight = 0.28

local LoadingMaterial = Material("ui/jazztronauts/testpattern")

local lastFactUpdate = 0

surface.CreateFont( "FactScreenFont", {
	font      = "VCR OSD Mono",
	size      = 35,
	weight    = 700,
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
local function renderFact(rt, f)
    local factLines = string.Split(f.fact, "\n")
    rt:Render( function()
        local mostr = "<font=FactScreenFont><center>" .. f.fact .. "</font></center>"
        local mo = markup.Parse(mostr, RTWidth * 0.9)

        cam.Start2D()

            surface.SetDrawColor(205, 20, 105)
            surface.DrawRect(0, 0, 512, 512)
            surface.SetTextColor(0, 0, 0)
            surface.SetFont("FactScreenFont")
            mo:Draw(RTWidth * 0.05, VisibleHeight * RTHeight, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

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
        cam.Start2D()
            surface.SetDrawColor(255, 1, 255)
            surface.DrawRect(0, 0, RTWidth, RTHeight)

            surface.SetMaterial(jazzSlideshowDHTML:GetHTMLMaterial())
            surface.DrawTexturedRect(0, RTHeight * 0.26, RTWidth * 1.07,  RTHeight * 0.93)

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
        f.fact = "Owner:\n" .. (name or f.fact)
        renderFact(rt, f)
    end )
end

-- Allow some fact names to override what it does when it would otherwise render
local factOverrides = {
    ws_screenshots = loadMapScreenshots,
    ws_owner = loadOwner
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
        local loadFunc = factOverrides[v.name] or renderFact
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

local SCAN_COMPLETE = 2
function ENT:ShouldShowTestPattern()
    return not self.CurrentFactMaterial 
        and self.GetSelector and IsValid(self:GetSelector()) 
        and self:GetSelector():GetScanState() == SCAN_COMPLETE
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
    return (self:GetFactID() % table.Count(factgen.GetFacts())) + 1
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
