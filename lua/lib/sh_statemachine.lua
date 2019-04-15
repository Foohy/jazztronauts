AddCSLuaFile()

function IsFunctor(t)
	return type(t) == "table" and rawget(t,"__functor")
end

local function unpack2(t, o, s, i, ne, ...)

	if s > 0 then return unpack2(t, o, s-1, i, ...) end
	if o > 0 then return ne, unpack2(t, o-1, s, i, ...) end
	if t[i] ~= nil then return t[i], unpack2(t, o, s, i + 1, ne, ...) end
	return ne, ...

end
-- -a (not a())
-- a + b (a() and b())
-- a - b (a() and not b())
-- a * b (a() or b())
-- a / b (a() or not ())
-- a % b (exclusive or)
_F = function(fn)

	return setmetatable({__functor = true}, {
		__index = function() end,
		__newindex = function() end,
		__call = function(self, ...) return fn(...) end,
		__unm = function(self)
			return _F(function(...)
				return not fn(...)
			end)
		end,
		__add = function(a,b)
			return _F(function(...)
				return a(...) and b(...)
			end)
		end,
		__sub = function(a,b)
			return _F(function(...)
				return a(...) and not b(...)
			end)
		end,
		__mul = function(a,b)
			return _F(function(...)
				return a(...) or b(...)
			end)
		end,
		__div = function(a,b)
			return _F(function(...)
				return a(...) or not b(...)
			end)
		end,
		__mod = function(a,b)
			return _F(function(...)
				local va = a(...)
				local vb = b(...)
				return (va and not vb) or (not va and vb)
			end)
		end,
		__concat = function(a,b)
			return _F(function(...)
				a(...)
				b(...)
			end)
		end,
	})

end

_T = function(fn, ofs, skip)

	return function(...)
		local bind = {...}
		return _F(function(...)
			return fn(unpack2(bind, ofs or 0, skip or 0, 1, ...))
		end)
	end

end

_NOP = _F( function() return true end )

local mc = {}

function mc:__call( min,max,normalize )

	if not self.pause then self.t = self.t + (CurTime() - self.l) * self.rate self.l = CurTime() end
	local d = self.t
	if min then d = math.max(min, d) - min end
	if max then d = math.min(max - min, d) end
	if normalize then d = d / (max - min) end
	return d

end

function mc:Set( set )

	self.t = set
	self.l = CurTime()

end

function mc:Reset()

	self:Set(0)

end

function mc:Rate( s, k )

	if k then self.rate = k end
	return self.rate

end

function mc:Paused( s, b )

	if b ~= nil then
		self.l = ((not b) and self.pause) and CurTime() or self.l self.pause = self.b
	end
	return self.pause

end

mc.__index = mc

Clock = function()

	return setmetatable({
		t = 0,
		l = CurTime(),
		pause = false,
		rate = 1
	}, mc)

end

module( "statemachine", package.seeall )

local mmfs = {}
mmfs.__tostring = function(self)

	return tostring(self.a) .. ">" .. tostring(self.b)

end

local mfs = {}
mfs.__index = function(self, k)

	return rawget(self, k)

end

mfs.__newindex = function(self, k, v)

	if type(v) ~= "function" and not IsFunctor(v) then error("Expected function") end
	rawset(self, k, v)

end

mfs.__concat = function(a, b)

	return setmetatable({a=a,b=b}, mmfs)

end

mfs.__tostring = function(self)

	return self.name

end

mfs.__call = function(self, func, ...)

	local v = rawget(self, func)
	if not v then
		print("State has no function named '" .. tostring(func) .. "'")
		return
	end

	local _,a,b,c,d,e,f,g,h,i = pcall(v, ...)
	if not _ then
		ErrorNoHalt(a)
	else
		return a,b,c,d,e,f,g,h,i
	end

end

local meta = {}
local function switchstates(sm, newstate, ...)

	local prev = rawget(sm, "currentstate")
	if prev and prev.exit then prev.exit(...) end
	rawset(sm, "currentstate", newstate)
	rawset(sm, "transitioned", true)
	return newstate.enter and newstate.enter(...) or nil

end

meta.__index = function(self, k)

	if k == "_" then return rawget(self, "currentstate") end
	if k == "_transitioned" then return rawget(self, "transitioned") end

	local statelist = rawget(self, "states")
	local edgegraph = rawget(self, "edges")
	if not statelist[k] then
		statelist[k] = setmetatable({ name = k }, mfs)
		edgegraph[statelist[k]] = {}
	end
	return statelist[k]

end

meta.__newindex = function(self, k, v)

	if type(k) == "table" and getmetatable(k) == mmfs then

		local edgegraph = rawget(self, "edges")
		local edge = edgegraph[k.a]
		for i, v in pairs( edge ) do
			if v.nextstate == k.b then table.remove( edgegraph[k.a], i ) break end
		end
		table.insert( edge,
		{
			nextstate = k.b, edge = function(...)

				local _,e = pcall(v, ...)
				if not _ then ErrorNoHalt(e) return false end
				return e

			end
		} )

	end

end

meta.__call = function(self, ...)

	local args = {...}
	local currentstate = rawget(self, "currentstate")
	rawset(self, "transitioned", false)

	if type(args[1]) == "table" and getmetatable(args[1]) == mfs then

		local state = args[1]
		table.remove(args, 1)
		return switchstates(self, state, unpack(args))

	end

	local did_switch = false
	local edgegraph = rawget(self, "edges")

	if currentstate == nil then return false end
	if not edgegraph[currentstate] then
		if currentstate.tick then currentstate.tick(...) end
		return false
	end

	for k, v in pairs( edgegraph[currentstate] ) do
		local res = v.edge(...)
		if res then
			switchstates(self, v.nextstate, ...)
			did_switch = true
			break
		end
	end

	if not did_switch then
		if currentstate.tick then currentstate.tick(...) end
	end

	return did_switch

end

function New()

	local sm = setmetatable(
	{
		states = {},
		edges = {},
		currentstate = nil,
		transitioned = false,
	}, meta)
	sm.none = _NOP
	sm( sm.none )
	return sm

end

if CLIENT then

function Layout(sm)

	local layout = {states = {}, edges = {}}
	local states = rawget(sm, "states")
	local edges = rawget(sm, "edges")
	local sx = ScrW() / 4
	local sy = ScrH() / 4
	local n = 0
	local i = 0
	for k,v in pairs(states) do n = n + 1 end
	for k,v in pairs(states) do
		local r = i / n
		local cx = sx + math.cos(r * math.pi * 2) * 150
		local cy = sy + math.sin(r * math.pi * 2) * 150
		layout.states[v] = {state = v, x = cx, y = cy}
		i = i + 1
	end

	for k,v in pairs(edges) do
		local stateedges = v
		for _,e in pairs(stateedges) do
			table.insert( layout.edges, { layout.states[k], layout.states[e.nextstate] } )
		end
	end

	layout.edgeheat = {}
	layout.stateheat = {}
	layout.lstate = nil
	layout.draw = function()

		for k,v in pairs(layout.edges) do
			layout.edgeheat[v] = math.max( (layout.edgeheat[v] or 0) - FrameTime() * 2, 0 )
			local h = layout.edgeheat[v]
			surface.SetDrawColor( Color( 255 * (1-h),255,255 * (1-h) ) )
			local dx = v[2].x - v[1].x
			local dy = v[2].y - v[1].y
			local a = math.atan2(dy,dx)
			local mx = math.cos(a) * 30
			local my = math.sin(a) * 30
			local ofsx = math.cos(a + math.pi/2) * 5
			local ofsy = math.sin(a + math.pi/2) * 5
			local a0x = math.cos(math.pi + a + math.pi / 8) * 10
			local a0y = math.sin(math.pi + a + math.pi / 8) * 10
			local a1x = math.cos(math.pi + a - math.pi / 8) * 10
			local a1y = math.sin(math.pi + a - math.pi / 8) * 10
			if v[1].state == layout.lstate and v[2].state == sm._ and sm._transitioned then layout.edgeheat[v] = 1 layout.stateheat[v[2]] = 1 end
			if v[1] ~= v[2] then
				surface.DrawLine( v[1].x + ofsx + mx, v[1].y + ofsy + my, v[2].x + ofsx - mx, v[2].y + ofsy - my )
				surface.DrawLine( v[2].x - mx + ofsx, v[2].y - my + ofsy, v[2].x + a0x - mx + ofsx, v[2].y + a0y - my + ofsy )
				surface.DrawLine( v[2].x - mx + ofsx, v[2].y - my + ofsy, v[2].x + a1x - mx + ofsx, v[2].y + a1y - my + ofsy )
			end
		end

		for k,v in pairs(layout.states) do
			layout.stateheat[v] = math.max( (layout.stateheat[v] or 0) - FrameTime() * 2, 0 )
			local h = layout.stateheat[v]
			draw.SimpleText( k, "ChatFont", v.x, v.y, k == sm._ and Color(255,255*(1-h),255*(1-h)) or Color(100,100*(1-h),100*(1-h)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		layout.lstate = sm._

	end

	return layout

end

end