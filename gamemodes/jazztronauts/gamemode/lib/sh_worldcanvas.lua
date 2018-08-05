AddCSLuaFile()

module( "worldcanvas", package.seeall )

local meta = {}
meta.__index = meta


function meta:PushScreenRenderMode()

	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.SetStencilReferenceValue( 1 )
	render.SetStencilWriteMask( 1 )
	render.SetStencilTestMask( 1 )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

	render.OverrideDepthEnable( true, true )
	surface.SetDrawColor(Color(0,0,0,1))
	surface.DrawRect(0, 0, self.xres, self.yres )
	render.OverrideDepthEnable( false, false )

	render.SetStencilReferenceValue( 1 )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

	cam.IgnoreZ(true)

	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )

end

function meta:PopScreenRenderMode()

	render.PopFilterMag()
	render.PopFilterMin()

	cam.IgnoreZ(false)

	render.SetStencilEnable(false)

end

function meta:Project( pos, dir )

	local a = (self.origin - pos):Dot( self.normal )
	local b = dir:Dot( self.normal )
	local c = a / b
	local v = pos + dir * c

	return v, c

end

function meta:Draw()

	if self.errored then
		if CurTime() - self.error_timer < 2 then
			gfx.renderPlane( self.origin, self.normal, self.width, self.height, Color(255,0,0,100) )
			return
		end
	end

	if self.debug then
		gfx.renderPlane( self.origin, self.normal, self.width, self.height, Color(255,100,40,50) )
	end

	cam.PushModelMatrix( self.world_screen_matrix )

	self:PushScreenRenderMode()

	if self.drawfunc then
		local b,e = pcall( self.drawfunc, unpack( self.drawargs ) )
		if not b then
			self.errored = true
			self.error_timer = CurTime()
			self.error_text = tostring( e )
			ErrorNoHalt( self.error_text .. "\n" )
		else
			self.errored = false
		end
	end

	self:PopScreenRenderMode()

	cam.PopModelMatrix()

end

function meta:GetMousePos( ply )

	ply = ply or LocalPlayer()

	local pos = self:Project( ply:GetShootPos(), ply:GetAimVector() )
	local dist = pos:Distance( ply:GetShootPos() )
	pos:Sub( self.origin )

	local x = -pos:Dot( self.angles:Right() ) * (self.xres / self.width) + self.xres / 2
	local y = -pos:Dot( self.angles:Up() ) * (self.yres / self.height) + self.yres / 2

	local focus = x >= 0 and x <= self.xres and y >= 0 and y <= self.yres

	return x, y, focus, dist

end

function meta:SetDrawFunc( func, ... )

	self.drawfunc = func
	self.drawargs = {...}

end

function meta:_UpdateMatrix()

	local scale_x = self.width / self.xres
	local scale_y = -self.height / self.yres
	local off_x = -self.width / 2
	local off_y = self.height / 2

	self.screen_matrix = Matrix({
		{0, 0, 1, 0},
		{scale_x, 0, 0, off_x},
		{0, scale_y, 0, off_y},
		{0, 0, 0, 1},
	})

	self.world_matrix = Matrix()
	self.world_matrix:Translate( self.origin )
	self.world_matrix:Rotate( self.angles )

	self.world_screen_matrix = self.world_matrix * self.screen_matrix
	return self

end

function meta:SetPos( origin )

	self.origin:Set( origin )
	self:_UpdateMatrix()

end

function meta:SetAngles( angles )

	self.angles:Set( angles )
	self.normal = angles:Forward()

	self:_UpdateMatrix()

 end

function meta:SetSize( width, height ) self.width = width  self.height = height self:_UpdateMatrix() end
function meta:SetResolution( width, height ) self.xres = width  self.yres = height self:_UpdateMatrix() end

function meta:GetPos() return self.origin end
function meta:GetAngles() return self.angles end
function meta:GetNormal() return self.normal end
function meta:GetSize() return self.width, self.height end
function meta:GetResolution() return self.xres, self.yres end

function meta:EnableDebug( enable ) self.debug = enable end

function New( width, height, origin, angles )

	return setmetatable({
		origin = origin or Vector(),
		normal = normal or Vector(0,0,1),
		angles = angles or Angle(),
		width = width or 128,
		height = height or 128,
		xres = 1,
		yres = 1,
	}, meta)

end