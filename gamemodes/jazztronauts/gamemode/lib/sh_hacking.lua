AddCSLuaFile()

local function GetIndexMapping()

	local indices = {}

end

local function ParseOutput( str, event )

	if type( str ) ~= "string" then return end

	local args = { event }
	for w in string.gmatch(str .. ",","(.-),") do
		table.insert( args, w )
	end

	if args[2] == "" then return nil end

	return args
end

if SERVER then 

	local proxy_name = "__jazz_io_proxy"

	util.AddNetworkString("input_fired")

	hook.Add("EntityKeyValue", "hacking", function( ent, key, value )
		if ent:GetName() == proxy_name then return value end

		-- Every output, we're going to store some additional info that we can look up later
		-- This way we can hook into each output and listen for events
		if string.Left( key, 2 ) == "On" then
			ent.JazzIOEvents = ent.JazzIOEvents or {}
			ent.JazzIOEvents[key] = ent.JazzIOEvents[key] or {}

			table.insert(ent.JazzIOEvents[key], {
				key = key, 
				value = value, 
				outdata = ParseOutput(value)
			})
		end

	end )


	local function SetupIOListener()

		print("****SetupIOListener****")

		local io_proxy = ents.FindByClass("jazz_io_proxy")[1]
		if not IsValid( io_proxy ) then
			io_proxy = ents.Create("jazz_io_proxy")
			io_proxy:SetPos( Vector(0,0,0) )
			io_proxy:SetName(proxy_name)
			io_proxy:Spawn()
		end

		-- Go through every entity, and for each output we create an additional output to fire that event 
		-- To our IO proxy. It then listens to those events and forwards them to the client
		for _, v in pairs(ents.GetAll()) do
			if not v.JazzIOEvents then continue end

			for _, outputs in pairs(v.JazzIOEvents) do

				-- For each output, create the duplicate with the data param the index into the full output data table
				for k, keyval in pairs(outputs) do
					local outputStr = string.format("%s %s,JazzForward_%s,%d,0,-1", keyval.key, proxy_name, keyval.key, k)
					v:Fire("AddOutput", outputStr)
				end
			end

		end
	end
	hook.Add("InitPostEntity", "hacking", SetupIOListener)
	hook.Add("PostCleanupMap", "hackingcleanup", SetupIOListener)

	/*
	hook.Add("AcceptInput", "hacking", function( ent, input, activator, caller, value )
		if not IsValid( caller ) then
			print("Unknown caller for: " .. tostring(input))
			if IsValid( activator ) then
				print("But activator was: " .. tostring(activator) )
			end
		end
	end )
*/

	return
end

local map = bsp2.GetCurrent()
local g_cull = frustum.New()

local hacker_vision = CreateMaterial("HackerVision" .. FrameNumber(), "UnLitGeneric", {
	["$basetexture"] = "concrete/concretefloor001a",
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$model"] = 0,
	["$additive"] = 0,
})

local function getToolTexture(texture)
	return CreateMaterial("HackerTool_" .. texture, "UnlitGeneric", {
		["$basetexture"] = "tools/tools" .. texture,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$model"] = 1,
		["$additive"] = 1,
		["$nocull"] = 0,
		["$alpha"] = 0.5
	})
end

local tooltextures = {
	["trigger_*"] = getToolTexture("trigger"),
	["func_button"] = getToolTexture("hint"),
	["func_button_timed"] = getToolTexture("hint")
}

local io_functions = {
	logic_auto = {
		inputs = {},
		outputs = {
			"OnMapSpawn"
		},
	},
	logic_relay = {
		inputs = {
			"Enable",
			"Disable",
			"Trigger",
			"Toggle",
			"CancelPending",
			"EnableRefire",
			"Kill",
			"Use",
		},
		outputs = {
			"OnSpawn",
			"OnTrigger",
		},
	},
	logic_branch = {
		inputs = {
			"SetValue",
			"SetValueTest",
			"Toggle",
			"ToggleTest",
			"Test",
		},
		outputs = {
			"OnTrue",
			"OnFalse",
		},
	},
	logic_timer = {
		inputs = {
			"RefireTime",
			"ResetTimer",
			"FireTimer",
			"Enable",
			"Disable",
			"Toggle",
			"LowerRandomBound",
			"UpperRandomBound",
			"AddToTimer",
			"SubtractFromTimer",
		},
		outputs = {
			"OnTimer",
			"OnTimerHigh",
			"OnTimerLow",
		},
	},
	func_button = {
		inputs = {
			"Kill",
			"Use",
			"Lock",
			"Unlock",
			"Press",
			"PressIn",
			"PressOut",
		},
		outputs = {
			"OnDamaged",
			"OnPressed",
			"OnUseLocked",
			"OnIn",
			"OnOut",
		},
	},
	func_rot_button = {
		inputs = {
			"Kill",
			"Use",
			"Lock",
			"Unlock",
			"Press",
			"PressIn",
			"PressOut",
		},
		outputs = {
			"OnDamaged",
			"OnPressed",
			"OnUseLocked",
			"OnIn",
			"OnOut",
		},
	},
	func_door = {
		inputs = {
			"Open",
			"Close",
			"Toggle",
			"Lock",
			"Unlock",
			"SetSpeed",
		},
		outputs = {
			"OnClose",
			"OnOpen",
			"OnFullyClosed",
			"OnFullyOpen",
			"OnBlockedClosing",
			"OnBlockedOpening",
			"OnUnblockedClosing",
			"OnUnblockedOpening",
			"OnLockedUse",
		},
	},
	func_door_rotating = {
		inputs = {
			"Open",
			"Close",
			"Toggle",
			"Lock",
			"Unlock",
			"SetSpeed",
		},
		outputs = {
			"OnClose",
			"OnOpen",
			"OnFullyClosed",
			"OnFullyOpen",
			"OnBlockedClosing",
			"OnBlockedOpening",
			"OnUnblockedClosing",
			"OnUnblockedOpening",
			"OnLockedUse",
		},
	},
	func_rotating = {
		inputs = {
			"SetSpeed",
			"Start",
			"Stop",
			"StopAtStartPos",
			"StartForward",
			"StartBackward",
			"Toggle",
			"Reverse",
		},
		outputs = {
		},
	},
	prop_dynamic = {
		inputs = {
			"SetAnimation",
			"SetDefaultAnimation",
			"SetPlaybackRate",
			"SetBodyGroup",
			"TurnOn",
			"TurnOff",
			"EnableCollision",
			"DisableCollision",
			"BecomeRagdoll",
		},
		outputs = {
			"OnAnimationBegun",
			"OnAnimationDone",
		},
	},
	env_sprite = {
		inputs = {
			"SetScale",
			"HideSprite",
			"ShowSprite",
			"ToggleSprite",
			"ColorRedValue",
			"ColorGreenValue",
			"ColorBlueValue",
			"Alpha",
			"Color",
		},
		outputs = {

		},
	},
	env_spark = {
		inputs = {
			"StartSpark",
			"StopSpark",
			"ToggleSpark",
			"SparkOnce"
		},
		outputs = {

		},
	},
	trigger_once = {
		inputs = {
			"Toggle",
			"Enable",
			"Disable",
		},
		outputs = {
			"OnStartTouch",
			"OnTrigger",
		},
	},
	trigger_multiple = {
		inputs = {
			"TouchTest",
			"Toggle",
			"Enable",
			"Disable",
		},
		outputs = {
			"OnStartTouchAll",
			"OnEndTouch",
			"OnEndTouchAll",
			"OnStartTouch",
			"OnTrigger",
		},
	},
	ambient_generic = {
		inputs = {
			"Pitch",
			"PlaySound",
			"StopSound",
			"ToggleSound",
			"Volume",
			"FadeIn",
			"FadeOut"
		},
		outputs = {

		},
	},
}

local function EntsByClass( class )

	local t = {}
	for k,v in pairs( map.entities ) do
		if v.classname == class then
			table.insert( t, v )
		end
	end
	return t

end

local function EntsByName( name )

	local t = {}
	for k,v in pairs( map.entities ) do
		if v.targetname == name or ( v.targetname and string.Right(name, 1) == "*" and string.find( v.targetname, string.sub( name, 1, -1 ) ) ) then
			table.insert( t, v )
		end
	end
	return t

end


local function GetMajorAxis( v )
	local best = 0
	local major_axis = 1
	for i=1, 3 do
		local d = math.abs(v[i])
		if d > best and d ~= 0 then major_axis = i best = d end
	end
	return major_axis
end

local function PointAlongEdges( edges, total_length, frac )

	local acc_length = 0
	local test_frac = total_length * frac
	local center = nil
	for _, edge in pairs( edges ) do
		local vec = edge[2] - edge[1]
		local length = vec:Length()
		if acc_length + length >= test_frac then
			return edge[1] + vec * ( (test_frac - acc_length) / length )
		end
		acc_length = acc_length + length
	end

	print("PointAlongEdges Bad Case")
	print(total_length, frac)
	PrintTable(edges)
end

local function PointAlongLine( line, frac )

	return PointAlongEdges( line.edges, line.length, frac )

end

local function FormLines( startpos, endpos )

	local edges = {}
	local base = startpos
	local total_length = 0
	local order = {3,2,1}
	for i=1, 3 do
		local vec = endpos - base
		local major = GetMajorAxis( vec )
		local mid = Vector(0,0,0)
		mid[major] = vec[major]
		local midpos = base + mid
		table.insert( edges, { base, midpos } )
		base = midpos
		total_length = total_length + mid:Length()
		if base:Distance( endpos ) < 1 then break end
	end

	local min = Vector(0,0,0)
	local max = Vector(0,0,0)

	ResetBoundingBox( min, max )

	for _, e in pairs( edges ) do
		AddPointToBoundingBox( e[1], min, max )
		AddPointToBoundingBox( e[2], min, max )
	end

	local expand = 5
	for i=1, 3 do
		min[i] = min[i] - expand
		max[i] = max[i] + expand
	end

	return {
		--[[edges = {
			{ startpos, midpos, },
			{ midpos, midpos2 },
			{ midpos2, endpos },
		},]]
		min = min,
		max = max,
		edges = edges,
		center = PointAlongEdges( edges, total_length, .5 ),
		length = total_length,
	}

end

local function getBrushes(node)
	local brushes = {}
	if node then
		if node.children then
			for _, v in pairs(node.children) do
				table.Add(brushes, getBrushes(v))
			end
		end

		if node.brushes then
			for _, b in pairs(node.brushes) do
				table.insert(brushes, b)
			end
		end
	end

	return brushes
end

local function createBrushMesh(material, brushes)

	-- Update the current mesh
	local bmesh = ManagedMesh(material)
	local vertices = {}

	-- Add vertices for every side
	local to_brush = Vector() --brush.center
	for _, brush in pairs(brushes) do
		for _, side in pairs(brush.sides) do
			if not side.winding then continue end

			local texinfo = side.texinfo
			local texdata = texinfo.texdata
			side.winding:Move( to_brush )
			side.winding:EmitMesh(texinfo.textureVecs, texinfo.lightmapVecs, texdata.width, texdata.height, -to_brush, vertices)
			side.winding:Move( -to_brush )
		end
	end

	-- Combine into single mesh
	bmesh:BuildFromTriangles(vertices)
	return bmesh
end

local function lookupBrushMaterial(classname)
	for k, v in pairs(tooltextures) do
		if string.find(classname, k) then return v end
	end

	return nil
end

local function PrepGraph()

	local graph = {}
	local indices = {}

	for k,v in pairs( map.entities ) do
		indices[v] = k
		if v.targetname == "closeCurtains" then
			print("ENT: " .. k)
			for k, v in pairs(v) do
				print( "\t" .. tostring(k) .. " = " .. tostring(v) )
			end
		end
		--print( v.classname )
	end

	--for k,v in pairs( io_functions ) do
	--	local elist = EntsByClass( k )
		for _, ent in pairs( map.entities ) do

			if not ent.origin then continue end

			local gent = {}
			gent.index = indices[ent]
			gent.ent = ent
			gent.pos = ent.origin
			gent.outputs = {}
			gent.targets = {}
			gent.has_targets = false
			gent.name = ent.targetname or ent.classname
			gent.blips = {}

			for _, out in pairs( ent.outputs or {} ) do
				table.insert( gent.outputs, ParseOutput( out[2], out[1] ) )
			end

			--[[for _, out in pairs( v.outputs ) do
				if ent[out] then gent.outputs[out] = ParseOutput( ent[out] ) end
			end]]

			for _, out in pairs( gent.outputs ) do
				local targetlist = EntsByName( out[2] )
				gent.targets[ out[2] ] = targetlist
				gent.has_targets = true
			end

			-- Render triggers
			local brushMaterial = ent.model and lookupBrushMaterial(ent.classname)
			if brushMaterial then
				local modelent = ManagedCSEnt("hackergun_" .. gent.index, ent.model)
				modelent:SetPos(ent.origin)
				local min, max = modelent:GetModelBounds()
				modelent:SetRenderBounds(min, max)
				modelent:SetNoDraw(true) -- #TODO: Set to false, let engine handle it?

				local brushes = {}
				if ent.bmodel then
					brushes = getBrushes(ent.bmodel.headnode)

					for _, v in pairs(brushes) do
						v:CreateWindings()
					end
				end

				modelent.JazzBrushMesh = createBrushMesh(brushMaterial, brushes)
				modelent.JazzBrushMaterial = brushMaterial
				modelent.JazzBrushMatrix = Matrix()

				function modelent:RenderOverride()
					local mtx = self.JazzBrushMatrix 
					mtx:SetTranslation(self:GetPos() )
					mtx:SetAngles(self:GetAngles() )
					cam.PushModelMatrix(mtx)
						render.SetMaterial(self.JazzBrushMaterial)
						render.SetColorModulation(1, 1, 1)
						self.JazzBrushMesh:Draw()
					cam.PopModelMatrix()
				end
				gent.model = modelent
			end

			table.insert( graph, gent )
		end
	--end

	local function FindEntGraph( ent )
		for _, gent in pairs( graph ) do
			if gent.ent == ent then return gent end
		end
		return nil
	end

	for _, gent in pairs( graph ) do
		for k, targetlist in pairs( gent.targets ) do
			for l, target in pairs( targetlist ) do
				targetlist[l] = FindEntGraph( target )
				if targetlist[l] then targetlist[l].targeted = true end
			end
		end
	end

	for _, gent in pairs( graph ) do
		gent.lines = {}
		local n = 0
		for k, targetlist in pairs( gent.targets ) do
			for l, target in pairs( targetlist ) do
				gent.lines[ target.index ] = FormLines( gent.pos + Vector(0,0,n), target.pos )
				n = n + 2
			end
		end
	end

	for i=#graph, 1, -1 do
		if not graph[i].has_targets and not graph[i].targeted then
			table.remove( graph, i )
		end
	end

	return graph

end

local graph = nil

local function AcceptedInput()
	if not graph then return end

	local target_index = net.ReadInt( 32 )
	local caller_index = net.ReadInt( 32 )
	local input = net.ReadString()
	local delay = net.ReadFloat()

	delay = math.max( delay, .1 )

	print("INPUT", input, caller_index, target_index)

	for k,gent in pairs( graph ) do
		if gent.index == caller_index then

			for _, output in pairs( gent.outputs ) do
				if output[3] == input and output[2] and gent.lines[ target_index ] then
					local speedcalc = gent.lines[ target_index ].length / delay
					table.insert( gent.blips, { t=CurTime(), target=target_index, speed = speedcalc, } )
				end
			end

		end
	end
end

net.Receive("input_fired", AcceptedInput)


local function UpdateBlips()
	for k,gent in pairs( graph or {} ) do
		for i=#gent.blips, 1, -1 do
			local blip = gent.blips[i]
			if blip.speed * (CurTime() - blip.t) / gent.lines[ blip.target ].length > 1 then
				table.remove( gent.blips, i )
			end
		end
	end
end

local hackEnable = CreateClientConVar("jazz_debug_hackerview", "0", false, false, "Toggle drawing the hacker gun view")
local hackCullDistance = CreateClientConVar("jazz_hack_cull_far", 10000, true, true, "Far plane of hacker view culling")

hook.Add( "HUDPaint", "hacker_vision", function()
	if not hackEnable:GetBool() then return end

	if map:IsLoading() then return end

	local dc_lines = 0
	local dc_models = 0
	local dc_blips = 0

	local box_extent = Vector(2,2,2)

	if not graph then
		local b,e = pcall( PrepGraph )
		if not b then print(e)
		else graph = e end
	end

	g_cull:FromPlayer( LocalPlayer(), 10, hackCullDistance:GetInt() )

	--if true then return end

	UpdateBlips()

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

		local b,e = pcall( function()


			local line_color = Color(20,120,20)

			for k,v in pairs( graph ) do
				v.visible = false
				if #v.lines == 0 then v.visible = g_cull:TestBox(v.pos, box_extent) end
				for target, l in pairs( v.lines ) do
					if g_cull:TestAABB( l.min, l.max ) then
						dc_lines = dc_lines + 1

						for _, edge in pairs( l.edges ) do
							gfx.renderBeam(edge[1] or Vector(), edge[2] or Vector(), line_color, line_color, 5)
						end
						v.visible = true
					end
				end
			end

			for k,v in pairs( graph ) do

				-- Draw brushes
				if v.model then
					--if g_cull:TestEntity( v.model ) then
						v.model:DrawModel()
						dc_models = dc_models + 1
					--end
				end

				if not v.visible then continue end

				-- Draw blips
				for _, blip in pairs( v.blips ) do
					local line = v.lines[blip.target]
					local dt = 0
					if line.length > 0 then
						dt = blip.speed * (CurTime() - blip.t) / line.length
					end
					local pulse = PointAlongLine( line, dt % 1 )
					gfx.renderBox( pulse, Vector(-2,-2,-2), Vector(2,2,2), Color(255,255,255,255) )
					for _, edge in pairs( line.edges ) do
						gfx.renderBeam(edge[1] or Vector(), edge[2] or Vector(), Color(80,255,80), Color(80,255,80), 20 * (1-dt))
					end
					dc_blips = dc_blips + 1
				end

				gfx.renderBox( v.pos, Vector(-2,-2,-2), Vector(2,2,2), Color(100,100,100) )

				local angle = Angle(0,0,0)
				local p0 = EyePos()
				angle:RotateAroundAxis( angle:Forward(), 90 )
				angle:RotateAroundAxis( angle:Right(), -math.atan2( v.pos.y - p0.y, v.pos.x - p0.x ) * 57.3 + 90 )
				--angle:RotateAroundAxis( angle:Up(), CurTime() * 20 + k * 100 )

				local cross = (p0 - v.pos):GetNormal():Cross( angle:Right() )
				local sin = cross:Length()
				local ang = -math.asin( sin ) * 57.3

				if p0.z > v.pos.z then ang = 180 - ang end

				angle:RotateAroundAxis( angle:Forward(), ang + 90 )

				cam.Start3D2D(v.pos, angle, .25 )
				draw.SimpleText(v.name or v.classname, nil, 0, 0, Color(255,255,100))
				cam.End3D2D()

			end

		end)
		if not b then print( e ) end

	cam.End()

	--render.BlurRenderTarget( rt:GetTarget(), 2, 2, 10 )
	render.PopRenderTarget()

	cam.Start2D()
	
	surface.SetDrawColor(255,255,255,255)
	render.SetMaterial(hacker_vision)
	render.DrawScreenQuad()

	local b,e = pcall( function()

		for k,v in pairs( graph ) do
			local ts = v.pos:ToScreen()
			--draw.SimpleText(v.name or v.classname, nil, ts.x, ts.y, Color(255,255,100))

			for name, out in pairs( v.outputs ) do
				local line = v.lines[ out[2] ]
				if line then
					local pos = line.center
					local ps = pos:ToScreen()
					--draw.DrawText(name .. "\n ->" .. out[3] .. "\n  ->" .. out[4], nil, ps.x, ps.y, Color(255,255,255))
				end
			end
		end

	end)
	if not b then print( e ) end

	cam.End2D()

	draw.SimpleText("Lines drawn: " .. dc_lines,nil,10,10,Color(255,100,100))
	draw.SimpleText("Models drawn: " .. dc_models,nil,10,20,Color(255,100,100))
	draw.SimpleText("Blips drawn: " .. dc_blips,nil,10,30,Color(255,100,100))

end)