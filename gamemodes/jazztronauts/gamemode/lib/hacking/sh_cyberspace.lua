AddCSLuaFile()

G_CYBERSPACE_META = G_CYBERSPACE_META or {}

module( "cyberspace", package.seeall )

local meta = G_CYBERSPACE_META
local g_cull = frustum.New()
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

function meta:GetTraceForRay( origin, dir )

	local t = math.huge
	local pick = nil
	local pos = nil
	local point = nil
	for _, trace in ipairs(self.traces) do

		local hit, toi, hitpoint = trace:TestRay(origin, dir)
		if hit then

			if toi < t then
				t = toi
				pick = trace
				pos = origin + dir * toi
				point = hitpoint
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

local blip_color = Color(255,180,50)
local was_mouse_down = false
function meta:Draw()

	local tracesDrawn = 0
	local hitTrace, pos, point = self:GetTraceForRay( EyePos(), EyeAngles():Forward() )

	g_cull:FromPlayer( LocalPlayer(), 10, 1000 )

	for k, trace in ipairs(self.traces) do
		if g_cull:TestAABB( trace.min, trace.max ) then
			trace:Draw()
			trace:DrawBlips()
			trace:DrawFlashes()
			tracesDrawn = tracesDrawn + 1
		end
	end

	if LocalPlayer():GetActiveTrace() == nil then
		if hitTrace and pos:Distance(LocalPlayer():EyePos()) < 500 then
			local along = (pos - point.pos):Dot( point.normal )
			local v = point.pos + point.normal * along
			--print(t)
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

	for ent in self.graph:Ents() do
		if self:ShouldDrawEnt( ent ) then
			ent:Draw()
		end
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

		--space:Draw()

	end)

	hook.Add("PostDrawOpaqueRenderables", "cyberspace", function()

		--space:Draw()

	end)

	hook.Add("HUDPaint", "cyberspace", function()

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