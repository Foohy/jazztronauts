if SERVER then AddCSLuaFile("sh_gfx.lua") return end

module( "gfx", package.seeall )

local lasermat	=		Material("effects/laser1.vmt")
local wire		=		Material("models/wireframe.vmt")
local color	=		Material("color.vmt")
local arrow	=		Material("gui/arrow.vmt")

function renderBeam(start_pos, end_pos, col, colb, rad)
	render.SetMaterial( lasermat );
	render.StartBeam( 2 );
	render.AddBeam(
		start_pos,
		rad,
		CurTime(),
		col or Color( 255, 255, 255, 255 )		--Color
	);
	render.AddBeam(
		end_pos,
		rad,
		CurTime() + 1,
		colb or col or Color( 255, 255, 255, 255 )
	);
	render.EndBeam();
end

function renderBox(pos, min, max, bcolor)
	render.SetMaterial( color )
	render.DrawBox(pos, Angle(0,0,0), min, max, bcolor or Color(255,255,255,255))
end

function renderPlane(pos, normal, w, h, col, r)
	local u = normal:Angle()
	--render.DrawBox(pos, u, Vector(0,-w,-h), Vector(0.01,w,h), col or Color(0,0,255,100))

	render.SetMaterial( color )
	render.DrawQuadEasy(pos, normal, w, h, col or Color(0,0,255,10), r or 0)
end

function renderArrowOnPlane(pos, normal, dir, w, h)
	local u = normal:Angle() + Angle(0,0,180)
	u:RotateAroundAxis(normal, dir)

	pos = pos + u:Up() * h

	render.SetMaterial( arrow )
	render.DrawBox(pos, u, Vector(0,-w,-h), Vector(0.01,w,h), Color(255,0,0,100))
end

function renderAngle(pos, angle)
	local u = angle

	render.SetMaterial( color )
	render.DrawBox(pos, u, Vector(0,-0.2,-0.2), Vector(6,0.2,0.2), Color(0,0,255,255))
	render.DrawBox(pos, u, Vector(-0.2,-0.2,0), Vector(0.2,0.2,6), Color(255,0,0,255))
	render.DrawBox(pos, u, Vector(-0.2,0,-0.2), Vector(0.2,6,0.2), Color(0,255,0,255))
end

function renderAxis(pos, forward, right, up, scale)
	scale = scale or 1

	local min = Vector(0,-0.2,-0.2) * scale
	local max = Vector(6,0.2,0.2) * scale

	render.SetMaterial( color )
	render.DrawBox( pos, forward:Angle(), min, max, Color(255,0,0,255) )
	render.DrawBox( pos, right:Angle(), min, max, Color(0,255,0,255) )
	render.DrawBox( pos, up:Angle(), min, max, Color(0,0,255,255) )
end