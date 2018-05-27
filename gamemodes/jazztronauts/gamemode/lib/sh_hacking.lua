AddCSLuaFile()

if SERVER then 

	for k,v in pairs( ents.GetAll() ) do
		if v:MapCreationID() ~= -1 then
			--print( v:MapCreationID() )
		end
	end

	util.AddNetworkString("input_fired")

	hook.Add("AcceptInput", "hacking", function( ent, input, activator, caller, value )

		if not IsValid( caller ) then
			print("Unknown caller for: " .. tostring(input))
			if IsValid( activator ) then
				print("But activator was: " .. tostring(activator) )
			end
		end

		if IsValid(ent) and IsValid(caller) then

			local name = ent:GetName()
			local index = caller:MapCreationID() - 1234 --really garry?

			--print(tostring(caller))

			--[[for k, v in pairs( ents.GetAll() ) do
				if v == caller then
					print( tostring(caller), " ", k, tostring(caller:GetPos()), caller:MapCreationID() - 1234 )
				end
			end]]

			net.Start( "input_fired" )
			net.WriteString( name )
			net.WriteString( input )
			net.WriteInt( index, 32 )
			net.Send( player.GetAll() )

		end

	end )

	return
end

local map = bsp2.GetCurrent()

local hacker_vision = CreateMaterial("HackerVision" .. FrameNumber(), "UnLitGeneric", {
	["$basetexture"] = "concrete/concretefloor001a",
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$model"] = 0,
	["$additive"] = 0,
})

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
		if string.find( v.classname or "", class ) then
			table.insert( t, v )
		end
	end
	return t

end

local function EntsByName( name )

	local t = {}
	for k,v in pairs( map.entities ) do
		if string.find( v.targetname or "", name ) then
			table.insert( t, v )
		end
	end
	return t

end

local function ParseOutput( event, str )

	if type( str ) ~= "string" then return end

	local args = { event }
	for w in string.gmatch(str .. ",","(.-),") do
		table.insert( args, w )
	end
	return args

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

	return {
		--[[edges = {
			{ startpos, midpos, },
			{ midpos, midpos2 },
			{ midpos2, endpos },
		},]]
		edges = edges,
		center = PointAlongEdges( edges, total_length, .5 ),
		length = total_length,
	}

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
				table.insert( gent.outputs, ParseOutput( out[1], out[2] ) )
			end

			--[[for _, out in pairs( v.outputs ) do
				if ent[out] then gent.outputs[out] = ParseOutput( ent[out] ) end
			end]]

			for _, out in pairs( gent.outputs ) do
				local target = EntsByName( out[2] )[1]
				gent.targets[ out[2] ] = target
				gent.has_targets = true
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
		for k, t in pairs( gent.targets ) do
			gent.targets[k] = FindEntGraph( gent.targets[k] )
			if gent.targets[k] then gent.targets[k].targeted = true end
		end
	end

	for _, gent in pairs( graph ) do
		gent.lines = {}
		local n = 0
		for k, t in pairs( gent.targets ) do
			print("MAKE LINE: " .. tostring(k))
			gent.lines[k] = FormLines( gent.pos + Vector(0,0,n), t.pos )
			n = n + 2
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

	local name = net.ReadString()
	local input = net.ReadString()
	local ent_index = net.ReadInt(32)

	--print("INPUT", name, input, ent_index)

	for k,gent in pairs( graph ) do
		if gent.index == ent_index then

			for _, output in pairs( gent.outputs ) do
				if output[3] == input and output[2] and gent.lines[ output[2] ] then
					table.insert( gent.blips, { t=CurTime(), target=output[2], speed = 300, } )
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

hook.Add( "PostRender", "hacker_vision", function()

	if map:IsLoading() then return end

	if not graph then
		local b,e = pcall( PrepGraph )
		if not b then print(e)
		else graph = e end
	end

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
	render.Clear( 0, 20, 100, 100, true, true )

	cam.Start(
		{
			x = 0,
			y = 0,
			w = w,
			h = h,
		})

		local b,e = pcall( function()

			for k,v in pairs( graph ) do
				gfx.renderBox( v.pos, Vector(-5,-5,-5), Vector(5,5,5), Color(100,80,0) )
			end

			for k,v in pairs( graph ) do

				for _, blip in pairs( v.blips ) do
					local line = v.lines[blip.target]
					local dt = blip.speed * (CurTime() - blip.t) / line.length
					local pulse = PointAlongLine( line, dt % 1 )
					gfx.renderBox( pulse, Vector(-2,-2,-2), Vector(2,2,2), Color(255,255,255,255) )
					for _, edge in pairs( line.edges ) do
						gfx.renderBeam(edge[1] or Vector(), edge[2] or Vector(), Color(255,80,80), Color(255,80,80), 20 * (1-dt))
					end
				end
				
				for target, l in pairs( v.lines ) do
					for _, edge in pairs( l.edges ) do
						gfx.renderBeam(edge[1] or Vector(), edge[2] or Vector(), nil, nil, 5)
					end
				end

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

end)