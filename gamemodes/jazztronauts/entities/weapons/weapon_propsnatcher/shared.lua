if SERVER then
	AddCSLuaFile()
	--util.AddNetworkString("remove_prop_scene")
	util.AddNetworkString("remove_client_send_trace")
end

SWEP.Base 					= "weapon_basehold"
SWEP.PrintName 		 		= "Prop Snatcher"
SWEP.Slot		 	 		= 0
SWEP.Category				= "Jazztronauts"

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
SWEP.KillsPeople			= true


local snatch1 = jstore.Register("snatch1", 10000, { 
    name = "Auto Aim", 
    cat = "Prop Snatcher", 
	desc = "Automatically aim to target props within the on-screen capture radius.",
    type = "upgrade" 
})
local snatch2 = jstore.Register("snatch2", 50000, { 
    name = "Auto-Auto Aim", 
    cat = "Prop Snatcher", 
	desc = "Hold down left click to automate picking up many props at a time.",
    requires = snatch1,
    type = "upgrade" 
})
local snatch3 = jstore.Register("snatch3", 1000000, { 
    name = "Ultimate Aim", 
    cat = "Prop Snatcher", 
	desc = "No matter where you aim, you're picking something up.",
    requires = snatch2,
    type = "upgrade" 
})

function SWEP:Initialize()
	self.BaseClass.Initialize( self )

	self:SetWeaponHoldType( self.HoldType )	

	-- Hook into unlock callbacks
	hook.Add( "OnUnlocked", self, function( self, list_name, key, ply ) 
		if ply == self.Owner and string.find(key, "snatch") then
			self:SetUpgrades()
		end
	end )

	-- self.Owner is null during initialize......
	timer.Simple(0, function()
		self:SetUpgrades()
	end)
end

-- Query and apply current upgrade settings to this weapon
function SWEP:SetUpgrades()

	-- Tier I - Aim in cone upgrade
	--self.EnableConeOrSomething = unlocks.IsUnlocked("store", self.Owner, snatch1)

	-- Tier II - Automatic fire upgrade
	self.Primary.Automatic = unlocks.IsUnlocked("store", self.Owner, snatch2)

	-- Tier III - World stealing
	self.CanStealWorld = unlocks.IsUnlocked("store", self.Owner, snatch3)
end


function SWEP:SetupDataTables()
	--Might use this later, who the fuck knows
end

function SWEP:Deploy()
	return true
end
function SWEP:CanSecondaryAttack() return self.CanStealWorld end

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
	if not mapgen.CanSnatch(ent) then
		print("NO! YOU CAN'T SNATCH THAT: " .. tostring(ent) .. " : " .. (ent:IsNPC() and "NPC" or "NOT NPC"))
		return false
	else
		print("YEAH YOU CAN SNATCH THAT: " .. tostring(ent))
		return true
	end
end

function SWEP:GetEntitySize(ent)
	return ent:GetMass() / 100
end

function SWEP:RemoveEntity( ent )

	if self:AcceptEntity( ent ) and not ent.doing_removal then

		snatch.New():StartProp( ent, self:GetOwner(), self.KillsPeople )
		GAMEMODE:CollectProp( ent, self:GetOwner() )

	end

end

function SWEP:RemoveWorld( position )

	snatch.New():StartWorld( position, self:GetOwner() )

end

--Reach out and touch something
function SWEP:TraceToRemove(stealWorld)

	local pos = self.Owner:GetShootPos()
	local dir = self.Owner:GetAimVector()

	local tr = util.TraceLine( {
		start = pos,
		endpos = pos + dir * 100000,
		filter = self:GetOwner(),
	} )

	if SERVER then
		if stealWorld then
			self:RemoveEntity( tr.Entity )
		end
	else
		if not tr.HitNonWorld and stealWorld then
			net.Start( "remove_client_send_trace" )
			net.WriteBit(0)
			net.WriteEntity( self )
			net.WriteVector( tr.HitPos )
			net.SendToServer()
		elseif self:AcceptEntity( tr.Entity ) and not stealWorld then
			net.Start( "remove_client_send_trace" )
			net.WriteBit(1)
			net.WriteEntity( self )
			net.WriteEntity( tr.Entity )
			net.SendToServer()
		end
	end

end

if SERVER then
	net.Receive("remove_client_send_trace", function(len, pl)

		local world = net.ReadBit() == 0
		local swep = net.ReadEntity()

		if world then

			swep:RemoveWorld( net.ReadVector() )

		else

			swep:RemoveEntity( net.ReadEntity() )

		end

	end)
end

function SWEP:PrimaryAttack()

	--Standard stuff
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + 0.1)
	self:EmitSound( self.Primary.Sound, 50, math.random( 200, 255 ) )
	
	if CLIENT or game.SinglePlayer() then
		self:TraceToRemove()
	end

	self:ShootEffects()

end

function SWEP:SecondaryAttack()
	print(self.CanStealWorld, self:CanSecondaryAttack())
	if !self:CanSecondaryAttack() then return end
	self:SetNextSecondaryFire(CurTime() + 0.5)
	self:EmitSound( self.Primary.Sound, 50, math.random( 50, 60 ) )
	
	if CLIENT or game.SinglePlayer() then
		self:TraceToRemove(true)
	end

	self:ShootEffects()
end

function SWEP:Holster(wep) return true end

function SWEP:ShootEffects()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end
