if SERVER then AddCSLuaFile("sh_camera.lua") end
if SERVER then return end

Camera = nil
IsCamera = nil

module( "camera", package.seeall )

local meta = {}
meta.__index = meta

IsCamera = function(camera)

	return getmetatable(camera) == meta

end

function meta:Init( pos, angle, fov, near, far )

	self.pos = pos or EyePos()
	self.angle = angle or EyeAngles()
	self.fov = fov or nil
	self.near = near or nil
	self.far = far or nil

	return self

end

function meta:Start3D( rect )

	if not IsRect(rect) then error("Expected Rectangle") end

	local x,y,w,h = rect:Unpack()
	cam.Start3D( self.pos, self.angle, self.fov, x, y, w, h )

end

function meta:End3D()

	cam.End3D()

end

function New(...)

	return setmetatable({}, meta):Init(...)

end

_G["Camera"] = New