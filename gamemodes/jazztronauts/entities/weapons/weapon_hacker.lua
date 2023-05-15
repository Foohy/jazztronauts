if SERVER then
	AddCSLuaFile()
end

SWEP.Base					= "weapon_base"
SWEP.PrintName				= jazzloc.Localize("jazz.weapon.hacker")
SWEP.Slot					= 4
SWEP.Category				= "#jazz.weapon.category"
SWEP.Purpose				= "#jazz.weapon.hacker.desc"
SWEP.WepSelectIcon			= Material( "weapons/weapon_hacker.png" )

SWEP.ViewModel				= "models/weapons/c_hackergoggles.mdl"
SWEP.WorldModel				= "models/weapons/w_hackergoggles.mdl"

SWEP.UseHands				= true

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
SWEP.Glitch					= 0.0 --weapon's actual current glitchiness
SWEP.GlitchIdeal			= 0.0 --weapons's ideal glitchiness (lerp glitch towards this)
SWEP.GlitchSources			= {} --what glitches us out

-- List this weapon in the store
local storeHacker = jstore.Register(SWEP, 35000, { type = "tool" })

local upgrade_enableWrites = jstore.Register("hacker_write", 500000, {
	name = jazzloc.Localize("jazz.weapon.hacker.upgrade.io"),
	cat = jazzloc.Localize("jazz.weapon.hacker"),
	desc = jazzloc.Localize("jazz.weapon.hacker.upgrade.io.desc"),
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

		--[[get our sources of glitchiness - shards, radiation, and magnets
			none of these things are likely to just spawn in,
			so we'll just get a table of them to refer to when we init]]
		self.GlitchSources = ents.FindByClass("jazz_shard")
		table.Add(self.GlitchSources,ents.FindByClass("jazz_shard_black"))
		--[[ - just kidding everything else is server only, not worth doing all this on the server for that.
		--get trigger hurts that deal radiation
		local tab = ents.FindByClass("trigger_hurt")
		PrintTable(tab)
		for key, value in ipairs(tab) do
			if IsValid(value) then
				local radiation = bit.band(value:GetInternalVariable("m_bitsDamageInflict"),DMG_RADIATION)
				print(radiation)
				if radiation > 0 then
					table.insert(self.GlitchSources,value)
				end
			end
		end
		--are magnets even worth searching for? I've never seen one used other than the coast.
		table.Add(self.GlitchSources,ents.FindByClass("phys_magnet"))
		]]
	else

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
	self:CalcGlitch()
	self.Glitch = self.GlitchIdeal
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

function SWEP:CalcGlitch()
	--glitchiness think
	if CLIENT and IsValid(self.Owner) then

		local viewmodel = self.Owner:GetViewModel()

		if IsValid(viewmodel) then

			local maxrange = 640000 --800^2 (HL2 geiger counter starts going off at 800HU)
			local pos = self.Owner:GetPos()
			self.GlitchIdeal = 0.0 --reset ideal glitchiness

			for key, value in ipairs(self.GlitchSources) do
				if IsValid(value) then
					--first, shards
					--if value:GetClass() == "jazz_shard" or value:GetClass() == "jazz_shard_black" then --only doing shards now, no need to check
						local vpos = value:GetPos()
						local dist = vpos:DistToSqr(pos)
						if dist < maxrange then
							if value:GetCollected() then
								--This shard is actively fucking shit up, so we get extra fucked up too
								self.GlitchIdeal = self.GlitchIdeal + ((maxrange - dist) / maxrange * 2)
							else
								--Shard exists, but hasn't been touched, only glitch up a bit
								self.GlitchIdeal = self.GlitchIdeal + ((maxrange - dist) / maxrange * 0.25)
							end
						end
					--elseif string.find(value:GetClass(),"trigger_hurt") then
					--end
				end
			end

			--move our glitchiness towards the ideal (this is never gonna be exact other than at 0, but it doesn't matter)
			if self.Glitch > self.GlitchIdeal then self.Glitch = self.Glitch - math.max(0.01,math.abs(self.Glitch-self.GlitchIdeal)/100) end
			if self.Glitch < self.GlitchIdeal then self.Glitch = self.Glitch + math.max(0.01,math.abs(self.Glitch-self.GlitchIdeal)/100) end

			viewmodel:SetPoseParameter("glitch", self.Glitch)
			viewmodel:InvalidateBoneCache()
		end
	end
end

function SWEP:Think()

	if CLIENT then
		self:CalcGlitch()
		self:SetNextClientThink(CurTime() + 0.1)
	end
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
