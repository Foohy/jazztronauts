if SERVER then
	AddCSLuaFile()
	--util.AddNetworkString("remove_prop_scene")
	util.AddNetworkString("remove_client_send_trace")
end

SWEP.Base					= "weapon_basehold"
SWEP.PrintName				= "Prop Snatcher"
SWEP.Slot					= 0
SWEP.Category				= "Jazztronauts"
SWEP.WepSelectIcon			= Material( "weapons/weapon_propsnatcher.png" )

SWEP.ViewModel				= "models/weapons/c_stunstick.mdl"
SWEP.WorldModel				= "models/weapons/w_stunbaton.mdl"
SWEP.HoldType				= "melee"

SWEP.Primary.Delay			= 0.1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Sound			= Sound( "weapons/357/357_fire2.wav" )
SWEP.Primary.Automatic		= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo		= "none"

-- General settings
SWEP.ReticleCircleMaterial	= Material("ui/jazztronauts/circle")
local LongRangeDefault		= 300
local ShortRangeDefault	= 175
SWEP.MaxRange				= LongRangeDefault
SWEP.CloseRange				= ShortRangeDefault

-- Tier 1 settings
local AimConeDefault		= 3
SWEP.AutoAimCone			= AimConeDefault

-- Tier 2 settings
SWEP.MinFireDelay			= 0.1 -- Min delay to fire when at full blast
SWEP.WarmUpTime				= 1 -- How long it takes to get to full blast

SWEP.Spawnable				= true
SWEP.RequestInfo			= {}
SWEP.KillsPeople			= true

SWEP.StartShootTime		= 0
SWEP.LastCursorPos			= Vector()

SWEP.SnatchSounds = {
	Sound("jazztronauts/snatch/snatch_get01.wav"),
	Sound("jazztronauts/snatch/snatch_get02.wav"),
	Sound("jazztronauts/snatch/snatch_get03.wav")
}

SWEP.MissSounds = {
	Sound("jazztronauts/snatch/snatch_miss02.wav"),
}

local snatch_cone = jstore.RegisterSeries("snatch_cone", 20000, 10, {
	name = "Aim Cone",
	desc = "Increase the radius of your center aim cone, so you can see and steal with minimal effort.",
	type = "upgrade",
	cat = "Prop Snatcher",
	priceMultiplier = 1.5,
})
local snatch_range = jstore.RegisterSeries("snatch_range", 10000, 10, {
	name = "Steal Range",
	desc = "Increase the range from which you can steal things.",
	type = "upgrade",
	cat = "Prop Snatcher",
	priceMultiplier = 1.5,
})
local snatch2 = jstore.Register("snatch2", 10000, {
	name = "Auto-Auto Aim",
	cat = "Prop Snatcher",
	desc = "Hold down left click to automate picking up many props at a time.",
	type = "upgrade"
})

local snatch_world = jstore.Register("snatch_world", 10000, {
	name = "Ultimate Aim",
	cat = "Prop Snatcher",
	desc = "No matter where you aim, you're picking something up. Hold right click to steal world brushes",
	type = "upgrade"
})
local snatch_multi = jstore.Register("snatch_multi", 50000, {
	name = "Multi Tasking",
	cat = "Prop Snatcher",
	desc = "Multi-task by being able to both steal world brushes and props at the same time",
	requires = snatch_world,
	type = "upgrade"
})
local snatch_world_speed = jstore.RegisterSeries("snatch_world_speed", 100, 10, {
	name = "World Stealing Speed",
	desc = "Steal the world 100% faster",
	requires = snatch_world,
	type = "upgrade",
	cat = "Prop Snatcher",
	priceMultiplier = 10,
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
function SWEP:SetUpgrades(overpowered)
	if not IsValid(self.Owner) then return end

	overpowered = overpowered or self.Overpowered or cvars.Bool("jazz_debug_snatch_allups", false)

	-- Tier I - Aim in cone upgrade
	self.AutoAimCone = AimConeDefault + jstore.GetSeries(self.Owner, snatch_cone) * 3.3

	-- Steal range
	local rangeLevel = overpowered and 10 or jstore.GetSeries(self.Owner, snatch_range)
	self.MaxRange	= LongRangeDefault + rangeLevel * 150
	self.CloseRange = ShortRangeDefault + rangeLevel * 25

	-- Tier II - Automatic fire upgrade
	self.Primary.Automatic = unlocks.IsUnlocked("store", self.Owner, snatch2) or overpowered

	-- Tier III - World stealing
	self.CanStealWorld = unlocks.IsUnlocked("store", self.Owner, snatch_world) or overpowered

	-- How fast they can steal the world
	self.WorldStealSpeed = overpowered and math.huge or (jstore.GetSeries(self.Owner, snatch_world_speed) + 1)
	self.WorldStealSpeed = self.WorldStealSpeed * 2

	-- Allow multi-tasking?
	self.CanMultitask = unlocks.IsUnlocked("store", self.Owner, snatch_multi) or overpowered
end

function SWEP:MakeOverpowered()
	self.Overpowered = true
	self:SetUpgrades(true)
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

	if not IsValid(self.Owner) then return end

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
	return mapgen.CanSnatch(ent) and (not ent.JazzSnatchWait or CurTime() > ent.JazzSnatchWait)
end

function SWEP:GetEntitySize(ent)
	return ent:GetMass() / 100
end

function SWEP:RemoveEntity( ent, snatchobj )

	if self:AcceptEntity( ent ) and not ent.doing_removal then
		snatchobj:SetMode(1)
		snatchobj:StartProp( ent, self:GetOwner(), self.KillsPeople )

		hook.Run("CollectProp", ent, self:GetOwner())
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


local frust = frustum.New()
local twosqrt2 = 2 * math.sqrt(2)
local function findInFrustum(ply, radius, angle)
	local startpos = ply:EyePos()
	local direction = ply:EyeAngles():Forward()

	local center = startpos + direction * radius / 2
	local findRadius = math.tan(math.rad(angle)) * radius * math.pi
	local near = ents.FindInSphere(center, findRadius)

	frust:Setup( 10, radius, angle * twosqrt2, 1, 1)
	frust:Orient( ply:EyePos(), ply:EyeAngles() )
	frust:CullEntities(near)

	return near
end

-- IT'S BEEN LIKE 10 YEARS HOW CAN THIS FUNCTION _STILL_ BE BUGGED
local function findInCone(startpos, direction, radius, angle, result)

	local center = startpos + direction * radius / 2
	local findRadius = math.tan(math.rad(angle)) * radius * math.pi
	local near = ents.FindInSphere(center, findRadius)

	local ang = math.cos(math.rad(angle))

	-- Filter out entities that aren't in the angle
	for _, v in ipairs(near) do
		local vpos = getPropCenter(v)
		local dir = (vpos - startpos)
		dir:Normalize()

		if direction:Dot(dir) >= ang then
			result[v] = v
		end
	end

	return result
end


-- Similar to find in cone, but flipped
-- Shoot a whole bunch of rays into the scene to see what they get
local coneSampleTrace = {}
local coneSampleRes = {}
local function findInConeSample(startpos, angle, aimCone, range, dimu, dimv, results)
	local res = {}
	local ttable = {
		start = startpos,
		filter = LocalPlayer(),
		output = res
	}

	coneSampleTrace.start = startpos
	coneSampleTrace.endpos = Vector()
	coneSampleTrace.filter = LocalPlayer()
	coneSampleTrace.output = coneSampleRes

	local mult = 17 -- #TODO: WHAT
	--local gcstart = collectgarbage("count")
	for u = 0, dimu do
		for v = 0, dimv do

			local radial = u * 1.0 / dimu
			local theta = 2 * math.pi * v / dimv
			local x = radial * math.cos(theta) * aimCone * mult + ScrW() / 2
			local y = radial * math.sin(theta) * aimCone * mult + ScrH() / 2

			local dir = util.AimVector(angle, 90, x, y, ScrW(), ScrH())

			//coneSampleTrace.endpos = coneSampleTrace.start + dir * range
			coneSampleTrace.endpos:Set(dir)
			coneSampleTrace.endpos:Mul(range)
			coneSampleTrace.endpos:Add(coneSampleTrace.start)

			util.TraceLine(coneSampleTrace)

			--debugoverlay.Line(res.StartPos, res.HitPos, 0.11, color_white, true)
			--debugoverlay.Sphere(coneSampleRes.StartPos + dir * 10, 0.02, 0.15, Color(255, 0, 0, 255), true)
			if IsValid(coneSampleRes.Entity) then
				results[coneSampleRes.Entity] = coneSampleRes.Entity
			end
		end
	end
	--print(collectgarbage("count") - gcstart)

	return results
end

local function filterTable(tbl, func)
	for k, v in pairs(tbl) do
		if func(v) then
			tbl[k] = nil
		end
	end
end

local aimTrace = {}
local validAccept = {}
local validAccept1 = {}
local validAccept2 = {}
local validFar = {}
local resAim = {}
local phaseNumber = 0
function SWEP:FindConeEntities()
	--sleep(0.1)
	phaseNumber = (phaseNumber + 1) % 3

	cam.Start3D() -- so ToScreen works

	-- Initial aim vector trace
	-- Entities hit directly from the center take priority
	aimTrace.start = self.Owner:GetShootPos()
	aimTrace.endpos = aimTrace.start + self.Owner:GetAimVector() * self.MaxRange
	aimTrace.filter = self:GetOwner()
	aimTrace.output = resAim

	util.TraceLine(aimTrace)

	-- Whatever the trace actually hit always has priority
	local closest, closedist2
	closedist2 = math.huge
	if self:AcceptEntity(resAim.Entity) then
		validAccept[resAim.Entity] = resAim.Entity
		closest = resAim.Entity
		closedist2 = 0
	end

	-- Phase 1: Close range find-in-cone
	-- Accepts everything as long as its an accepted entity
	if phaseNumber == 0 then
		table.Empty(validAccept1)
		table.Merge(validAccept1, findInFrustum(LocalPlayer(), self.CloseRange, self.AutoAimCone ))
		filterTable(validAccept1, function(v)
			return not self:AcceptEntity(v)
		end )
	end

	-- Phase 2: Mid-range shotgun traces
	-- Shoots out a shitload of traces and accepts anything they hit
	if phaseNumber == 1 then
		table.Empty(validAccept2)
		findInConeSample(resAim.StartPos, resAim.Normal:Angle(), self.AutoAimCone, self.MaxRange, 6, 17, validAccept2)
		filterTable(validAccept2, function(v)
			return not self:AcceptEntity(v)
		end )
	end

	-- Merge current results into single table
	table.Empty(validAccept)
	table.Merge(validAccept, validAccept1)
	table.Merge(validAccept, validAccept2)

	-- Phase 3: Far range find in cone.
	-- Serves only as a 'prop esp'. Does not add anything as a valid target
	-- Only so you can see there's props through walls
	if phaseNumber == 2 then
		table.Empty(validFar)
		findInCone(resAim.StartPos, resAim.Normal, self.MaxRange * 2, self.AutoAimCone, validFar)
		filterTable(validFar, function(v)
			return not self:AcceptEntity(v) or validAccept[v]
		end )
	end

	local maxdist2 = self.MaxRange^2
	local endPos = resAim.StartPos + resAim.Normal * self.MaxRange

	-- Find closest entity to center of screen
	if closedist2 > 0 then
		for _, v in pairs(validAccept) do
			if not IsValid(v) then continue end

			local centerpos = getPropCenter(v)
			local ldist2 = (resAim.StartPos - centerpos):LengthSqr() - v:BoundingRadius()

			if ldist2 < closedist2 then
				closedist2 = ldist2
				closest = v
			end
		end
	end

	cam.End3D()

	-- Give back the closest entities, available entities, and nearby entities
	return closest, validAccept, validFar
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

		-- Tell the server which entity we'd like to pick
		if self:AcceptEntity( self.ConeEnt ) then
			self.ConeEnt.JazzSnatchWait = CurTime() + 2.0
			net.Start( "remove_client_send_trace" )
			net.WriteBit(1)
			net.WriteEntity( self )
			net.WriteEntity( self.ConeEnt )
			net.SendToServer()

			self:EmitSound( self.SnatchSounds[math.random(1,#self.SnatchSounds)], 50, math.random( 100, 100 ), 1, CHAN_AUTO  )

			-- Add some nice feedback
			self.ShootFade = 1
			self.HoverAlpha = 2
		else
			-- Wow this drills into your ears after a while
			local missSoundFade = math.Clamp(1/4.0 + (self.StartShootTime + 4 - CurTime()) / 4, 0, 1)
			self:EmitSound( self.MissSounds[math.random(1,#self.MissSounds)], 50, math.random( 100, 100 ), missSoundFade, CHAN_USER_BASE )

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

		elseif swep:IsAcceptingProps() then

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

local circleTbl = {}
local function drawCircle(x, y, radius, segments)
	table.Empty(circleTbl)

	circleTbl[#circleTbl + 1] = { x = x, y = y, u = 0.5, v = 0.5 }
	for i = 0, segments do
		local a = math.rad( ( i / segments ) * -360 )
		circleTbl[#circleTbl + 1] = { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 }
	end

	local a = math.rad( 0 )
	circleTbl[#circleTbl + 1] = { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 }

	surface.DrawPoly( circleTbl )
end

-- If auto aim is enabled, show the sphere of influence/current reticle
SWEP.HoverAlpha = 0
SWEP.ShootFade = 0
SWEP.WorldShootFade = 0
SWEP.BadShootFade = 0
SWEP.EquipFade = 0
function SWEP:DrawHUD()

	if IsValid(self.Owner:GetVehicle()) then return end -- Don't draw while in vehicle
	if dialog.IsInDialog() then return end -- Also don't draw while in a dialog

	local pfov = LocalPlayer():GetFOV()
	local aimradius = (ScrW() / 2) * math.tan(math.rad(90 - pfov/2)) * math.tan(math.rad(self.AutoAimCone))
	local drawExtended = self.AutoAimCone > 0

	local curMarker = self:GetCurSnatchMarker()
	local worldShootGoal = IsValid(curMarker) and 1 - curMarker:GetSpawnPercent() or 0

	-- #TODO: When _holding_, keep the circle at the smaller radius and show that same semicircle
	-- from the bus caller
	local radius = aimradius * (1 - math.sin(math.pi * self.WorldShootFade * 0.5) * 0.8)
	radius = radius * math.EaseInOut(self.EquipFade, 0, 1)

	-- Aimhack higlight
	local ent, accept, near = self.ConeEnt, self.ConeAccept or {}, self.ConeNear or {}

	-- Draw entities we can't grab now, but we're nearby
	local s = ScreenScale(1)
	surface.SetDrawColor(100, 100, 100)
	for _, v in pairs(near) do
		if not IsValid(v) then continue end

		cam.Start3D()
		local toscr = getPropCenter(v):ToScreen()
		cam.End3D()

		surface.DrawRect(toscr.x - s, toscr.y - s, s *2, s *2)
	end

	-- Draw all the entities that are currently eligible to be snatched
	local s = ScreenScale(2)
	surface.SetDrawColor(255, 100, 100)

	render.SetStencilEnable(true)
	render.SetStencilWriteMask(0xFF)
	render.SetStencilTestMask(0xFF)

	render.ClearStencil()

	-- First, draw where we cut out the world
	render.SetStencilReferenceValue(1)
	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	render.SetStencilPassOperation(STENCIL_REPLACE)

	-- Write the circle where we want to clip props to
	render.OverrideColorWriteEnable(true, false)
	drawCircle(ScrW() / 2, ScrH() / 2, radius * 0.75, 15)
	render.OverrideColorWriteEnable(false)

	-- Now every prop drawn will obey the stencil
	render.SetStencilCompareFunction(STENCIL_EQUAL)

	-- Highlight the hovered entity the most

	render.SuppressEngineLighting(true)

	-- Also redraw/color all 'available' props
	local _, mat = jazzvoid.GetVoidOverlay()
	render.MaterialOverride(mat)
	render.SetColorModulation(4, 4, 4)
	cam.Start3D()

		for k, v in pairs(accept) do
			if not IsValid(v) then continue end
			v:DrawModel()
		end

		render.SetColorModulation(1, 1, 1)
		render.MaterialOverride()
		render.SuppressEngineLighting(false)
		render.SetStencilEnable(false)

		-- Render a bounding box over the selected prop
		if IsValid(ent) then
			local srcPos = self:GetAttachment( 1 ).Pos
			if !LocalPlayer():ShouldDrawLocalPlayer() then
				srcPos = LocalPlayer():GetViewModel():GetAttachment( 1 ).Pos
			end

			JazzRenderGrabEffect(ent, nil, srcPos)
		end

	cam.End3D()

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

	if self.CanMultitask then
		local totalSize = aimradius * 2.55
		surface.DrawTexturedRect(ScrW() / 2 - totalSize/2, ScrH() / 2 - totalSize/2, totalSize, totalSize)
	end

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

function SWEP:IsAcceptingProps()
	return not IsValid(self:GetCurSnatchMarker(newMarker)) or self.CanMultitask
end

function SWEP:CanPrimaryAttack()
	return self:IsAcceptingProps()
end

function SWEP:PrimaryAttack()
	self.BaseClass.PrimaryAttack( self )

	--Standard stuff
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self:GetPrimaryShootDelay())

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
	local scale = math.Clamp((size.x + size.y + size.z) * 0.0004 - 0.15, 0, 1)

	return scale
end

function SWEP:CalcView(ply, pos, ang, fov)
	local marker = self:GetCurSnatchMarker(newMarker)
	if not IsValid(marker) or not marker.GetProgress or not marker.Brush then return end

	local scale = getBrushScale(marker.Brush)
	scale = math.max(0, scale - self.WorldStealSpeed * 0.000001)

	self.PullShake = self.PullShake or 0
	self.GoalShake = self.GoalShake or 0
	self.NextRandom = self.NextRandom or 0
	if CurTime() > self.NextRandom then
		local time = math.random(0.1, 0.7)
		self.NextRandom = CurTime() + time
		self.GoalShake = math.random(0.2, 1) * sign(math.random(-1, 1))

		util.ScreenShake(pos, 5 * scale, 5, time, 256)
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

-- Do the cone tracing stuff here instead of in SWEP:Think
-- This stuff really only ever needs to update once per frame, where Think() can be called multiple times
hook.Add("PostRender", "JazzUpdateSnatchEnts", function()
	local self = LocalPlayer():GetWeapon("weapon_propsnatcher")
	if not IsValid(self) or self != LocalPlayer():GetActiveWeapon() then return end

	local ent, accept, near = self:FindConeEntities()
	self.ConeEnt = ent
	self.ConeAccept = accept
	self.ConeNear = near
end )

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
					if not IsValid(self) or not self.GetCurSnatchMarker then return end
					if self:GetCurSnatchMarker() != newMarker then return end
					if not IsValid(self.Owner) then return end

					local scale = getBrushScale(newMarker.BrushInfo)
					self.Owner:ViewPunch(Angle(scale * 30, 0, 0))
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

	self.Weapon:SendWeaponAnim( ACT_VM_HITKILL )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end
