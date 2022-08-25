AddCSLuaFile()

module( "bsp2", package.seeall )

local map = bsp2.GetCurrent()

--[[for k,v in pairs( map[bsp3.LUMP_TEXINFO] ) do
	--if string.find( v.texdata.material, "TOOLS/" ) then PrintTable(v) end
end

for k,v in pairs( map[bsp3.LUMP_TEXDATA_STRING_DATA] ) do
	if string.find( v, "TOOLS/" ) then print(v) end
end

for k,v in pairs( map[bsp3.LUMP_TEXDATA] ) do
	if string.find( v.material, "TOOLS/" ) then PrintTable(v) end
end]]

local function findBrushSide( leaf, pos )

	for k, brush in pairs( leaf.brushes ) do

		if bit.band( brush.contents, leaf.contents ) == 0 then continue end --CONTENTS_DETAIL

		local inside = true
		local bside = nil
		local g = -9999
		for _, side in pairs( brush.sides ) do

			local pln = side.plane.back
			local d = pos:Dot( pln.normal ) - pln.dist
			if d > 0.01 then inside = false end
			if d > g then bside = side g = d end

		end
		if inside then return bside, brush end

	end

	return nil

end

local function traceBrushSides( brush, tw )

	local first = 0
	local last = 999999
	local testside = nil

	for _, side in pairs( brush.sides ) do

		local pln = side.plane.back
		local denom = tw.dir:Dot( pln.normal )
		local dist = pln.dist - pln.normal:Dot( tw.pos )

		if denom ~= 0.0 then

			local t = dist / denom

			if denom < 0 then
				if t > first then
					testside = side
					first = t
				end
			else
				last = math.min( last, t )
			end

		end

		if first > last then return nil end

	end

	return testside, first

end

local function traceBrushes( leaf, tw )

	local bbrush = nil
	local bside = nil

	for _, brush in pairs( leaf.brushes ) do

		if bit.bor( brush.contents, tw.mask ) ~= tw.mask then continue end --CONTENTS_DETAIL
		if bit.band( brush.contents, CONTENTS_DETAIL ) == 0 then continue end

		local side, t = traceBrushSides( brush, tw )
		if side then

			if t < tw.tmax then
				tw.tmax = t
				tw.tmin = t
				bside = side
				bbrush = brush
			end

		end
	end

	return bside, bbrush

end

function traceNode( node, tw )

	if node == nil then return end
	local stack = {}
	local pos = Vector(tw.pos)
	local dir = Vector(tw.dir)
	local inv = nil

	if tw.mtx then
		inv = tw.mtx:Copy()
		inv:Invert()

		inv:Transform3( pos, 1, pos )
		inv:Transform3( dir, 0, dir )
	end

	local steps = 0

	tw.t = tw.tmax

	local out = 999
	while out > 0 do
		out = out - 1

		steps = steps + 1
		tw.Steps = steps

		if not node.is_leaf then

			local pln = node.plane
			local denom = dir:Dot( pln.normal )
			local dist = pln.dist - pln.normal:Dot( pos )
			local near = dist <= 0

			if denom ~= 0.0 then

				local t = dist / denom
				if 0 <= t and t <= tw.tmax then

					if t >= tw.tmin then

						table.insert(stack, {
							node = node.children[ near and 2 or 1 ],
							tmax = tw.tmax,
						})
						tw.tmax = t

					else

						near = not near

					end

				end

			end

			node = node.children[ near and 1 or 2 ]

		else

			if node.has_detail_brushes then --bit.band( CONTENTS_DETAIL, tw.mask ) ~= 0 and

				--print(CurTime() .. "TEST DETAILS")
				local side, brush = traceBrushes( node, tw )

				if side then
					tw.hit = true
					tw.leaf = node
					tw.t = tw.tmin
					tw.Hit = true
					tw.HitPos = pos + dir * tw.t
					tw.HitWorld = true
					tw.Brush = brush
					tw.Side = side
					tw.IsDetail = true
				end

			end

			if not tw.hit and bit.band( node.contents, tw.mask ) ~= 0 then

				tw.hit = true
				tw.leaf = node
				tw.t = tw.tmin
				tw.Hit = true
				tw.HitPos = pos + dir * tw.t
				tw.HitNormal = Vector(0,0,1)
				tw.HitWorld = not tw.Entity

				tw.Side, tw.Brush = findBrushSide( node, tw.HitPos )

			end

			if tw.hit == true then

				if tw.Side then
					tw.HitNormal = Vector(tw.Side.plane.back.normal)
					tw.TexInfo = tw.Side.texinfo
					tw.Contents = tw.Brush.contents
				end

				if inv then
					tw.mtx:Transform3( tw.HitPos, 1, tw.HitPos )
					tw.mtx:Transform3( tw.HitNormal, 0, tw.HitNormal )
				end
				return tw

			end


			if #stack == 0 then return tw end
			local top = stack[#stack]
			table.remove( stack, #stack )

			tw.tmin = tw.tmax
			node = top.node
			tw.tmax = top.tmax

		end

	end

	return tw

end

local function buildFilterMap(filter, dest)
	table.Empty(dest)
	if not filter then return end

	for k, v in pairs(filter) do
		dest[v] = v
	end
end

local filterMap = {}
local meta = getmetatable( map )
function meta:Trace( tdata)
	local tdatacopy = table.Copy(tdata)
	local res = traceNode( self.models[1].headnode, tdata )
	buildFilterMap(tdata.filter, filterMap)

	if not tdata.ignoreents then
		for k,v in pairs( self.entities ) do
			if filterMap[v.classname] then continue end

			if v.bmodel then
				local pos = v.origin and Vector(v.origin)
				local ang = v.angles and Angle(v.angles)

				-- If this bmodel has an existent entity analog in the world
				-- adopt the entity's position/angles
				local realEnts = bmodelmap.GetEntity(v.bmodel.id - 1)
				if realEnts then

					-- TODO: Potentially multiple entities with the same bmodel (but rare)
					-- For now just grab the first one, but should probably handle this later
					local _, real = next(realEnts)
					if IsValid(real) then
						pos = real:GetPos()
						ang = real:GetAngles()
					end
				end

				local d = table.Copy(tdatacopy)

				d.Entity = v
				d.pos = Vector(d.pos)
				d.dir = Vector(d.dir)

				local mtx = Matrix()
				mtx:SetTranslation( pos or Vector(0,0,0) )
				mtx:SetAngles( ang or Angle(0,0,0) )
				d.mtx = mtx

				traceNode( v.bmodel.headnode, d )
				d.Steps = (res and (d.Steps + res.Steps)) or d.Steps
				res = (res and res.t < d.t) and res or d
				--print("yo: ", v.bmodel.id, tostring(v.origin), d.hit)
			end
		end
	end

	return res
end


if SERVER then return end


local function drawFace( face )

	local winding = poly.Winding()
	for i=1, #face.edges do

		winding:Add( face.edges[i][1] )

	end
	winding:Move( face.plane.normal )
	winding:Render()

end

local function drawBrush( brush, mtx )

	if mtx then cam.PushModelMatrix(mtx) end

	brush:Render()

	if mtx then cam.PopModelMatrix() end

end

local function drawLeaf( leaf, mtx )

	if mtx then cam.PushModelMatrix(mtx) end

	for k,v in pairs( leaf.brushes ) do
		drawBrush( v )
	end

	if mtx then cam.PopModelMatrix() end

end

local function drawModel( model )

	for k,v in pairs( model.faces ) do
		drawFace( v )
	end

end

local convar_run_test = CreateClientConVar("jazz_debug_bspquery", "0", false, false, "Toggle on screen debugging of the bsp query module.")

local trace_res = nil
hook.Add( "HUDPaint", "dbgquery", function()
	if not convar_run_test:GetBool() then return end

	if map:IsLoading() then return end

	if trace_res and trace_res.Hit then

		if not map.entities[1].index then
			for k, ent in pairs( map.entities ) do
				ent.index = k
			end
		end


		local ent = trace_res.Entity
		local d = tostring( ( "%0.1f"):format( trace_res.t ) )
		d = ent and ( ( ent.targetname and ent.targetname .. "<" .. ent.classname .. ">" ) or ent.classname ) .. " [" .. d .. ", " .. ent.index .. " ]" or d
		d = trace_res.IsDetail and "detail [" .. d .. "]" or d

		local inf = trace_res.TexInfo
		local d2 = inf and (inf.texdata.material .. " [" .. inf.texdata.width .. "x" .. inf.texdata.height .. "]" ) or "<no texture data>"

		if not trace_res.Side then
			d2 = "<no side>"
		end

		surface.SetFont("DermaLarge")

		local w = math.max( surface.GetTextSize(d), surface.GetTextSize(d2) ) + 10
		draw.RoundedBox( 8, ScrW()/2 - w/2, ScrH()/2 + 20, w, 110, Color(0,0,0,220) )

		draw.SimpleText(d, "DermaLarge", ScrW()/2, ScrH()/2 + 30, Color(80,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		draw.SimpleText(d2, "DermaLarge", ScrW()/2, ScrH()/2 + 60, Color(80,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		draw.SimpleText(trace_res.Steps .. " iterations", "DermaLarge", ScrW()/2, ScrH()/2 + 90, Color(80,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

	end

end )

hook.Add( "PostDrawOpaqueRenderables", "dbgquery", function( bdepth, bsky )
	--if not cvardebug:GetBool() then return end
	--if bsky then return end

	--drawFace( face )

	--drawBrush( map.brushes[6] )

	if not convar_run_test:GetBool() then return end
	if map:IsLoading() then return end

	--if true then return end

	local mask = bit.bor( MASK_SOLID, CONTENTS_DETAIL )
	mask = bit.bor( mask, CONTENTS_GRATE )
	mask = bit.bor( mask, CONTENTS_TRANSLUCENT )
	--mask = bit.bor( mask, CONTENTS_PLAYERCLIP )
	--mask = bit.bor( mask, CONTENTS_MONSTERCLIP )

	local res = map:Trace({
		pos = LocalPlayer():EyePos(),
		dir = LocalPlayer():EyeAngles():Forward(),
		tmin = 0,
		tmax = 10000,
		mask = mask,
		--ignoreents = true,
	} )

	--trace( map.models[1].headnode, d )
	/*
	local res = trace( map.models[1].headnode, {
		pos = LocalPlayer():EyePos(),
		dir = LocalPlayer():EyeAngles():Forward(),
		tmin = 0,
		tmax = 10000,
		mask = mask,
	} )

	for k,v in pairs( map.entities ) do

		--if string.find( v.classname, "trigger_" ) then continue end

		if v.bmodel then

			local d = {
				pos = LocalPlayer():EyePos(),
				dir = LocalPlayer():EyeAngles():Forward(),
				tmin = 0,
				tmax = 10000,
				Entity = v,
				mask = mask,
			}

			local mtx = Matrix()
			mtx:SetTranslation( v.origin or Vector(0,0,0) )
			mtx:SetAngles( v.angles or Angle(0,0,0) )
			d.mtx = mtx

			trace( v.bmodel.headnode, d )
			d.Steps = (res and (d.Steps + res.Steps)) or d.Steps
			res = (res and res.t < d.t) and res or d

		end

	end*/

	if res then

		--print( res.t or 0 )

		if res.Hit then

			gfx.renderAngle( res.HitPos, res.HitNormal:Angle() )

			if not res.Brush then
				drawLeaf( res.leaf, res.mtx )
			else
				drawBrush( res.Brush, res.mtx  )
			end

		end

	end
	trace_res = res

end )