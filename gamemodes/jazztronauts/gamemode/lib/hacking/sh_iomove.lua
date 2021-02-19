AddCSLuaFile()

local Player = FindMetaTable("Player")

function Player:SetTracePos( along )

	self:SetNWFloat( "io_trace_along", along )

end

function Player:GetTracePos()

	return self:GetNWFloat( "io_trace_along", 0 )

end

function Player:GetActiveTrace()

	local cyberspace = bsp2.GetCurrent().cyberspace
	if cyberspace then
		local id = 1 + self:GetNWInt( "io_trace", -1 )
		--print("gettrace: " .. id)
		return cyberspace:GetTraceByIndex(id)
	else
		print("No cyberspace :(")
	end

end

function Player:SetActiveTrace( trace )

	local cyberspace = bsp2.GetCurrent().cyberspace
	if cyberspace and trace then
		print("Trace Set")
		self:SetNWInt( "io_trace", trace:GetIndex() - 1 )
	else
		self:SetNWInt( "io_trace", -1 )
	end

end

module( "iomove", package.seeall )

function AttachPlayerToTrace( ply, trace, along )

	ply:SetActiveTrace( trace )
	ply:SetTracePos( along )

	local pos, quat = trace:GetPointAlongPath( along )
	local driver = ents.Create("jazz_io_drive")
	driver:SetPos( pos )
	driver:SetOwner( ply )
	driver:SetAngles( ply:EyeAngles() )
	driver:Spawn()
	driver:Activate()

	-- we need to wait until the entity is available on the client
	-- figure out how to do this
	timer.Simple(.5, function()

		drive.PlayerStopDriving( ply )
		drive.PlayerStartDriving( ply, driver, "drive_io" )

	end)

	return driver

end


if CLIENT then

	--[[local playerRotDelta = Quat(0,0,0,1)
	local targetRotation = Quat(0,0,0,1)
	local offsetRotation = Quat(0,0,0,1)
	local targetPos = Vector(0,0,0)
	hook.Add("CalcView", "iotracetest", function( ply, pos, angles, fov )

		local trace = ply:GetActiveTrace()
		if trace then

			local real = Quat():FromAngles(angles)
			local delta = playerRotDelta:Invert():Mult( real )
			playerRotDelta = real
			offsetRotation = offsetRotation:Mult(delta)


			local along = ply.localTracePos --ply:GetTracePos()
			local pos, quat = trace:GetPointAlongPath(along)
			targetRotation = targetRotation:Slerp(quat, 1 - math.exp( FrameTime() * -40 ))

			local f,r,u = targetRotation:ToVectors()
			targetPos = pos + u * 5

			local view = {}
			view.origin = targetPos
			view.angles = targetRotation:Mult(offsetRotation):ToAngles()
			view.drawviewer = true

			return view

		else

			playerRotDelta:FromAngles(angles)
			targetRotation:FromAngles(angles)
			targetPos = pos

		end

	end)]]

end



--
--
-- This is the default drive type for when you right click -> drive in sandbox
--
--

DEFINE_BASECLASS( "drive_base" )

drive.Register( "drive_io",
{
	Init = function( self )

		self.CameraDist		= 1
		self.CameraDistVel	= 0.1

	end,

	CalcView = function( self, view )

		local idealdist = math.max( 10, self.Entity:BoundingRadius() ) * self.CameraDist

		self:CalcView_ThirdPerson( view, idealdist, 2, { self.Entity } )

		view.angles.roll = 0

	end,

	SetupControls = function( self, cmd )

		self.CameraDistVel = self.CameraDistVel + cmd:GetMouseWheel() * -0.5

		self.CameraDist = self.CameraDist + self.CameraDistVel * FrameTime()
		self.CameraDist = math.Clamp( self.CameraDist, 2, 20 )
		self.CameraDistVel = math.Approach( self.CameraDistVel, 0, self.CameraDistVel * FrameTime() * 2 )

	end,

	StartMove = function( self, mv, cmd )

		self.Player:SetObserverMode( OBS_MODE_CHASE )

		if ( mv:KeyReleased( IN_USE ) ) then
			if SERVER then self.Entity:Remove() end
			self:Stop()
		end

		if ( mv:KeyReleased( IN_RELOAD ) ) then

			local mins, maxs = self.Player:GetHull()
			local check = util.TraceHull({
				start = self.Entity:GetPos(),
				endpos = self.Entity:GetPos(),
				filter = self.Entity,
				mins = mins,
				maxs = maxs,
				mask = MASK_SOLID,
			})

			if not check.Hit then

				if SERVER then 
					print("SET ANGLES: ", self.Entity:GetAngles() )
					self.Player:SetPos( self.Entity:GetPos() )
					self.Player:SetEyeAngles( self.Entity:GetAngles() )
					self.Player:SetAngles( self.Entity:GetAngles() )
					self.Entity:Remove() 
				end
				self:Stop()

			end
		end

		mv:SetOrigin( self.Entity:GetNetworkOrigin() )
		mv:SetVelocity( self.Entity:GetAbsVelocity() )
		mv:SetMoveAngles( mv:GetAngles() )
		mv:SetAngles( mv:GetAngles() )

	end,

	Move = function( self, mv )

		local speed = 0.0005 * FrameTime()
		if ( mv:KeyDown( IN_SPEED ) ) then speed = 0.005 * FrameTime() end
		if ( mv:KeyDown( IN_DUCK ) ) then speed = 0.00005 * FrameTime() end

		-- Simulate noclip's action when holding space
		if ( mv:KeyDown( IN_JUMP ) ) then mv:SetUpSpeed( 10000 ) end

		local ang = mv:GetMoveAngles()
		local pos = mv:GetOrigin()
		local vel = mv:GetVelocity()

		-- Cancel out the roll
		ang.roll = 0

		vel = vel + ang:Forward()	* mv:GetForwardSpeed()	* speed
		vel = vel + ang:Right()		* mv:GetSideSpeed()		* speed
		vel = vel + ang:Up()		* mv:GetUpSpeed()		* speed

		if ( math.abs( mv:GetForwardSpeed() ) + math.abs( mv:GetSideSpeed() ) + math.abs( mv:GetUpSpeed() ) < 0.1 ) then
			vel = vel * 0.90
		else
			vel = vel * 0.99
		end

		local trace = self.Player:GetActiveTrace()
		local t0 = trace:FindPointOnPath( pos )

		local p0, q0 = trace:GetPointAlongPath( t0 )
		local t1 = t0 + q0:Forward():Dot( vel )

		t1 = math.Clamp(t1, 0, trace:GetLength())

		local p1, q1 = trace:GetPointAlongPath( t1 )

		if q0:Forward():Dot(q1:Forward()) < 0.99 then
			local v0 = vel:Dot( q0:Forward() )
			vel = q1:Forward() * v0
		end

		pos = p1 --pos + vel

		mv:SetVelocity( vel )
		mv:SetOrigin( pos )

	end,

	FinishMove = function( self, mv )

		self.Entity:SetNetworkOrigin( mv:GetOrigin() )
		self.Entity:SetAbsVelocity( mv:GetVelocity() )
		self.Entity:SetAngles( mv:GetAngles() )

	end

}, "drive_base" )
