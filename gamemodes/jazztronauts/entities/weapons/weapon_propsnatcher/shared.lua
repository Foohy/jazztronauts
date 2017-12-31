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

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )	
end

function SWEP:SetupDataTables()

end

function SWEP:Deploy()
	return true
end

function SWEP:DrawWorldModel()

	self:DrawModel()

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

function SWEP:TraceToRemove()
	local pos = self.Owner:GetShootPos()
	local dir = self.Owner:GetAimVector()

	local tr = util.TraceLine( {
		start = pos,
		endpos = pos + dir * 100000,
		mask = MASK_SOLID,
		collisiongroup = COLLISION_GROUP_WEAPON
	} )

	if tr.Entity and tr.Entity:GetClass() == "prop_physics" and not tr.Entity.doing_removal then
		tr.Entity.doing_removal = true

		local phys = tr.Entity:GetPhysicsObject()

		net.Start("remove_prop_scene")
		net.WriteUInt( 1, 8 )
		net.WriteEntity( tr.Entity )
		net.WriteFloat( CurTime() )
		net.WriteVector( phys:GetVelocity() )
		net.WriteVector( phys:GetAngleVelocity() )
		net.Send( player.GetAll() )
		timer.Simple(.02, function()
			tr.Entity:Remove()
		end )

		phys:EnableCollisions(false)
		phys:EnableMotion(false)
	end
end

function SWEP:PrimaryAttack()
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

	local function CopyEntityToClient( ent )
		local cl = ManagedCSEnt( "scene_entity_" .. tostring(nextEntityID), ent:GetModel() )
		nextEntityID = nextEntityID + 1

		cl:SetPos( ent:GetPos() )
		cl:SetAngles( ent:GetAngles() )
		cl:CreateShadow()

		return cl
	end

	net.Receive("remove_prop_scene", function()
		local mode = net.ReadUInt( 8 )
		local ent = net.ReadEntity()
		local time = net.ReadFloat()
		local vel = net.ReadVector()
		local avel = net.ReadVector()

		if not ent:IsValid() then return end
		local oldent = ent
		ent = CopyEntityToClient( ent )

		ent:PhysicsInit( SOLID_VPHYSICS )
		ent:GetPhysicsObject():SetVelocity( vel )
		ent:GetPhysicsObject():AddAngleVelocity( avel )
		ent:SetNoDraw( false )

		oldent:SetNoDraw( true )
		oldent:DestroyShadow()

		local koffset = Vector(100,0,0)
		local guy = ManagedCSEnt( "mingeboy" .. nextEntityID, "models/Kleiner.mdl" )
		local physcannon = ManagedCSEnt( "mingeboy" .. nextEntityID, "models/weapons/w_physics.mdl" )
		nextEntityID = nextEntityID + 1

		guy:SetNoDraw( true )
		physcannon:SetNoDraw( true )

		table.insert( scenes, {
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

		scene.ent:PhysicsDestroy()
		scene.ent:SetNoDraw( true )

	end

	local function DrawScene( scene )

		local dt = ( CurTime() - scene.time )


		local blink = 3.85
		if dt > blink then
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

		local scale = 1 - ( (math.max( dt, 1 ) - 1) / (scene.duration - 1) )
		local mtx = Matrix({
			{scale, 0, 0, 0},
			{0, scale, 0, 0},
			{0, 0, scale, 0},
			{0, 0, 0, 1},
		})

		local guytargetpos = scene.ent:GetPos() + scene.koffset

		scene.guypos:Add( (guytargetpos - scene.guypos) * (1 - math.exp(FrameTime() * -4)) )

		local guyangle = (scene.ent:GetPos() - scene.guypos):GetNormalized():Angle()

		scene.guy:EnableMatrix( "RenderMultiply", mtx )
		scene.guy:SetAngles( guyangle )
		scene.guy:SetPos( scene.guypos )
		scene.guy:SetupBones()

		local physpos = scene.guy:GetBonePosition( scene.guy:LookupBone( "ValveBiped.Bip01_Pelvis" ) )

		scene.physcannon:EnableMatrix( "RenderMultiply", mtx )
		scene.physcannon:SetAngles( guyangle )
		scene.physcannon:SetPos( physpos )
		scene.physcannon:DrawModel()

		scene.guy:DrawModel()

		if scale < 1 then
			scene.ent:SetNoDraw( true )
			scene.ent:EnableMatrix( "RenderMultiply", mtx )
			scene.ent:DrawModel()
		end

		if CurTime() - scene.time > 1 then

			scene.ent:GetPhysicsObject():AddVelocity( Vector(0,0,500) * FrameTime() )
			scene.ent:GetPhysicsObject():AddAngleVelocity( Vector(0,0,1000) * FrameTime() )

			physpos = physpos + guyangle:Forward() * 20 * scale

			local dist = physpos:Distance(scene.ent:GetPos())
			local offset = -CurTime()*4

			render.SetMaterial( beammaterial )
			render.DrawBeam( physpos, scene.ent:GetPos(), 10 * scale, offset, dist/100 + offset, color_blue)

		end

	end

	hook.Add( "PostDrawOpaqueRenderables", "DrawRemoveScenes", function(depth, sky)
	
		for i=#scenes, 1, -1 do
			if CurTime() - scenes[i].time > scenes[i].duration then
				DoneScene( scenes[i] )
				table.remove( scenes, i )
			else
				DrawScene( scenes[i] )
			end
		end

	end)

end