AddCSLuaFile()

G_IOTRACE_META = G_IOTRACE_META or {}

module( "iotrace", package.seeall )

local vmeta = FindMetaTable("Vector")
local vunpack = vmeta.Unpack
local vpack = vmeta.SetUnpacked
local vset = vmeta.Set
local vmul = vmeta.Mul
local vdiv = vmeta.Div
local vadd = vmeta.Add
local vsub = vmeta.Sub
local vdot = vmeta.Dot
local vlen = vmeta.Length
local vlen2 = vmeta.LengthSqr
local vdistance = vmeta.Distance

local function GetMajorAxis( v )

	local best = 0
	local major_axis = 1
	for i=1, 3 do
		local d = math.abs(v[i])
		if d > best and d ~= 0 then major_axis = i best = d end
	end
	return major_axis

end

local meta = G_IOTRACE_META
meta.__index = meta

function meta:Init( from, to, index )

	self.from = from
	self.to = to
	self.index = index
	self.min = Vector()
	self.max = Vector()
	self.blips = {}
	self.points = {}

	return self

end

function meta:BuildPath( direct )

	self.points = {}

	local base = self.from
	local target = self.to
	local length = 0

	if direct then

		local dir = target - base
		local dirlen = dir:Length()

		length = dirlen

		self.points[#self.points+1] = {
			pos = base,
			dir = dir,
			normal = dir:GetNormal(),
			binormal = Vector(0,0,1),
			len = dirlen,
			along = 0,
			next = base + dir,
		}

	else

		for i=1, 3 do

			local vec = target - base -- vector to target
			local major = GetMajorAxis(vec) -- largest axis

			-- direction along largest axis
			local dir = Vector(0,0,0)
			dir[major] = vec[major]

			-- length of direction
			local dirlen = math.abs(vec[major])
			length = length + dirlen

			-- end-point along direction
			self.points[#self.points+1] = {
				pos = base,
				dir = dir,
				normal = dir:GetNormal(),
				binormal = Vector(0,0,1),
				len = dirlen,
				along = length - dirlen,
				next = base + dir,
			}
			base = base + dir

			if base:Distance( target ) < 1 then break end

		end

	end

	for i=1, #self.points do

		-- calculate a valid binormal based on previous / next point
		local point = self.points[i]
		if math.abs(point.binormal:Dot(point.normal)) > 0.99 then
			if self.points[i+1] then
				point.binormal = self.points[i+1].normal
			elseif self.points[i-1] then
				point.binormal = self.points[i-1].normal
			end
		end

		-- build orthonormal basis as a quaternion
		point.tangent = point.binormal:Cross(point.normal)
		point.quat = Quat():FromVectors(
			point.normal,
			point.tangent,
			point.binormal)

	end

	self.length = length
	self:ComputeBounds()

end

function meta:ComputeBounds()

	local min = self.min
	local max = self.max

	ResetBoundingBox( min, max )

	for _, point in ipairs( self.points ) do

		-- add line to bounding box
		AddPointToBoundingBox( point.pos, min, max )
		AddPointToBoundingBox( point.next, min, max )

		-- add bounding box around this line
		point.min = Vector(point.pos)
		point.max = Vector(point.next)
		OrderVectors(point.min, point.max)
		point.min:Sub(Vector(2,2,2))
		point.max:Add(Vector(2,2,2))
		point.x0 = point.min.x
		point.y0 = point.min.y
		point.z0 = point.min.z
		point.x1 = point.max.x
		point.y1 = point.max.y
		point.z1 = point.max.z

	end

	-- expand main bounding box by 5
	local expand = 5
	for i=1, 3 do
		min[i] = min[i] - expand
		max[i] = max[i] + expand
	end

	self.x0 = min.x
	self.y0 = min.y
	self.z0 = min.z

	self.x1 = max.x
	self.y1 = max.y
	self.z1 = max.z

	self.center = (self.min + self.max) / 2
	self.extent = (self.max - self.min) / 2
	self.radius = self.extent:Length()
	self.radiusSqr = self.radius * self.radius

	self.cx = self.center.x
	self.cy = self.center.y
	self.cz = self.center.z

end

local IntersectRayBoxRaw = IntersectRayBoxRaw

local vpos = Vector()
local vup = Vector()
local vnormal = Vector()


local function vcross(a,b,c)

	local ax, ay, az = vunpack(a)
	local bx, by, bz = vunpack(b)
	vpack(c,
		ay * bz - az * by,
		az * bx - ax * bz,
		ax * by - ay * bx
	)
	return c

end

-- (if trace hits), returns true, TOI, segment points
function meta:TestRay(ox, oy, oz, dx, dy, dz, origin, dir, maxDist, distToLine)

	distToLine = distToLine or 4

	local x0, y0, z0 = self.x0, self.y0, self.z0
	local x1, y1, z1 = self.x1, self.y1, self.z1

	-- test against entire trace
	local hit, t = IntersectRayBoxRaw(
		ox, oy, oz, 
		dx, dy, dz, 
		x0, y0, z0, 
		x1, y1, z1)

	if not hit or t > maxDist then return false end

	local points = self.points

	-- test against each segment
	for i=1, #points do

		local point = points[i]
		local x0, y0, z0 = point.x0, point.y0, point.z0
		local x1, y1, z1 = point.x1, point.y1, point.z1

		local hit, t = IntersectRayBoxRaw(
			ox, oy, oz, 
			dx, dy, dz, 
			x0, y0, z0, 
			x1, y1, z1)

		if hit and t < maxDist then

			-- test against a plane oriented towards the ray
			vcross( point.normal, dir, vup )
			vcross( vup, point.normal, vnormal )
			local toi = IntersectRayPlane(origin, dir, point.pos, vnormal)

			-- calculate local point of interection on plane
			vset(vpos, dir)
			vmul(vpos, toi)
			vadd(vpos, origin)
			vsub(vpos, point.pos)
			local x = vdot( vpos, point.normal )
			local y = vdot( vpos, vup )

			-- only hit if within segment
			if x > 0 and x < point.len then

				-- only hit if close to segment "vertically"
				if math.abs(y) < distToLine then
					return hit, toi, point
				end

			end

		end

	end

	return false

end

function meta:GetIndex() return self.index end
function meta:GetLength() return self.length end
function meta:GetPointAlongPath( t )

	local acc = 0
	local num = #self.points
	for i=1, num do

		-- iterate along points until t is within range, then extrapolate
		local point = self.points[i]
		if acc + point.len > t or i == num then
			return point.pos + point.normal * (t - acc), point.quat
		end
		acc = acc + point.len

	end

end

local function SqrDistToLine( a, b, pos )

	local v = (b - a)
	local vl = v:Length()
	local vn = v / vl
	local d = (pos - a):Dot( vn )
	d = math.Clamp(d, 0, vl)

	local vp = a + vn * d
	return (vp - pos):LengthSqr()

end

local vorg = Vector()
local vdir = Vector()
local function ConformLineToSphere( pos, radiusSqr, a, b )

	vset(vorg, a)
	vset(vdir, a)
	vsub(vdir, pos)
	vsub(b, a)
	local u = b
	local o = vorg
	local c = pos
	local l = vlen(u)
	vdiv(u, l)

	local v = (vdot(u, vdir) ^ 2) - (vlen2(vdir) - radiusSqr)

	if v < 0 then return false, a, b end
	if v == 0 then return false, a, b end

	local d = -vdot(u,vdir)

	local root = math.sqrt(v)

	local d0 = math.Clamp(d + root, 0, l)
	local d1 = math.Clamp(d - root, 0, l)

	vset(a, u)
	vset(b, u)
	vmul(a, d0)
	vmul(b, d1)
	vadd(a, o)
	vadd(b, o)
	return true

end

function meta:FindPointOnPath( pos )

	local dist = math.huge
	local p = 0
	for i=1, #self.points do

		local point = self.points[i]
		local along = (pos - point.pos):Dot( point.normal )

		along = math.Clamp(along, 0, point.len)

		local v = point.pos + point.normal * along
		local vd = (v - pos):LengthSqr()

		if vd < dist then
			dist = vd
			p = point.along + along
		end

	end
	return p

end

if CLIENT then

	local startBeam = render.StartBeam
	local endBeam = render.EndBeam
	local addBeam = render.AddBeam
	local drawLine = render.DrawLine
	local base_trace_color = Color(180,0,255,255)
	local base_trace_color2 = Color(180/4,0,255/4,255)
	local blip_color = Color(255,180,50)
	local blip_color2 = Color(255/2,180/2,50)
	local MIN_DELAY = 0.5

	blip_color, base_trace_color = base_trace_color, blip_color
	blip_color2, base_trace_color2 = base_trace_color2, blip_color2

	function meta:ClearBlips()

		self.blips = {}

	end

	function meta:AddBlip( duration, time )

		self.blips[#self.blips+1] = {
			time = time or CurTime(),
			duration = duration,
		}

	end

	local vstart = Vector()
	local vend = Vector()
	local vma = Vector()
	local sqrt = math.sqrt

	function meta:Draw(color, width, t0, t1, nocull)

		--if true then return end

		local maxDist = 300
		local maxDistSqr = maxDist * maxDist
		local eye = _G.G_EYE_POS

		-- this has to be fast!
		if not nocull then
			local x,y,z = _G.G_EYE_X, _G.G_EYE_Y, _G.G_EYE_Z
			local dx,dy,dz = (x-self.cx), (y-self.cy), (z-self.cz)
			local dist = sqrt(dx*dx + dy*dy + dz*dz)
			local distCheck = dist - self.radius
			if distCheck > maxDist then return end
			--if true then return end
		end

		t0 = t0 or 0
		t1 = t1 or self.length
		color = color or base_trace_color
		width = width or 2

		if t1 < t0 then t0, t1 = t1, t0 end

		for _, point in ipairs( self.points ) do

			vset(vstart, point.pos)
			vset(vend, point.next)

			local term = point.along + point.len > t1
			local show = true

			if point.along + point.len < t0 then continue end

			if term then
				vset(vma, point.normal)
				vmul(vma, t1 - point.along)
				vset(vend, vstart)
				vadd(vend, vma)
			end

			if t0 > point.along then
				vset(vma, point.normal)
				vmul(vma, t0 - point.along )
				vadd(vstart, vma)
			end

			if not nocull then
				show = ConformLineToSphere( eye, maxDistSqr, vstart, vend )
			end

			if show then
				startBeam( 2 )
				addBeam(vstart, width, 0, color)
				addBeam(vend, width, 0, color)
				endBeam()
			end

			if term then break end

		end

	end

	function meta:DrawBlips()

		local tracelen = self:GetLength()
		local steps = 50
		local space = 1
		local extratime = (space/tracelen) * steps

		for i=#self.blips, 1, -1 do

			local blip = self.blips[i]
			local trace = blip.trace
			local t = CurTime() - blip.time

			local blip_scale = 1
			if t > blip.duration then

				local flash = 1 - math.min((t - blip.duration) / MIN_DELAY, 1)
				blip_scale = flash

			end

			if blip.duration > 0 then

				local bliptime = math.min(t / blip.duration, 1 + extratime)
				local time = bliptime * tracelen

				for k=1, steps do

					local time2 = math.Clamp( time - (k * space), 0, tracelen )
					local pos = self:GetPointAlongPath( time2 )
					local size = (8 - (k/steps) * 8 ) * blip_scale
					if time2 == tracelen then size = size * 2 end
					render.DrawSprite( pos, size, size, blip_color )

				end

			end

		end

	end

	function meta:DrawFlashes()

		for i=#self.blips, 1, -1 do

			local blip = self.blips[i]
			local t = CurTime() - blip.time
			if t > blip.duration + MIN_DELAY then

				table.remove(self.blips, i) 
				continue

			end

			if t > blip.duration then

				local flash = 1 - math.min((t - blip.duration) / MIN_DELAY, 1)
				if flash > 0 then
					local col = LerpColor(blip_color, Color(0,0,0,0), 1 - flash)
					self:Draw( col, 8, nil, nil, true )
					self:Draw( col, 16, nil, nil, true )
				end

			else

				self:Draw( blip_color, 8, 0, (t / blip.duration) * self.length, true )

			end

		end

	end

end

function New(...)

	return setmetatable({}, meta):Init(...)

end