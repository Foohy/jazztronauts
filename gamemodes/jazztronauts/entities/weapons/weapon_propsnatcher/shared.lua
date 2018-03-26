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
SWEP.Primary.Automatic		= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Ammo 		= "none"

-- General settings
SWEP.ReticleCircleMaterial 	= Material("ui/jazztronauts/circle")
SWEP.MaxRange 				= 500

-- Tier 1 settings
SWEP.AutoAimCone			= 10

-- Tier 2 settings
SWEP.MinFireDelay 			= 0.1 -- Min delay to fire when at full blast
SWEP.WarmUpTime				= 5 -- How long it takes to get to full blast

SWEP.Spawnable 				= true
SWEP.RequestInfo			= {}
SWEP.KillsPeople			= true

SWEP.StartShootTime 		= 0
SWEP.LastCursorPos			= Vector()


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
	self.Primary.Automatic = true// unlocks.IsUnlocked("store", self.Owner, snatch2)

	-- Tier III - World stealing
	self.CanStealWorld = true //unlocks.IsUnlocked("store", self.Owner, snatch3)
end


function SWEP:SetupDataTables()
	self.BaseClass.SetupDataTables( self )
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
	return mapgen.CanSnatch(ent)
end

function SWEP:GetEntitySize(ent)
	return ent:GetMass() / 100
end

function SWEP:RemoveEntity( ent, snatchobj )

	if self:AcceptEntity( ent ) and not ent.doing_removal then
		snatchobj:SetMode(1)
		snatchobj:StartProp( ent, self:GetOwner(), self.KillsPeople )
		GAMEMODE:CollectProp( ent, self:GetOwner() )

	end

end

function SWEP:RemoveWorld( position, snatchobj )

	snatchobj:SetMode(2)
	snatchobj:StartWorld( position, self:GetOwner() )

end

-- IT'S BEEN LIKE 10 YEARS HOW CAN THIS FUNCTION _STILL_ BE BUGGED
local function findInCone(startpos, direction, radius, angle)
	local near = ents.FindInSphere(startpos, radius)
	local ang = math.cos(math.rad(angle))
	local res = {}

	-- Filter out entities that aren't in the angle
	for _, v in ipairs(near) do
		local dir = (v:GetPos() - startpos)
		dir:Normalize()

		if direction:Dot(dir) >= ang then
			table.insert(res, v)
		end
	end

	return res
end

local backtrace = {
	start = Vector(),
	endpos = Vector(),
	filter = nil,
}
local function IsVisible(self, ent)
	backtrace.start:Set(ent:GetPos())
	backtrace.endpos:Set(self.Owner:EyePos())
	backtrace.filter = self.Owner
	-- For simplicity, don't allow entities to block backtraces, only brushes
	//backtrace.mask = bit.bor(MASK_SOLID_BRUSHONLY, CONTENTS_MOVEABLE  )
	backtrace.mask = MASK_VISIBLE    

	local res = util.TraceLine(backtrace)
	return not res.Hit
end

-- Given a trace result
function SWEP:FindConeEntity(tr )
	local accept = {}
	local near = {}

	-- Whatever the trace actually hit always has priority	
	local closest, closedist
	closedist = math.huge
	if self:AcceptEntity(tr.Entity) then 
		table.insert(accept, tr.Entity)
		closest = tr.Entity
		closedist = 0
	end

	local maxdist2 = self.MaxRange^2
	local valid = findInCone(tr.StartPos, tr.Normal, self.MaxRange * 2, self.AutoAimCone)
	local endPos = tr.StartPos + tr.Normal * self.MaxRange

	-- Find the first available entity within the cone of influence
	for _, v in pairs(valid) do
		local dist2 = (v:GetPos() - tr.StartPos):LengthSqr()
		if self:AcceptEntity(v) then
			local isVis = dist2 < maxdist2 and IsVisible(self, v) 

			-- Insert into appropriate table
			local tbl = isVis and accept or near 
			table.insert(tbl, v)

			-- Check if closest
			if isVis then
				local ldist = util.DistanceToLine(tr.StartPos, endPos, v:GetPos())
				if ldist < closedist then
					closedist = ldist
					closest = v
				end
			end
		end
	end

	-- Didn't find any valid entities (or returning array)
	return closest, accept, near
end

--Reach out and touch something
function SWEP:TraceToRemove(stealWorld)

	local pos = self.Owner:GetShootPos()
	local dir = self.Owner:GetAimVector()

	local tr = util.TraceLine( {
		start = pos,
		endpos = pos + dir * self.MaxRange,
		filter = self:GetOwner(),
	} )

	-- Tell the server we'd like to steal the world right here
	if stealWorld and not tr.HitNonWorld then

		net.Start( "remove_client_send_trace" )
		net.WriteBit(0)
		net.WriteEntity( self )
		net.WriteVector( tr.HitPos )
		net.SendToServer()

		self.WorldShootFade = 1

	elseif not stealWorld then
		local ent = self:FindConeEntity(tr)

		-- Tell the server which entity we'd like to pick
		if self:AcceptEntity( ent ) then
			net.Start( "remove_client_send_trace" )
			net.WriteBit(1)
			net.WriteEntity( self )
			net.WriteEntity( ent )
			net.SendToServer()

			-- Add some nice feedback
			self.ShootFade = 1
			self.HoverAlpha = 2
		else
			self.BadShootFade = 1.0
		end
	else
		self.BadShootFade = 1.0
	end
end

if SERVER then
	net.Receive("remove_client_send_trace", function(len, pl)

		local world = net.ReadBit() == 0
		local swep = net.ReadEntity()
		local snatchobj = snatch.New()

		if world then

			swep:RemoveWorld( net.ReadVector(), snatchobj )

		else

			swep:RemoveEntity( net.ReadEntity(), snatchobj )

		end

	end)
end

local function LerpColor(t, c1, c2)
	return Color(Lerp(t, c1.r, c2.r), Lerp(t, c1.g, c2.g), Lerp(t, c1.b, c2.b))
end

local function ToVector(c)
	return Vector(c.r / 255.0, c.g / 255.0, c.b / 255.0)
end

-- If auto aim is enabled, show the sphere of influence/current reticle
SWEP.HoverAlpha = 0
SWEP.ShootFade = 0
SWEP.WorldShootFade = 0
SWEP.BadShootFade = 0
function SWEP:DrawHUD()
	local pfov = LocalPlayer():GetFOV()
	local radius = (ScrW() / 2) * math.tan(math.rad(90 - pfov/2)) * math.tan(math.rad(self.AutoAimCone))

	-- #TODO: When _holding_, keep the circle at the smaller radius and show that same semicircle
	-- from the bus caller
	radius = radius - math.sin(math.pi * self.WorldShootFade) * ScreenScale(50)

	-- Aimhack higlight 
	local pos = self.Owner:GetShootPos()
	local dir = self.Owner:GetAimVector()

	local tr = util.TraceLine( {
		start = pos,
		endpos = pos + dir * self.MaxRange,
		filter = self:GetOwner(),
	} )

	//local timeStart = SysTime()
	local ent, accept, near = self:FindConeEntity(tr)
	//print((SysTime() - timeStart) * 1000)

	-- Draw entities we can't grab now, but we're nearby	
	local s = ScreenScale(1)
	surface.SetDrawColor(100, 100, 100)
	for _, v in pairs(near) do
		cam.Start3D()
		local toscr = v:GetPos():ToScreen()
		cam.End3D()

		surface.DrawRect(toscr.x - s, toscr.y - s, s *2, s *2)
	end

	-- Draw all the entities that are currently eligible to be snatched
	local s = ScreenScale(2)
	surface.SetDrawColor(255, 100, 100)
	for _, v in pairs(accept) do
		cam.Start3D()
		local toscr = v:GetPos():ToScreen()
		cam.End3D()

		surface.DrawRect(toscr.x - s, toscr.y - s, s *2, s *2)
	end

	-- Draw what we're currently hovered over
	if IsValid(ent) then
		cam.Start3D()
		local toscr = ent:GetPos():ToScreen()
		cam.End3D()

		local moveAmt = math.min(1, FrameTime() * 30)
		self.LastCursorPos.x = Lerp(moveAmt, self.LastCursorPos.x, toscr.x)
		self.LastCursorPos.y = Lerp(moveAmt, self.LastCursorPos.y, toscr.y)

		local asize = 50.0
		surface.SetMaterial(self.ReticleCircleMaterial)
		surface.SetDrawColor(100, 255, 100)
		surface.DrawTexturedRect(self.LastCursorPos.x - asize/2, self.LastCursorPos.y - asize/2, asize, asize)
	end

	-- Large cone range circle
	local size = radius * 2.55
	local color = HSVToColor(20 + self.ShootFade * 30, 0.1 + self.ShootFade * 0.9, 1)
	color = LerpColor(self.BadShootFade, color, Color(255, 60, 60)) -- Fade in red for bad boy shots
	self.ReticleCircleMaterial:SetFloat("$glowend", 0.5 + (1 - self.ShootFade) * 1)

	local glowcol = HSVToColor( self.ShootFade * 30, 0.1 + self.ShootFade * 0.9, 1)
	self.ReticleCircleMaterial:SetVector("$glowcolor", ToVector(glowcol) * (self.ShootFade - 0.2))

	local alpha = math.max(self.HoverAlpha, math.min(1, self.WorldShootFade * 50))
	surface.SetDrawColor(color.r, color.g, color.b, 20 + alpha * 200)
	surface.SetMaterial(self.ReticleCircleMaterial)
	surface.DrawTexturedRect(ScrW() / 2 - size/2, ScrH() / 2 - size/2, size, size)

	-- Step hover alpha linearly
	local speed = 10
	self.HoverAlpha = math.Approach(self.HoverAlpha, IsValid(ent) and 1 or 0, FrameTime() * speed) 
	self.ShootFade = math.Approach(self.ShootFade, 0, FrameTime() * 3)
	self.WorldShootFade = math.Approach(self.WorldShootFade, 0, FrameTime() * 2.1)
	self.BadShootFade = math.Approach(self.BadShootFade, 0, FrameTime() * 3)
end

-- When button starts being held down
function SWEP:StartPrimaryAttack()
	self.StartShootTime = CurTime()
end

-- When button released, revert primary fire to be sooner (so they can still click faster)
function SWEP:StopPrimaryAttack()
	self:SetNextPrimaryFire(self:LastShootTime() + self.MinFireDelay)
end

function SWEP:GetPrimaryShootDelay()
	local p = (CurTime() - self.StartShootTime) / self.WarmUpTime

	return math.max(0, (1 - p) * 0.50) + self.MinFireDelay
end

function SWEP:PrimaryAttack()
	self.BaseClass.PrimaryAttack( self )

	--Standard stuff
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self:GetPrimaryShootDelay())
	self:EmitSound( self.Primary.Sound, 50, math.random( 200, 255 ) )
	
	if CLIENT or game.SinglePlayer() then
		self:TraceToRemove()
	end

	self:ShootEffects()

end

function SWEP:SecondaryAttack()
	self.BaseClass.SecondaryAttack( self )
	
	if !self:CanSecondaryAttack() then return end
	self:SetNextSecondaryFire(CurTime() + 0.5)
	//self:EmitSound( self.Primary.Sound, 50, math.random( 50, 60 ) )
	
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
