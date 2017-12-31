if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("remove_prop_scene")
end

SWEP.PrintName 		 		= "Prop Snatcher"
SWEP.Slot		 	 		= 0

SWEP.ViewModel		 		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel				= "models/weapons/w_pistol.mdl"
SWEP.HoldType		 		= "pistol"

SWEP.Primary.Delay			= 0.1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Ammo 			= "none"
SWEP.Primary.Sound	 		= Sound( "weapons/357/357_fire2.wav" )
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Ammo 		= "none"

SWEP.Spawnable 				= true
SWEP.RequestInfo			= {}
SWEP.KillsPeople			= false

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )	
end

function SWEP:SetupDataTables()
	--Might use this later, who the fuck knows
end

function SWEP:Deploy()
	return true
end

function SWEP:DrawWorldModel()

	self:DrawModel()

	--Might use this later, who the fuck knows
	local attach = self:LookupAttachment("muzzle")
	if attach > 0 then
		attach = self:GetAttachment(attach)
		attach = attach.Pos
	else
		attach = self.Owner:GetShootPos()
	end

end

function SWEP:ViewModelDrawn(viewmodel) end
function SWEP:Think() end
function SWEP:OnRemove() end

function SWEP:AcceptEntity( ent )

	--Accept only this kinda stuff
	if ent == nil then return false end
	if ent:GetClass() == "prop_physics" then return true end
	if ent:GetClass() == "prop_dynamic" then return true end
	if ent:GetClass() == "prop_ragdoll" then return true end
	if ent:IsNPC() then return true end
	print("FILTERED-OUT: " .. tostring(ent))
	return false

end

--Reach out and touch something
function SWEP:TraceToRemove()

	local pos = self.Owner:GetShootPos()
	local dir = self.Owner:GetAimVector()

	local tr = util.TraceLine( {
		start = pos,
		endpos = pos + dir * 100000,
		filter = self:GetOwner(),
	} )

	if self:AcceptEntity( tr.Entity ) and not tr.Entity.doing_removal then

		--Don't allow edge-case double-removal
		tr.Entity.doing_removal = true

		local phys = tr.Entity:GetPhysicsObject()

		--Send to the net
		net.Start("remove_prop_scene")
		net.WriteUInt( 1, 8 )
		net.WriteEntity( tr.Entity )
		net.WriteFloat( CurTime() )
		net.WriteVector( phys:IsValid() and phys:GetVelocity() or Vector(0,0,0) )
		net.WriteVector( phys:IsValid() and phys:GetAngleVelocity() or Vector(0,0,0) )
		net.Send( player.GetAll() )

		--After a very short time, remove the thing from the server
		timer.Simple(.02, function()
			if tr.Entity:IsNPC() and self.KillsPeople then
				if not string.find( tr.Entity:GetClass(), "strider" ) then
					tr.Entity:TakeDamage(10000, self.Owner, self)
				else
					tr.Entity:TakeDamage(2, self.Owner, self)
				end
			end
			tr.Entity:Remove()
		end )

		--Disable physics as much as possible
		if phys:IsValid() then
			phys:EnableCollisions(false)
			phys:EnableMotion(false)
		end

	end

end

function SWEP:PrimaryAttack()

	--Standard stuff
	if !self:CanPrimaryAttack() then return end

	if SERVER then
		self.Owner:EmitSound( self.Primary.Sound, 50, math.random( 200, 255 ) )
		self:TraceToRemove()
	end

	self:ShootEffects()

end

function SWEP:Holster(wep) return true end

function SWEP:ShootEffects()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end

function SWEP:Reload() return false end
function SWEP:CanPrimaryAttack() return true end
function SWEP:CanSecondaryAttack() return false end
function SWEP:CanSecondaryAttack() return false end
function SWEP:Reload() return false end


if CLIENT then

	local scenes = {}
	local nextEntityID = 0
	local beammaterial = Material("cable/physbeam")
	local spritematerial = Material( "sprites/light_ignorez" )

	local function ShouldMakeRagdoll( ent )

		--This one doesn't work for some reason
		if string.find( ent:GetClass(), "npc_clawscanner" ) then return false end

		--Check if modelinfo string contains the phrase "ragdollconstraint"
		return string.find( util.GetModelInfo( ent:GetModel() ).KeyValues or "", "ragdollconstraint" ) ~= nil
	end

	local function CopyEntityToClient( ent )

		--Check if a ragdoll should be made
		local should_ragdoll = ShouldMakeRagdoll( ent )

		--Create clientside entity
		local cl = ManagedCSEnt( "scene_entity_" .. tostring(nextEntityID), ent:GetModel(), should_ragdoll )
		nextEntityID = nextEntityID + 1

		--Copy basic parameters
		cl:SetPos( ent:GetPos() )
		cl:SetAngles( ent:GetAngles() )
		cl:SetSkin( ent:GetSkin() )
		cl:CreateShadow()

		return cl, should_ragdoll
	end

	net.Receive("remove_prop_scene", function()

		--Read the net
		local mode = net.ReadUInt( 8 )
		local ent = net.ReadEntity()
		local time = net.ReadFloat()
		local vel = net.ReadVector()
		local avel = net.ReadVector()

		--Entity needs to exist
		if not ent:IsValid() then return end

		--Store handle to previous entity
		local oldent = ent

		--Replace with new clientside entity
		local is_ragdoll = false
		ent, is_ragdoll = CopyEntityToClient( ent )

		if not is_ragdoll then

			--If not a ragdoll, init general prop physics
			ent:PhysicsInit( SOLID_VPHYSICS )
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:SetVelocity( vel )
				phys:AddAngleVelocity( avel )
			end

		else

			--If it is a ragdoll, copy all bone positions to physics objects
			oldent:SetupBones()

			for i=0, ent:GetPhysicsObjectCount()-1 do
				local boneid = oldent:TranslatePhysBoneToBone( i )
				if boneid > -1 then
					local mtx = oldent:GetBoneMatrix( boneid )
					local phys = ent:GetPhysicsObjectNum( i )
					if phys then
						phys:SetPos( mtx:GetTranslation(), true )
						phys:SetAngles( mtx:GetAngles() )
						phys:Wake()
						phys:SetVelocity( vel )
						phys:AddAngleVelocity( avel )
					end
				end
			end


		end

		--Draw the new entity
		ent:SetNoDraw( false )

		--Don't draw the old one
		oldent:SetNoDraw( true )
		oldent:DestroyShadow()

		--Create mingebag starter-kit
		local guy = ManagedCSEnt( "mingeboy" .. nextEntityID, "models/Kleiner.mdl" )
		local physcannon = ManagedCSEnt( "mingeboy" .. nextEntityID, "models/weapons/w_physics.mdl" )
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
		local basepos = oldent:GetPos() + Vector(0,0,2)
		local cull = {}
		for k,v in pairs( offsets ) do
			local ep = basepos + v * 2
			local tr = util.TraceLine( {
				start = basepos,
				endpos = ep,
				mask = MASK_SOLID,
				collisiongroup = COLLISION_GROUP_WEAPON,
				filter = { oldent, ent }
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

		--Build scene table
		table.insert( scenes, {
			is_ragdoll = is_ragdoll,
			guy = guy,
			physcannon = physcannon,
			mode = mode,
			ent = ent,
			time = time,
			duration = 4,
			koffset = koffset,
			guypos = ent:GetPos() + koffset - Vector(0,0,1000)
		})
	end)

	local function DoneScene( scene )

		if not scene.is_ragdoll then
			--DO NOT EVER DO THIS ON A RAGDOLL, IT CRASHES HARD
			scene.ent:PhysicsDestroy()
		else

			--CSEnts linger for a bit before being garbage collected,
			--freeze the ragdoll so it doesn't make any noise.
			for i=0, scene.ent:GetPhysicsObjectCount()-1 do

				local phys = scene.ent:GetPhysicsObjectNum(i)
				phys:EnableMotion(false)

			end

		end

		--We're done with the CSEnt, so don't draw it
		scene.ent:SetNoDraw( true )

	end

	local function DrawScene( scene )

		local dt = ( CurTime() - scene.time )

		local blink = 3.85
		if dt > blink then

			--SHING
			local sdt = ((CurTime() - scene.time) - blink) / (scene.duration - blink)
			local sc = 4 * (sdt * (1-sdt))

			render.SetMaterial( spritematerial )
			render.DrawSprite( scene.ent:GetPos(), 3000 * sc, 3000 * sc, Color(255,255,255) )
			render.DrawSprite( scene.ent:GetPos(), 200 * sc, 6000 * sc, Color(255,255,255) )
			render.DrawSprite( scene.ent:GetPos(), 6000 * sc, 200 * sc, Color(255,255,255) )

			if not scene.sfx_played then
				scene.sfx_played = true
				EmitSound( "jazztronauts/ding.wav", scene.ent:GetPos(), scene.ent:EntIndex(), CHAN_AUTO, 1, 75, 0, 100 )
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
		local guyangle = (scene.ent:GetPos() - scene.guypos):GetNormalized():Angle()

		--Transform guy
		scene.guy:EnableMatrix( "RenderMultiply", mtx )
		scene.guy:SetAngles( guyangle )
		scene.guy:SetPos( scene.guypos )
		scene.guy:SetupBones()

		--Get primo physgun location
		local physpos = scene.guy:GetBonePosition( scene.guy:LookupBone( "ValveBiped.Bip01_Pelvis" ) )

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
				scene.ent:EnableMatrix( "RenderMultiply", mtx )
			else
				--Optional stupid looking bone scaling
				--[[for i=0, scene.ent:GetBoneCount()-1 do
					scene.ent:ManipulateBoneScale( i, Vector(scale, scale, scale) )
				end]]
			end

		end

		--Physgun turns on after one second
		if CurTime() - scene.time > 1 then

			--Draw the phys beam
			physpos = physpos + guyangle:Forward() * 20 * scale

			local dist = physpos:Distance(scene.ent:GetPos())
			local offset = -CurTime()*4

			render.SetMaterial( beammaterial )
			render.DrawBeam( physpos, scene.ent:GetPos(), 10 * scale, offset, dist/100 + offset, color_blue)

		end

	end

	--Physics stuff has to happen in here
	function TickScene( scene )

		--Where the guy wants to be
		local guytargetpos = scene.ent:GetPos() + scene.koffset

		--Interpolate movement to the target position
		scene.guypos:Add( (guytargetpos - scene.guypos) * (1 - math.exp(FrameTime() * -4)) )

		--Physgun turns on after one second
		if CurTime() - scene.time > 1 then

			if not scene.is_ragdoll then

				--Regular props are pushed upward at a constant rate, they also spin
				local phys = scene.ent:GetPhysicsObject()
				if phys:IsValid() then

					scene.ent:GetPhysicsObject():ApplyForceCenter( Vector(0,0,800) * scene.ent:GetPhysicsObject():GetMass() * FrameTime() )
					scene.ent:GetPhysicsObject():AddAngleVelocity( Vector(0,0,1000) * FrameTime() )

				else

					--No physics? just move the thing
					scene.ent:SetPos( scene.ent:GetPos() + Vector(0,0,100) * FrameTime() )

				end

			else

				--Same thing for ragdolls but do it to all physobjects
				for i=0, scene.ent:GetPhysicsObjectCount()-1 do

					local phys = scene.ent:GetPhysicsObjectNum(i)

					phys:ApplyForceCenter( Vector(0,0,800) * phys:GetMass() * FrameTime() )
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

end