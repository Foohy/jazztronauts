AddCSLuaFile()

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

local meta = {}
meta.__index = meta

function meta:Init(from, to)

	self.from = from
	self.to = to
	self:BuildPath()
	self:ComputeBounds()

	return self

end

function meta:BuildPath()

	self.points = {}

	local base = self.from:GetPos()
	local target = self.to:GetPos()
	local length = 0
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
			next = base + dir,
		}
		base = base + dir

		if base:Distance( target ) < 1 then break end

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

end

function meta:ComputeBounds()

	local min = Vector(0,0,0)
	local max = Vector(0,0,0)

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

	end

	-- expand main bounding box by 5
	local expand = 5
	for i=1, 3 do
		min[i] = min[i] - expand
		max[i] = max[i] + expand
	end

	self.min = min
	self.max = max

end

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

function meta:Draw()

	for i=1, #self.points do

		gfx.renderBeam(self.points[i].pos, self.points[i].next, nil, nil, 5)

	end

end

function New(from, to)

	return setmetatable({}, meta):Init(from, to)

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