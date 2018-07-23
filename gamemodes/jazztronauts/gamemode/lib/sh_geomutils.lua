if SERVER then AddCSLuaFile("sh_geomutils.lua") end

function AABBToSphere( mins, maxs )

	local center = (mins + maxs) / 2
	local diagonal = (maxs - mins):Length()

	return center, diagonal / 2

end

local meta = {}
meta.__index = meta

function Vector4(x,y,z,w) return setmetatable({ x = x, y = y, z = z, w = w }, meta) end

function meta:Dot(vec, w)

	if isvector( vec ) then
		w = w or 1
		return vec.x * self.x + vec.y * self.y + vec.z * self.z + w * self.w
	elseif getmetatable( vec ) == meta then
		return vec.x * self.x + vec.y * self.y + vec.z * self.z + vec.w * self.w
	end

end

local meta = {}
meta.__index = meta

function TexMatrix(s, t) return setmetatable({ s = s, t = t }, meta) end

function meta:GetUV(vec)

	return self.s:Dot(vec), self.t:Dot(vec)

end

function Plane(x,y,z,dist)

	local p = nil
	if isvector(x) then
		p = { normal = Vector(x), dist = y or 0, type = z }
	else
		p = { normal = Vector(x,y,z), dist = dist }
	end

	p.back = { normal = p.normal * -1, dist = -p.dist, back = p, type = p.type }
	return p

end

local _saabbcenter = Vector(0,0,0)
local _saabbextent = Vector(0,0,0)
function TestBoxPlane( plane, mins, maxs, expand )

	_saabbcenter:Set( mins )
	_saabbcenter:Add( maxs )
	_saabbcenter:Mul( .5 )

	_saabbextent:Set( maxs )
	_saabbextent:Sub( _saabbcenter )

	local absNormal = Vector(plane.normal)
	absNormal.x = math.abs(absNormal.x)
	absNormal.y = math.abs(absNormal.y)
	absNormal.z = math.abs(absNormal.z)

	local x = _saabbextent:Dot(absNormal) + ( expand or 0 )
	local d = _saabbcenter:Dot(plane.normal) - plane.dist

	if math.abs(d) < x then return 0 end
	if d > x then return 1 end
	return -1

end

local boundsMin = Vector( 99999, 99999, 99999 )
local boundsMax = Vector( -99999, -99999, -99999 )
function ResetBoundingBox(min,max)
	min:Set( boundsMin )
	max:Set( boundsMax )
	return min, max
end

function AddPointToBoundingBox(point,min,max)

	for i=1, 3 do
		min[i] = math.min(min[i], point[i])
		max[i] = math.max(max[i], point[i])
	end

end