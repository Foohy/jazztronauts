-- Variables that are used on both client and server

AddCSLuaFile()

SWEP.Author			= "Zak"
SWEP.Instructions	= "Lua Physics Gun"
SWEP.Category		= "Jazztronauts"

SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.UseHands			= true

SWEP.ViewModel			= "models/weapons/c_physcannon.mdl"
SWEP.WorldModel			= "models/weapons/w_physics.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "PhysCannon"
SWEP.Slot				= 0
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false

local PickupSound = Sound( "weapons/physcannon/physcannon_pickup.wav" )
local DropSound = Sound( "weapons/physcannon/physcannon_drop.wav" )
local HoldSound = Sound( "weapons/physcannon/superphys_hold_loop.wav" )
local ChargeSound = Sound( "weapons/physcannon/physcannon_charge.wav" )
local ClawsOpen = Sound( "weapons/physcannon/physcannon_claws_open.wav" )
local ClawsClose = Sound( "weapons/physcannon/physcannon_claws_close.wav" )
local Launch = Sound( "weapons/physcannon/superphys_launch1.wav" )

function calcSplineFromTable(values, dt, v)
	return spline.CatmullRomSpline(
		values[1],
		values[2],
		values[3],
		values[4], dt, v)
end

function createRandAnimSpline(custom)
	local animInfo = {}
	animInfo.points = {}
	animInfo.timer = 0.0
	animInfo.rate = 1.0
	animInfo.mag = 1.0
	animInfo.dt = 0.0
	animInfo.pos = Vector()
	animInfo.start = CurTime()
	if not custom then
		for i=1, 5 do
			table.insert(animInfo.points, VectorRand())
		end
	end
	return animInfo
end

function updateAnimSpline(anim)
	anim.timer = anim.timer + FrameTime() * anim.rate
	anim.dt = math.Clamp(anim.timer, 0.0, 1.0)

	if anim.dt == 1.0 then
		if anim.oneoff and #anim.points == 4 then
			anim.pos = anim.points[3]
			anim.done = true
			return
		end

		anim.timer = 0
		table.remove(anim.points, 1)
		if not anim.oneoff then
			table.insert(anim.points, VectorRand())
		end
		anim.dt = 0.0
	end

	anim.pos = calcSplineFromTable(anim.points, anim.dt, anim.pos) * anim.mag
end

function SWEP:Initialize()
	self.holding = nil
	self.holdingPhys = nil
	self.holdingPivot = nil
	self.prevmatrix = Matrix()
	self.nextmatrix = Matrix()
end

function SWEP:Reload()

end

function SWEP:Think()

end

function SWEP:Animate()
	if CLIENT then
		self.animPuntPos = createRandAnimSpline()
		self.animPuntPos.oneoff = true
		self.animPuntPos.rate = 2
		self.animPuntPos.points = {
			Vector(0,0,0),
			Vector(-2,0,-1),
			Vector(-10,0,-5),
			Vector(-8,0,-4),
			Vector(-6,0,-3),
			Vector(-4,0,-2),
			Vector(-2,0,0),
			Vector(0,0,0),
			Vector(0,0,0),
		}

		self.animPuntAng = createRandAnimSpline()
		self.animPuntAng.oneoff = true
		self.animPuntAng.rate = 2
		self.animPuntAng.points = {
			Vector(0,0,0),
			Vector(-7,0,-5),
			Vector(-20,0,-8),
			Vector(-10,0,-13),
			Vector(-7,0,-10),
			Vector(-3,0,-5),
			Vector(-1,0,-2),
			Vector(0,0,0),
			Vector(0,0,0),
		}
	end
end

function SWEP:PhysPunt( phys )

	phys:ApplyForceCenter( self:GetOwner():EyeAngles():Forward() * 2000 * self:GetPowerFactor() * phys:GetMass() )
	if SERVER then self:GetOwner():EmitSound( Launch ) end

end

function SWEP:PrimaryAttack()

	if not IsFirstTimePredicted() then return end

	if not self:GetNWBool("bHoldingProp") then

		self.nextAttack = self.nextAttack or 0
		local tr = self:GetOwner():GetEyeTrace()
		if IsValid(tr.Entity) and self.nextAttack < CurTime() then

			if tr.HitPos:Distance(self:GetOwner():EyePos()) > 500 then return end

			if IsValid(tr.Entity:GetPhysicsObject()) then
				--if tr.Entity:GetPhysicsObject():IsMotionEnabled() == false then return end
				self:PhysPunt( tr.Entity:GetPhysicsObject() )

			end

			local effectdata = EffectData()
				effectdata:SetOrigin( tr.HitPos )
				effectdata:SetStart( self:GetOwner():GetShootPos() )
				effectdata:SetAttachment( 1 )
				effectdata:SetEntity( self )
			util.Effect( "luaphysgun_tracer", effectdata )

			self.nextAttack = CurTime() + 0.5

			self:Animate()
		end
		return

	else

		if IsValid( self.holdingPhys ) then
			self:PhysPunt( self.holdingPhys )
		end
		self:Drop()
		self:Animate()

	end

	self:SetNextPrimaryFire( CurTime() + 1 )

end

function SWEP:GetPhysState(phys)
	local dLinear, dAngular = phys:GetDamping()
	local dGravity = phys:IsGravityEnabled()
	local dMass = phys:GetMass()
	return {
		pos = phys:GetPos(),
		ang = phys:GetAngles(),
		dLinear = dLinear,
		dAngular = dAngular,
		dGravity = dGravity,
		dMass = dMass
	}
end

function SWEP:GetPlayerState()
	return {
		pos = self:GetOwner():EyePos(),
		ang = self:GetOwner():EyeAngles(),
		forward = self:GetOwner():GetForward(),
		right = self:GetOwner():GetRight(),
		up = self:GetOwner():GetUp()
	}
end

function SWEP:GetPowerFactor()

	return 1 --.01

end

function SWEP:Pickup()

	if CLIENT then return end

	local trace = util.GetPlayerTrace( self:GetOwner() )
	trace.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )

	local tr = util.TraceLine( trace )
	local ent = tr.Entity

	if not tr.HitNonWorld then return end
	if not ent then return end

	if string.find(ent:GetClass(), "func_") then return end
	if ent:IsPlayer() then return end

	if not GAMEMODE:GravGunPickupAllowed(self:GetOwner(), ent) then return end

	local phys = ent:GetPhysicsObject()

	if not phys or not phys:IsValid() then return end
	if phys:IsMotionEnabled() == false then
		if ent.was_held_before then
			phys:EnableMotion(true)
		else
			return
		end
	end

	ent.was_held_before = true

	if ent._heldByPhysgun then return end

	self.holding = ent
	self.holdingPhys = phys
	self.holdingPivot = tr.HitPos

	self.propRotate = Quaternion():FromAngles(self.holdingPhys:GetAngles())

	self.propState = self:GetPhysState(self.holdingPhys)
	self.playerState = self:GetPlayerState()

	self.initPropState = self:GetPhysState(self.holdingPhys)
	self.initPlayerState = self:GetPlayerState()

	self.holdingPhys:SetDamping( 30 * self:GetPowerFactor(), 30 * self:GetPowerFactor() )
	self.holdingPhys:EnableGravity( true )

	self.holdDist = self.holdingPivot:Distance(self.playerState.pos)
	self.holdDist = math.Clamp(self.holdDist, 50, 250)
	self.minHoldDist = self.holding:BoundingRadius() + 10
	self.maxHoldDist = math.max(self.minHoldDist, 350)
	--self.holdDist = self.holding:BoundingRadius() + 100

	self.entPlane = Space():FromEntity(self.holding)
	self.entPivot = self.entPlane:WorldToLocal(self.holdingPivot) * -1
	self.entCollisionGroup = self.holding:GetCollisionGroup()

	--self.holding:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self.holding._heldByPhysgun = true

	--print(self.propState.dLinear .. " : " .. self.propState.dAngular)

	self:SetNWBool("bHoldingProp", true)
	self:SetNWEntity("HoldingProp", self.holding)
	self:SetNWVector("HoldingPivot", self.entPivot)
	GAMEMODE:GravGunOnPickedUp(self:GetOwner(), self.holding)

	self:GetOwner():EmitSound( PickupSound )
	self:GetOwner():EmitSound( ClawsOpen )

	self.holdPatch = CreateSound( self:GetOwner(), HoldSound )
	self.holdPatch:PlayEx(1, 50)
	self.holdPatch:ChangePitch(100, 0.5)

	self.prevmatrix:SetAngles( self.holding:GetAngles() )
	self.prevmatrix:SetTranslation( self.holding:GetPos() )
	self.prevcollisiongroup = self.holding:GetCollisionGroup()
	--self.holding:SetCollisionGroup( COLLISION_GROUP_WEAPON )

end

function SWEP:Drop()

	if self.holding == nil then return end

	local washolding = self.holding
	self.holding = nil

	self:GetOwner():EmitSound( ClawsClose )
	self:GetOwner():EmitSound( DropSound )

	self.snapRotate = nil
	self:SetNWBool("bHoldingProp", false)
	self:SetNWEntity("HoldingProp", nil)

	if self.holdPatch then
		--self.holdPatch:ChangePitch(10, 1)
		self.holdPatch:Stop()
	end

	if not IsValid(washolding) then return end

	washolding:SetCollisionGroup( self.prevcollisiongroup )

	if washolding and IsValid(washolding) and IsValid(self.holdingPhys) then
		self.holdingPhys:SetDamping( self.initPropState.dLinear, self.initPropState.dAngular )
		self.holdingPhys:EnableGravity( self.initPropState.dGravity )
		washolding:SetCollisionGroup(self.entCollisionGroup)
		GAMEMODE:GravGunOnDropped(self:GetOwner(), washolding)
	end

	self.holdingPhys = nil
	washolding._heldByPhysgun = false

end

if SERVER then

	--Generate snap orientations
	local root2 = math.sqrt(2) / 2

	local axisVectors = {
		Vector(0,0,1),
		Vector(0,1,0),
		Vector(1,0,0),
		Vector(root2,root2,0),
		Vector(0,root2,root2),
		Vector(root2,0,root2),
		Vector(-root2,root2,0),
		Vector(0,-root2,root2),
		Vector(-root2,0,root2)
	}

	local orthVectors = {}
	local snapQuats = {}

	for i=1, #axisVectors do table.insert(axisVectors, axisVectors[i] * -1) end
	for i=1, #axisVectors do

		for j=i+1, #axisVectors do
			local a = axisVectors[i]
			local b = axisVectors[j]

			if a:Dot(b) == 0 then
				local c = a:Cross(b)
				table.insert(orthVectors, {a,b,c})
				table.insert(orthVectors, {b,a,c})
				table.insert(orthVectors, {a,b,b:Cross(a)})
				table.insert(orthVectors, {b,a,b:Cross(a)})
			end
		end

	end

	local function qvec(v) return string.format("%0.2f, %0.2f, %0.2f", v.x, v.y, v.z) end

	--print("Generated " .. #orthVectors .. " object snap orientations")

	for i=1, #orthVectors do

		local a,b,c = unpack(orthVectors[i])
		--print(qvec(a) .. " | " .. qvec(b) .. " | " .. qvec(c))
		table.insert(snapQuats, Quaternion():FromVectors(a,b,c))

	end

	function closestSnapVector(quat)

		local closest = 360
		local snap = nil
		for i=1, #snapQuats do
			local d = snapQuats[i]:AngleDiff(quat)
			if d < closest then
				snap = snapQuats[i]
				closest = d
			end
		end
		return snap

	end

	function SWEP:UpdateControls(plState)

		local ucmd = self:GetOwner():GetCurrentCommand()

		local rotX = ucmd:GetMouseX() / 15
		local rotY = ucmd:GetMouseY() / 15
		local wheel = ucmd:GetMouseWheel()

		self.wheelLerp = self.wheelLerp or 0
		self.wheelLerp = Lerp(0.1, self.wheelLerp, wheel)

		self.holdDist = math.Clamp(self.holdDist + self.wheelLerp * 25, self.minHoldDist, self.maxHoldDist)

		if self:GetOwner():KeyDown(IN_SPEED) then
			rotX = rotX * 2
			rotY = rotY * 2
		end


		if not self:GetOwner():KeyDown(IN_USE) then return end

		plState.ang = self.playerState.ang

		local q = Quaternion():FromAxis(self.playerState.right, rotY / 57.3)
		self.propRotate = q:Mult(self.propRotate)

		local q = Quaternion():FromAxis(Vector(0,0,1), rotX / 57.3)
		self.propRotate = q:Mult(self.propRotate)

		if self:GetOwner():KeyDown(IN_SPEED) then

			local snapAmt = 10
			local euler = self.propRotate:ToAngles()
			local worldPos, worldEuler = LocalToWorld(Vector(0,0,0), euler, Vector(0,0,0), Angle(0,0,0))

			local snapTo = closestSnapVector(self.propRotate)
			if snapTo then
				--self.propRotate = self.propRotate:Slerp(snapTo, 0.02)
				self.snapRotate = snapTo
			end

		else

			if self.snapRotate then
				self.propRotate = self.snapRotate
				self.snapRotate = nil
			end

		end

	end

end

function SWEP:CalcView(ply, pos, angles, fov)

	if self:GetNWBool("bHoldingProp") and ply:KeyDown(IN_USE) then
		self._lockViewAngle = self._lockViewAngle or angles
		ply:SetEyeAngles(self._lockViewAngle)
		angles = self._lockViewAngle
	else
		self._lockViewAngle = nil
	end

	return pos, angles, fov

end

function SWEP:CalcViewModelView( wep, vm, ang, pos )

	if self:GetNWBool("bHoldingProp") and self:GetOwner():KeyDown(IN_USE) then
		ang = wep:GetOwner():EyeAngles()
		pos = wep:GetOwner():EyePos()
	end

	self.animPos = self.animPos or createRandAnimSpline()
	self.animAng = self.animAng or createRandAnimSpline()

	if self:GetNWBool("bHoldingProp") then

		self.animPos.mag = self.animPos.mag + (0.1 - self.animPos.mag) * .2
		self.animAng.mag = self.animAng.mag + (0.2 - self.animAng.mag) * .2

	else

		self.animPos.mag = self.animPos.mag + (0.0 - self.animPos.mag) * .2
		self.animAng.mag = self.animAng.mag + (0.0 - self.animAng.mag) * .2

	end

	self.animPos.rate = 2.0
	self.animAng.rate = 3.0

	updateAnimSpline(self.animPos)
	updateAnimSpline(self.animAng)

	local loffset = self.animPos.pos

	if self.animPuntPos then
		if self.animPuntPos.done then
			self.animPuntPos = nil
		else
			updateAnimSpline(self.animPuntPos)
			loffset = loffset + self.animPuntPos.pos
		end
	end


	pos = pos + loffset.x * ang:Forward()
	pos = pos + loffset.y * ang:Right()
	pos = pos + loffset.z * ang:Up()

	ang.p = ang.p + self.animAng.pos.x
	ang.y = ang.y + self.animAng.pos.y
	ang.r = ang.r + self.animAng.pos.z

	if self.animPuntAng then
		if self.animPuntAng.done then
			self.animPuntAng = nil
		else
			updateAnimSpline(self.animPuntAng)
			ang.p = ang.p + self.animPuntAng.pos.x
			ang.y = ang.y + self.animPuntAng.pos.y
			ang.r = ang.r + self.animPuntAng.pos.z
		end
	end

	return pos, ang

end

function SWEP:MovePlayers()

	self.prevmatrix = self.prevmatrix or Matrix()
	self.nextmatrix = self.nextmatrix or Matrix()

	self.nextmatrix:SetAngles( self.holding:GetAngles() )
	self.nextmatrix:SetTranslation( self.holding:GetPos() )

	if not self.prevmatrix:Invert() then
		print("FECK")
	end

	local deltamtx = self.nextmatrix * self.prevmatrix

	for k,v in pairs(player.GetAll()) do
		local tr = util.TraceLine( {
			start = v:GetPos() + Vector(0,0,20),
			endpos = v:GetPos() - Vector(0,0,100),
			filter = v,
			--mask = MASK_SOLID,
			--collisiongroup = COLLISION_GROUP_DEBRIS,
		} )

		if v:GetGroundEntity() == self.holding or self.holding == tr.Entity then
		--if v:GetGroundEntity() == self.holding then
			--print("PUSH: " .. v:Nick())
			--v:SetVelocity( push / 2 )

			if v.lastpostime == nil or v.lastpostime < CurTime() - .1 then
				v.lastpostime = nil
				v.lastpos = nil
				--print("clearlast")
			end

			local newpos = deltamtx * v:GetPos()
			--print("PUSH: " .. tostring(v.lastpos))
			v:SetPos( newpos )
			v.lastpos = newpos
			v.lastpostime = CurTime()
			v:SetGroundEntity( self.holding )
			--print(newpos)
			--v:SetParent( self.holding )
		else
			--print("NOT GROUND")
		end
	end

	self.prevmatrix:Set(self.nextmatrix)

end

function SWEP:Think()

	if CLIENT then return end

	if not self.holding then return end
	if not IsValid(self.holding) then self:Drop() return end
	if not IsValid(self.holdingPhys) then self:Drop() return end
	if not self.holdingPhys:IsMotionEnabled() then self:Drop() return end

	local squared_power_factor = self:GetPowerFactor()
	squared_power_factor = squared_power_factor * squared_power_factor

	self:MovePlayers()

	local newPlayerState = self:GetPlayerState()

	self:UpdateControls(newPlayerState)

	local move = newPlayerState.pos - self.playerState.pos
	local prevAngle = self.playerState.ang
	local currAngle = newPlayerState.ang

	local qAngle = Quaternion():FromAngles(currAngle)
	local forward, right, up = qAngle:ToVectors()

	local dQuat = Quaternion()
	local propDiff = GetAngleDifference(self.holdingPhys:GetAngles(), self.propState.ang)
	local plDiff = GetAngleDifference(self.playerState.ang, newPlayerState.ang, dQuat)

	local currentLocalSpace = Space():SetAngles(self.propState.ang)
	currentLocalSpace:SetPos(self.propState.pos)

	if self.snapRotate then
		local snapAngles = self.snapRotate:ToAngles()
		propDiff = GetAngleDifference(self.holdingPhys:GetAngles(), snapAngles)
		currentLocalSpace:SetAngles(snapAngles)
	end

	local grabOffset = currentLocalSpace:LocalToWorld(self.entPivot)

	self.propState.pos = self.playerState.pos + forward * self.holdDist
	self.propState.pos = self.propState.pos + move

	local push = (grabOffset - self.holdingPhys:GetPos())

	self.holdingPhys:Wake()
	--self.holdingPhys:AddVelocity(push * 14 * self:GetPowerFactor())
	self.holdingPhys:ApplyForceCenter( push * 14 * self.holdingPhys:GetMass() * squared_power_factor)


	local rAxis = Vector(propDiff.r, propDiff.p, propDiff.y)
	local rAngle = 10

	if math.abs(rAxis:Length()) > 0.001 and math.abs(rAngle) > 0.001 then

		self.holdingPhys:AddAngleVelocity(rAxis * rAngle * squared_power_factor)

	end

	local deltaP = self.playerState.ang.p - newPlayerState.ang.p
	local deltaY = self.playerState.ang.y - newPlayerState.ang.y

	local q = Quaternion():FromAxis(self.playerState.right, deltaP / 57.3)
	self.propRotate = q:Mult(self.propRotate)

	local q = Quaternion():FromAxis(Vector(0,0,1), -deltaY / 57.3)
	self.propRotate = q:Mult(self.propRotate)

	local physQuat = Quaternion():FromAngles(self.holdingPhys:GetAngles())
	local propIntrusionDifference = self.propRotate:AngleDiff( physQuat )

	self.propState.ang = self.propRotate:ToAngles()
	self.playerState = newPlayerState

end

function SWEP:SecondaryAttack()

	if not IsFirstTimePredicted() then return end

	if self.holding then
		self:Drop()
	else
		self:Pickup()
	end

end

function SWEP:OnDrop()

	self:Drop()

end

function SWEP:OnRemove()

	self:Drop()

end

function SWEP:Holster()

	self:Drop()
	return true

end

function SWEP:Reload()

	if CLIENT then return end

	local prop = self.holding
	if prop then
		self.holdingPhys:EnableMotion(false)
		self:Drop()
	end

end

function SWEP:ShouldDropOnDie() return false end

local function lpColor(ent, index, lp, gp)

	local pos = ent:GetPos() + ent:OBBCenter()
	local normal = (pos - gp):GetNormal()
	local dot = normal:Dot(LocalPlayer():EyeAngles():Forward())

	local absDot = dot
	if dot < 0 then absDot = 0 end

	return Color(255 * absDot,100 * absDot,200 * math.Clamp(math.abs(dot) + 0.4,0,1))

end

if CLIENT then

	local MatFlare = Material("effects/blueflare1")

	local function renderGrabEffect(ent, pivot, srcPos)

		local currentLocalSpace = Space():SetAngles(ent:GetAngles())
		currentLocalSpace:SetPos(ent:GetPos())

		local color = nil

		if ent.GetHoldColor then
			local t = ent:GetHoldColor()
			if t:Length() > 0 then
				color = Color(t.x * 255,t.y * 255,t.z * 255)
			end
		end

		local maxs = ent:OBBMaxs()
		local mins = ent:OBBMins()

		--maxs = maxs + Vector(10,10,10)
		--mins = mins - Vector(10,10,10)

		local grabOffset = currentLocalSpace:LocalToWorld(pivot * -1)

		local localPoints = {
			Vector(mins.x, mins.y, maxs.z),
			Vector(maxs.x, mins.y, maxs.z),
			Vector(maxs.x, maxs.y, maxs.z),
			Vector(mins.x, maxs.y, maxs.z),
			Vector(mins.x, mins.y, mins.z),
			Vector(maxs.x, mins.y, mins.z),
			Vector(maxs.x, maxs.y, mins.z),
			Vector(mins.x, maxs.y, mins.z)
		}

		local grabColors = {}
		local grabPoints = {}

		gfx.renderBeam(srcPos, grabOffset, Color(0,0,0), color or Color(255,100,255), 35)

		for i=1, #localPoints do
			local gp = ent:LocalToWorld(localPoints[i])
			grabColors[i] = color or lpColor(ent, i, localPoints[i], gp)
			grabPoints[i] = gp
			gfx.renderBeam(srcPos, gp, Color(50,25,50), Color(0,0,0), 6)
		end

		render.SetMaterial( MatFlare )
		for i=1, #localPoints do
			render.DrawSprite( grabPoints[i], 10, 10, grabColors[i] )
		end

		for i=1, 4 do
			local n = i + 1
			local p = i + 4
			local j = i + 5
			if i == 4 then n = 1 end
			if i == 4 then j = 5 end
			gfx.renderBeam(grabPoints[i], grabPoints[n], grabColors[i], grabColors[n], 20)
			gfx.renderBeam(grabPoints[i], grabPoints[p], grabColors[i], grabColors[p], 20)
			gfx.renderBeam(grabPoints[p], grabPoints[j], grabColors[p], grabColors[j], 20)
		end

		gfx.renderBox(grabOffset, Vector(-4,-4,-4), Vector(4,4,4), color or Color(255,100,255) )

	end

	local function renderVMFx(weapon, vm, pos)

		local brt = weapon.prongs

		if weapon.animPuntPos then
			if not weapon.animPuntPos.done then
				local dt = 1 - math.min( (CurTime() - weapon.animPuntPos.start) * 4, 1.0 )
				brt = brt + dt * 3
			end
		end

		local corePulse = (math.cos(CurTime() * 3)/2 + 0.5) * 10
		local corePulse2 = (math.sin(CurTime() * 3)/2 + 0.5) * 10
		if brt == 0.0 then return end

		render.SetMaterial( MatFlare )
		render.DrawSprite( pos, 50 * brt + corePulse, 50 * brt + corePulse, Color( 255,100,255 ) )
		render.DrawSprite( pos, 50 * brt + corePulse2, 50 * brt + corePulse2, Color( 50,50,255 ) )

		local pins = {
			vm:GetAttachment(2).Pos,
			vm:GetAttachment(3).Pos,
			vm:GetAttachment(4).Pos,
			vm:GetAttachment(5).Pos,
			vm:GetAttachment(6).Pos,
			vm:GetAttachment(7).Pos
		}

		local col = Color( 255*brt,100*brt,255*brt )
		for i=1, #pins do
			local size = 10 * brt + math.cos(CurTime() * 4 + i) * 3
			render.DrawSprite( pins[i], size, size, col )
		end

		gfx.renderBeam(pins[1], pins[2], col, col, 80 - brt * 70)
		gfx.renderBeam(pins[1], pins[3], col, col, 80 - brt * 70)
		gfx.renderBeam(pins[4], pins[6], col, col, 80 - brt * 70)
		gfx.renderBeam(pins[4], pins[5], col, col, 80 - brt * 70)

	end

	hook.Add("PostDrawTranslucentRenderables", "fphysgun_fx", function()

		for _,ply in pairs(player.GetAll()) do

			local weapon = ply:GetActiveWeapon()
			if not IsValid(weapon) or weapon:GetClass() ~= "weapon_luaphysgun" then continue end

			if ply == LocalPlayer() then
				local vm = LocalPlayer():GetViewModel()
				if not IsValid(vm) then continue end

				local attach = vm:GetAttachment(1)
				local pos, ang = attach.Pos, attach.Ang
				weapon.prongs = weapon.prongs or 0

				if weapon:GetNWBool("bHoldingProp") then
					local propEnt = weapon:GetNWEntity("HoldingProp")
					if IsValid(propEnt) then

						renderGrabEffect(propEnt, weapon:GetNWVector("HoldingPivot"), pos)

					end

					weapon.prongs = weapon.prongs + FrameTime() * 4
				else
					weapon.prongs = weapon.prongs - FrameTime() * 4
				end

				weapon.prongs = math.Clamp(weapon.prongs, 0, 1)
				vm:SetPoseParameter( "active", weapon.prongs )

				renderVMFx(weapon, vm, pos)

			else

				if weapon:GetNWBool("bHoldingProp") then
					local propEnt = weapon:GetNWEntity("HoldingProp")
					if IsValid(propEnt) then

						local at = weapon:GetAttachment(1)

						renderGrabEffect(propEnt, weapon:GetNWVector("HoldingPivot"), at.Pos)

					end
				end

			end

		end

	end)

end

hook.Add("PlayerBindPress", "fphysgun_blockbinds", function(ply, bind, pressed)

	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetNWBool("bHoldingProp") then
		if bind == "invprev" or bind == "invnext" then return true end
	end

end)

hook.Add("AllowPlayerPickup", "fphysgun_allowpickup", function(ply)

	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetNWBool("bHoldingProp") then
		return false
	end

end)