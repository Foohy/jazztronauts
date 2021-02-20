AddCSLuaFile()

G_CYBERSPACE_META = G_CYBERSPACE_META or {}

module( "cyberspace", package.seeall )

local meta = G_CYBERSPACE_META
meta.__index = meta

function meta:Init(iograph)

	self.traces = {}
	self.io_to_trace = {}
	self.trace_to_io = {}
	self.graph = iograph
	self:BuildTraces()

	return self

end

function meta:ShouldDrawEnt( ent )

	local inputs = ent:GetInputs()
	local outputs = ent:GetOutputs()
	if #outputs == 0 and #inputs == 0 then return false end
	return true

end

function meta:GetTraceByIndex( index )

	return self.traces[index]

end

function meta:GetIOForTrace( trace )

	return self.trace_to_io[trace]

end

function meta:GetTraceForRay( origin, dir, result, maxDist )

	maxDist = maxDist or math.huge

	local t = maxDist
	local pick = nil
	local point = nil

	local test = G_IOTRACE_META.TestRay
	local ox, oy, oz = origin:Unpack()
	local dx, dy, dz = dir:Unpack()

	result = result or Vector()

	dx = 1/dx
	dy = 1/dy
	dz = 1/dz

	for _, trace in ipairs(self.traces) do

		local hit, toi, hitpoint = test(
			trace, 
			ox, oy, oz, 
			dx, dy, dz, 
			origin, dir, maxDist)

		if hit then

			if toi < t then
				t = toi
				pick = trace
				result:Set(dir)
				result:Mul(toi)
				result:Add(origin)
				point = hitpoint
			end

		end

	end

	return pick, result, point

end

function meta:BuildTraces()

	for ent in self.graph:Ents() do

		local inputs = ent:GetInputs()
		local outputs = ent:GetOutputs()
		if #outputs == 0 and #inputs == 0 then continue end

		local n = 0
		for _, output in ipairs(outputs) do

			local id = #self.traces+1
			local startPos = ent:GetPos() + Vector(0,0,n)
			local endPos = output.to:GetPos()
			local trace = iotrace.New( startPos, endPos, id )

			trace:BuildPath()

			self.traces[id] = trace
			self.io_to_trace[output] = self.traces[id]
			self.trace_to_io[trace] = output
			n = n + 2

		end

	end

end

function meta:AddBlipsFromIOEvent( ent, event )

	local outputs = ent:GetOutputs()
	if #outputs == 0 then return end

	for _, output in ipairs(outputs) do

		if output.event == event then

			local trace = self.io_to_trace[output]
			assert(trace)

			trace:AddBlip( tonumber(output.delay) )

		end

	end

end

if CLIENT then

	local blip_color = Color(255,180,50)
	local was_mouse_down = false
	local lasermat = Material("effects/laser1.vmt")
	local flaremat = Material("effects/blueflare1")

	local trace_draw = G_IOTRACE_META.Draw
	local trace_draw_flashes = G_IOTRACE_META.DrawFlashes
	local trace_draw_blips = G_IOTRACE_META.DrawBlips
	local vray_result = Vector()

	function meta:Draw()

		local eye, forward = EyePos(), EyeAngles():Forward() 
		local tracesDrawn = 0

		local gc0 = collectgarbage( "count" )
		local t = SysTime()

		render.SetMaterial(lasermat)
		for k, trace in ipairs(self.traces) do
			trace_draw(trace)
		end

		for k, trace in ipairs(self.traces) do
			trace_draw_flashes(trace)
		end

		render.SetMaterial(flaremat)
		for k, trace in ipairs(self.traces) do
			trace_draw_blips(trace)
		end

		_G.G_GARBAGE = collectgarbage( "count" ) - gc0

		if LocalPlayer():GetActiveTrace() == nil then
			local hitTrace, pos, point = self:GetTraceForRay( eye, forward, vray_result, 300 )
			if hitTrace then
				local along = (pos - point.pos):Dot( point.normal )
				local v = point.pos + point.normal * along
				--print(t)
				render.SetMaterial(lasermat)
				hitTrace:Draw(Color(200,210,255), 15, point.along + along - 30, point.along + along + 30)
				--hitTrace:Draw( blip_color, 10, t - 30, t + 30 )

				--render.DrawLine(Vector(0,0,0), v)

				-- FIXME: Do this better
				if input.IsMouseDown(MOUSE_LEFT) then
					if not was_mouse_down then
						print("DO IT")
						ionet.RequestRideTrace( hitTrace, point.along + along )
						was_mouse_down = true
					end
				else
					was_mouse_down = false
				end

			end
		end

		--[[for ent in self.graph:Ents() do
			if self:ShouldDrawEnt( ent ) then
				--ent:Draw()
			end
		end]]

		

		print("Draw[" .. _G.G_GARBAGE .. "] took " .. (SysTime() - t) * 1000 .. "ms")

	end

end

function New(...)

	return setmetatable({}, meta):Init(...)

end

if CLIENT then

	local hackEnable = CreateConVar(
		"jazz_debug_hackerview", "0", 
		{ FCVAR_CHEAT }, 
		"Toggle drawing the hacker gun view")

	local function ShouldDrawHackerview()
		if hackEnable:GetBool() then return true end

		local weapon = LocalPlayer():GetActiveWeapon()
		if IsValid(weapon) and weapon:GetClass() == "weapon_hacker" then 
			return true 
		end

		return false
	end

	local blip_color = Color(255,180,50)
	local hacker_vision = CreateMaterial("HackerVision" .. FrameNumber(), "UnLitGeneric", {
		["$basetexture"] = "concrete/concretefloor001a",
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$model"] = 0,
		["$additive"] = 1,
	})

	local space = nil

	hook.Add("IOEventTriggered", "cyberspace", function(ent, event)

		if space then space:AddBlipsFromIOEvent( ent, event ) end

	end)

	hook.Add("PostDrawTranslucentRenderables", "cyberspace", function()

		--[[if not ShouldDrawHackerview() then return end

		if bsp2.GetCurrent() == nil then return end
		if bsp2.GetCurrent():IsLoading() then return end
		if space == nil then space = bsp2.GetCurrent().cyberspace end

		space:Draw()]]

	end)

	hook.Add("PostDrawOpaqueRenderables", "cyberspace", function()

		--space:Draw()

	end)

	bsp2.GetCurrent().cyberspace = New( bsp2.GetCurrent().iograph )

	hook.Add("HUDPaint", "cyberspace", function()

		--if true then return end
		if not ShouldDrawHackerview() then return end

		if bsp2.GetCurrent() == nil then return end
		if bsp2.GetCurrent():IsLoading() then return end
		if space == nil then space = bsp2.GetCurrent().cyberspace end

		local w = ScrW()
		local h = ScrH()

		local rt = irt.New("hackvision", w, h)
			:EnableDepth(true,true)
			:EnableFullscreen(false)
			:EnablePointSample(true)
			:SetAlphaBits(8)

		hacker_vision:SetTexture("$basetexture", rt:GetTarget())

		render.PushRenderTarget(rt:GetTarget())
		render.Clear( 0, 0, 0, 255, true, true ) --60

		cam.Start(
			{
				x = 0,
				y = 0,
				w = w,
				h = h,
			})

			--render.SetMaterial( lasermat );

			local b,e = pcall( function()

				_G.G_EYE_POS = EyePos()
				_G.G_EYE_X = _G.G_EYE_POS.x
				_G.G_EYE_Y = _G.G_EYE_POS.y
				_G.G_EYE_Z = _G.G_EYE_POS.z
				space:Draw()

			end)
			if not b then print( e ) end

		cam.End()

		render.PopRenderTarget()


		cam.Start2D()

		surface.SetDrawColor(0,0,0,230)
		surface.DrawRect(0,0,ScrW(),ScrH())

		surface.SetDrawColor(255,255,255,255)
		render.SetMaterial(hacker_vision)
		render.DrawScreenQuad()

		surface.SetDrawColor(blip_color)
		surface.DrawRect( ScrW()/2 - 5, ScrH()/2 - 1, 10,2 )
		surface.DrawRect( ScrW()/2 - 1, ScrH()/2 - 5, 2,10 )

		cam.End2D()

	end)

end