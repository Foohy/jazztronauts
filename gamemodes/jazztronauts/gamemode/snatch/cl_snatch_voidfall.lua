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

local strainbig = {
	Sound("npc/dog/dog_straining1.wav"),
	Sound("npc/dog/dog_straining2.wav"),
	Sound("npc/dog/dog_straining3.wav")
}

local popbig = {
	Sound("weapons/underwater_explode3.wav"),
	Sound("weapons/underwater_explode4.wav")
}

local function getScale(scene)
	local min, max = scene:GetEntity():GetRenderBounds()
	local size = max - min

	local scale = math.max(size.x * size.y, size.x * size.z, size.y * size.z)
	local remapped = math.Clamp(math.Remap(scale, 1000, 700000, 0, 1), 0, 1)

	return remapped
end

local function isBigTake(scale)
	return scale > 0.8
end

local function Handle( scene )
	if scene:GetMode() ~= 2 then return end

	local scale = getScale(scene)
	local bigTake = isBigTake(scale)

	scene.duration = bigTake and 5 or 4
	scene.breaktime = bigTake and 1.8 or 0
	scene.startpos = scene:GetRealEntity():GetPos()
	local eyes = vector_origin
	if IsValid(LocalPlayer()) then eyes = LocalPlayer():EyePos() end
	scene.startvel = (eyes - scene.startpos):GetNormalized() * 100 + Vector(0, 0, 100)
	scene.angvel = AngleRand() * 0.25
	scene:GetEntity():SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

	local phys = scene:GetEntity():GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

	local sounds = bigTake and strainbig or strainsounds
	sound.Play(table.Random(sounds), scene.startpos, 85 + scale* 35, 120 - (1 - scale) * 50)

	--Build scene table
	table.insert( scenes, scene )

end

hook.Add( "HandlePropSnatch", "snatch_voidfall", Handle )


local function DoneScene( scene )

	scene:Finish()

end

local function DrawScene( scene )
	if not IsValid(scene:GetEntity()) then return end

	-- Redraw the entity in the jazz void
	scene:GetEntity():DrawModel()
end

--Physics stuff has to happen in here
local function TickScene( scene )
	local t = (CurTime() - scene.time)
	local p = t / scene.duration
	local ent = scene:GetEntity()
	if not IsValid(ent) then return end

	if t > scene.breaktime then
		t = t - scene.breaktime

		if not scene.playedPop then
			scene.playedPop = true
			local scale = getScale(scene)
			local bigTake = isBigTake(scale)

			sound.Play( "garrysmod/balloon_pop_cute.wav", scene.startpos, 85 + scale * 35, 120 - scale * 90)
			if bigTake then
				sound.Play( table.Random(popbig), scene.startpos, 85 + scale * 35, 120 - scale * 90, 0.5)
			end

			local distScale = scene.startpos:Distance(LocalPlayer():EyePos())
			util.ScreenShake(scene.startpos, 8, 8, 0.25 + scale - distScale * 0.0001, 0)
		end

		ent:SetModelScale(1 - t / (scene.duration - scene.breaktime))

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
		local pos = scene.startpos + VectorRand() * math.Clamp(scene.breaktime - 0.25 - t, 0, 1) * 3
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