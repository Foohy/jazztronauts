if SERVER then AddCSLuaFile("sh_space.lua") end

local meta = {}
meta.__index = meta

function meta:Identity()
	self.forward.x = 1
	self.forward.y = 0
	self.forward.z = 0

	self.right.x = 0
	self.right.y = 1
	self.right.z = 0

	self.up.x = 0
	self.up.y = 0
	self.up.z = 1
	return self
end

function meta:FromEntity(e)
	self.forward = e:GetForward()
	self.right = e:GetRight()
	self.up = e:GetUp()
	self:SetPos(e:GetPos())
	return self
end

function meta:Rotate(angle)
	self.forward:Rotate(angle)
	self.right:Rotate(angle)
	self.up:Rotate(angle)
end

function meta:SetPos(pos)
	self.origin.x = pos.x
	self.origin.y = pos.y
	self.origin.z = pos.z
end

function meta:SetAngles(angle)
	self.forward = angle:Forward()
	self.right = angle:Right()
	self.up = angle:Up()
	return self
end

function meta:GetAngles()
	return BasisToAngles(self.forward, self.right, self.up)
end

--Project a point onto a plane
function meta:ProjectPoint(origin)
	local a = (self.origin - origin):Dot(self.up)
	local b = self.up:Dot(self.up)
	local c = a / b
	local v = origin + self.up * c

	return v, c
end

--Project a vector onto a plane
function meta:ProjectVector(origin, normal)
	local a = (self.origin - origin):Dot(self.up)
	local b = normal:Dot(self.up)
	local c = a / b
	local v = origin + normal * c

	return v, c
end

function meta:GetX(origin) return (origin - self.origin):Dot(self.forward) end
function meta:GetY(origin) return (origin - self.origin):Dot(self.right) end
function meta:GetZ(origin) return (origin - self.origin):Dot(self.up) end

function meta:WorldToLocal(origin)
	local v = origin - self.origin
	local f = v:Dot(self.forward)
	local r = v:Dot(self.right)
	local u = v:Dot(self.up)

	return Vector(f,r,u)
end

function meta:LocalToWorld(origin)
	local v = self.origin
	v = v + origin.x * self.forward
	v = v + origin.y * self.right
	v = v + origin.z * self.up

	return v
end

function meta:CalcZRot()
	local r = self.up:Angle():Right()
	local theta = self.right:Dot(r)
	local cross = self.right:Cross(r):Dot(self.up)

	if theta > 1.0 or theta < -1.0 then theta = 180
	else theta = math.acos(theta) * 57.3 end
	if cross >= 0 then return -theta end

	return theta
end

function meta:CalcYRot()
	local r = self.right:Angle():Up()
	local theta = self.up:Dot(r)
	local cross = self.up:Cross(r):Dot(self.right)

	if theta > 1.0 or theta < -1.0 then theta = 180
	else theta = math.acos(theta) * 57.3 end
	if cross >= 0 then return -theta end

	return theta
end

function meta:IsInFront(origin)
	return self:GetZ(origin) >= 0
end

function meta:IsFacing(vector)
	return vector:Dot(self.up) < 0
end

function Space(origin)
	return setmetatable( {
		origin = origin or Vector(0,0,0),
		forward = Vector(1,0,0),
		right = Vector(0,1,0),
		up = Vector(0,0,1),
	}, meta )
end