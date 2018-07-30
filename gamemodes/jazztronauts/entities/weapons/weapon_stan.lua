if SERVER then
	AddCSLuaFile()
end

SWEP.Base 					= "weapon_basehold"
SWEP.PrintName 		 		= "Stan"
SWEP.Slot		 	 		= 0
SWEP.Category				= "Jazztronauts"
SWEP.Purpose				= "Teleport through solid walls, brushes, and playerclips by summoning the power of Stan" 

SWEP.ViewModel		 		= "models/weapons/c_stan.mdl"
SWEP.WorldModel				= ""

SWEP.UseHands		= true

SWEP.HoldType		 		= "magic"

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.Primary.Delay			= 0.1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Ammo 			= "none"
SWEP.Primary.Sound	 		= Sound( "weapons/357/357_fire2.wav" )
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Ammo 		= "none"


local DefaultTeleportDistance 	= 256
local DefaultProngCount			= 2
local DefaultSpeed				= 300

SWEP.Spawnable 				= true
SWEP.RequestInfo			= {}
SWEP.TeleportDistance		= DefaultTeleportDistance
SWEP.ProngCount 			= DefaultProngCount
SWEP.SpeedRate				= DefaultSpeed
SWEP.TopSpeed 				= 2000


-- List this weapon in the store
local storeStan = jstore.Register(SWEP, 4000, { type = "tool" })

-- Create 3 items to be purchased one after the other that control range
local storeRange = jstore.RegisterSeries("stan_range", 2000, 10, { 
	name = "Range", 
	requires = storeStan, 
	desc = "Increases range and depth of walls to travel through",
	type = "upgrade",
	priceMultiplier = 2,
})
local storeSpeed = jstore.RegisterSeries("stan_speed", 1000, 10, { 
	name = "Speed", 
	requires = storeStan, 
	desc = "Decreases warm up time",
	type = "upgrade",
	priceMultiplier = 2,
})

function SWEP:Initialize()

	self.BaseClass.Initialize( self )
	self:SetWeaponHoldType( self.HoldType )

	self.speed = 0
	self.offset = 0
	self.open = 0
	self.glow = 0
	self.lasttime = CurTime()
	self.hitpos = Vector(0,0,0)

	self.Hum = CreateSound(self, "ambient/machines/machine6.wav")
	self.BeamLoop1 = CreateSound(self, "ambient/machines/machine_whine1.wav")


	hook.Add( "OnUnlocked", self, function( self, list_name, key, ply ) 
		local baseKey = jstore.GetSeriesBase(key)
		if ply == self.Owner and storeRange == baseKey or storeSpeed == baseKey then
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
	if not IsValid(self.Owner) then return end

	local rangeLevel = jstore.GetSeries(self.Owner, storeRange)
	self.TeleportDistance = DefaultTeleportDistance + math.pow(rangeLevel, 2) * 300

	local speedLevel = jstore.GetSeries(self.Owner, storeSpeed)
	self.SpeedRate = DefaultSpeed + speedLevel * 300

	-- # of skulls == # of upgrades
	self.ProngCount = DefaultProngCount + rangeLevel + speedLevel
end

function SWEP:SetupDataTables()
	self.BaseClass.SetupDataTables( self )
end

function SWEP:Deploy()


	local vm = self.Owner:GetViewModel()
	local depseq = IsValid(vm) and vm:LookupSequence( "anim_deploy" ) or nil
	if depseq then 
		vm:SendViewModelMatchingSequence( depseq )
		--vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_draw" ) )
		vm:SetPlaybackRate( 1.5 )
	end

	return true

end

function SWEP:StartPrimaryAttack()


	if CLIENT then

		--self.Owner:EmitSound( self.Primary.Sound, 50, 140 )
		--self.Hum:Play()

	end

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	--self.Owner:MuzzleFlash()
	--self.Owner:SetAnimation( PLAYER_ATTACK1 )


	//print("Starting to attack")

end

function SWEP:StopPrimaryAttack()

	//print("Stopping attack")

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "anim_deploy" ) )
	--vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_draw" ) )
	vm:SetPlaybackRate( 1 )

end

function SWEP:Cleanup()

	if CLIENT then
		self.Hum:Stop()
		self.BeamLoop1:Stop()
	end

end

function SWEP:DrawWorldModel()

	self:DrawModel()

end


local shiver = {}
local MatFlare = Material("effects/blueflare1")

function SWEP:PostDrawViewModel(viewmodel, weapon, ply)

	local hands = ply:GetHands()
	local atBone = hands:LookupBone( "ValveBiped.Bip01_R_Hand" )

	if not atBone then return end

	local pos, ang = hands:GetBonePosition( atBone )
	local mtx = Matrix()

	pos = pos + ang:Forward()

	mtx:SetAngles( ang )
	mtx:SetTranslation( pos )

	self.offset = self.offset + self.speed * RealFrameTime()
	self.offset = math.NormalizeAngle(self.offset)

	local r = self.offset + UnPredictedCurTime() * 15
	for i=1, self.ProngCount do

		self:AddProng( i, mtx, r + i * (360/self.ProngCount) )

	end

	render.SetMaterial( MatFlare )
	local s = math.cos( CurTime() * 5 ) * 5 + 20
	local s2 = math.cos( CurTime() * 8 ) * 5 + 10
	local s3 = math.cos( CurTime() * 3 ) * 8 + 5
	render.DrawSprite( pos, s, s, Color(255,0,0) )
	render.DrawSprite( pos, s2, s2, Color(255,0,0) )
	render.DrawSprite( pos, s3, s3, Color(255,0,0) )

end

function SWEP:PreDrawViewModel(viewmodel, weapon, ply)



end



function SWEP:AddProng( id, mtx, rot )
	
	shiver[id] = shiver[id] or {}
	shiver[id].amt = shiver[id].amt or 0
	shiver[id].again = shiver[id].again or (CurTime() + (.5 + math.random() * 3))

	if shiver[id].again < CurTime() then
		shiver[id].again = CurTime() + (.5 + math.random() * 3)
		shiver[id].amt = 1
	end

	shiver[id].amt = math.max( shiver[id].amt - FrameTime() * 2, 0 )

	local ent = ManagedCSEnt( "gun_prong_" .. id, "models/Gibs/HGIBS.mdl" )
	ent:SetNoDraw( true )
	ent:SetLOD(0)

	local a = (EyePos() - mtx:GetTranslation()):GetNormal():Angle()

	local out = math.pow( math.sin( self.open * math.pi / 2 ), 2 )
	local lmtx = Matrix()
	lmtx:SetScale( Vector( 0.2, 0.2, 0.2 ) )
	lmtx:Rotate( Angle( 0, 0, rot ) )
	lmtx:Translate( Vector( -10, out * 30 + 20, 0 ) + VectorRand() * shiver[id].amt )

	lmtx:Rotate( Angle(90 * self.glow, math.sin( CurTime() + id * 2 ) * 10 + 180, 180 -90 * (1-self.open) ) )

	lmtx:Scale( Vector(2,2,2) )

	local transformed = mtx * lmtx
	local tpos = transformed:GetTranslation()
	ent:EnableMatrix( "RenderMultiply", transformed )
	ent:DrawModel()

	local col = Color(255,20,0)
	local size = self.glow > .75 and 20 or 10
	col.r = col.r * self.glow
	col.g = col.g * self.glow
	col.b = col.b * self.glow

	render.SetMaterial( MatFlare )
	render.DrawSprite( tpos, size, size, col )

	if self.glow > .1 then
		gfx.renderBeam( tpos, self.hitpos, col, col, math.random(10,20) )
	end

end

function SWEP:ViewModelDrawn( viewmodel ) 

end

function SWEP:TestPlayerLocation( pos )

	local mins, maxs = self.Owner:GetCollisionBounds()
	local tr = util.TraceHull( {
		start = pos,
		endpos = pos,
		mins = mins,
		maxs = maxs,
	} )

	if tr.StartSolid then return false end
	return true

end

function SWEP:TraceFragments( start, endpos )

	local fragments = {}
	local dir = (endpos - start)
	local normal = dir:GetNormal()
	local length = dir:Length()

	local primary = util.TraceLine( {
		start = start,
		endpos = endpos,
		mask = MASK_PLAYERSOLID_BRUSHONLY,
		--collisiongroup = COLLISION_GROUP_WEAPON
		filter = self.Owner,
	} )

	local remaining = length * (1 - primary.Fraction)
	debugoverlay.Sphere(primary.HitPos, 10, 0)
	if primary.Hit and remaining > 0 then

		normal = -primary.HitNormal

		table.insert(fragments, { start = start, endpos = primary.HitPos, tr = primary } )
		local secondary = util.TraceLine( {
			start = primary.HitPos + normal * 2,
			mask = MASK_PLAYERSOLID_BRUSHONLY,
			endpos = primary.HitPos + normal * remaining,
		} )

		if secondary.StartSolid then
			
			local secondary_end = primary.HitPos + normal * remaining * secondary.FractionLeftSolid
			debugoverlay.Sphere(secondary_end, 15, 0, Color(0, 0, 255), true)

			table.insert(fragments, { start = primary.HitPos, endpos = secondary_end, tr = secondary } )
			remaining = remaining * (1 - secondary.FractionLeftSolid)

			if remaining == 0 then return fragments end
			local mins, maxs = self.Owner:GetCollisionBounds()
			local tertiary = util.TraceHull( {
				start = secondary_end + normal * 2,
				endpos = secondary_end + normal * remaining,
				mask = MASK_PLAYERSOLID,
				--collisiongroup = COLLISION_GROUP_WEAPON
				filter = self.Owner,
				mins = mins,
				maxs = maxs,
			} )
			debugoverlay.SweptBox(tertiary.StartPos, tertiary.HitPos, mins, maxs, Angle(0,0,0), 0.1)
			debugoverlay.Sphere(tertiary.HitPos, 15, 0.1, Color(255, 0, 0), true)
			if bit.band( util.PointContents( tertiary.HitPos ), CONTENTS_SOLID ) == 0 then

				
				local backtrace = util.TraceHull( {
					start = tertiary.HitPos,
					endpos = secondary_end + normal * 2,
					mask = MASK_PLAYERSOLID,
					mins = mins,
					maxs = maxs,
				} )

				debugoverlay.SweptBox(tertiary.HitPos, backtrace.HitPos, mins, maxs, Angle(0,0,0), 0.1, Color(255, 255, 0))
				debugoverlay.Sphere(backtrace.HitPos, 15, 0.11, Color(0, 255, 255), true)
				debugoverlay.Sphere(backtrace.StartPos, 15, 0.11, Color(255, 55, 155), true)

				if self:TestPlayerLocation( backtrace.HitPos ) then

					table.insert(fragments, { start = secondary_end, endpos = backtrace.HitPos, tr = tertiary } )

				end

			end

		end

	end

	return fragments

end

local lasermat = Material("effects/laser1.vmt")
function SWEP:DrawHUD()

	cam.Start3D()
	cam.IgnoreZ(true)

	local b,e = pcall(function()

		local viewmodel = self.Owner:GetViewModel(0)
		local hands = LocalPlayer():GetHands()
		local atBone = hands:LookupBone( "ValveBiped.Bip01_R_Hand" )

		if not atBone then return end

		local atpos, atang = hands:GetBonePosition( atBone )
		local distance = self.TeleportDistance
		local viewdir = self.Owner:GetAimVector()
		local startpos = self.Owner:GetShootPos()
		local endpos = startpos + viewdir * distance

		local origin = atpos

		local fragments = self:TraceFragments( startpos, endpos )
		if #fragments ~= 3 then return end

		local function projected( origin, pos, normal )
			local projection = normal or (endpos - origin):GetNormal()
			return origin + math.max( (pos - origin):Dot(projection), 0 ) * projection
		end

		local colors = {
			Color(255,0,0),
			Color(255,100,0),
			Color(100,100,0)
		}

		local root2 = math.sqrt(2)
		local views = {}

		local frag = fragments[1]
		local fragnormal = frag.tr.HitNormal
		local ifragnormal = -fragnormal
		local angle = fragnormal:Angle()

		local step = (360/5)
		for i=1, 5 do
			local r = 50
			local a = (step * i - 18) * DEG_2_RAD
			table.insert( views, frag.endpos - angle:Right() * math.cos(a) * r + angle:Up() * math.sin(a) * r )
		end

		local indices = {
			{1,3},
			{3,5},
			{5,2},
			{2,4},
			{4,1},
		}

		for i=1, #fragments do

			local frag = fragments[i]

			for _, view in pairs(views) do
				gfx.renderBeam( projected( view, frag.start, ifragnormal ), projected( view, frag.endpos, ifragnormal ), colors[i], Color(0,0,0), 20 )
			end

			if i == 2 then
				for _, id in pairs(indices) do
					gfx.renderBeam( projected( views[id[1]], frag.start, ifragnormal ), projected( views[id[2]], frag.start, ifragnormal ), colors[i], colors[i], 20 )
				end
			end

			local altcolor = Color(colors[i].r, colors[i].g, colors[i].b, colors[i].a)
			local frac = ((i-1) / 2)
			local v = Lerp(frac,1,.3)
			altcolor.r = altcolor.r * v
			altcolor.g = altcolor.g * v
			altcolor.b = altcolor.b * v

			if i == 3 then altcolor.g = altcolor.g + 20 end

			render.SetMaterial( lasermat )
			render.StartBeam( 370 / 10 )

			for j=0, 370, 10 do

				local r = 50
				local a0 = (j - 90) * DEG_2_RAD
				local pos = frag.endpos - angle:Right() * math.cos(a0) * r + angle:Up() * math.sin(a0) * r
				render.AddBeam(
					projected( pos, frag.endpos, ifragnormal ),
					20 + self.glow * 100,
					i,
					altcolor
				)

			end
			
			render.EndBeam()

		end

	end)

	cam.End3D()

	if not b then print(e) end

	local sub = math.max(self.glow - .5, 0) * 2

	surface.SetDrawColor(255,0,0,255 * math.pow(sub, 3))
	surface.DrawRect( 0, 0, ScrW(), ScrH() )

end

function SWEP:CalcViewModelView( viewmodel, oldpos, oldang, pos, ang )

	pos = pos + VectorRand() * self.glow * .2
	ang.p = ang.p + math.random() * self.glow * 2
	ang.y = ang.y + math.random() * self.glow * 2
	ang.r = ang.r + math.random() * self.glow * 2

	--pos = pos + ang:Forward() * 18

	return pos, ang

end

function SWEP:CalcView( ply, pos, ang, fov )
	local view = {}

	local diff = 180 - fov
	fov = math.max(fov - math.pow(self.glow,4) * diff, 0)
	
	return pos, ang, fov
end

--Check singleplayer

function SWEP:Teleport()

	local distance = self.TeleportDistance
	local viewdir = self.Owner:GetAimVector()
	local startpos = self.Owner:GetShootPos()
	local endpos = startpos + viewdir * distance
	local fragments = self:TraceFragments( startpos, endpos )

	if #fragments ~= 3 then
		if SERVER then self.Owner:EmitSound( Sound( "buttons/button10.wav" ), 100, 100 ) end
		return
	end

	if SERVER then 
		self.Owner:EmitSound( Sound( "beams/beamstart5.wav" ), 100, 70 )
		self.Owner:EmitSound( Sound( "beamstart7.wav" ), 70, 40 )
		self.Owner:SetPos( fragments[3].endpos )
	end

	if CLIENT and self:IsCarriedByLocalPlayer() then
		LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 128), 1, 0)
	end

end

function SWEP:DoLight()
	if SERVER then return end

	local dlight = DynamicLight(self:EntIndex())
	if dlight then
		dlight.pos = self:GetPos()

		dlight.r = (self.speed / self.TopSpeed) * 255
		dlight.g = 0
		dlight.b = 0
		dlight.brightness = 4
		dlight.Size = 128
		dlight.DieTime = CurTime() + 1
	end
end

function SWEP:Think() 
	self.speed = self.speed or 0
	self.offset = self.offset or 0
	self.open = self.open or 0
	self.glow = self.glow or 0
	self.lasttime = self.lasttime or CurTime()
	self.hitpos = self.hitpos or Vector(0,0,0)

	local dt = ( CurTime() - self.lasttime )
	local speedrate = self.SpeedRate --3850 --750
	local openrate = 4
	local topspeed = self.TopSpeed

	if not self:IsPrimaryAttacking() then
		speedrate = 750
	end

	if dt <= 0 then return end

	if self.speed > 0 then
		self:DoLight()
	end

	if self:IsPrimaryAttacking() then
		if CLIENT and self.open == 0 then

			self:EmitSound( Sound( "npc/roller/blade_out.wav" ), 80, 130 )

		end

		if self.open < 1 then

			self.open = math.min( self.open + dt * openrate, 1 )

			if CLIENT and self.open == 1 then
				self.Hum:Play()
				self.BeamLoop1:Play()
			end

		elseif self.speed < topspeed then

			self.speed = math.min( self.speed + dt * speedrate, topspeed )

			if self.speed == topspeed then
				--if CLIENT then self.BeamLoop1:Play() end
				self:Teleport()
				self:StopPrimaryAttacking()
			end

		end

		if not self:CanTeleport() then
			self:StopPrimaryAttacking()
		end

	else

		if self.speed > 0 then
			
			if self.speed == topspeed then
				--if CLIENT then self.BeamLoop1:Stop() end
				--if SERVER then self.Owner:EmitSound( Sound( "ambient/explosions/explode_7.wav" ), 100, 180 ) end
			end

			self.speed = math.max( self.speed - dt * speedrate, 0 )

		else

			if CLIENT and self.open == 1 then
				self.Hum:Stop()
				self.BeamLoop1:Stop()
				self:EmitSound( Sound( "npc/roller/blade_in.wav" ), 100, 120 )
			end

			self.open = math.max( self.open - dt * openrate, 0 )

		end

	end

	if CLIENT and self.open == 1 then

		self.Hum:ChangePitch(50 + self.speed / 10)
		self.BeamLoop1:ChangePitch(50 + self.speed / 10)

		--util.ScreenShake(LocalPlayer():GetPos(), math.pow(self.glow, 4), 8, 0.02, 100) 

	end

	self.glow = self.speed / topspeed

	if SERVER then
		--print( self.speed )
	end

	self.lasttime = CurTime()


	local pos = self.Owner:GetShootPos()
	local dir = self.Owner:GetAimVector()
	local tr = util.TraceLine( {
		start = pos,
		endpos = pos + dir * 100000,
		mask = MASK_SOLID,
		collisiongroup = COLLISION_GROUP_WEAPON
	} )

	self.hitpos = tr.HitPos

end

function SWEP:CanTeleport()
	if CLIENT and not self:IsCarriedByLocalPlayer() then return true end

	local distance = self.TeleportDistance
	local viewdir = self.Owner:GetAimVector()
	local startpos = self.Owner:GetShootPos()
	local endpos = startpos + viewdir * distance
	local fragments = self:TraceFragments( startpos, endpos )
	return #fragments == 3

end

function SWEP:CanPrimaryAttack()

	return self.open == 0 and self:CanTeleport()

end

function SWEP:PrimaryAttack()

	self.BaseClass.PrimaryAttack( self )

end

function SWEP:ShootEffects()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end

function SWEP:Reload() return false end
function SWEP:CanSecondaryAttack() return false end
