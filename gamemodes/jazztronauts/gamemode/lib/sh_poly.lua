if SERVER then AddCSLuaFile("sh_poly.lua") end

module( "poly", package.seeall )

winding_big_range = 65535
winding_epsilon = 0.1
winding_epsilon_continuous = 0.005
SIDE_CROSS = -2
SIDE_FRONT = 1
SIDE_BACK = 2
SIDE_ON = 3

local meta = {}
meta.__index = meta

function Winding() return setmetatable({}, meta):Init() end

function meta:Init()

	self.points = {}
	return self

end

function meta:Add(p, mutable)

	self.points[#self.points+1] = mutable and p or Vector(p)

end

function meta:Move(v)

	for i=1, #self.points do

		self.points[i] = self.points[i] + v --:Add( v )

	end
	return self

end

function meta:Clear()

	self.points = {}

end

function meta:Copy(mutable)

	local new = Winding()
	for i=1, #self.points do
		new:Add( self.points[i], mutable )
	end
	return new

end

function meta:Reverse()

	for i=1, math.floor(#self.points / 2) do
		self.points[i], self.points[#tbl - i + 1] = self.points[#tbl - i + 1], self.points[i]
	end

end

local function roundfix(nc, dist, v)
	if nc == 1 then return dist end
	if nc == -1 then return -dist end
	return v
end

local __side_list = {}
for i=1, 100 do __side_list[i] = {} end

local function buildSidesFromPoints(w, plane, epsilon)

	local has_front = false
	local has_back = false

	for i=1, #w.points do
		local dot = w.points[i]:Dot( plane.normal ) - plane.dist
		local d = __side_list[i]

		if not d then __side_list[i] = {} d = __side_list[i] end

		d.dist = dot
		if dot > epsilon then
			d.side = SIDE_FRONT
			has_front = true
		elseif dot < -epsilon then
			d.side = SIDE_BACK
			has_back = true
		else
			d.side = SIDE_ON
		end
	end

	local first = __side_list[1]
	local last = __side_list[#w.points+1]
	last.dist = first.dist
	last.side = first.side

	return __side_list, has_front, has_back

end

--returns [ front, back ] windings
function meta:Split(plane, epsilon, mutable)

	local sides, has_front, has_back = buildSidesFromPoints( self, plane, epsilon or winding_epsilon )

	if not has_front then return nil, mutable and self or self:Copy() end
	if not has_back then return mutable and self or self:Copy(), nil end

	local front = Winding()
	local back = Winding()

	for i=1, #self.points do

		local p1 = self.points[i]

		if sides[i].side == SIDE_ON then

			front:Add( p1, mutable )
			back:Add( p1, mutable )
			continue

		end

		if sides[i].side == SIDE_FRONT then front:Add( p1, mutable ) end
		if sides[i].side == SIDE_BACK then back:Add( p1, mutable ) end

		if sides[i+1].side == SIDE_ON or sides[i+1].side == sides[i].side then
			continue
		end

		local p2 = Vector( self.points[ (i % #self.points) + 1 ] )
		local dot = sides[i].dist / ( sides[i].dist - sides[i+1].dist )

		p2:Sub(p1)
		p2:Mul(dot)
		p2:Add(p1)

		front:Add( p2, mutable )
		back:Add( p2, mutable )

	end

	return front, back

end

function meta:Clip(plane, epsilon)

	local sides, has_front, has_back = buildSidesFromPoints( self, plane, epsilon or winding_epsilon )

	if not has_front then self:Clear() return end
	if not has_back then return end

	local front = Winding()

	for i=1, #self.points do

		local p1 = self.points[i]

		if sides[i].side == SIDE_ON then

			front:Add( p1, true )
			continue

		end

		if sides[i].side == SIDE_FRONT then front:Add(p1) end
		if sides[i+1].side == SIDE_ON or sides[i+1].side == sides[i].side then
			continue
		end

		local p2 = Vector( self.points[ (i % #self.points) + 1 ] )
		local dot = sides[i].dist / ( sides[i].dist - sides[i+1].dist )

		p2:Sub(p1)
		p2:Mul(dot)
		p2:Add(p1)

		front:Add( p2, true )

	end

	self.points = front.points

end

function meta:Area()

	local total = 0
	for i=3, #self.points do
		local a = self.points[i-1] - self.points[1]
		local b = self.points[i] - self.points[1]
		total = total + a:Cross(b):Length() * 0.5

	end
	return total

end

function meta:Bounds()

	local min = Vector(99999, 99999, 99999)
	local max = Vector(-99999, -99999, -99999)

	for i=1, #self.points do

		local v = self.points[i]
		if v.x < min.x then min.x = v end
		if v.y < min.y then min.y = v end
		if v.z < min.z then min.z = v end

		if v.x > max.x then max.x = v end
		if v.y > max.y then max.y = v end
		if v.z > max.z then max.z = v end

	end

	return min, max

end

function meta:Center()

	local center = Vector(0,0,0)

	for i=1, #self.points do
		center:Add( self.points[i] )
	end

	center:Mul( 1 / #self.points )
	return center

end

function meta:Plane()

	local plane = {}

	if #self.points < 2 then return Plane(0,0,0,0) end

	local a,b = nil,nil
	for i=1, #self.points do
		a = self.points[ (i % #self.points) + 1  ] - self.points[ i ]
		b = self.points[ ((i+1) % #self.points) + 1 ] - self.points[ i ]
		if a:Length() > 0.5 and b:Length() > 0.5 then break end
	end
	if a == nil or b == nil then error("Winding:Plane - bad vectors dawg") end

	local normal = b:Cross(a)
	normal:Normalize()
	local dist = self.points[1]:Dot( normal )

	return Plane( normal, dist )

end

function meta:PlaneSide(plane)

	local front = false
	local back = false

	for i=1, #self.points do

		local d = self.points[i]:Dot( plane.normal ) - plane.dist
		if d < -winding_epsilon then

			if front then return SIDE_CROSS end
			back = true

		elseif d > winding_epsilon then

			if back then return SIDE_CROSS end
			front = true

		end

	end

	if back then return SIDE_BACK end
	if front then return SIDE_FRONT end
	return SIDE_ON

end

function meta:Check()

	if #self.points < 3 then error("Winding:Check - not enough points on winding") end

	local area = self:Area()
	if area < 1 then error("Winding:Check - winding too small, area = " .. area) end

	local plane = self:Plane()

	for i=1, #self.points do

		local p1 = self.points[i]
		local p2 = self.points[ (i % #self.points) + 1 ]

		if p1.x > winding_big_range or p1.x < -winding_big_range then error("Winding:Check - point out of range " .. i .. " : x = " .. p1.x) end
		if p1.y > winding_big_range or p1.y < -winding_big_range then error("Winding:Check - point out of range " .. i .. " : y = " .. p1.y) end
		if p1.z > winding_big_range or p1.z < -winding_big_range then error("Winding:Check - point out of range " .. i .. " : z = " .. p1.z) end

		local d = p1:Dot(plane.normal) - plane.dist
		if d < -winding_epsilon or d > winding_epsilon then error("Winding:Check - point off plane") end

		local dir = p2 - p1
		if dir:Length() < winding_epsilon then error("Winding:Check - degenerate edge") end

		local edgenormal = plane.normal:Cross( dir )
		edgenormal:Normalize()

		local edgedist = p1:Dot( edgenormal ) + winding_epsilon

		for j=1, #self.points do

			if j ~= i then

				if self.points[j]:Dot( edgenormal ) > edgedist then
					error("Winding:Check - non-convex")
				end

			end

		end

	end

end

function meta:RemoveColinearPoints()

	local w = Winding()
	for i=0, #self.points-1 do

		local j = 1 + (i+1) % #self.points
		local k = 1 + (i+#self.points - 1) % #self.points

		local v1 = self.points[j] - self.points[i+1]
		local v2 = self.points[i+1] - self.points[k]
		v1:Normalize()
		v2:Normalize()
		if v1:Dot(v2) < 0.999 then
			w:Add( self.points[i+1], true )
		end

	end

	if #w.points == #self.points then return false end
	self.points = w.points

	return true

end

function meta:RemoveEqualPoints(epsilon)

	if #self.points == 0 then return false end
	epsilon = epsilon or winding_epsilon

	local w = Winding()
	w:Add( self.points[1] )

	for i=1, #self.points do

		if (self.points[i] - w.points[#w.points]):Length() > epsilon then
			w:Add( self.points[i], true )
		end

	end

	if #w.points == #self.points then return false end
	self.points = w.points

	return true

end

function meta:TryMerge(other, planenormal)

	local a = self
	local b = other
	local p1, p2, p3, p4
	local i,j,k
	local found = false

	i = 1 repeat
		p1 = a.points[i]
		p2 = a.points[ (i % #a.points) + 1 ]

		j = 1 repeat
			p3 = b.points[j]
			p4 = b.points[ (j % #a.points) + 1 ]

			k = 1 repeat
				if math.abs( p1[k] - p4[k] ) > .1 then break end
				if math.abs( p2[k] - p3[k] ) > .1 then break end
			k = k + 1 until k == 3
			if k == 3 then break end

		j = j + 1 until j == #b.points
		if j < #b.points then break end

	i = i + 1 until i == #a.points
	if i == #a.points then print("no matching edges") return nil end

	--so things work because lua had to fucking start indices at ONE!
	i = i - 1
	j = j - 1

	print('A\n',p1,'\n',p4,'\nB',p2,'\n',p3)

	local back = a.points[ ( (i+#a.points-1) % #a.points ) + 1 ]
	local delta = p1 - back
	local normal = planenormal:Cross( delta )
	normal:Normalize()

	local back = b.points[ ( (j+2) % #b.points ) + 1 ]
	local delta = back - p1
	local dot = delta:Dot( normal )
	if dot > winding_epsilon_continuous then return nil end
	local keep1 = dot < -winding_epsilon_continuous

	local back = a.points[ ( (i+2) % #a.points ) + 1 ]
	local delta = back - p2
	local normal = planenormal:Cross( delta )
	normal:Normalize()

	local back = b.points[ ( (j+#b.points-1) % #b.points ) + 1 ]
	local delta = back - p2
	local dot = delta:Dot( normal )
	if dot > winding_epsilon_continuous then return nil end
	local keep2 = dot < -winding_epsilon_continuous

	local out = Winding()

	k = (i+1) % #a.points repeat k = (k+1) % #a.points
		if k ~= (i+1) % #a.points or keep2 then
			out:Add( a.points[k+1] )
		end
	until k == i

	k = (j+1) % #a.points repeat k = (k+1) % #a.points
		if k ~= (j+1) % #a.points or keep1 then
			out:Add( b.points[k+1] )
		end
	until k == j

	return out

end

function meta:Merge(other, planenormal)

	local a = self
	local b = other
	local w = self:Copy()
	local sides = {}

	w:RemoveEqualPoints(.2)

	for i=0, #b.points-1 do
		local v = b.points[i+1]
		for j=0, #w.points-1 do
			local edgevec = w.points[1 + (j+1) % #w.points] - w.points[1 + j % #w.points]
			local sepnormal = edgevec:Cross( planenormal )
			sepnormal:Normalize()
			if sepnormal:Length() < 0.9 then
				table.remove( w.points, j+1 )
				j = j - 1
			else
				local dist = w.points[1 + (j % #w.points)]:Dot( sepnormal )
				if v:Dot( sepnormal ) - dist < -winding_epsilon then sides[j+1] = SIDE_BACK
				else sides[j+1] = SIDE_FRONT end
			end
		end
		for j=0, #w.points-1 do
			if sides[j+1] == SIDE_BACK and sides[1 + (j+1) % #w.points] == SIDE_BACK then
				table.remove( w.points, 1 + (j+1) % #w.points )
				j = j - 1
			end
		end
		local found = false
		for j=0, #w.points do
			if sides[j+1] == SIDE_FRONT and sides[1 + (j+1) % #w.points] == SIDE_BACK then
				if found then print("WARNING:MULTIPLE-ON-BACK") end
				found = true
				break
			end
		end
		for j=0, #w.points-1 do
			if sides[j+1] == SIDE_FRONT and sides[1 + (j+1) % #w.points] == SIDE_BACK then
				local after = 1+(j+2) % #w.points
				table.insert( w.points, after, v )
			end
		end

	end

	w:RemoveColinearPoints()

	return w

end

local invcolor = 1/255
local lightmapTex = nil

-- Generate a single half-lit lightmap for now
if CLIENT then
	local lightmaprt = irt.New("jazz_snatch_lightmaptex", 64, 64)
	lightmapTex = lightmaprt:GetTarget()
	lightmaprt:Render(function() render.Clear(12, 12, 12, 255) end )
end

function meta:Render(col, depth, offset, wire)

	self.rplane = self.rplane or self:Plane()

	if self.mesh and not wire then
		if col then
			render.SetColorModulation( col.r * invcolor, col.g * invcolor, col.b * invcolor )
		end
		render.SetLightmapTexture(lightmapTex)
		render.SetLightingOrigin( self.cache_center )
		render.SetMaterial( self.material )

		--if lightmap ~= nil then render.SetLightmapTexture( lightmap ) end
		self.mesh:Draw()

		return
	end

	for i=1, #self.points do

		local p1 = self.points[i]
		local p2 = self.points[ (i % #self.points) + 1 ]

		if offset then
			p1 = p1 - self.rplane.normal * offset
			p2 = p2 - self.rplane.normal * offset
		end

		render.DrawLine( p1, p2, col or Color(20,100,255), depth )
	end

end


local function makeMaterial( texture )

	local params = {
		["$basetexture"] = texture,
		["$model"] = 1,
		--["$vertexalpha"] = 1,
		["$vertexcolor"] = 0,
		["$ignorez"] = 0,
	}

	local mat = CreateMaterial("mxx_" .. texture, "VertexLitGeneric", params);

	return mat

end

function meta:EmitMesh(texmatrix, lmmatrix, width, height, offset, meshVerts )
	width = width or 1
	height = height or 1
	material = material or default_mesh_material

	local function emitPointVert(p, normal, verts)
		local u,v = 0,0
		if texmatrix ~= nil then
			u,v = texmatrix:GetUV(p + offset)
			u = u / width
			v = v / height
		end

		-- Optionally insert into a specified vertex table if they wanna do something spiffy
		if meshVerts then
			table.insert(meshVerts, {pos = p, u = u, v = v, normal = normal})
		else
			mesh.Position( p )
			mesh.TexCoord( 0, u, v )


			if lmmatrix ~= nil then
				u,v = lmmatrix:GetUV(p + offset)
			end

			--local light = render.ComputeLighting( p, normal )

			mesh.TexCoord( 1, u, v )
			mesh.Normal( normal )
			--mesh.Color( light.x*255, light.y*255, light.z*255, 255 )
			mesh.Color( 255, 255, 255, 100 )
			mesh.AdvanceVertex()
		end
	end

	local normal = self:Plane().normal


	for i=2, #self.points-1 do
		emitPointVert(self.points[1], normal)
		emitPointVert(self.points[i+1], normal)
		emitPointVert(self.points[i], normal)
	end

end

local default_mesh_material = Material( "editor/wireframe" )
function meta:CreateMesh(material, texmatrix, lmmatrix, width, height, offset )
	self.mesh = ManagedMesh(material )

	mesh.Begin( self.mesh:Get(), MATERIAL_TRIANGLES, #self.points - 2 )
		self:EmitMesh( texmatrix, lmmatrix, width, height, offset)
	mesh.End()

	self.material = material
	self.cache_center = self:Center()

end

local function FindMajorAxis(plane)

	local normal = plane.normal
	local max = -winding_big_range
	local x = 0
	for i=1, 3 do
		local v = math.abs( normal[i] )
		if v > max then
			x = i
			max = v
		end
	end

	return x

end

local __up_vector = Vector(0,0,0)
local __left_vector = Vector(0,0,0)
local __x_vector = Vector(1,0,0)
local __z_vector = Vector(0,0,1)
local __zero_vector = Vector(0,0,0)

function BaseWinding(plane)

	-- We cache base windings since a lot of brushsides may share the same plane ( co-planar )
	if plane._basewinding then return plane._basewinding:Copy(true) end

	local major = FindMajorAxis( plane )
	if major == 0 then error("BaseWinding - No major axis for plane") end

	local up = __up_vector
	up:Set( major == 3 and __x_vector or __z_vector )

	local v = up:Dot( plane.normal )
	up:Add( plane.normal * -v )
	up:Normalize()

	local origin = plane.normal * plane.dist
	local right = up:Cross( plane.normal )

	up:Mul( winding_big_range )
	right:Mul( winding_big_range )

	--print(origin - up, up, up:Dot(right), up:Dot(plane.normal))

	local left = __left_vector
	left:Set(__zero_vector)
	left:Sub(right)
	left:Add(origin)
	right:Add(origin)

	local w = Winding()
	w:Add( left + up, true )
	w:Add( right + up, true )
	w:Add( right - up, true )
	w:Add( left - up, true )

	plane._basewinding = w

	--w:Check()

	return w:Copy(true)

end