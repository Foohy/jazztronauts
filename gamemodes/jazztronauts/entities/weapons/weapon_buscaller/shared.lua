if SERVER then
	AddCSLuaFile()
end

SWEP.Base					= "weapon_basehold"
SWEP.PrintName				= "Portable Bus Stop"
SWEP.Slot					= 5
SWEP.Category				= "Jazztronauts"
SWEP.WepSelectIcon			= Material( "weapons/weapon_buscaller.png" )

SWEP.ViewModel				= "models/weapons/c_pistol.mdl"
SWEP.WorldModel				= "models/weapons/w_pistol.mdl"
SWEP.HoldType				= "pistol"

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

SWEP.BeamMat				= Material("cable/physbeam")

function SWEP:Initialize()
	self.BaseClass.Initialize( self )
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:SetupDataTables()
	self.BaseClass.SetupDataTables( self )

	self:NetworkVar("Entity", 0, "BusMarker")
end

function SWEP:Deploy()
	return true
end

function SWEP:DrawWorldModel()

	self:DrawModel()

end


function SWEP:UpdateBeamHum()
	local active = self:IsPrimaryAttacking()

	if not self:IsCarriedByLocalPlayer() then return end

	if active then
		if not self.BeamHum then
			self.BeamHum = CreateSound(self, "ambient/energy/force_field_loop1.wav")
		end

		if not self.BeamHum:IsPlaying() then
			self.BeamHum:Play()
		end
	elseif self.BeamHum then
		self.BeamHum:Stop()
		self.BeamHum = nil
	end
end

function SWEP:SwitchWeaponThink()
	if not IsFirstTimePredicted() then return end
	local owner = self:GetOwner()
	local forceAttack = owner:KeyDownLast(IN_ATTACK) and owner:KeyDown(IN_ATTACK)

	-- Because this is only a hack, only do it for one 'cycle'
	-- User must un-press attack before being able to attack again
	if not forceAttack then
		self.IgnoreAttackForced = true
	end

	if forceAttack and not self:IsPrimaryAttacking() and not self.IgnoreAttackForced then
		self:PrimaryAttack()
		print("force attack")
		self.IgnoreAttackForced = true
	end

end

function SWEP:Think()

	self:SwitchWeaponThink()
	if SERVER then return end

	local marker = self:GetBusMarker()

	-- If the marker is no longer valid, stop attacking
	if not IsValid(marker) and self.HadMarker then
		self:StopPrimaryAttacking()
		self.HadMarker = false
	end

	self:UpdateBeamHum()
	if IsValid(marker) and marker.AddJazzRenderBeam then
		marker:AddJazzRenderBeam(self:GetOwner())
	end

	-- If the marker has enough people, vary the pitch as it gets closer
	if IsValid(marker) and marker.GetSpawnPercent then
		self.HadMarker = true

		local perc = marker:GetSpawnPercent()
		if self.BeamHum then self.BeamHum:ChangePitch(100 + perc * 100) end
	end
end

-- Get the bus stop they're aimed at, or nil if they aren't looking at one
local function GetLookMarker(pos, dir, fov)
	for _, v in pairs(ents.FindByClass("jazz_bus_marker")) do
		if v.IsLookingAt and v:IsLookingAt(pos, dir, fov) then return v end
	end

	return nil
end

function SWEP:CreateBusMarker(pos, angle)
	local marker = ents.Create("jazz_bus_marker")
	marker:SetPos(pos)
	marker:SetAngles(angle)
	marker:Spawn()
	marker:Activate()

	return marker
end

-- Set the player up with either the marker they're aimed at or a brand new one
function SWEP:CreateOrUpdateBusMarker()
	local owner = self:GetOwner()
	local pos = owner:GetShootPos()
	local dir = owner:GetAimVector()

	local marker = GetLookMarker(pos, dir, owner:GetFOV())

	-- If we weren't looking at an existing marker,
	-- do a trace to where WE want to put it
	if !IsValid(marker) then
		local tr = util.TraceLine( {
			start = pos,
			endpos = pos + dir * 100000,
			mask = MASK_SOLID,
			collisiongroup = COLLISION_GROUP_WEAPON
		} )

		marker = self:CreateBusMarker(tr.HitPos, tr.HitNormal:Angle())
	end

	self:SetBusMarker(marker)
	marker:AddPlayer(owner)
end

function SWEP:PrimaryAttack()
	self.BaseClass.PrimaryAttack(self)

	self:GetOwner():ViewPunch( Angle( -1, 0, 0 ) )
	self:EmitSound( self.Primary.Sound, 50, math.random( 200, 255 ) )

	if IsFirstTimePredicted() then

		if SERVER then

			self:CreateOrUpdateBusMarker()
		end
	end

	self:ShootEffects()
end

function SWEP:ShootEffects()

	local owner = self:GetOwner()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	owner:MuzzleFlash()
	owner:SetAnimation( PLAYER_ATTACK1 )

end

function SWEP:StopPrimaryAttack()
	if !IsFirstTimePredicted() then return end

	if SERVER and IsValid(self:GetBusMarker()) then
		self:GetBusMarker():RemovePlayer(self:GetOwner())
	end

	self:SetBusMarker(nil)
end

function SWEP:Cleanup()
	if self.BeamHum then
		self.BeamHum:Stop()
	end

	self.IgnoreAttackForced = false
end


function SWEP:Reload() return false end
function SWEP:CanPrimaryAttack() return true end
function SWEP:CanSecondaryAttack() return false end
function SWEP:CanSecondaryAttack() return false end
function SWEP:Reload() return false end

hook.Add("CreateMove", "JazzSwitchToBusCaller", function(cmd)
	if not LocalPlayer():Alive() then return end

	-- Suppress weapon fire if we're over a summon circle
	local curWep = LocalPlayer():GetActiveWeapon()
	local firstShot = cmd:KeyDown(IN_ATTACK) && not LocalPlayer():KeyDownLast(IN_ATTACK)
	if firstShot && (!IsValid(curWep) or curWep:GetClass() != "weapon_buscaller") then

		local pos = LocalPlayer():GetShootPos()
		local dir = LocalPlayer():GetAimVector()

		local marker = GetLookMarker(pos, dir)

		-- Valid marker hit, suppress and switch to weapon
		if IsValid(marker) then
			local caller = LocalPlayer():GetWeapon("weapon_buscaller")

			-- Automatically switch to the bus caller weapon
			if IsValid(caller) then
				cmd:SelectWeapon(caller)
			end
		end
	end
end )

-- Give the player the bus caller if they're hovering over it and somehow don't have it
hook.Add("SetupMove", "JazzSwitchToBusCaller", function(ply, mv, cmd)
	local curWep = ply:GetActiveWeapon()
	if CLIENT or not cmd:KeyDown(IN_ATTACK) then return end
	if IsValid(curWep) and curWep:GetClass() == "weapon_buscaller" then return end
	if ply:HasWeapon("weapon_buscaller") then return end

	-- Check to see if we're clicking in the direction of a bus caller
	local pos = ply:GetShootPos()
	local dir = ply:GetAimVector()

	local marker = GetLookMarker(pos, dir)

	-- If we're in the direction of a marker, give the player the weapon and switch to it
	if IsValid(marker) then
		local wep = ply:Give("weapon_buscaller")

		-- Manually switch to it. Very hacky and not predicted,
		-- but we're already too late for prediction anyway
		if IsValid(wep) then
			ply:SelectWeapon(wep:GetClass())
		end
	end
end )
