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

	-- Call the think function for other clients too
	-- It's not canon, but it's kind of nice to be able to do this
	if CLIENT then
		hook.Add("Think", self, function(self)
			if LocalPlayer() != self.Owner then self:Think() end
		end )
	end
end

function SWEP:SetupDataTables()

	 -- Used for networking to other players only
	self:NetworkVar("Bool", 31, "IsAttacking")
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
		self:SetIsAttacking(true)

	end

end

function SWEP:StartAttack() 

end

function SWEP:StopAttack() 

end

function SWEP:IsAttacking()
	if SERVER or (self.Owner == LocalPlayer() and not game.SinglePlayer()) then
		return self.IsAttackHeld
	else 
		return self.GetIsAttacking and self:GetIsAttacking() 
	end
end

function SWEP:StopAttacking()

	if self.IsAttackHeld then 
		self:StopAttack()
		self.IsAttackHeld = false
		self:SetIsAttacking(false)
	end	

end

function SWEP:Holster(wep)

	self:StopAttacking()
	self:Cleanup()

	return true

end

function SWEP:OnRemove()

	self:StopAttacking()
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
	if key == IN_ATTACK and IsValid( wep ) and wep.StopAttacking then

		if wep.IsAttackHeld then

			wep:StopAttacking()
			wep.IsAttackHeld = false


		end

	end

end )