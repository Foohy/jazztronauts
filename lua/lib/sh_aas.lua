if SERVER then AddCSLuaFile("sh_aas.lua") end
if SERVER then return end

if true then return end

local bspdata = bsp.Get( "maps/" .. game.GetMap() .. ".bsp" )
--local bspdata = bsp.Get( "maps/gm_construct.bsp")

local function AddUniquePlane( planes, plane )

	for k,v in pairs( planes ) do
		if v.normal:Dot( plane.normal ) > .99 and math.abs( v.dist - plane.dist ) < 0.01 then
			return false
		end
	end

	table.insert( planes, plane )

end

local params = {
	["$basetexture"] = "phoenix_storms/cube",
	["$model"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1,
	["$translucent"] = 1,
	["$ignorez"] = 0,
}

local colormat = CreateMaterial("litmaterialtest4", "VertexLitGeneric", params);

local function MakePolygons( work, bsp )

	work.brushes = {}
	work.windings = {}

	print("MELD PLANES")
	for i=1, #bsp.planes, 2 do
		local p1 = bsp.planes[i]
		local p2 = bsp.planes[i+1]
		p1.back = p2
		p2.back = p1
		if p1.normal:Dot(p2.normal) > -0.99 or p1.dist ~= -p2.dist then
			error("PLANE ENCODING NOT CORRECT")
		end
	end

	--if true then return end


	local rootBrush = brush.Brush():CreateFromAABB( Vector(-6000,-6000,-6000), Vector(6000,6000,6000) )
	--table.insert( work.brushes, rootBrush )
	local mat = colormat --Material("models/wireframe")

--if false then
	local max = 10000
	local sidenum = 0
	local remain = #bsp.brushes
	for i=1, #bsp.brushes - 1 do
		local origbrush = bsp.brushes[i]
		max = max - 1
		if max == 0 then break end

		remain = remain - 1

		local newbrush = brush.Brush()
		newbrush.contents = origbrush.contents

		for _, origside in pairs( origbrush.sides ) do
			local side = brush.Side( origside.plane.back )
			side.texinfo = origside.texinfo
			newbrush:Add( side )
		end
		newbrush:CreateWindings()

		newbrush.center = (newbrush.min + newbrush.max) / 2
		newbrush.fade = 1
		newbrush.new = true
		table.insert( work.brushes, newbrush )

		if max % 10 == 1 then task.Sleep(.0005, "windingsReady", work) end
		--if max % 100 == 1 then print(remain) task.Yield("progress") end
	end
--end

--[[
	local test = brush.Brush():CreateFromAABB( Vector(-30,-30,100), Vector(30,30,200) )
	test.contents = CONTENTS_SOLID
	table.insert( work.brushes, test )

	local test = brush.Brush():CreateFromAABB( Vector(-80,-30,120), Vector(80,30,180) )
	test.contents = CONTENTS_SOLID
	table.insert( work.brushes, test )

	local test = brush.Brush():CreateFromAABB( Vector(-30,-80,120) + Vector(0,0,50), Vector(30,80,180) + Vector(0,0,50) )
	test.contents = CONTENTS_SOLID
	table.insert( work.brushes, test )
]]

	task.Sleep(.0001, "windingsReady", work)
	print("READY TO CHOP " .. #work.brushes .. " BRUSHES!!!")
	task.Sleep(2)

	work.brushes = csg.ChopBrushes( work.brushes )
	--print("KEEP: " .. #keep)

	print("DONE CHOPPING")
	task.Sleep(10)

	for k,v in pairs( work.brushes ) do
		v.fade = 1
		v.split = false
		v.center = (v.min + v.max) / 2
	end

	task.Yield("windingsReady", work)

end

local function BuildReverseBSP( work, bsp )
	MakePolygons( work, bsp )
	print("Reverse BSP")
end

local function load()

	--print("Loading: " .. bsp:GetName())
	bspdata:LoadTextureInfo()
	bspdata:LoadBrushes()

	local work = {}
	BuildReverseBSP( work, bspdata )

	return work

end

local task_running = false
local function runTask()

	if task_running then return end
	task_running = true

	local t = task.New( load, 1 )
	function t:chunk( name, count )
		Msg("LOADING: " .. string.upper(name) .. " : " .. count )
	end

	function t:progress()
		Msg(".")
	end

	function t:chunkdone( name, count, tab )
		Msg("DONE\n")
	end

	function t:windingsReady( work )

		hook.Add( "PostDrawOpaqueRenderables", "DrawBrushWindings", function(depth, sky)

			--if sky or depth then return end

			local point = EyePos()
			local thresh = 400000
			local zerovec = Vector(0,0,0)

			render.SuppressEngineLighting( true )

			local other = true
			for k,v in pairs(work.brushes) do
				local ds = ( v.center or zerovec ):DistToSqr( point )
				--other = not other
				if not v.fade then v.split = true end

				if (v.fade2 and v.fade2 > 0) or v.split then
					if v.split then v.fade2 = 1 end
					if v.fade2 then v.fade2 = math.max(v.fade2 - FrameTime() * 1, 0) end
					v:Render( Color(255,50,50, 255 * v.fade2), false )
				end
				if v.fade and other then
					if ds < thresh or v.new then
						v.fade = math.max(v.fade - FrameTime() * 1, 0)
						v.new = false
						render.ResetModelLighting( v.fade, v.fade, v.fade )
						v:Render( Color(255,v.fade * 255,255,20), false )
					else
						v.fade = 1
					end
				end
			end

			render.SuppressEngineLighting( false )

		end )

	end

	function t:OnFinished()
		task_running = false
	end

end

hook.Add( "PostDrawOpaqueRenderables", "DrawBrushWindings", function(depth, sky)
end)

--[[hook.Add( "KeyPress", "AdvanceStop", function( ply, key )
	if ( key == IN_USE ) then
		runTask()
	end
end )]]