if SERVER then AddCSLuaFile("sh_rect.lua") end

Rect = nil
Box = nil
IsBox = nil
IsRect = nil
TextRect = nil

DOCK_LEFT = 0x1
DOCK_RIGHT = 0x2
DOCK_TOP = 0x4
DOCK_BOTTOM = 0x8
DOCK_CENTER = 0x10

local DOCK_X = bit.bor( DOCK_LEFT, DOCK_RIGHT )
local DOCK_Y = bit.bor( DOCK_TOP, DOCK_BOTTOM )

local rmeta = {}
rmeta.__index = rmeta

local bmeta = {}
bmeta.__index = bmeta

function rmeta:Inset(m)

	self.x = self.x + m
	self.y = self.y + m
	self.w = self.w - m * 2
	self.h = self.h - m * 2
	return self

end
function bmeta:Inset(m)

	self.x0 = self.x0 + m
	self.y0 = self.y0 + m
	self.x1 = self.x1 - m
	self.y1 = self.y1 - m
	return self

end

function rmeta:ScreenScale() self.w = ScreenScale(self.w) self.h = ScreenScale(self.h) return self end

function rmeta:GetCenter() return self.x + self.w / 2, self.y + self.h / 2 end
function bmeta:GetCenter() return (self.x0 + self.x1) / 2, (self.y0 + self.y1) / 2 end

function rmeta:Move(x,y) self.x = self.x + x self.y = self.y + y return self end
function bmeta:Move(x,y) self.x0 = self.x0 + x self.y0 = self.y0 + y self.x1 = self.x1 + x self.y1 = self.y1 + y return self end

function rmeta:GetMin() return self.x, self.y end
function rmeta:GetMax() return self.x + self.w, self.y + self.h end

function rmeta:SetMin(x,y)
	self.w = math.max( self.w - ( x - self.x ), 0 )
	self.h = math.max( self.h - ( y - self.h ), 0 )
	self.x = x
	self.y = y
end

function rmeta:SetMax(x,y)
	self.w = math.max( x - self.x, 0 )
	self.h = math.max( y - self.y, 0 )
end

function bmeta:GetMin() return self.x0, self.y0 end
function bmeta:GetMax() return self.x1, self.y1 end

function bmeta:SetMin(x,y) self.x0 = x self.y0 = y end
function bmeta:SetMax(x,y) self.x1 = x self.y1 = y end

function rmeta:GetSize() return self.w, self.h end
function bmeta:GetSize() return self.x1 - self.x0, self.y1 - self.y0 end

function rmeta:Unpack(...) return self.x, self.y, self.w, self.h, ... end
function bmeta:Unpack(...) return self.x0, self.y0, self.x1, self.y1, ... end

local function SetClip( a, enable )

	local a_minx, a_miny = a:GetMin()
	local a_maxx, a_maxy = a:GetMax()

	render.SetScissorRect( a_minx, a_miny, a_maxx, a_maxy, enable )

end

rmeta.SetClip = SetClip
bmeta.SetClip = SetClip

local function Clamp( a, b )

	if not IsBox(a) and not IsRect(a) then return end
	if not IsBox(b) and not IsRect(b) then return end

	local a_minx, a_miny = a:GetMin()
	local a_maxx, a_maxy = a:GetMax()
	local b_minx, b_miny = b:GetMin()
	local b_maxx, b_maxy = b:GetMax()

	if a_minx < b_minx then a:SetMin( b_minx, a_miny ) end
	if a_miny < b_miny then a:SetMin( a_minx, b_miny ) end

	if a_maxx > b_maxx then a:SetMax( b_maxx, a_maxy ) end
	if a_maxy > b_maxy then a:SetMax( a_maxx, b_maxy ) end

	return a

end

rmeta.Clamp = Clamp
bmeta.Clamp = Clamp

local function Remap( a, b, x, y, clamped )

	if not IsBox(a) and not IsRect(a) then return end
	if not IsBox(b) and not IsRect(b) then return end

	local a_minx, a_miny = a:GetMin()
	local a_maxx, a_maxy = a:GetMax()
	local b_minx, b_miny = b:GetMin()
	local b_maxx, b_maxy = b:GetMax()

	local remap_x = ((x - a_minx) / (a_maxx - a_minx))
	local remap_y = ((y - a_miny) / (a_maxy - a_miny))

	if clamped then
		remap_x = math.max( math.min( remap_x, 1 ), 0 )
		remap_y = math.max( math.min( remap_y, 1 ), 0 )
	end

	return
		remap_x * (b_maxx - b_minx) + b_minx,
		remap_y * (b_maxy - b_miny) + b_miny

end

rmeta.Remap = Remap
bmeta.Remap = Remap

--moves 'a' to dock into 'b'
local function Dock( a, b, mode )

	if not IsBox(a) and not IsRect(a) then return end
	if not IsBox(b) and not IsRect(b) then return end

	local a_minx, a_miny = a:GetMin()
	local a_maxx, a_maxy = a:GetMax()
	local a_ctrx, a_ctry = a:GetCenter()
	local b_minx, b_miny = b:GetMin()
	local b_maxx, b_maxy = b:GetMax()
	local b_ctrx, b_ctry = b:GetCenter()
	local move_x = 0
	local move_y = 0

	if mode == DOCK_CENTER then
		move_x = b_ctrx - a_ctrx
		move_y = b_ctry - a_ctry
	else

		if bit.band( mode, DOCK_LEFT ) ~= 0 then
			move_x = move_x - (a_minx - b_minx)
		elseif bit.band( mode, DOCK_RIGHT ) ~= 0 then
			move_x = move_x - (a_maxx - b_maxx)
		end

		if bit.band( mode, DOCK_TOP ) ~= 0 then
			move_y = move_y - (a_miny - b_miny)
		elseif bit.band( mode, DOCK_BOTTOM ) ~= 0 then
			move_y = move_y - (a_maxy - b_maxy)
		end

		if bit.band( mode, DOCK_CENTER ) ~= 0 then
			if bit.band( mode, DOCK_X ) ~= 0 then
				move_y = b_ctry - a_ctry
			elseif bit.band( mode, DOCK_Y ) ~= 0 then
				move_x = b_ctrx - a_ctrx
			end
		end

	end

	a:Move( move_x, move_y )
	return a

end

rmeta.Dock = Dock
bmeta.Dock = Dock

local function ContainsPoint(self,x,y)

	local minx, miny = self:GetMin()
	local maxx, maxy = self:GetMax()

	if x < minx or x > maxx then return false end
	if y < miny or y > maxy then return false end
	return true

end

rmeta.ContainsPoint = ContainsPoint
bmeta.ContainsPoint = ContainsPoint

IsRect = function(rect) return getmetatable(rect) == rmeta end
IsBox = function(box) return getmetatable(box) == bmeta end

TextRect = function(text, font)

	surface.SetFont( font or "DermaDefault" )
	local w,h = surface.GetTextSize( text )

	return Rect(0,0,w,h)

end

Rect = function(x,y,w,h)

	if x == "screen" then
		x = 0
		y = 0
		w = ScrW()
		h = ScrH()
	elseif IsRect(x) then
		local rect = x
		x = rect.x
		y = rect.y
		w = rect.w
		h = rect.h
	elseif IsBox(x) then
		local box = x
		x = box.x0
		y = box.y0
		w = box.x1 - box.x0
		h = box.y1 - box.y0
	end

	w = math.max(w, 0)
	h = math.max(h, 0)

	return setmetatable({x=x,y=y,w=w,h=h}, rmeta)

end

Box = function(x0,y0,x1,y1)

	if x0 == "screen" then
		return Box( Rect(x0) )
	elseif IsRect(x0) then
		local rect = x0
		x0 = rect.x
		y0 = rect.y
		x1 = x0 + rect.w
		y1 = y0 + rect.h
	elseif IsBox(x0) then
		local box = x0
		x0 = box.x0
		y0 = box.y0
		x1 = box.x1
		y1 = box.y1
	end

	x1 = math.max(x0, x1)
	y1 = math.max(y0, y1)

	return setmetatable({x0=x0,y0=y0,x1=x1,y1=y1}, bmeta)

end