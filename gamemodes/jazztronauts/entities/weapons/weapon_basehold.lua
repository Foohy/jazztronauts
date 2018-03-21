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

local WEAPON_PRIMARY    = IN_ATTACK
local WEAPON_SECONDARY  = IN_ATTACK2

local function AddWeaponFireMode(self, netvar, hookname)
	return { 
		IsHeld = false, 
		SetNet = self["Set" .. netvar], 
		GetNet = self["Get" .. netvar],
		StartHook = self["Start" .. hookname],
		StopHook = self["Stop" .. hookname]
	}
end

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

	self.AttackStates = {}
	self.AttackStates[WEAPON_PRIMARY] = AddWeaponFireMode(self, "IsAttacking", "PrimaryAttack")
	self.AttackStates[WEAPON_SECONDARY] = AddWeaponFireMode(self, "IsSecondaryAttacking", "SecondaryAttack")

	//self.IsAttackHeld = false

	-- Call the think function for other clients too
	-- It's not canon, but it's kind of nice to be able to do this
	if CLIENT then
		hook.Add("Think", self, function(self)
			if IsValid(self.Owner) and LocalPlayer() != self.Owner then 
				self:Think() 
			end
		end )
	end
end

function SWEP:SetupDataTables()

	 -- Used for networking to other players only
	self:NetworkVar("Bool", 31, "IsAttacking")
	self:NetworkVar("Bool", 30, "IsSecondaryAttacking")
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

function SWEP:AnyAttack(mode)
	local state = self.AttackStates[mode]
	if state.IsHeld == false then
		state.IsHeld = true
		state.StartHook(self)
		state.SetNet(self, true)
	end
end

function SWEP:AnyStopAttack(mode)
	local state = self.AttackStates[mode]
	if state.IsHeld then 
		state.IsHeld = false
		state.StopHook(self)
		state.SetNet(self, false)
	end	
end

function SWEP:AnyIsAttacking(mode)
	local state = self.AttackStates[mode]
	if SERVER or (self.Owner == LocalPlayer() and not game.SinglePlayer()) then
		return state.IsHeld
	else 
		return state.GetNet(self)
	end
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	if not IsFirstTimePredicted() then return end

	self:AnyAttack(WEAPON_PRIMARY)
end

function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end
	if not IsFirstTimePredicted() then return end

	self:AnyAttack(WEAPON_SECONDARY)
end

function SWEP:IsPrimaryAttacking()
	return self:AnyIsAttacking(WEAPON_PRIMARY)
end

function SWEP:IsSecondaryAttacking()
	return self:AnyIsAttacking(WEAPON_SECONDARY)
end

-- Utility functions
function SWEP:StopPrimaryAttacking() self:AnyStopAttack(WEAPON_PRIMARY) end
function SWEP:StopSecondaryAttacking() self:AnyStopAttack(WEAPON_SECONDARY) end

-- Hooks to be overwritten in baseclasses
function SWEP:StartPrimaryAttack() end
function SWEP:StopPrimaryAttack() end
function SWEP:StartSecondaryAttack() end
function SWEP:StopSecondaryAttack() end

function SWEP:Cleanup() end


function SWEP:Holster(wep)

	-- Stop all firemodes from attacking
	for k, _ in pairs(self.AttackStates) do
		self:AnyStopAttack(k)
	end
	
	self:Cleanup()

	return true
end

function SWEP:OnRemove()

	-- Stop all firemodes from attacking
	for k, _ in pairs(self.AttackStates) do
		self:AnyStopAttack(k)
	end

	self:Cleanup()
end

function SWEP:ShootEffects()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end

function SWEP:Reload() return false end
function SWEP:CanPrimaryAttack() return true end
function SWEP:CanSecondaryAttack() return false end

hook.Add("KeyRelease", "ReleaseTriggerOnGunsWhatCanBeHeldDown", function(ply, key)
	if not IsFirstTimePredicted() then return end
	if key != WEAPON_PRIMARY and key != WEAPON_SECONDARY then return end

	local wep = ply:GetActiveWeapon()
	if IsValid( wep ) and wep.AnyStopAttack then
	
		-- PRIMARY/SECONDARY_WEAPON is an alias for their IN_ATTACK binds
		wep:AnyStopAttack(key)
	end
end )