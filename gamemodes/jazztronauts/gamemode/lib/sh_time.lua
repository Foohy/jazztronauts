AddCSLuaFile()

module("jtime", package.seeall)

local tm_meta = {}
tm_meta.__index = tm_meta

local t_meta = {}
t_meta.__index = t_meta
t_meta.__call = function( self, ... )

	return self:FromStart( ... )

end

function tm_meta:Init()

	self.funcs = {}
	self.count = 0
	return self

end

function tm_meta:Update()

	local ft = FrameTime()
	for func, _ in pairs(self.funcs) do
		func( ft )
	end

end

function tm_meta:GetCount()

	return self.count

end

function t_meta:Init()

	return self

end

function t_meta:Range( start, stop, normalized )

	if start < 0 and self.limit then start = self.limit + start end
	if stop < 0 and self.limit then stop = self.limit + stop end

	local x = math.max(self.time.v - start, 0)
	if stop then x = math.min(x, stop) end
	if normalized then return math.max( math.min( x / (stop - start), 1 ), 0) end

end

function t_meta:FromStart( clamp, divisor )

	local x = clamp and math.max(self.time.v, 0) or self.time.v
	if divisor then x = math.min(x / divisor, 1) end
	return x

end

function t_meta:FromEnd( clamp, divisor )

	local x = clamp and math.max(self.limit - self.time.v, 0) or (self.limit - self.time.v)
	if divisor then x = math.min(x / divisor, 1) end
	return x

end

function t_meta:Normalized()

	if not self.limit then return self:FromStart() end
	return math.min( math.max(self.time.v, 0) / self.limit, 1 )

end

function t_meta:Time( f )

	if not f then return self.time.v end
	self.time.v = f
	return self

end

function t_meta:Rate( f )

	if not f then return self.time.r end
	self.time.r = f
	return self

end

function t_meta:Bound( f )

	if not f then return self.limit end
	self.limit = f
	return self

end


function TickManager()

	return setmetatable({}, tm_meta):Init()

end


function Ticker( tm )

	if not tm then return nil end

	local tv = { v=0, r=1 }
	local t = setmetatable({ 
		tm = tm,
		time = tv,
	}, t_meta):Init()

	local updater = function( ft )
		tv.v = tv.v + ft * tv.r
	end

	t.gc = GCHandler( function()
		tm.funcs[ updater ] = nil
		tm.count = tm.count - 1
	end )

	tm.funcs[ updater ] = true
	tm.count = tm.count + 1

	return t

end