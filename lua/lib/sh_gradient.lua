if SERVER then AddCSLuaFile("sh_gradient.lua") end
if SERVER then return end

local _cvec = {}
local function CVec(id, x,y,z)

	local v = _cvec[id] or Vector(0,0,0)
	v.x = x or 0
	v.y = y or 0
	v.z = z or 0
	_cvec[id] = v
	return v

end

local mat_color = Material( "color" )
function LinearGradient( rect, angle, stops, offset, material )

	offset = offset or 0

	local r = angle * DEG_2_RAD
	local cx, cy = rect:GetCenter()
	local cos = math.cos( r )
	local sin = math.sin( r )
	local cos2 = math.cos( r + math.pi/2 )
	local sin2 = math.sin( r + math.pi/2 )

	render.SetScissorRect( Box(rect):Unpack(true) )
	render.SetMaterial( material or mat_color )

	local total_stop_count = #stops + 2

	local function add_stop(i, dist, col)
		local sx = cx + cos * (dist + offset)
		local sy = cy + sin * (dist + offset)
		local x0,y0,x1,y1 = sx+cos2*9999, sy+sin2*9999, sx-cos2*9999, sy-sin2*9999

		mesh.Position( CVec(i,x0,y0,0) )
		mesh.Color( col.r,col.g,col.b,col.a )
		mesh.TexCoord( 0, (x0 - rect.x) / rect.w, (y0 - rect.y) / rect.h )
		mesh.AdvanceVertex()

		mesh.Position( CVec(i,x1,y1,0) )
		mesh.Color( col.r,col.g,col.b,col.a )
		mesh.TexCoord( 0, (x1 - rect.x) / rect.w, (y1 - rect.y) / rect.h )
		mesh.AdvanceVertex()
	end

	mesh.Begin(MATERIAL_TRIANGLE_STRIP, total_stop_count * 2)

	local b,e = pcall( function()

	add_stop("min", -9999, stops[1][2])

	for k,stop in pairs(stops) do
		add_stop(k, stop[1], stop[2])
	end

	add_stop("max", 9999, stops[#stops][2])

	end)
	if not b then print(e) end

	mesh.End()

	render.SetScissorRect( 0,0,0,0,false )

end

local _gradients = {}
function CacheGradient(name, rect, angle, stops, offset, material)

	local x,y = rect.x, rect.y
	local w,h = rect:GetSize()
	local rt = irt.New("stored_gradient_" .. name,w,h)

	rect.x = 0
	rect.y = 0

	rt:SetAlphaBits( 8 )
	rt:EnableDepth( false, false )
	rt:Render( function()

		local oldW, oldH = ScrW(), ScrH()
		render.Clear( 0,0,0,0 )
		render.SetViewPort( rect:Unpack() )
		render.OverrideAlphaWriteEnable( true, true )
		cam.Start2D()

		LinearGradient( rect, angle, stops, offset, material )

		cam.End2D()
		render.OverrideAlphaWriteEnable( false )
		render.SetViewPort( 0, 0, oldW, oldH )

	end )

	_gradients[name] = rt:GetUnlitMaterial(true,false,true,true)
	rect.x = x
	rect.y = y

	return _gradients[name]

end

function LinearGradientCached(name, rect, custom_color)

	if _gradients[name] then
		if not custom_color then
			surface.SetDrawColor(255,255,255,255)
		else
			surface.SetDrawColor(
				custom_color.r,
				custom_color.g,
				custom_color.b,
				custom_color.a
			)
		end
		surface.SetMaterial( _gradients[name] )
		surface.DrawTexturedRect(rect:Unpack())
	end

end