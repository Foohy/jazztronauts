if SERVER then
	AddCSLuaFile()
end

SWEP.Base					= "weapon_basehold"
SWEP.PrintName				= "Run"
SWEP.Slot					= 0
SWEP.Category				= "Jazztronauts"
SWEP.Purpose				= "Jump higher and run faster. "

SWEP.ViewModel				= "models/weapons/c_pistol.mdl"
SWEP.WorldModel				= "models/weapons/w_pistol.mdl"

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
	name = "Ignore Fall Damage",
	cat = "Run",
	desc = "Fall from any height, and while Run is equipped, you will take zero fall damage.",
	type = "upgrade",
	requires = storeRun
})

function SWEP:Initialize()

	self.BaseClass.Initialize( self )
	self:SetWeaponHoldType( self.HoldType )

	timer.Simple(0, function()
		self:SetUpgrades()
	end)
end

-- Query and apply current upgrade settings to this weapon
function SWEP:SetUpgrades()
	if not IsValid(self.Owner) then return end

	self.IgnoreFallDamage = unlocks.IsUnlocked("store", self.Owner, run_nofall)
end

function SWEP:ShouldTakeFallDamage()
	return not self.IgnoreFallDamage
end

function SWEP:SetupDataTables()
	self.BaseClass.SetupDataTables( self )
end

function SWEP:Deploy()

	if SERVER then
		self.OldRunSpeed = self.Owner:GetRunSpeed()
		self.OldWalkSpeed = self.Owner:GetWalkSpeed()
		self.OldJumpPower = self.Owner:GetJumpPower()
	end

	return true

end

function SWEP:Cleanup()
	if SERVER and self.OldRunSpeed and IsValid(self.Owner) then
		self.Owner:SetRunSpeed(self.OldRunSpeed)
		self.Owner:SetWalkSpeed(self.OldWalkSpeed)
		self.Owner:SetJumpPower(self.OldJumpPower)
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


	for i=0, ent:GetBoneCount() do

		--print( tostring( ent:GetBoneName( i ) ) )

	end

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

end

function SWEP:ViewModelDrawn( viewmodel )

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

	self.Owner:SetWalkSpeed( 800 )
	self.Owner:SetRunSpeed( 800 )
	self.Owner:SetJumpPower( 500 )

end

function SWEP:CanPrimaryAttack()

	return true

end

function SWEP:PrimaryAttack()

	self.BaseClass.PrimaryAttack( self )

end

function SWEP:ShootEffects()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end

function SWEP:Reload() return false end
function SWEP:CanSecondaryAttack() return false end
