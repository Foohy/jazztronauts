if SERVER then
	AddCSLuaFile()
	--util.AddNetworkString("remove_prop_scene")
	util.AddNetworkString("remove_client_send_trace")
end

SWEP.Base 					= "weapon_basehold"
SWEP.PrintName 		 		= "Prop Snatcher"
SWEP.Slot		 	 		= 0
SWEP.Category				= "Jazztronauts"

SWEP.ViewModel		 		= "models/weapons/c_pistol.mdl"
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
local AimConeDefault 		= 0
SWEP.AutoAimCone			= AimConeDefault

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

CreateConVar("jazz_debug_snatch_allups", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY }, "Temporarily enable all upgrades for snatcher")

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

	local override = cvars.Bool("jazz_debug_snatch_allups", false)

	-- Tier I - Aim in cone upgrade
	self.AutoAimCone = (unlocks.IsUnlocked("store", self.Owner, snatch1) or override) and 10 or AimConeDefault

	-- Tier II - Automatic fire upgrade
	self.Primary.Automatic = unlocks.IsUnlocked("store", self.Owner, snatch2) or override

	-- Tier III - World stealing
	self.CanStealWorld = unlocks.IsUnlocked("store", self.Owner, snatch3) or override
end


function SWEP:SetupDataTables()
	self.BaseClass.SetupDataTables( self )
	self:NetworkVar("Entity", 0, "CurSnatchMarker")
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

local function getPropCenter(ent)
	local backtrmin, backtrmax = ent:GetCollisionBounds()
	backtrmin = util.LocalToWorld(ent, backtrmin)
	backtrmax = util.LocalToWorld(ent, backtrmax)

	return (backtrmin + backtrmax) / 2
end

-- IT'S BEEN LIKE 10 YEARS HOW CAN THIS FUNCTION _STILL_ BE BUGGED
local function findInCone(startpos, direction, radius, angle)
	local near = ents.FindInSphere(startpos, radius)
	local ang = math.cos(math.rad(angle))
	local res = {}

	-- Filter out entities that aren't in the angle
	for _, v in ipairs(near) do
		local vpos = getPropCenter(v)
		local dir = (vpos - startpos)
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

	if ent:GetClass() == "jazz_static_proxy" then return true end

	backtrace.start:Set(getPropCenter(ent))
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
	cam.Start3D() -- so ToScreen works

	-- Whatever the trace actually hit always has priority	
	local closest, closedist2
	closedist2 = math.huge
	if self:AcceptEntity(tr.Entity) then 
		table.insert(accept, tr.Entity)
		closest = tr.Entity
		closedist2 = 0
	end

	local maxdist2 = self.MaxRange^2
	local valid = findInCone(tr.StartPos, tr.Normal, self.MaxRange * 2, self.AutoAimCone)
	local endPos = tr.StartPos + tr.Normal * self.MaxRange

	-- Find the first available entity within the cone of influence
	for _, v in pairs(valid) do
		local centerpos = getPropCenter(v)
		local dist2 = (centerpos - tr.StartPos):LengthSqr()
		if self:AcceptEntity(v) then
			local isVis = dist2 < maxdist2 and IsVisible(self, v) 

			-- Insert into appropriate table
			local tbl = isVis and accept or near 
			table.insert(tbl, v)

			-- Check if closest
			if isVis then
				local scrpos = centerpos:ToScreen()
				local ldist = (scrpos.x - ScrW()/2)^2 + (scrpos.y - ScrH()/2)^2
				if ldist < closedist2 then
					closedist2 = ldist
					closest = v
				end
			end
		end
	end

	cam.End3D()

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
	if stealWorld and tr.HitWorld then

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
SWEP.EquipFade = 0
function SWEP:DrawHUD()
	local pfov = LocalPlayer():GetFOV()
	local radius = (ScrW() / 2) * math.tan(math.rad(90 - pfov/2)) * math.tan(math.rad(self.AutoAimCone))
	local drawExtended = self.AutoAimCone > 0

	local curMarker = self:GetCurSnatchMarker()
	local worldShootGoal = IsValid(curMarker) and 1 - curMarker:GetSpawnPercent() or 0
	if IsValid(curMarker) then
		--self.WorldShootGoal = 0.5
	end

	-- #TODO: When _holding_, keep the circle at the smaller radius and show that same semicircle
	-- from the bus caller
	radius = radius - math.sin(math.pi * self.WorldShootFade * 0.5) * ScreenScale(50)
	radius = radius * math.EaseInOut(self.EquipFade, 0, 1)

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
		local toscr = getPropCenter(v):ToScreen()
		cam.End3D()

		surface.DrawRect(toscr.x - s, toscr.y - s, s *2, s *2)
	end

	-- Draw all the entities that are currently eligible to be snatched
	local s = ScreenScale(2)
	surface.SetDrawColor(255, 100, 100)
	for _, v in pairs(accept) do
		cam.Start3D()
		local toscr = getPropCenter(v):ToScreen()
		cam.End3D()

		surface.DrawRect(toscr.x - s, toscr.y - s, s *2, s *2)
	end

	-- Draw what we're currently hovered over
	if IsValid(ent) and drawExtended then
		cam.Start3D()
		local toscr = getPropCenter(ent):ToScreen()
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

	-- Draw player count if we're grabbing a brush
	if IsValid(curMarker) and curMarker.GetNumPlayers and curMarker:GetNumPlayers() > 1 then
		local numPlayers = curMarker:GetNumPlayers()
		draw.SimpleText("x" .. numPlayers, "JazzMouseHint", ScrW()/2, ScrH()/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	-- Step hover alpha linearly
	local speed = 10
	self.HoverAlpha = math.Approach(self.HoverAlpha, IsValid(ent) and 1 or 0, FrameTime() * speed) 
	self.ShootFade = math.Approach(self.ShootFade, 0, FrameTime() * 3)
	self.WorldShootFade = math.Approach(self.WorldShootFade, worldShootGoal, FrameTime() * 5.1)
	self.BadShootFade = math.Approach(self.BadShootFade, 0, FrameTime() * 3)
	self.EquipFade = math.Approach(self.EquipFade, 1, FrameTime() * 3)
end

function SWEP:Deploy()
	self.EquipFade = 0

	return self.BaseClass.Deploy(self)
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

local function sign(n)
	return n >= 0 and 1 or -1
end

local strainsounds = {
	Sound("physics/metal/metal_solid_strain1.wav"),
	Sound("physics/metal/metal_solid_strain2.wav"),
	Sound("physics/metal/metal_solid_strain3.wav"),
	Sound("physics/metal/metal_solid_strain4.wav"),
	Sound("physics/metal/metal_solid_strain5.wav"),
	Sound("physics/metal/metal_box_strain1.wav"),
	Sound("physics/metal/metal_box_strain2.wav"),
	Sound("physics/metal/metal_box_strain3.wav"),
	Sound("physics/metal/metal_box_strain4.wav")
}

local function getBrushScale(brush)
	local size = brush.max - brush.min
	local scale = 1 - math.Clamp(500.0 / (size.x + size.y + size.z) - 0.2, 0, 1)
	print(scale, 1000.0 / (size.x + size.y + size.z) - 0.2)
	return scale
end

function SWEP:CalcView(ply, pos, ang, fov)
	local marker = self:GetCurSnatchMarker(newMarker)
	if not IsValid(marker) or not marker.GetProgress then return end

	local scale = getBrushScale(marker.Brush)

	self.PullShake = self.PullShake or 0
	self.GoalShake = self.GoalShake or 0
	self.NextRandom = self.NextRandom or 0
	if CurTime() > self.NextRandom then
		local time = math.random(0.1, 0.7)
		self.NextRandom = CurTime() + time
		self.GoalShake = math.random(0.2, 1) * sign(math.random(-1, 1))

		util.ScreenShake(pos, 5, 5, time, 256)
		if math.random() > 0.65 then
			self.Owner:EmitSound(table.Random(strainsounds), 75, math.random(80, 100), 0.25)
		end
	end
	self.PullShake = math.Approach(self.PullShake, self.GoalShake, FrameTime() * 7)

	local p = marker:GetProgress()
	local rot = self.PullShake * 25 + math.sin(CurTime() * 7) * 10
	rot = rot + math.sin(CurTime() * 70) * 3

	return pos, ang + Angle(0, 0, rot * p * scale), fov + p * scale * 25
end

function SWEP:RemoveSnatchMarker()
	local curMarker = self:GetCurSnatchMarker()
	if IsValid(curMarker) then
		curMarker:RemovePlayer(self.Owner)
	end

	self:SetCurSnatchMarker(Entity(0))
end

function SWEP:StopSecondaryAttack()
	if SERVER then
		self:RemoveSnatchMarker()
	end
end

function SWEP:Think() 
	if not SERVER then return end
	if self:IsSecondaryAttacking() then
		local curMarker = self:GetCurSnatchMarker()
		if not IsValid(curMarker) then 
			--local tr = self:WorldStealTrace()
			local newMarker = snatch.FindOrCreateWorld(self.Owner:GetShootPos(), self.Owner:GetAimVector(), self.MaxRange)

			if IsValid(newMarker) then
				newMarker:AddPlayer(self.Owner)
				self:SetCurSnatchMarker(newMarker)
				newMarker:RegisterOnActivate(function()
					if self:GetCurSnatchMarker() != newMarker then return end

					local scale = getBrushScale(newMarker.BrushInfo)
					self.Owner:ViewPunch(Angle(scale * 20, 0, 0))
				end )
			end
		end
	end
end

function SWEP:SecondaryAttack()
	self.BaseClass.SecondaryAttack( self )

	self:ShootEffects()
end

function SWEP:Holster(wep) return true end

function SWEP:ShootEffects()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end
