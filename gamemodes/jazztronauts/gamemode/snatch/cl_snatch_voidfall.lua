local scenes = {}
local strainsounds = {
	Sound("physics/metal/metal_solid_strain1.wav"),
	Sound("physics/metal/metal_solid_strain2.wav"),
	Sound("physics/metal/metal_solid_strain3.wav"),
	Sound("physics/metal/metal_solid_strain4.wav"),
	Sound("physics/metal/metal_solid_strain5.wav"),
	Sound("physics/metal/metal_box_strain1.wav"),
	Sound("physics/metal/metal_box_strain2.wav"),
	Sound("physics/metal/metal_box_strain3.wav"),
	Sound("physics/metal/metal_box_strain4.wav")
}

local function Handle( scene )

	if scene:GetMode() ~= 2 then return end
	--scene:GetRealEntity(), scene:GetEntity()

	scene.duration = 4
	scene.startpos = scene:GetRealEntity():GetPos()
	scene.startvel = (LocalPlayer():EyePos() - scene.startpos):GetNormalized() * 100 + Vector(0, 0, 100)
	scene.angvel = AngleRand() * 0.25
	scene:GetEntity():SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

	local phys = scene:GetEntity():GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

	sound.Play(table.Random(strainsounds), scene.startpos, 85, math.Rand(75, 100))

	--Build scene table
	table.insert( scenes, scene )

end

hook.Add( "HandlePropSnatch", "snatch_voidfall", Handle )


local function DoneScene( scene )

	scene:Finish()

end

local function DrawScene( scene )
	if (CurTime() - scene.time) < 1 then return end 

	-- Redraw the entity in the jazz void
	scene:GetEntity():DrawModel()
end

--Physics stuff has to happen in here
local function TickScene( scene )
	local t = (CurTime() - scene.time)
	local p = t / scene.duration
	local ent = scene:GetEntity()

	if t > 1 then
		t = t - 1

		if not scene.playedPop then
			scene.playedPop = true
			sound.Play( "garrysmod/balloon_pop_cute.wav", scene.startpos, 95, math.random(50, 80))
		end

		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableGravity(true)
		else
			local pos = scene.startpos + scene.startvel * t
			pos = pos + 0.5 * physenv.GetGravity() * (t ^ 2)
			ent:SetPos( pos )

			ent:SetAngles( scene.angvel * t)

		end
	else
		local pos = scene.startpos + VectorRand() * math.max(0, .5 - t) * 5
		ent:SetPos( pos )
	end

end

hook.Add( "Think", "TickVoidRemoveScenes", function() 
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

hook.Add("JazzDrawVoid", "DrawInsideVoidRemoveScenes", function()
	for i=#scenes, 1, -1 do
		if CurTime() - scenes[i].time <= scenes[i].duration then
			DrawScene( scenes[i] )
		end
	end
end )