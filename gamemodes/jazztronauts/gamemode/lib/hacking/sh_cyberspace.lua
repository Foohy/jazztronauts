AddCSLuaFile()

module( "cyberspace", package.seeall )

local meta = {}
local g_cull = frustum.New()
meta.__index = meta

function meta:Init(iograph)

	self.traces = {}
	self.io_to_trace = {}
	self.blips = {}
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

function meta:GetTraceForRay( origin, dir )

	local t = math.huge
	local pick = nil
	local pos = nil
	local point = nil
	for _, trace in ipairs(self.traces) do

		local hit, toi, point = trace:TestRay(origin, dir)
		if hit then

			if toi < t then
				t = toi
				pick = trace
				pos = origin + dir * toi
				point = point
			end

		end

	end
	return pick, pos, point

end

function meta:BuildTraces()

	for ent in self.graph:Ents() do

		local inputs = ent:GetInputs()
		local outputs = ent:GetOutputs()
		if #outputs == 0 and #inputs == 0 then continue end

		local n = 0
		for _, output in ipairs(outputs) do

			local id = #self.traces+1
			self.traces[id] = iotrace.New( ent, output.to, id, Vector(0,0,n) )
			self.io_to_trace[output] = self.traces[id]
			n = n + 2

		end

	end

end

local MIN_BLIP_DELAY = 0.5

function meta:AddBlipsFromIOEvent( ent, event )

	local outputs = ent:GetOutputs()
	if #outputs == 0 then return end

	for _, output in ipairs(outputs) do

		if output.event == event then

			local trace = self.io_to_trace[output]
			assert(trace)

			self.blips[#self.blips+1] = {
				trace = trace,
				time = CurTime(),
				duration = tonumber(output.delay),
			}

		end

	end

end

local lasermat	= Material("effects/laser1.vmt")
local flaremat = Material("effects/blueflare1")
local box_extent = Vector(2,2,2)
local base_trace_color = Color(180,0,255,255)
local base_trace_color2 = Color(180/4,0,255/4,255)
local blip_color = Color(255,180,50)
local blip_color2 = Color(255/2,180/2,50)

function meta:Draw()

	local tracesDrawn = 0
	local hitTrace, pos, point = self:GetTraceForRay( EyePos(), EyeAngles():Forward() )

	g_cull:FromPlayer( LocalPlayer(), 10, 500 )

	--render.SetColorMaterial()
	render.SetMaterial(lasermat)
	for k, trace in ipairs(self.traces) do
		if g_cull:TestAABB( trace.min, trace.max ) then
			--3 + math.cos(k + CurTime() * 2) * 2
			trace:Draw(base_trace_color)
			--trace:Draw(base_trace_color2,base_trace_color2,64)
			tracesDrawn = tracesDrawn + 1
		end
	end

	--[[if hitTrace then
		hitTrace:Draw(blip_color, nil, 10)
		local along = (pos - point.pos):Dot( point.normal )
		local v = point.pos + point.normal * along

		render.DrawLine(Vector(0,0,0), pos)
	end]]

	for ent in self.graph:Ents() do
		if self:ShouldDrawEnt( ent ) then
			ent:Draw()
		end
	end

	-- trace flashes
	render.SetMaterial(lasermat)
	for i=#self.blips, 1, -1 do

		local blip = self.blips[i]
		local trace = blip.trace
		local elapsed = (CurTime() - blip.time)
		local t = elapsed / (blip.duration + MIN_BLIP_DELAY)
		if t >= 1 then table.remove(self.blips, i) continue end

		local blip_scale = 1
		if elapsed > blip.duration then
			local flash = 1 - math.min(elapsed - blip.duration, MIN_BLIP_DELAY) / MIN_BLIP_DELAY
			if flash > 0 then
				local col = LerpColor(blip_color, Color(0,0,0,0), 1 - flash)
				trace:Draw( col, col, 8 )
				trace:Draw( col, col, 16 )
			end
			blip_scale = flash
		end

	end

	-- moving blips
	render.SetMaterial(flaremat)
	for i=#self.blips, 1, -1 do

		local blip = self.blips[i]
		local trace = blip.trace
		local elapsed = (CurTime() - blip.time)

		local blip_scale = 1
		if elapsed > blip.duration then
			local flash = 1 - math.min(elapsed - blip.duration, MIN_BLIP_DELAY) / MIN_BLIP_DELAY
			blip_scale = flash
		end

		if blip.duration > 0 then
			local steps = 50
			local space = 1
			local tracelen = trace:GetLength()
			local bliptime = math.min(elapsed / blip.duration, 1 + (space/tracelen) * steps)
			local time = bliptime * tracelen

			for k=1, steps do
				local time2 = math.Clamp( time - (k * space), 0, tracelen )
				local pos = trace:GetPointAlongPath( time2 )
				local size = (8 - (k/steps) * 8 ) * blip_scale
				if time2 == tracelen then size = size * 2 end
				render.DrawSprite( pos, size, size, blip_color )
			end
		end

	end

end

function New(...)

	return setmetatable({}, meta):Init(...)

end

if CLIENT then

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

		--space:Draw()

	end)

	hook.Add("PostDrawOpaqueRenderables", "cyberspace", function()

		--space:Draw()

	end)

	hook.Add("HUDPaint", "cyberspace", function()

		if bsp2.GetCurrent() == nil then return end
		if bsp2.GetCurrent():IsLoading() then return end
		if space == nil then space = New( bsp2.GetCurrent().iograph ) end

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

				space:Draw()

			end)
			if not b then print( e ) end

		cam.End()

		render.PopRenderTarget()


		cam.Start2D()

		surface.SetDrawColor(255,255,255,255)
		render.SetMaterial(hacker_vision)
		render.DrawScreenQuad()

		surface.SetDrawColor(blip_color)
		surface.DrawRect( ScrW()/2 - 5, ScrH()/2 - 1, 10,2 )
		surface.DrawRect( ScrW()/2 - 1, ScrH()/2 - 5, 2,10 )

		cam.End2D()

	end)

end