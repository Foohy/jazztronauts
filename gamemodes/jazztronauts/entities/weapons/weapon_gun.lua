if SERVER then
	AddCSLuaFile()
end

SWEP.Base 					= "weapon_basehold"
SWEP.PrintName 		 		= "Gun"
SWEP.Slot		 	 		= 0

SWEP.ViewModel		 		= "models/weapons/c_pistol.mdl"
SWEP.WorldModel				= "models/weapons/w_pistol.mdl"

SWEP.UseHands		= true

SWEP.HoldType		 		= "pistol"

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

SWEP.Spawnable 				= true
SWEP.RequestInfo			= {}
SWEP.TeleportDistance		= 5120000

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

	print("INIT")

end

function SWEP:SetupDataTables()
	--Might use this later, who the fuck knows
end

function SWEP:Deploy()

	return true

end

function SWEP:StartAttack()

	self.BaseClass.StartAttack( self )


	if CLIENT then

		--self.Owner:EmitSound( self.Primary.Sound, 50, 140 )
		--self.Hum:Play()

	end

	--self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	--self.Owner:MuzzleFlash()
	--self.Owner:SetAnimation( PLAYER_ATTACK1 )


	print("Starting to attack")

end

function SWEP:StopAttack()

	print("Stopping attack")

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

function SWEP:PreDrawViewModel(viewmodel, weapon, ply)

	local atBone = viewmodel:LookupBone( "ValveBiped.square" )

	if not atBone then return end

	local pos, ang = viewmodel:GetBonePosition( atBone )
	local mtx = Matrix()
	mtx:SetAngles( ang )
	mtx:SetTranslation( pos )

	local r = self.offset + CurTime() * 15
	local count = 5
	for i=1, count do

		self:AddProng( i, mtx, r + i * (360/count) )

	end

end

local shiver = {}
local MatFlare = Material("effects/blueflare1")
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
	lmtx:Rotate( Angle( 90, 0, rot ) )
	lmtx:Translate( Vector( -10, out * 30 + 20, 0 ) + VectorRand() * shiver[id].amt )

	lmtx:Rotate( Angle(90 * self.glow, math.sin( CurTime() + id * 2 ) * 10, -90 * (1-self.open) ) )

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
		--mask = MASK_SOLID,
		--collisiongroup = COLLISION_GROUP_WEAPON
		filter = self.Owner,
	} )

	local remaining = length * (1 - primary.Fraction)
	if primary.Hit and remaining > 0 then

		normal = -primary.HitNormal

		table.insert(fragments, { start = start, endpos = primary.HitPos, tr = primary } )
		local secondary = util.TraceLine( {
			start = primary.HitPos + normal * 2,
			endpos = primary.HitPos + normal * remaining,
		} )

		if secondary.StartSolid then

			local secondary_end = primary.HitPos + normal * remaining * secondary.FractionLeftSolid

			table.insert(fragments, { start = primary.HitPos, endpos = secondary_end, tr = secondary } )
			remaining = remaining * (1 - secondary.FractionLeftSolid)

			if remaining == 0 then return fragments end

			local tertiary = util.TraceLine( {
				start = secondary_end + normal * 2,
				endpos = secondary_end + normal * remaining,
				--mask = MASK_SOLID,
				--collisiongroup = COLLISION_GROUP_WEAPON
				filter = self.Owner,
			} )

			if bit.band( util.PointContents( tertiary.HitPos ), CONTENTS_SOLID ) == 0 then

				local mins, maxs = self.Owner:GetCollisionBounds()
				local backtrace = util.TraceHull( {
					start = tertiary.HitPos,
					endpos = tertiary.HitPos - normal * remaining,
					mins = mins,
					maxs = maxs,
				} )

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
		local atBone = viewmodel:LookupBone( "ValveBiped.square" )

		if not atBone then return end

		local atpos, atang = viewmodel:GetBonePosition( atBone )
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

	return pos, ang

end

function SWEP:CalcView( ply, pos, ang, fov )
	local view = {}

	local diff = 180 - fov
	fov = fov - math.pow(self.glow,4) * diff

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

	if CLIENT then
		LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 128), 1, 0)
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
	local speedrate = 3850 --750
	local openrate = 4
	local topspeed = 2000

	if not self:IsAttacking() then
		speedrate = 750
	end

	if dt == 0 then return end

	if self:IsAttacking() then

		if CLIENT and self.open == 0 then

			self.Owner:EmitSound( Sound( "npc/roller/blade_out.wav" ), 50, 130 )

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
				self:StopAttacking()
			end

		end

		if not self:CanTeleport() then
			self:StopAttacking()
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
				self.Owner:EmitSound( Sound( "npc/roller/blade_in.wav" ), 100, 120 )
			end

			self.open = math.max( self.open - dt * openrate, 0 )

		end

	end

	if CLIENT and self.open == 1 then

		self.Hum:ChangePitch(50 + self.speed / 10)
		self.BeamLoop1:ChangePitch(50 + self.speed / 10)

		--util.ScreenShake(LocalPlayer():GetPos(), math.pow(self.glow, 4), 8, 0.02, 100) 

	end

	self.offset = self.offset + self.speed * dt
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
