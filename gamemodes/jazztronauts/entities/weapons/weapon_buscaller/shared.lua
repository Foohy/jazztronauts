if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName 		 		= "Portable Bus Stop"
SWEP.Slot		 	 		= 5
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
SWEP.Secondary.Ammo 			= "none"

SWEP.BeamMat				= Material("cable/physbeam")

SWEP.Spawnable 				= true
SWEP.RequestInfo			= {}

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )	
	
	if CLIENT then
		self.BeamHum = CreateSound(self, "ambient/energy/force_field_loop1.wav")
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Entity", 0, "BusMarker")
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

	local marker = self:GetBusMarker()
	if IsValid(marker) then 
		local dist = attach:Distance(marker:GetPos())
		local offset = -CurTime()*4

		render.SetMaterial(self.BeamMat)
		render.DrawBeam(attach, marker:GetPos(), 3, offset, dist/100 + offset, color_blue)
	end

	render.SetMaterial( Material( "sprites/light_glow02_add" ) )
	//render.DrawSprite( attach, 25, 25, Color( self.Color.r, self.Color.g, self.Color.b, 255 ) )
end

function SWEP:ViewModelDrawn(viewmodel)
	cam.Start3D()
		local marker = self:GetBusMarker()
		if !IsValid(marker) then return end
		local angpos = viewmodel:GetAttachment(self:LookupAttachment("muzzle"))
		local dist = angpos.Pos:Distance(marker:GetPos())
		local offset = -CurTime()*4

		render.SetMaterial(self.BeamMat)
		render.DrawBeam(angpos.Pos, marker:GetPos(), 3, offset, dist/100 + offset, color_blue)
	cam.End3D()
end

function SWEP:IsBeamActive()
	if self.Owner:GetActiveWeapon() != self then return false end

	if CLIENT and LocalPlayer() == self.Owner then 
		return self.Owner:KeyDown(IN_ATTACK)
	end

	return IsValid(self:GetBusMarker())
end

function SWEP:Think()
	if SERVER then return end 
	
	-- TODO: Clean this up. 
	if self.BeamHum:IsPlaying() and !self:IsBeamActive() then 
		self.BeamHum:Stop()
	end

	if !self.BeamHum:IsPlaying() and self:IsBeamActive() then
		self.BeamHum:Play()
	end

	-- If the marker has enough people, vary the pitch as it gets closer
	local marker = self:GetBusMarker()
	if IsValid(marker) and marker.GetSpawnPercent and marker:GetSpawnPercent() > 0 then 
		local perc = marker:GetSpawnPercent()
		if self.BeamHum then self.BeamHum:ChangePitch(100 + perc * 100) end
	end
end

function SWEP:OnRemove()
	if self.BeamHum then 
		self.BeamHum:Stop() 
		self.BeamHum = nil
	end
end

-- Get the bus stop they're aimed at, or nil if they aren't looking at one
function SWEP:GetLookMarker(pos, dir)
	for _, v in pairs(ents.FindByClass("jazz_bus_marker")) do
		local posDir = (v:GetPos() - pos):GetNormal()
		
		local amt = 0.992
		if posDir:Dot(dir) > amt then return v end
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
	local pos = self.Owner:GetShootPos()
	local dir = self.Owner:GetAimVector()

	local marker = self:GetLookMarker(pos, dir)

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
	marker:AddPlayer(self.Owner)
end 

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end

	self.Owner:ViewPunch( Angle( -1, 0, 0 ) )

	if IsFirstTimePredicted() then 
		if SERVER then
			self.Owner:EmitSound( self.Primary.Sound, 50, math.random( 200, 255 ) )
			self:CreateOrUpdateBusMarker()
		end
	end

	self:ShootEffects()
end

-- The opposite of Attack is Dettack. It's when they stop attacking.
function SWEP:PrimaryDettack()
	if !IsFirstTimePredicted() then return end

	if SERVER and IsValid(self:GetBusMarker()) then
		self:GetBusMarker():RemovePlayer(self.Owner)
	end
	
	self:SetBusMarker(nil)
end

function SWEP:Holster(wep)
	self:PrimaryDettack()

	if self.BeamHum then
		self.BeamHum:Stop()
	end
	return true
end

-- Hook into when the player stops holding ATTACK to turn off their persistent beam
hook.Add("KeyRelease", "JazzMarkerStopBeam", function(ply, key)
	local wep = ply:GetWeapon("weapon_buscaller")
	if key == IN_ATTACK and IsValid(wep) and wep.PrimaryDettack then
		wep:PrimaryDettack()
	end
end )

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
