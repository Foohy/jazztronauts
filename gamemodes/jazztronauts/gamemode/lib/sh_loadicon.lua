AddCSLuaFile()
if SERVER then return end

module( 'loadicon', package.seeall )

LoadIcon = LoadIcon or Material("ui/jazztronauts/catload")
LoadStates = LoadStates or {}



function SetLoadIcon(iconTex)
	LoadIcon = iconTex
end

-- When you start loading something
function PushLoadState(str)
	LoadStates[#LoadStates + 1] = str
end

function SetLoadState(str)
	LoadStates[#LoadStates] = str
end

-- When you finish loading something
function PopLoadState()
	LoadStates[#LoadStates] = nil
end

-- Get's the text of the currently loading task
function GetCurrentTask()
	if #LoadStates > 0 then return LoadStates[#LoadStates] end

	return ""
end

local IconSize = ScreenScale(16)
local IconMargin = ScreenScale(8)
local TextMargin = ScreenScale(8)

surface.CreateFont("JazzLoadStateFont", {
	font		= "VCR OSD Mono",
	size		= ScreenScale(6),
	weight		= 500,
	antialias	= false
})

local CurAlpha = 0
local lastText = ""
function Paint()
	local GoalAlpha = #LoadStates > 0 and 1.0 or 0.0

	CurAlpha = math.Approach(CurAlpha, GoalAlpha, FrameTime())

	if CurAlpha <= 0 then return end
	local drawColor = Color(255, 255, 255, CurAlpha * 255)
	surface.SetDrawColor(drawColor)

	-- Loading Icon
	surface.SetMaterial(LoadIcon)
	//surface.DrawTexturedRect(ScrW() - IconSize - IconMargin, ScrH() - IconSize - IconMargin, IconSize, IconSize)
	surface.DrawTexturedRectRotated(ScrW() - IconSize/2 - IconMargin, ScrH() - IconSize / 2 - IconMargin, IconSize, IconSize, CurTime() * 180)

	-- Current task
	local tx = ScrW() - IconSize - IconMargin - TextMargin
	local ty = ScrH() - IconSize / 2 - IconMargin
	local curTask = GetCurrentTask()
	if #curTask == 0 then
		curTask = lastText
	else
		lastText = curTask
	end

	draw.SimpleText(curTask, "JazzLoadStateFont", tx, ty, drawColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	surface.SetDrawColor(255, 255, 255)
end