local scenes = {}
local nextEntityID = 0
local beammaterial = Material("cable/physbeam")
local spritematerial = Material( "sprites/light_ignorez" )

local function Handle( scene )

	if scene:GetMode() ~= 1 then return end


	--Create mingebag starter-kit
	local guy = ManagedCSEnt( "mingeboy" .. nextEntityID, "models/jazztronauts/zak/Boneless_Kleiner.mdl" )
	local physcannon = ManagedCSEnt( "mingeboy" .. nextEntityID, "models/weapons/w_physics.mdl" )
	physcannon:SetSkin(1)
	nextEntityID = nextEntityID + 1

	--Build a list of directions to spawn the guy relative to the prop
	--based on where the player is looking
	local angle = EyeAngles()
	angle.p = 0
	local offsets = {
		angle:Forward() * 30 + angle:Right() * 50,
		angle:Forward() * -30 + angle:Right() * -50,
		angle:Forward() * -30 + angle:Right() * 50,
		angle:Forward() * 30 + angle:Right() * -50,
		angle:Forward() * -30,
	}

	--Cull invalid offsets (offsets where the guy's gonna be in a wall)
	local basepos = scene:GetRealEntity():GetPos() + Vector(0,0,2)
	local cull = {}
	for k,v in pairs( offsets ) do
		local ep = basepos + v * 2
		local tr = util.TraceLine( {
			start = basepos,
			endpos = ep,
			mask = MASK_SOLID,
			collisiongroup = COLLISION_GROUP_WEAPON,
			filter = { scene:GetRealEntity(), scene:GetEntity() }
		} )

		if tr.Fraction > .5 then
			table.insert( cull, v )
		end
	end

	--Cut our losses by choosing the next best offset (closest)
	if #cull == 0 then table.insert( cull, offsets[#offsets] ) end

	--Choose a random offset from the culled list
	local koffset = cull[ math.random(1, #cull) ]

	--Don't draw mingebag stuff, drawmodel will be called later
	guy:SetNoDraw( true )
	physcannon:SetNoDraw( true )

	scene.guy = guy
	scene.physcannon = physcannon
	scene.duration = 4
	scene.koffset = koffset
	scene.guypos = scene:GetEntity():GetPos() + koffset - Vector(0,0,1000)

	-- If static prop, ignore collisions and re-render in void
	if scene.is_proxy then
		local ent = scene:GetEntity()
		ent:PhysicsDestroy()
	end

	--Build scene table
	table.insert( scenes, scene )

end

hook.Add( "HandlePropSnatch", "snatch_kleiner", Handle )


local function DoneScene( scene )

	scene:Finish()

end

local function DrawScene( scene, voidrender )
	-- Verify first if it exists.
	if not scene:GetEntity():IsValid() then return end

	-- If rendering in void ONLY render the prop
	-- Also only do this for static props for performance reasons
	if voidrender and scene.is_proxy then
		local ent = scene:GetEntity()
		ent:DrawModel()
	end

	local dt = ( CurTime() - scene.time )
	local pos = scene:GetEntity():GetPos()

	local blink = 3.85
	if dt > blink then

		--SHING
		local sdt = ((CurTime() - scene.time) - blink) / (scene.duration - blink)
		local sc = 0.25 * (sdt * (1-sdt))

		render.SetMaterial( spritematerial )
		render.DrawSprite( pos, 3000 * sc, 3000 * sc, Color(255,255,255) )
		render.DrawSprite( pos, 200 * sc, 6000 * sc, Color(255,255,255) )
		render.DrawSprite( pos, 6000 * sc, 200 * sc, Color(255,255,255) )

		if not scene.sfx_played then
			scene.sfx_played = true
			EmitSound( "jazztronauts/ding.wav", pos, scene:GetEntity():EntIndex(), CHAN_AUTO, 1, 75, 0, 100 )
		end

	end

	--Scale everything based on time since mingeboy picks up the thing
	local scale = 1 - ( (math.max( dt, 1 ) - 1) / (scene.duration - 1) )
	local mtx = Matrix({
		{scale, 0, 0, 0},
		{0, scale, 0, 0},
		{0, 0, scale, 0},
		{0, 0, 0, 1},
	})

	--Aim our guy at the prop
	local guyangle = (pos - scene.guypos):GetNormalized():Angle()

	--Transform guy
	scene.guy:EnableMatrix( "RenderMultiply", mtx )
	scene.guy:SetAngles( guyangle )
	scene.guy:SetPos( scene.guypos )

	--Get primo physgun location
	local physpos = scene.guypos

	--Attach physgun to guy
	scene.physcannon:EnableMatrix( "RenderMultiply", mtx )
	scene.physcannon:SetAngles( guyangle )
	scene.physcannon:SetPos( physpos )

	--Draw things
	scene.physcannon:DrawModel()
	scene.guy:DrawModel()

	if scale < 1 then

		--If we're scaling, start applying transform matrix to prop,
		--this only works on regular props though
		if not scene.is_ragdoll then
			scene:GetEntity():EnableMatrix( "RenderMultiply", mtx )
		else
			--Optional stupid looking bone scaling
			--[[for i=0, scene:GetEntity():GetBoneCount()-1 do
				scene:GetEntity():ManipulateBoneScale( i, Vector(scale, scale, scale) )
			end]]
		end

	end

	--Physgun turns on after one second
	if CurTime() - scene.time > 1 then

		--Draw the phys beam
		physpos = physpos + guyangle:Forward() * 20 * scale

		local dist = physpos:Distance( pos )
		local offset = -CurTime()*4

		render.SetMaterial( beammaterial )
		render.DrawBeam( physpos, pos, 10 * scale, offset, dist/100 + offset, color_blue)

	end

end

--Physics stuff has to happen in here
local function TickScene( scene )
	-- Verify first if it exists.
	if not scene:GetEntity():IsValid() then return end

	--Where the guy wants to be
	local guytargetpos = scene:GetEntity():GetPos() + scene.koffset

	--Interpolate movement to the target position
	scene.guypos:Add( (guytargetpos - scene.guypos) * (1 - math.exp(FrameTime() * -4)) )

	--Physgun turns on after one second
	if CurTime() - scene.time > 1 then

		if not scene.is_ragdoll then

			--Regular props are pushed upward at a constant rate, they also spin
			local ent = scene:GetEntity()
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then

				phys:ApplyForceCenter( Vector(0,0,1000) * phys:GetMass() * FrameTime() )
				phys:AddAngleVelocity( Vector(0,0,1000) * FrameTime() )

			else

				--No physics? just move the thing
				scene.velocity = scene.velocity or 0
				scene.velocity = scene.velocity + 0.5 * FrameTime()
				ent:SetPos( ent:GetPos() + Vector(0,0, 200) * scene.velocity * FrameTime() )
				ent:SetAngles(ent:GetAngles() + Angle(100, 300, 200) * scene.velocity * FrameTime())

			end

		else

			local ent = scene:GetEntity()

			--Same thing for ragdolls but do it to all physobjects
			for i=0, ent:GetPhysicsObjectCount()-1 do

				local phys = ent:GetPhysicsObjectNum(i)

				phys:ApplyForceCenter( Vector(0,0,1000) * phys:GetMass() * FrameTime() )
				phys:AddAngleVelocity( Vector(0,0,1000) * FrameTime() )

			end

		end

	end

end

hook.Add( "Think", "TickRemoveScenes", function()

	for i=#scenes, 1, -1 do

		if CurTime() - scenes[i].time > scenes[i].duration then
			--Finish and remove after time elapses
			DoneScene( scenes[i] )
			table.remove( scenes, i )
		else
			--Otherwise, tick
			TickScene( scenes[i] )
		end

	end

end)

hook.Add( "PostDrawOpaqueRenderables", "DrawRemoveScenes", function(depth, sky)

	for i=#scenes, 1, -1 do

		if CurTime() - scenes[i].time <= scenes[i].duration then
			--Draw scene if time left
			DrawScene( scenes[i] )
		end

	end

end)

hook.Add("JazzDrawVoid", "DrawRemoveSceneVoid", function()
	for i=#scenes, 1, -1 do
		if CurTime() - scenes[i].time <= scenes[i].duration then
			DrawScene( scenes[i], true )
		end
	end
end )
