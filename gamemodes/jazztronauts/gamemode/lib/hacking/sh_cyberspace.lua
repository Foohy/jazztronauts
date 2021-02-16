AddCSLuaFile()

module( "cyberspace", package.seeall )

local meta = {}
local g_cull = frustum.New()
meta.__index = meta

function meta:Init(iograph)

	self.traces = {}
	self.io_to_trace = {}
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

function meta:BuildTraces()

	for ent in self.graph:Ents() do

		local inputs = ent:GetInputs()
		local outputs = ent:GetOutputs()
		if #outputs == 0 and #inputs == 0 then continue end

		for _, output in ipairs(outputs) do

			local id = #self.traces+1
			self.traces[id] = iotrace.New( ent, output.to, id )
			self.io_to_trace[output] = self.traces[id]

		end

	end

end

local lasermat	= Material("effects/laser1.vmt")
local box_extent = Vector(2,2,2)

function meta:Draw()

	local tracesDrawn = 0

	g_cull:FromPlayer( LocalPlayer(), 10, 500 )

	render.SetMaterial( lasermat )
	for _, trace in ipairs(self.traces) do
		if g_cull:TestAABB( trace.min, trace.max ) then
			trace:Draw()
			tracesDrawn = tracesDrawn + 1
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

	local hacker_vision = CreateMaterial("HackerVision" .. FrameNumber(), "UnLitGeneric", {
		["$basetexture"] = "concrete/concretefloor001a",
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$model"] = 0,
		["$additive"] = 0,
	})

	local space = nil

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
		render.Clear( 0, 0, 0, 100, true, true ) --60

		cam.Start(
			{
				x = 0,
				y = 0,
				w = w,
				h = h,
			})

			render.SetMaterial( lasermat );

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

		cam.End2D()

	end)

end