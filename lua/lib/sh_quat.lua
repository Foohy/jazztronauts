if SERVER then AddCSLuaFile("sh_quat.lua") end

local quat = {}

function IsQuat( v )
	return getmetatable(v) == quat
end

function Quat(vx,vy,vz,vw)
	return setmetatable( {
		x = vx or 0,
		y = vy or 0,
		z = vx or 0,
		w = vw or 0,
	}, quat )
end

Quaternion = Quat

function quat.__index(self, i)

	if type(i) == "number" then
		if i == 1 then return self.x end
		if i == 2 then return self.y end
		if i == 3 then return self.z end
		if i == 4 then return self.w end
	else
		local g = rawget(self, i)
		if g then return g end

		return rawget(quat, i)
	end

end

function quat.__newindex(self, i, n)

	if type(i) == "number" then
		if i == 1 then self.x = n end
		if i == 2 then self.y = n end
		if i == 3 then self.z = n end
		if i == 4 then self.w = n end
	else
		rawset(self, i, n)
	end

end

function quat.__eq(a, b)

	return (a.x == b.x) and (a.y == b.y) and (a.z == b.z) and (a.w == b.w)

end

function quat:Conjugate(dst)

	dst = dst or Quaternion()

	dst.x = -self.x;
	dst.y = -self.y;
	dst.z = -self.z;
	dst.w = self.w;

	return dst

end

function quat:Invert(dst)

	dst = dst or Quaternion()

	self:Conjugate(dst)
	local magnitudeSqr = self:Dot(self);
	if magnitudeSqr ~= 0 then
		local inv = 1.0 / magnitudeSqr;
		dst.x = dst.x * inv;
		dst.y = dst.y * inv;
		dst.z = dst.z * inv;
		dst.w = dst.w * inv;
	end

	return dst

end

function quat:Normalize()

	local radius = self:Dot(self)
	if radius ~= 0 then
		radius = math.sqrt(radius);
		local iradius = 1.0/radius;
		self.x = self.x * iradius;
		self.y = self.y * iradius;
		self.z = self.z * iradius;
		self.w = self.w * iradius;
	end
	return radius

end

function quat:QuaternionAlign( q, dst )

	dst = dst or Quaternion()

	local p = self

	local a = 0;
	local b = 0;
	local i = 0;

	for i = 1, 4 do
		a = a + (p[i]-q[i])*(p[i]-q[i]);
		b = b + (p[i]+q[i])*(p[i]+q[i]);
	end

	if a > b then
		for i = 1, 4 do
			dst[i] = -q[i];
		end
	elseif dst ~= q then
		for i = 1, 4 do
			dst[i] = q[i];
		end
	end

	return dst

end

function quat:Add(other)

	local q2 = self:QuaternionAlign( other );

	self.x = self.x + q2.x;
	self.y = self.y + q2.y;
	self.z = self.z + q2.z;
	self.w = self.w + q2.w;

	return self

end

function quat:Mult( other, dst )

	dst = dst or Quaternion()

	local p = self
	local q2 = self:QuaternionAlign( other );
	local qt = dst

	qt.x =  p.x * q2.w + p.y * q2.z - p.z * q2.y + p.w * q2.x;
	qt.y = -p.x * q2.z + p.y * q2.w + p.z * q2.x + p.w * q2.y;
	qt.z =  p.x * q2.y - p.y * q2.x + p.z * q2.w + p.w * q2.z;
	qt.w = -p.x * q2.x - p.y * q2.y - p.z * q2.z + p.w * q2.w;

	return dst

end

function quat:AngleDiff( other )

	local qInv = other:Conjugate()
	local diff = Quaternion()
	self:Mult( qInv, diff )

	local sinang = math.sqrt( diff.x * diff.x + diff.y * diff.y + diff.z * diff.z )
	local angle = ( 2 * math.asin( sinang ) ) * 57.3
	return angle

end

function quat:Dot(b)

	local a = self
	return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w

end

function quat:Blend( other, t, dst )

	other = self:QuaternionAlign( other )

	local qt = dst or Quaternion()
	local sclp = 1.0 - t
	local sclq = t
	for i=1, 4 do
		qt[i] = sclp * self[i] + sclq * other[i]
	end

	qt:Normalize()

	return qt

end

function quat:Slerp( other, t, dst )

	local omega = 0
	local cosom = 0
	local sinom = 0
	local sclp = 0
	local sclq = 0

	other = self:QuaternionAlign( other );

	local qt = dst or Quaternion()
	local cosom = self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w;

	if (1.0 + cosom) > 0.000001 then
		if (1.0 - cosom) > 0.000001 then
			omega = math.acos( cosom );
			sinom = math.sin( omega );
			sclp = math.sin( (1.0 - t)*omega) / sinom;
			sclq = math.sin( t*omega ) / sinom;
		else
			sclp = 1.0 - t;
			sclq = t;
		end
		for i=1, 4 do
			qt[i] = sclp * self[i] + sclq * other[i];
		end
	else
		qt[1] = -other[2]
		qt[2] = other[1]
		qt[3] = -other[4]
		qt[4] = other[3]

		sclp = math.sin( (1.0 - t) * (0.5 * math.pi))
		sclq = math.sin( t * (0.5 * math.pi))
		for i=1, 4 do
			qt[i] = sclp * self[i] + sclq * other[i];
		end
	end

	return qt

end

local _iangles = Angle(0,0,0)

function quat:FromAngles(angles)

	_iangles.p = angles.p * DEG_2_RAD
	_iangles.y = angles.y * DEG_2_RAD
	_iangles.r = angles.r * DEG_2_RAD

	angles = _iangles

	local sp = math.sin(angles.p * 0.5)
	local cp = math.cos(angles.p * 0.5)

	local sy = math.sin(angles.y * 0.5)
	local cy = math.cos(angles.y * 0.5)

	local sr = math.sin(angles.r * 0.5)
	local cr = math.cos(angles.r * 0.5)

	local srXcp = sr * cp
	local crXsp = cr * sp

	self.x = srXcp*cy-crXsp*sy; // X
	self.y = crXsp*cy+srXcp*sy; // Y

	local crXcp = cr * cp
	local srXsp = sr * sp;

	self.z = crXcp*sy-srXsp*cy; // Z
	self.w = crXcp*cy+srXsp*sy; // W (real component)

	return self

end

function quat:FromVectors(forward, right, up)

	local trace = forward.x + right.y + up.z + 1.0
	if trace > 1.0000001 then
		self.x = right.z - up.y
		self.y = up.x - forward.z
		self.z = forward.y - right.x
		self.w = trace
	elseif forward.x > right.y and forward.x > up.z then
		trace = 1.0 + forward.x - right.y - up.z;
		self.x = trace;
		self.y = forward.y + right.x
		self.z = up.x + forward.z
		self.w = right.z - up.y
	elseif right.y > up.z then
		trace = 1.0 + right.y - forward.x - up.z;
		self.x = right.x + forward.y;
		self.y = trace;
		self.z = right.z + up.y;
		self.w = up.x - forward.z;
	else
		trace = 1.0 + up.z - forward.x - right.y;
		self.x = up.x + forward.z;
		self.y = right.z + up.y;
		self.z = trace;
		self.w = forward.y - right.x;
	end

	self:Normalize()
	return self

end

function quat:ToVectors(forward, right, up)

	forward = forward or Vector()
	right = right or Vector()
	up = up or Vector()
	local q = self

	forward.x = 1.0 - 2.0 * q.y * q.y - 2.0 * q.z * q.z;
	forward.y = 2.0 * q.x * q.y + 2.0 * q.w * q.z;
	forward.z = 2.0 * q.x * q.z - 2.0 * q.w * q.y;

	right.x = 2.0 * q.x * q.y - 2.0 * q.w * q.z;
	right.y = 1.0 - 2.0 * q.x * q.x - 2.0 * q.z * q.z;
	right.z = 2.0 * q.y * q.z + 2.0 * q.w * q.x;

	up.x = 2.0 * q.x * q.z + 2.0 * q.w * q.y;
	up.y = 2.0 * q.y * q.z - 2.0 * q.w * q.x;
	up.z = 1.0 - 2.0 * q.x * q.x - 2.0 * q.y * q.y;

	return forward, right, up

end

local _staticR1 = Quaternion()
local _staticRDST = Quaternion()

function quat:RotateAroundAxis(axis, angle)

	local q = _staticR1:FromAxis( axis, angle * DEG_2_RAD )
	q = self:Mult(q, _staticRDST)

	self.x = q.x
	self.y = q.y
	self.z = q.z
	self.w = q.w

end

local _vectorForward = Vector(1,0,0)
local _vectorRight = Vector(0,1,0)
local _vectorUp = Vector(0,0,1)

function quat:Rotate(angle)

	self:RotateAroundAxis(_vectorForward, angle.r)
	self:RotateAroundAxis(_vectorRight, angle.p)
	self:RotateAroundAxis(_vectorUp, angle.y)

end

local _tempVForward = Vector(0,0,0)
local _tempVRight = Vector(0,0,0)
local _tempVUp = Vector(0,0,0)

function quat:ToAngles()

	self:ToVectors(
		_tempVForward,
		_tempVRight,
		_tempVUp)

	return BasisToAngles(_tempVForward, _tempVRight, _tempVUp)

end

function quat:RotateVector(v)

	local vn = v:GetNormal()
	local vq = Quaternion(vn.x, vn.y, vn.z)

	local conjugate = self:Conjugate()
	local res = Quaternion()
	vq:Mult( conjugate, res )
	self:Mult( res, res )

	return Vector( res.x, res.y, res.z )

end

function quat:FromAxis(vector, angle)

	angle = angle * 0.5

	local sinAngle = math.sin(angle)

	self.x = vector.x * sinAngle
	self.y = vector.y * sinAngle
	self.z = vector.z * sinAngle
	self.w = math.cos(angle)

	return self

end

function quat:ToAxis()

	local axis = Vector()
	local angle = (2 * math.acos(self.w)) * 57.3;
	if angle > 180 then
		angle = angle - 360
	end
	axis.x = self.x;
	axis.y = self.y;
	axis.z = self.z;
	axis:Normalize()

	return axis, angle

end

local _staticConjugate = Quaternion()
local _staticQ1 = Quaternion()
local _staticQ2 = Quaternion()
local _staticQ3 = Quaternion()

function GetAngleDifference(a, b, q)

	_staticQ1:FromAngles(a)
	_staticQ2:FromAngles(b)

	_staticQ1:Conjugate(_staticConjugate)
	_staticConjugate:Mult(_staticQ2, _staticQ3)

	if q then
		q.x = _staticQ3.x
		q.y = _staticQ3.y
		q.z = _staticQ3.z
		q.w = _staticQ3.w
	end

	return BasisToAngles(_staticQ3:ToVectors())

end