print("TCL")

local horse = CreateMaterial( "horse2", "UnlitGeneric",
{
	["$basetexture"] = "ui/transition_horse",
	["$vertexcolor"] = true,
})

local starttime = CurTime()
local transitioning = 0
local rate = .75
local shoulddrawlate = true

function transitionOut(delay, nosound, drawearly)
	if not nosound then
		if delay ~= nil then
			timer.Simple( delay, function() surface.PlaySound( "jazztronauts/slide.wav" ) end )
		else
			surface.PlaySound( "jazztronauts/slide.wav" )
		end
	end

	transitioning = -1
	starttime = CurTime() + (delay or 0)
	shoulddrawlate = not drawearly
end

function transitionIn(delay, nosound, drawearly)
	if not nosound then
		if delay ~= nil then
			timer.Simple( delay, function() surface.PlaySound( "jazztronauts/slide_reverse.wav" ) end )
		else
			surface.PlaySound( "jazztronauts/slide_reverse.wav" )
		end
	end

	transitioning = 1
	starttime = CurTime() + (delay or 0)
	shoulddrawlate = not drawearly
end

local function getTransitionAmount()
	return ( CurTime() - starttime ) * rate
end

function isTransitioning()
	local amount = getTransitionAmount()
	return transitioning != 0 and (amount >= 0 and amount <= 1)
end

concommand.Add("txin", function() transitionIn() end )
concommand.Add("txout", function() transitionOut() end )

--[[timer.Simple(1,function()
	transitionOut()
end)
timer.Simple(3,function()
	transitionIn()
end)]]

local convar_drawtransition = CreateClientConVar("jazz_transition", "1", true, false, "Roll that beautiful bean footage.")

if convar_drawtransition:GetBool() then
	if mapcontrol.IsInHub() then
		transitionIn(2)
	end
end

local function drawTransition()

	local amount = getTransitionAmount()

	if transitioning == 0 then
		return
	end

	if transitioning == -1 then
		amount = 1 - amount

		if amount < 0 then
			surface.SetDrawColor(0,0,0,255)
			surface.DrawRect( 0, 0, ScrW(), ScrH() )
			return
		end
	end

	if transitioning == 1 then
		if amount > 1 then
			return
		end
	end

	amount = math.max(amount, 0)
	amount = amount * amount

	local display = Rect("screen")
	local transitionrect = Rect(0,0,0,0)
	transitionrect:Dock( display, DOCK_CENTER )
	transitionrect:Inset(-amount * 4096)

	transitionrect.x = math.floor(transitionrect.x)
	transitionrect.y = math.floor(transitionrect.y)
	transitionrect.w = math.floor(transitionrect.w)
	transitionrect.h = math.floor(transitionrect.h)

	local box = Box( transitionrect )

	render.OverrideBlendFunc( true, BLEND_ZERO, BLEND_SRC_COLOR )

	surface.SetMaterial( horse )
	surface.SetDrawColor(0,0,0,255)
	surface.DrawTexturedRect(transitionrect:Unpack())

	surface.DrawRect( 0, 0, box.x0, ScrH() )
	surface.DrawRect( box.x0, 0, ScrW() - box.x0, box.y0 )
	surface.DrawRect( box.x1, box.y0, ScrW() - box.x1, ScrH() - box.y0 )
	surface.DrawRect( box.x0, box.y1, box.x1 - box.x0, ScrH() - box.y1 )

	render.OverrideBlendFunc( false )
end

hook.Add("PostRenderVGUI", "jazzCatTransitionLate", function()
	if not shoulddrawlate then return end

	drawTransition()
end)

hook.Add("PreDrawHUD", "jazzCatTransition", function()
	if shoulddrawlate then return end

	cam.Start2D()
	drawTransition()
	cam.End2D()
end )