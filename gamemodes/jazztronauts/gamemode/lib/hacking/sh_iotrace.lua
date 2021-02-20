AddCSLuaFile()

G_IOTRACE_META = G_IOTRACE_META or {}

module( "iotrace", package.seeall )

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

end

local IntersectRayBoxRaw = IntersectRayBoxRaw

-- (if trace hits), returns true, TOI, segment points
function meta:TestRay(ox, oy, oz, dx, dy, dz, origin, dir, distToLine)

	distToLine = distToLine or 4

	local x0, y0, z0 = self.x0, self.y0, self.z0
	local x1, y1, z1 = self.x1, self.y1, self.z1

	-- test against entire trace
	local hit, _ = IntersectRayBoxRaw(ox, oy, oz, dx, dy, dz, x0, y0, z0, x1, y1, z1)
	if not hit then return false end

	local points = self.points

	-- test against each segment
	for i=1, #points do

		local point = points[i]
		local x0, y0, z0 = point.x0, point.y0, point.z0
		local x1, y1, z1 = point.x1, point.y1, point.z1

		local hit, t = IntersectRayBoxRaw(ox, oy, oz, dx, dy, dz, x0, y0, z0, x1, y1, z1)

		if hit then

			-- test against a plane oriented towards the ray
			local up = point.normal:Cross( dir )
			local normal = up:Cross( point.normal )
			local toi = IntersectRayPlane(origin, dir, point.pos, normal)

			-- calculate local point of interection on plane
			local pos = origin + dir * toi
			local lpos = pos - point.pos
			local x = lpos:Dot( point.normal )
			local y = lpos:Dot( up )

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

local function ConformLineToSphere( pos, radius, a, b )

	local u = (b-a)
	local o = a
	local c = pos
	local l = u:Length()
	u:Div(l)

	local v = ((u:Dot(o - c)) ^ 2) - ((o - c):LengthSqr() - radius * radius)

	if v < 0 then return false, a, b end
	if v == 0 then return false, a, b end

	local d = -(u:Dot(o - c))

	local root = math.sqrt(v)

	local d0 = math.Clamp(d + root, 0, l)
	local d1 = math.Clamp(d - root, 0, l)

	return true, o + u * d0, o + u * d1

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

	local vmeta = FindMetaTable("Vector")
	local v_distance = vmeta.Distance

	function meta:Draw(color, width, t0, t1, nocull)

		--if true then return end

		local maxDist = 300
		local maxDistSqr = maxDist * maxDist
		local eye = _G.G_EYE_POS

		--_G.G_HOTPATH = _G.G_HOTPATH + 1

		local distCheck = v_distance(eye, self.center) - self.radius
		if distCheck > maxDist and not nocull then
			return
		end

		t0 = t0 or 0
		t1 = t1 or self.length
		color = color or base_trace_color
		width = width or 2

		if t1 < t0 then t0, t1 = t1, t0 end

		for _, point in ipairs( self.points ) do

			local startPos = point.pos
			local endPos = point.next
			local term = point.along + point.len > t1
			local show = true

			if point.along + point.len < t0 then continue end

			if term then
				endPos = startPos + point.normal * (t1 - point.along)
			end

			if t0 > point.along then
				startPos = startPos + point.normal * (t0 - point.along)
			end

			if not nocull then
				show, startPos, endPos = ConformLineToSphere( eye, maxDist, startPos, endPos )
			end

			if show then
				startBeam( 2 )
				addBeam(startPos, width, 0, color)
				addBeam(endPos, width, 0, color)
				endBeam()
			end
			--drawLine(point.pos, point.next)

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

-- Test code
if CLIENT and false then

	local function WPoint(x,y,z)
		local v = {Vector(x,y,z)}
		function v:GetPos() return self[1] end
		return v
	end

	local points = {}
	local traces = {}
	math.randomseed(1)
	for i=1, 31 do
		local x = math.Rand(600, 1000)
		local y = math.Rand(600, 800)
		local z = math.Rand(30,250)
		points[#points+1] = WPoint(x,y,z)
	end

	for i=1, #points-1 do
		traces[#traces+1] = New( points[i], points[i+1] )
	end

	local offset = Quat(0,0,0,1)

	local startRotation = Quat(0,0,0,1)
	local targetRotation = Quat(0,0,0,1)
	local rot = 0
	local running = false
	local preroll = 0
	local prerollTime = 1.1
	local traceID = 1
	local targetPos = Vector(0,0,0)
	local startPos = Vector(0,0,0)
	local travel = 0
	local speed = 130
	hook.Add("CalcView", "iotracetest", function( ply, pos, angles, fov )

		local trace = traces[traceID]
		if running then
			if preroll == prerollTime then
				startRotation:FromAngles(angles)
				startPos = pos
			end

			preroll = math.max(preroll - FrameTime(), 0)


			if preroll > 0 then
				local lerp = ((prerollTime - preroll) / prerollTime)
				local pos, quat = trace:GetPointAlongPath(0)
				local f,r,u = quat:ToVectors()
				targetRotation = startRotation:Slerp(quat, lerp)
				targetPos = LerpVector(lerp, startPos, pos + u * 5)
			else
				travel = travel + speed * FrameTime()
				if travel > trace:GetLength() then
					travel = travel - trace:GetLength()
					traceID = traceID + 1
					trace = traces[traceID]
				end

				if trace ~= nil then
					local pos, quat = trace:GetPointAlongPath(travel)
					targetRotation = targetRotation:Slerp(quat, 1 - math.exp( FrameTime() * -40 ))

					local f,r,u = targetRotation:ToVectors()
					targetPos = pos + u * 5
				else
					running = false
				end
			end

			local view = {}
			view.origin = targetPos
			view.angles = targetRotation:ToAngles()

			return view

		end

		--[[local r = CurTime() * math.pi * 0.1
		local s = math.sin(r)
		local t = CosRange(-30, trace:GetLength() + 30, r)
		local pos,quat = trace:GetPointAlongPath( t )
		local f,r,u = targetRotation:ToVectors()

		if s < 0 then
			offset.w = 1
			offset.z = 0
		else
			offset.w = 0
			offset.z = 1
		end

		rot = rot + FrameTime() * s * 180

		quat = quat:Mult(offset)
		--quat = quat:Mult( Quat():FromAngles( Angle(0,0,rot) ) )

		local view = {}

		targetRotation = targetRotation:Slerp(quat, 1 - math.exp( FrameTime() * -6 ))

		view.origin = pos + u * 5
		view.angles = targetRotation:ToAngles()
		--view.fov = fov + (CurTime() - bus.StartLaunchTime) * 20

		return view]]

	end)

	hook.Add("PostDrawTranslucentRenderables", "iotracetest", function()
		for i=1, #traces do
			traces[i]:Draw()
		end
	end)

	concommand.Add("doit", function()
		surface.PlaySound("the_hackerman_cometh_to_steal_your_IO.mp3")
		running = true
		preroll = prerollTime
		traceID = 1
	end)

end