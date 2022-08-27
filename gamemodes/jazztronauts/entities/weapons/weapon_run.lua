if SERVER then
	AddCSLuaFile()
end

SWEP.Base					= "weapon_basehold"
SWEP.PrintName				= JazzLocalize("jazz.weapon.run")
SWEP.Slot					= 0
SWEP.Category				= "#jazz.weapon.category"
SWEP.Purpose				= "#jazz.weapon.run.desc"
SWEP.WepSelectIcon			= Material( "weapons/weapon_run.png" )

SWEP.ViewModel				= "models/weapons/c_run.mdl"
SWEP.WorldModel				= "models/weapons/w_run.mdl"

SWEP.UseHands		= true

SWEP.HoldType				= "duel"

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.Primary.Delay			= 0.1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Sound			= Sound( "weapons/357/357_fire2.wav" )
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo		= "none"

SWEP.Spawnable				= true
SWEP.RequestInfo			= {}

-- List this weapon in the store
local storeRun = jstore.Register(SWEP, 10000, { type = "tool" })

-- No fall damage upgrade
local run_nofall = jstore.Register("run_nofall", 15000, {
	name = JazzLocalize("jazz.weapon.stan.upgrade.nofall"),
	--cat = JazzLocalize("jazz.weapon.run"),
	desc = JazzLocalize("jazz.weapon.stan.upgrade.nofall.desc"),
	type = "upgrade",
	requires = storeRun
})

function SWEP:Initialize()

	self.BaseClass.Initialize( self )
	self:SetWeaponHoldType( self.HoldType )

	if CLIENT then
		self:SetUpgrades()
	end
end

function SWEP:OwnerChanged()
	self:SetUpgrades()
end

-- Query and apply current upgrade settings to this weapon
function SWEP:SetUpgrades()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	self.IgnoreFallDamage = unlocks.IsUnlocked("store", owner, run_nofall)
end

function SWEP:ShouldTakeFallDamage()
	return not self.IgnoreFallDamage
end

function SWEP:SetupDataTables()
	self.BaseClass.SetupDataTables( self )
end

function SWEP:Deploy()

	if SERVER then
		local owner = self:GetOwner()
		self.OldRunSpeed = owner:GetRunSpeed()
		self.OldWalkSpeed = owner:GetWalkSpeed()
		self.OldJumpPower = owner:GetJumpPower()
	end

	self:SendWeaponAnim(ACT_VM_IDLE)

	return true

end

function SWEP:Cleanup()
	local owner = self:GetOwner()
	if SERVER and self.OldRunSpeed and IsValid(owner) then
		owner:SetRunSpeed(self.OldRunSpeed)
		owner:SetWalkSpeed(self.OldWalkSpeed)
		owner:SetJumpPower(self.OldJumpPower)

		--clean up posing
		local arm_right = owner:LookupBone( "ValveBiped.Bip01_R_UpperArm" )
		local arm_right2 = owner:LookupBone( "ValveBiped.Bip01_R_ForeArm" )
		local arm_left = owner:LookupBone( "ValveBiped.Bip01_L_UpperArm" )
		local arm_left2 = owner:LookupBone( "ValveBiped.Bip01_L_ForeArm" )
		local spine = owner:LookupBone( "ValveBiped.Bip01_Spine1" )

		if arm_left and arm_left2 then
			owner:ManipulateBoneAngles( arm_left, Angle(0,0,0) )
			owner:ManipulateBoneAngles( arm_left2, Angle(0,0,0) )
		end

		if arm_right and arm_right2 then
			owner:ManipulateBoneAngles( arm_right, Angle(0,0,0) )
			owner:ManipulateBoneAngles( arm_right2, Angle(0,0,0) )
		end

		if spine then
			owner:ManipulateBoneAngles( spine, Angle(0,0,0) )
		end
	end
end

function SWEP:DrawWorldModel()

	self:DrawModel()

	local ent = self:GetOwner()

	if not IsValid( ent ) then return end

	local arm_right = ent:LookupBone( "ValveBiped.Bip01_R_UpperArm" )
	local arm_right2 = ent:LookupBone( "ValveBiped.Bip01_R_ForeArm" )
	local arm_left = ent:LookupBone( "ValveBiped.Bip01_L_UpperArm" )
	local arm_left2 = ent:LookupBone( "ValveBiped.Bip01_L_ForeArm" )
	local spine = ent:LookupBone( "ValveBiped.Bip01_Spine1" )


	--[[for i=0, ent:GetBoneCount() do

		print( tostring( ent:GetBoneName( i ) ) )

	end]]

	local t = 0--CurTime() * 1000

	local v = math.min( ent:GetVelocity():Length() / 100, 1 )

	if ent:OnGround() then t = 0 end

	if arm_left and arm_left2 then
		ent:ManipulateBoneAngles( arm_left, Angle(0,80*v,0) )
		ent:ManipulateBoneAngles( arm_left2, Angle(0,80*v,0) )
	end

	if arm_right and arm_right2 then
		ent:ManipulateBoneAngles( arm_right, Angle(0,100*v,0) )
		ent:ManipulateBoneAngles( arm_right2, Angle(0,70*v,0) )
	end

	if spine then
		ent:ManipulateBoneAngles( spine, Angle(0,30*v,0) )
	end

end

function SWEP:PreDrawViewModel(viewmodel, weapon, ply)

	if IsValid(ply) then
        local movex = ply:GetPoseParameter("move_x") or 0.5
        local movey = ply:GetPoseParameter("move_y") or 0.5
		local playback = 0.5 + ply:GetVelocity():Length2DSqr() / 1280000 --(800 * 800 * 2)

        self.CurPoseX = self.CurPoseX or 0.5
        self.CurPoseY = self.CurPoseY or 0.5
		self.CurPlayback = self.CurPlayback or 0.5

        -- Approach goal
        local APPROACH_SPEED = 2
        self.CurPoseX = math.Approach(self.CurPoseX, movex, FrameTime() * APPROACH_SPEED)
        self.CurPoseY = math.Approach(self.CurPoseY, movey, FrameTime() * APPROACH_SPEED)
		self.CurPlayback = math.Approach(self.CurPlayback, playback, FrameTime() * APPROACH_SPEED)

        viewmodel:SetPoseParameter("move_x", math.Remap( self.CurPoseX, 0, 1, -1, 1))
        viewmodel:SetPoseParameter("move_y", math.Remap( self.CurPoseY, 0, 1, -1, 1))
		viewmodel:SetPlaybackRate(self.CurPlayback)
    end

end

function SWEP:DrawHUD()

end

function SWEP:CalcViewModelView( viewmodel, oldpos, oldang, pos, ang )

	return pos, ang

end

function SWEP:CalcView( ply, pos, ang, fov )

	return pos, ang, fov

end

function SWEP:Think()

	local owner = self:GetOwner()
	owner:SetWalkSpeed( 800 )
	owner:SetRunSpeed( 800 )
	owner:SetJumpPower( 500 )

end

function SWEP:CanPrimaryAttack()

	return true

end

function SWEP:PrimaryAttack()

	self.BaseClass.PrimaryAttack( self )

end

function SWEP:ShootEffects()

	local owner = self:GetOwner()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	owner:MuzzleFlash()
	owner:SetAnimation( PLAYER_ATTACK1 )

end

function SWEP:Reload() return false end
function SWEP:CanSecondaryAttack() return false end
