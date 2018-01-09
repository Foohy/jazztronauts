print("TCL")

local horse = CreateMaterial( "horse2", "UnlitGeneric",
{
	["$basetexture"] = "ui/transition_horse",
	["$vertexcolor"] = true,
})

local starttime = CurTime()
local transitioning = 0
local rate = .75

function transitionOut(delay)
	if delay ~= nil then
		timer.Simple( delay, function() surface.PlaySound( "jazztronauts/slide.wav" ) end )
	else
		surface.PlaySound( "jazztronauts/slide.wav" )
	end
	transitioning = -1
	starttime = CurTime() + (delay or 0)
end

function transitionIn(delay)
	if delay ~= nil then
		timer.Simple( delay, function() surface.PlaySound( "jazztronauts/slide_reverse.wav" ) end )
	else
		surface.PlaySound( "jazztronauts/slide_reverse.wav" )
	end
	transitioning = 1
	starttime = CurTime() + (delay or 0)
end

--[[timer.Simple(1,function()
	transitionOut()
end)
timer.Simple(3,function()
	transitionIn()
end)]]

--if not mapcontrol.IsInHub() then
	transitionIn(1)
--end

hook.Add("PostRenderVGUI", "transitions", function()

	local amount = ( CurTime() - starttime ) * rate

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

end)