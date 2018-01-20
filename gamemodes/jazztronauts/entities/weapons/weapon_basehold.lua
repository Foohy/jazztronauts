if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName 		 		= "Holding"
SWEP.Slot		 	 		= 0

SWEP.ViewModel		 		= "models/weapons/c_pistol.mdl"
SWEP.WorldModel				= "models/weapons/w_pistol.mdl"

SWEP.UseHands		= true

SWEP.HoldType		 		= "pistol"

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.Primary.Delay			= 1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Ammo 			= "none"
SWEP.Primary.Sound	 		= Sound( "weapons/357/357_fire2.wav" )
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Ammo 		= "none"

SWEP.Spawnable 				= false
SWEP.RequestInfo			= {}

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )
	self.IsAttackHeld = false

end

function SWEP:SetupDataTables()

--	self:NetworkVar("Bool", 0, "Attacking")
--	self:NetworkVar("Float", 0, "AttackStart")

end

function SWEP:Deploy()

	return true

end

function SWEP:GetMuzzleAttachment()
	
	local attach = self:LookupAttachment("muzzle")
	if attach > 0 then
		attach = self:GetAttachment(attach)
		attach = attach.Pos
	else
		attach = self.Owner:GetShootPos()
	end

	return attach

end

function SWEP:DrawWorldModel()

	self:DrawModel()

end

function SWEP:ViewModelDrawn(viewmodel) end
function SWEP:Think() end
function SWEP:OnRemove() end

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() then return end

	if self.IsAttackHeld == false then

		self.IsAttackHeld = true
		self:StartAttack()

	end

end

function SWEP:StartAttack() 

end

function SWEP:StopAttack() 

end

function SWEP:IsAttacking()

	return self.IsAttackHeld

end

function SWEP:Holster(wep)

	if self.IsAttackHeld then 
		self:StopAttack()
		self.IsAttackHeld = false
	end

	self:Cleanup()

	return true

end

function SWEP:OnRemove()

	if self.IsAttackHeld then 
		self:StopAttack()
		self.IsAttackHeld = false
	end

	self:Cleanup()

end

function SWEP:Cleanup() end

function SWEP:ShootEffects()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end

function SWEP:Reload() return false end
function SWEP:CanPrimaryAttack() return true end
function SWEP:CanSecondaryAttack() return false end

hook.Add("KeyRelease", "ReleaseTriggerOnGunsWhatCanBeHeldDown", function(ply, key)

	local wep = ply:GetActiveWeapon()
	if key == IN_ATTACK and IsValid( wep ) and wep.StopAttack then

		if wep.IsAttackHeld then

			wep:StopAttack()
			wep.IsAttackHeld = false


		end

	end

end )