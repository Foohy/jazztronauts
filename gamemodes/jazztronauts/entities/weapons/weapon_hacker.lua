if SERVER then
	AddCSLuaFile()
end

SWEP.Base					= "weapon_base"
SWEP.PrintName				= JazzLocalize("jazz.weapon.hacker")
SWEP.Slot					= 0
SWEP.Category				= "#jazz.weapon.category"
SWEP.Purpose				= "#jazz.weapon.hacker.desc"
SWEP.WepSelectIcon			= Material( "weapons/weapon_hacker.png" )

SWEP.ViewModel				= "models/weapons/c_hackergoggles.mdl"
SWEP.WorldModel				= "models/weapons/w_hackergoggles.mdl"

SWEP.UseHands		= true

SWEP.HoldType				= "magic"

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
local storeHacker = jstore.Register(SWEP, 35000, { type = "tool" })

local upgrade_enableWrites = jstore.Register("hacker_write", 500000, {
	name = JazzLocalize("jazz.weapon.hacker.upgrade.io"),
	cat = JazzLocalize("jazz.weapon.hacker"),
	desc = JazzLocalize("jazz.weapon.hacker.upgrade.io.desc"),
	type = "upgrade",
	requires = storeHacker
})

function SWEP:Initialize()

	self.BaseClass.Initialize( self )
	self:SetWeaponHoldType( self.HoldType )

	if CLIENT then
		hook.Add("JazzShouldDrawHackerview", self, function()
			return self:ShouldDrawHackerview()
		end)
	end
end

function SWEP:ShouldDrawHackerview()
	local owner = self:GetOwner()
	if IsValid(owner) and owner != LocalPlayer() then
		hook.Remove("JazzShouldDrawHackerview", self)
		return
	end

	if owner != LocalPlayer() or owner:GetActiveWeapon() != self then return 0 end
	if !unlocks.IsUnlocked("store", owner, upgrade_enableWrites) then return 1 end
	return 2 //Turbo
end

function SWEP:SetupDataTables()
	--self.BaseClass.SetupDataTables( self )
end

function SWEP:Holster()
	return true
end

function SWEP:Deploy()

	return true
end


function SWEP:DrawWorldModel()

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

end

function SWEP:CanPrimaryAttack()

	return unlocks.IsUnlocked("store", self:GetOwner(), upgrade_enableWrites) 

end

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end
	if ( !self.Owner:IsNPC() ) then self.Owner:ViewPunch( Angle( -1, 0, 0 ) ) end
	self:ShootEffects()
end

function SWEP:ShootEffects()

	local owner = self:GetOwner()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	owner:MuzzleFlash()
	owner:SetAnimation( PLAYER_ATTACK1 )

end

function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	surface.SetDrawColor(255, 255, 255, alpha)
	if self.WepSelectIcon then
		surface.SetMaterial(self.WepSelectIcon)
	else
		surface.SetTexture("weapons/swep")
	end

	surface.DrawTexturedRect(x + w / 2 - 128, y + h / 2 - 64, 256, 128)
	self:PrintWeaponInfo(x + w + 20, y + h, alpha)
end

function SWEP:Reload() return false end
function SWEP:CanSecondaryAttack() return false end
