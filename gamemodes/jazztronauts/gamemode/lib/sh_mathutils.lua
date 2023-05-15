if SERVER then AddCSLuaFile("sh_mathutils.lua") end

--Constants
LOG_2		= 0.6931471805599
PI			= 3.1415926535898 --180 degrees
PI_OVER_2	= 1.5707963267949 --90 degrees
DEG_2_RAD	= PI / 180 --degrees * DEG_2_RAD = radians
RAD_2_DEG	= 180 / PI --radians * RAD_2_DEG = degrees
EPSILON	= 0.00001

--Convert orthonormal basis into an euler tuple
function BasisToAngles(forward, right, up)

	local xyDist = math.sqrt( forward.x * forward.x + forward.y * forward.y );
	local angle = Angle()

	if xyDist > 0.001 then
		angle.y = math.atan2( forward.y, forward.x ) * 57.3
		angle.p = math.atan2( -forward.z, xyDist ) * 57.3
		angle.r = math.atan2( right.z, up.z ) * 57.3
	else
		angle.y = math.atan2( -right.x, right.y ) * 57.3
		angle.p = math.atan2( -forward.z, xyDist ) * 57.3
		angle.r = 0
	end

	return angle

end

--Convert an euler tuple into an orthonormal basis
function AnglesToBasis(angle)

	local v1 = Vector(1,0,0)
	local v2 = Vector(0,1,0)
	local v3 = Vector(0,0,1)

	v1:Rotate(angle)
	v2:Rotate(angle)
	v3:Rotate(angle)

	return v1, v2, v3

end

--Rounds a value to zero based on threshold
function RoundToZero( value, threshold )

	threshold = threshold or EPSILON

	if math.abs(value) < threshold then value = 0 end
	return value

end

--Returns the average of an amount of numbers of a table
function Average( nums )

	if type( nums ) ~= "table" then return end

	local total = #nums
	local sum = 0

	for i=0, total do
		sum = sum + tonumber( nums[i] )
	end

	return sum / total

end

--Sine function ranging between min and max
function SinRange( min, max, theta )

	return min + (.5 * math.sin(theta) + .5) * ( max - min )

end

--Cosine function ranging between min and max
function CosRange( min, max, theta )

	return min + (.5 * math.cos(theta) + .5) * ( max - min )

end

--Take the given number to the largest power of two
function PowerOfTwo(n)

	return math.pow(2, math.ceil(math.log(n) / LOG_2))

end

--[a1 --v-- a2]
--[b1 -------v------ b2]
--Map v from 'a' range to 'b' range
function Remap(v, a1, a2, b1, b2)
	local a = (v - a1) / (a2 - a1)
	return a * (b2 - b1) + b1
end

--Wrap the value 'a' between 'min' and 'max'
--Default wraps between 0 and 1
function Wrap(a, min, max)
	min = min or 0
	max = max or 1
	return math.fmod(a, ( max - min ) ) + min
end

--Quadratic bezier curve thru a,b,c by coefficient 't'
function Quadratic(a, b, c, t)
	local mt = 1 - t
	local c1 = (mt * a + t * b)
	local c2 = (mt * b + t * c)
	return mt * c1 + t * c2
end

--Cubic bezier curve thru a,b,c,d by coefficient 't'
function Cubic(a, b, c, d, t)
	local mt = 1 - t
	local mts = mt ^ 2
	local c1 = (mt * mts) * a
	local c2 = (3*mts) * t * b
	local c3 = (3*mts) * t * c
	local c4 = (t ^ 3) * d
	return c1 + c2 + c3 + c4
end

--Cubic hermite spline thru p0 and p1 by coefficient 't'
function CubicHermite(p0, p1, m0, m1, t)
	local tS = t*t;
	local tC = tS*t;

	return (2*tC - 3*tS + 1)*p0 + (tC - 2*tS + t)*m0 + (-2*tC + 3*tS)*p1 + (tC - tS)*m1
end

--Lerp colors
function LerpColor(c0, c1, f, out)
	out = out or Color(0,0,0,0)
	out.r = c0.r + (c1.r - c0.r) * f
	out.g = c0.g + (c1.g - c0.g) * f
	out.b = c0.b + (c1.b - c0.b) * f
	out.a = c0.a + (c1.a - c0.a) * f
	return out
end

function MulAlpha(color, a)
	return Color(color.r, color.g, color.b, color.a * a)
end

local function fit(x)
	return 1 - 0.5*x + 0.1665831*x^2 - 0.04136174*x^3 + 0.007783141*x^4 - 0.0008936082*x^5
end

function Bounce(t, speed, decay, fdecay, upshot)
	local decay = math.max(decay or 1.6, 0.0001)
	speed = speed or 1.0 / 4.0
	local freqDecay = math.Clamp(fdecay or .6, 0.0001, 2.0)
	local coef = 1 / fit(freqDecay)

	if not upshot then t = t + speed * .5 end --upshot
	local root = speed / (speed - freqDecay * t / coef)

	if root < 0 then return 0 end

	local idf = 1.0 / freqDecay
	local i = math.floor(math.log(root) * idf)
	local duration = speed / math.exp( i * freqDecay )
	local offset = idf * coef * speed * (1 - math.exp( -i * freqDecay ))
	local amplitude = 1 / math.exp(i * decay)

	t = ( t - offset ) / duration
	--t = t - offset / duration
	return t * ( 1 - t ) * 4 * amplitude
end

-- Local functions to reduce indexing churn
local __vtab = FindMetaTable("Vector")
local __vset = __vtab.Set
local __vadd = __vtab.Add
local __vsub = __vtab.Sub
local __vdot = __vtab.Dot
local __vmul = __vtab.Mul
local __vlensqr = __vtab.LengthSqr
local __vdistsqr = __vtab.DistToSqr
local __vnorm = __vtab.Normalize
local __vunpack = __vtab.Unpack
local __vsetunpacked = __vtab.SetUnpacked

local fmax = math.max
local fmin = math.min
function IntersectRayBox(origin, dir, min, max)

	local x0,y0,z0 = __vunpack(min)
	local x1,y1,z1 = __vunpack(max)
	local ox,oy,oz = __vunpack(origin)
	local dx,dy,dz = __vunpack(dir)

	dx = 1/dx
	dy = 1/dy
	dz = 1/dz

	local t0 = (x0 - ox) * dx
	local t1 = (x1 - ox) * dx
	local t2 = (y0 - oy) * dy
	local t3 = (y1 - oy) * dy
	local t4 = (z0 - oz) * dz
	local t5 = (z1 - oz) * dz

	local tmin =
	fmax(
		fmax(
			fmin(t0,t1),
			fmin(t2,t3)
		),
		fmin(t4,t5)
	)

	local tmax =
	fmin(
		fmin(
			fmax(t0,t1),
			fmax(t2,t3)
		),
		fmax(t4,t5)
	)

	if tmax < 0 then return false end
	if tmin > tmax then return false end

	return true, tmin

end

-- Transform the given normal into the coordinate space of the given matrix
local function TransformNormal( mtx, normal )

	local A00, A01, A02, A03,
		  A10, A11, A12, A13,
		  A20, A21, A22, A23,
		  A30, A31, A32, A33 = mtx:Unpack()

	local x,y,z = normal:Unpack()

	return Vector(
		A00 * x + A01 * y + A02 * z,
		A10 * x + A11 * y + A12 * z,
		A20 * x + A21 * y + A22 * z
	)

end

-- Returns the normal of the given triangle vertices
-- Note: this returns a shared vector
local __vtemp = Vector()
local __vtemp2 = Vector()
local __vtemp3 = Vector()
local function TriNormal(a,b,c)

	__vset(__vtemp, a)
	__vsub(__vtemp, b)
	__vset(__vtemp2, c)
	__vsub(__vtemp2, a)

    -- Cross-product creates a vector (more GC), do it manually here
    local a1,a2,a3 = __vunpack(__vtemp)
    local b1,b2,b3 = __vunpack(__vtemp2)

    __vsetunpacked(__vtemp3,
        a2 * b3 - a3 * b2,
        a3 * b1 - a1 * b3,
        a1 * b2 - a2 * b1
    )

	__vnorm(__vtemp3)
	return __vtemp3

end

-- Calculates the Barycentric coordinates of a point within a triangle
local __vedge1 = Vector()
local __vedge2 = Vector()
local __vedge3 = Vector()
local function TriBarycentric(a,b,c,point)

    __vset(__vedge1, b)
    __vsub(__vedge1, a)
    __vset(__vedge2, c)
    __vsub(__vedge2, a)
    __vset(__vedge3, point)
    __vsub(__vedge3, a)
	local v0 = __vedge1
	local v1 = __vedge2
	local v2 = __vedge3
	local d00 = __vdot(v0, v0)
	local d01 = __vdot(v0, v1)
	local d11 = __vdot(v1, v1)
	local d20 = __vdot(v2, v0)
	local d21 = __vdot(v2, v1)
	local denom = d00 * d11 - d01 * d01
	if denom == 0 then return 0,0,0 end

    local idenom = 1 / denom
	local v = (d11 * d20 - d01 * d21) * idenom
	local w = (d00 * d21 - d01 * d20) * idenom
	local u = 1.0 - v - w
	return u,v,w

end

-- Computes the time-of-intersection of a ray v plane
-- Not using util.IntersectRayWithPlane because it creates a new Vector (GC)
-- and this gets called a lot.
local __vraytemp = Vector()
local function RayIntersectPlane( normal, origin, p, dir )

	local d = __vdot(normal, dir)
	if d < -0.0001 then

        __vset(__vraytemp, origin)
        __vsub(__vraytemp, p)
		t = __vdot(__vraytemp, normal) / d
		return t >= 0, t

	end

	return false

end

-- Computes the intersection between a ray and a single triangle
-- Returns the hit position and its Barycentric coordinates
local __eptemp = Vector()
function RayIntersectIndexedTriangle( indices, positions, i, p, dir )

	local A = positions[ indices[i] ]
	local B = positions[ indices[i+1] ]
	local C = positions[ indices[i+2] ]

    -- Compute the triangle normal, early-out if facing wrong way
	local N = TriNormal(A,B,C)
	if __vdot(N, dir) > 0 then return false end

    -- Compute plane intersection against plane triangle sits on
	local check, t = RayIntersectPlane( N, A, p, dir )
	if not check then return false end

    -- ep = p + dir * t
    __vset(__eptemp, dir)
    __vmul(__eptemp, t)
    __vadd(__eptemp, p)
    local ep = __eptemp

    -- Compute Barycentric coordinates of hit point
    local u,v,w = TriBarycentric(A, B, C, ep)

    -- If Barycentric coordinates rest outside of triangle, it's not a hit
    if u == 0 and v == 0 and w == 0 then return false end
    if u < 0 or u > 1 or v < 0 or v > 1 or w < 0 or w > 1 then return false end

    return true, t, __eptemp, N, u,v,w

end
