AddCSLuaFile()

if SERVER then return end

module("drugs", package.seeall )

local bDrugsOn = false

local drugs_front_buffer = CreateMaterial("DrugsFrontBuffer", "UnLitGeneric", {
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$additive"] = 0,
})

local drugs_back_buffer = CreateMaterial("DrugsBackBuffer", "UnLitGeneric", {
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$additive"] = 0,
})

local warp_material0 = CreateMaterial("WarpMaterial0_norm", "UnLitGeneric", {
	["$basetexture"] = "sunabouzu/jazzswirl01",
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$additive"] = 0,
})

local warp_material0_add = CreateMaterial("WarpMaterial0_add", "UnLitGeneric", {
	["$basetexture"] = "sunabouzu/jazzswirl01",
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$additive"] = 1,
})

local warp_material1 = CreateMaterial("WarpMaterial1", "UnLitGeneric", {
	["$basetexture"] = "sunabouzu/jazzswirl02",
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$additive"] = 1,
})

local warp_material2 = CreateMaterial("WarpMaterial2", "UnLitGeneric", {
	["$basetexture"] = "sunabouzu/jazzswirl03",
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$additive"] = 1,
})

local additive_color = CreateMaterial("AdditiveColor", "UnLitGeneric", {
	["$basetexture"] = "color/white",
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$additive"] = 1,
})

local sprite_material = CreateMaterial("SpriteMaterial", "UnLitGeneric", {
	["$basetexture"] = "sprites/light_glow01",
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$additive"] = 1,
})

hook.Add("PostDrawTranslucentRenderables", "drugs", function( bdepth, bsky )

	if not bDrugsOn then return end

	-- Draw the drug front buffer on the screen
	-- Doing it here allows the hud to render correctly over top
	render.SetMaterial(drugs_front_buffer)
	render.DrawScreenQuad()

end)

-- Function forwards
local render_setmaterial = render.SetMaterial
local render_quadeasy = render.DrawQuadEasy
local render_startbeam = render.StartBeam
local render_addbeam = render.AddBeam
local render_endbeam = render.EndBeam
local math_rad = math.rad
local math_pi = math.pi
local math_cos = math.cos
local math_sin = math.sin
local math_fmod = math.fmod
local mesh_begin = mesh.Begin
local mesh_end = mesh.End
local mesh_pos = mesh.Position
local mesh_color = mesh.Color
local mesh_texcoord = mesh.TexCoord
local mesh_advance = mesh.AdvanceVertex

local vec = Vector()
local ang = Angle()
local col = Color(255,255,255)
local vec_setunpacked = vec.SetUnpacked
local vec_unpack = vec.Unpack
local vec_rotate = vec.Rotate
local vec_add = vec.Add
local vec_mul = vec.Mul
local ang_setunpacked = ang.SetUnpacked
local col_setunpacked = col.SetUnpacked

-- Caching
local vec_facing = Vector(-1,0,0)
local vec_zero = Vector(0,0,0)
local ang_zero = Angle(0,0,0)

-- Transients
local function qa(p,y,r) ang_setunpacked(ang,p,y,r) return ang end
local function qv(x,y,z) vec_setunpacked(vec,x,y,z) return vec end
local function qc(r,g,b,a) col_setunpacked(col,r,g,b,a) return col end

-- Draw a cylinder with UV texture scrolling
local function drawCylinder(time, speed, alpha)

	local temp = nil
	local angle = 0
	local sides = 30
	local radius = 30
	local increment = (2 * math_pi / sides) * 1.0001
	local cos = math_cos(increment)
	local sin = math_sin(increment)
	local x = math_cos(angle) * radius
	local y = math_sin(angle) * radius
	local u = 0
	local vs = math_fmod(time * speed, 2)
	local iu = 1/sides

	mesh_begin(MATERIAL_TRIANGLE_STRIP, (sides+1) * 2)

	for i=0, sides do
		mesh_pos( qv(800,x*0.1,y*0.1) )
		mesh_color(255,255,255,alpha)
		mesh_texcoord(0, u+vs*0.5, 1-vs)
		mesh_advance()

		mesh_pos( qv(0,x,y) )
		mesh_color(255,255,255,alpha)
		mesh_texcoord(0, u+vs*0.5 + 0.5, 1-vs+1)
		mesh_advance()

		temp = x * cos - y * sin
		y = x * sin + y * cos
		x = temp
		u = u + iu
	end

	mesh_end()

end

local fx_trails = {}
local fx_trail_colors = {}
local fx_trail_len = 200

for i=1, 6 do
	fx_trails[i] = {}
	fx_trail_colors[i] = {}

	for j=1, fx_trail_len do
		fx_trails[i][j] = Vector()
		fx_trail_colors[i][j] = Color(0,0,0,0)
	end
end

local rt_back_buffer = nil
local rt_front_buffer = nil
local rt_initialized = false

hook.Add("HUDPaint", "drugs", function()

	if not bDrugsOn then return end
	if not rt_initialized then

		-- Setup rendertargets
		rt_initialized = true
		rt_front_buffer = irt.New("drugbuffer", w, h)
			:EnableDepth(true,true)
			:EnableFullscreen(true)
			:EnablePointSample(false)
			:SetAlphaBits(8)

		rt_back_buffer = irt.New("drugbackbuffer", w, h)
			:EnableDepth(true,true)
			:EnableFullscreen(true)
			:EnablePointSample(false)
			:SetAlphaBits(8)

	end

	local time, w, h = CurTime(), ScrW(), ScrH()

	-- Bind to materials
	drugs_front_buffer:SetTexture("$basetexture", rt_front_buffer:GetTarget())
	drugs_back_buffer:SetTexture("$basetexture", rt_back_buffer:GetTarget())

	-- Push frontbuffer rendertarget
	render.PushRenderTarget(rt_front_buffer:GetTarget())
	render.Clear( 0, 0, 0, 255, true, true )

	-- Draw backbuffer into frontbuffer (with a bit of transparency so it doesn't blow out)
	cam.Start2D()
	surface.SetDrawColor(255,255,255,255)
	surface.SetMaterial( drugs_back_buffer )

	local x,y = 0,5 -- Offset vertically
	surface.DrawTexturedRectRotated( x + w/2, y + h/2,w+2,h+2, math_cos(time) * 0.4 )
	cam.End2D()

	-- Render 3D contents into frontbuffer
	cam.Start3D(vec_zero, ang_zero, 120, 0, 0, w, h, 0.1, 1000)

	-- A bunch of cylinders with UV scrolling on them
	-- 'warp_material0' is non-additive to clamp the effect from overblowing
	render_setmaterial(warp_material0)
	drawCylinder(time, 0.5, 2)
	render_setmaterial(warp_material0_add)
	drawCylinder(time, 0.8, 10)

	render_setmaterial(warp_material1)
	drawCylinder(time, -1, 10)
	drawCylinder(time, -0.5, 30)

	render_setmaterial(warp_material2)
	drawCylinder(time, 0.25, 10)
	drawCylinder(time+0.1, 0.25, 30)

	-- That cool PS2 effect
	local rx = time * 90
	local ry = time * 30
	local rz = time * 10

	-- Draw some sprites
	render_setmaterial(sprite_material)
	for i=1, 6 do
		local k = time + i*(time * 0.4)
		local c = math_cos(k) * 30
		local s = math_sin(k) * 30
		local x,y,z = 0,c,s
		local v = qv(x,y,z)
		vec_rotate(v, qa(rx, ry, rz))
		x,y,z = vec_unpack(v)

		local pos = qv(x+40,y,z)
		render_quadeasy(pos, vec_facing, 16, 16, qc(100,200,200,255))

		local trail = fx_trails[i]
		trail[#trail+1] = trail[1]
		table.remove(trail, 1)
		trail[#trail]:Set(pos)
	end

	-- Draw trails on those sprites
	render_setmaterial(additive_color)
	for i=1, 6 do
		local trail = fx_trails[i]

		-- Small white trail
		render_startbeam(fx_trail_len)
		for j=1, fx_trail_len do
			local v = trail[j]
			local c = fx_trail_colors[i][j]
			local cx = 255 * (j / fx_trail_len)
			col_setunpacked(c,cx,cx,cx,cx)
			render_addbeam(v, 0.5, 0, c)
		end
		render_endbeam()

		-- Larger blue trail
		render_startbeam(fx_trail_len)
		for j=1, fx_trail_len do
			local k = 0.8 * (j/fx_trail_len)
			local v = trail[j]
			local c = fx_trail_colors[i][j]
			col_setunpacked(c, 60*k,100*k,255*k,255)
			render_addbeam(v, 3*k, 0, c)
			vec_add(v, qv(0,0,0.2))
			vec_mul(v, 1.01)
		end
		render_endbeam()
	end

	cam.End3D()

	-- Copy frontbuffer into backbuffer
	render.CopyRenderTargetToTexture(rt_back_buffer:GetTarget())
	render.PopRenderTarget()

	-- Apply blur to taste
	render.BlurRenderTarget(rt_back_buffer:GetTarget(), 0.2, 8, 2)

end)

function Enable( bEnable )

	bDrugsOn = bEnable

end