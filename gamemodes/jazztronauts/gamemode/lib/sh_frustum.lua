if SERVER then

	AddCSLuaFile()

end

module("frustum", package.seeall)

--Perspective matrix calculations
local standard4by3inv = 1.0 / ( 4.0 / 3.0 )

local function ScaleFOVByWidthRatio( fov, ratio )

	local half = fov * ( math.rad(0.5) )
	local t = math.tan( half ) * ratio
	return math.deg( math.atan( t ) ) * 2.0

end

local function BuildPerspective( near, far, fov, width, height, m )

	local aspect = (width / height)
	fov = ScaleFOVByWidthRatio(fov, aspect * standard4by3inv)
	local wscale = 1 / math.tan(math.rad(fov * .5))
	local hscale = aspect * wscale

	m:Identity()
	m:SetField(1,1,wscale)
	m:SetField(2,2,hscale)
	m:SetField(3,3,far / (near - far))
	m:SetField(3,4,near * far / (near - far))
	m:SetField(4,3,-1)
	m:SetField(4,4,0)
	return m

end

--Matrix multiplication functions using tables instead of VMatrix
--keeps everything local to LuaJIT where we have the most power (2x speed)
local function MultMatrix3(mv, p, w, o)

	local x = p.x
	local y = p.y
	local z = p.z

	o.x = mv[1][1] * x + mv[1][2] * y + mv[1][3] * z + mv[1][4] * w
	o.y = mv[2][1] * x + mv[2][2] * y + mv[2][3] * z + mv[2][4] * w
	o.z = mv[3][1] * x + mv[3][2] * y + mv[3][3] * z + mv[3][4] * w
	return o

end

local function MultMatrix4(mv, p, w, o)

	local x = p.x
	local y = p.y
	local z = p.z

	o.x = mv[1][1] * x + mv[1][2] * y + mv[1][3] * z + mv[1][4] * w
	o.y = mv[2][1] * x + mv[2][2] * y + mv[2][3] * z + mv[2][4] * w
	o.z = mv[3][1] * x + mv[3][2] * y + mv[3][3] * z + mv[3][4] * w
	w   = mv[4][1] * x + mv[4][2] * y + mv[4][3] * z + mv[4][4] * w

	return o, w

end

local function MultMatrix4Transposed(mv, p, w, o)

	local x = p.x
	local y = p.y
	local z = p.z

	o.x = mv[1][1] * x + mv[2][1] * y + mv[3][1] * z + mv[4][1] * w
	o.y = mv[1][2] * x + mv[2][2] * y + mv[3][2] * z + mv[4][2] * w
	o.z = mv[1][3] * x + mv[2][3] * y + mv[3][3] * z + mv[4][3] * w
	w   = mv[1][4] * x + mv[2][4] * y + mv[3][4] * z + mv[4][4] * w

	return o, w

end

--Geometry that makes up the frustum (cube)
local geometry = {

	points = {
		Vector(-1,-1,-1),
		Vector(1,-1,-1),
		Vector(1,1,-1),
		Vector(-1,1,-1),
		Vector(-1,-1,1),
		Vector(1,-1,1),
		Vector(1,1,1),
		Vector(-1,1,1),
	},
	quads = {
		{4,3,2,1},
		{1,2,6,5},
		{2,3,7,6},
		{3,4,8,7},
		{4,1,5,8},
		{5,6,7,8},
	},
	indices = {
		{1,2},
		{2,3},
		{3,4},
		{4,1},

		{5,6},
		{6,7},
		{7,8},
		{8,5},

		{1,5},
		{2,6},
		{3,7},
		{4,8},
	},
	planeIndices = {
		right = {4,5,1},
		left = {2,7,3},
		bottom = {1,6,2},
		top = {4,7,8},
		near = {4,2,3},
		far = {8,7,6},
	}

}

local meta = {}
meta.__index = meta

function New( ... )

	return setmetatable({}, meta):Init( ... )

end

function meta:Init()

	--Precache matrix objects
	self.perspectiveMatrix = Matrix()
	self.viewMatrix = Matrix()

	self.invPerspectiveMatrix = Matrix()
	self.invViewMatrix = Matrix()

	self.viewMatrixIsValid = false
	self.perpectiveMatrixIsValid = false

	self.txpoints = {}
	self.txplanes = {}
	self.wplanes = {}

	--Precache vector objects
	for i=1, 8 do self.txpoints[i] = Vector(0,0,0) end

	--Precache plane objects
	for k,v in pairs( geometry.planeIndices ) do

		self.txplanes[k] = {
			normal = Vector(0,0,0),
			absnormal = Vector(0,0,0),
			dist = 0
		}
		self.wplanes[k] = {
			normal = Vector(0,0,0),
			absnormal = Vector(0,0,0),
			dist = 0
		}

	end

	return self

end

function meta:IsValid()

	return self.viewMatrixIsValid and self.perpectiveMatrixIsValid

end

function meta:_FinalizeViewMatrix()

	--Inverted view matrix
	self.invViewMatrix:Set( self.viewMatrix )
	self.invViewMatrix:Invert()

	--Copy matrices to lua
	self.viewMatrixTable = self.viewMatrix:ToTable()
	self.invViewMatrixTable = self.invViewMatrix:ToTable()

	self.viewMatrixIsValid = true

	--Build world-space planes
	self:BuildWorldPlanes()

end

function meta:_FinalizePerspectiveMatrix()

	--Inverted perspective matrix
	self.invPerspectiveMatrix:Set( self.perspectiveMatrix )
	self.invPerspectiveMatrix:Invert()

	--Copy matrices to lua
	self.perspectiveMatrixTable = self.perspectiveMatrix:ToTable()
	self.invPerspectiveMatrixTable = self.invPerspectiveMatrix:ToTable()

	self.perpectiveMatrixIsValid = true

	--Build box and planes in frustum-space
	self:BuildBox()
	self:BuildPlanes()

end

function meta:Setup(near, far, fov, width, height)

	BuildPerspective( near, far, fov, width, height, self.perspectiveMatrix )

	self:_FinalizePerspectiveMatrix()

	return self

end

function meta:SetupOrtho(near, far, left, right, top, bottom)

	local m = self.perspectiveMatrix
	m:Identity()
	m:SetField(1,1,2 / (right - left))
	m:SetField(2,2,2 / (top - bottom))
	m:SetField(3,3,-2 / (far - near))
	m:SetField(1,4,-((right+left) / (right-left)))
	m:SetField(2,4,-((top+bottom) / (top-bottom)))
	m:SetField(3,4,-((far+near) / (far-near)))

	self:_FinalizePerspectiveMatrix()

	self.IsOrtho = true
	self.OrthoShape = {
		left = left,
		right = right,
		top = top,
		bottom = bottom,
	}

	return self

end

function meta:Orient(pos, angles)

	local f = angles:Forward()
	local r = angles:Right()
	local u = angles:Up()

	f:Mul( -1 )

	self.viewMatrix:SetForward(r)
	self.viewMatrix:SetRight(u)
	self.viewMatrix:SetUp(f)
	self.viewMatrix:SetTranslation(pos)

	self:_FinalizeViewMatrix()

end

--Build a box from the geometry and transform it into frustum-space
local _temp_vector = Vector()
function meta:BuildBox()

	for k,v in pairs( geometry.points ) do

		local p, w = MultMatrix4( self.invPerspectiveMatrixTable, v, 1, self.txpoints[k] )
		self.txpoints[k]:Mul( 1 / w )

	end

end

--Build planes from frustum-space box
function meta:BuildPlanes()

	--Trying not to make any vectors here
	for k,v in pairs( geometry.planeIndices ) do

		local v1,v2,v3 = self.txpoints[ v[1] ], self.txpoints[ v[2] ], self.txpoints[ v[3] ]

		local plane = self.txplanes[k]
		plane.normal.x = (v2.y - v1.y) * (v3.z - v1.z) - (v2.z - v1.z) * (v3.y - v1.y)
		plane.normal.y = (v2.z - v1.z) * (v3.x - v1.x) - (v2.x - v1.x) * (v3.z - v1.z)
		plane.normal.z = (v2.x - v1.x) * (v3.y - v1.y) - (v2.y - v1.y) * (v3.x - v1.x)

		plane.normal:Mul( 1 / plane.normal:Length() )

		plane.absnormal.x = math.abs(plane.normal.x)
		plane.absnormal.y = math.abs(plane.normal.y)
		plane.absnormal.z = math.abs(plane.normal.z)

		plane.dist = plane.normal:Dot(v1)

	end

end

--Transform frustum-space planes into world-space
function meta:BuildWorldPlanes()

	for k,v in pairs( self.txplanes ) do

		local plane = self.wplanes[k]
		local nrm, dist = MultMatrix4Transposed( self.invViewMatrixTable, v.normal, -v.dist, plane.normal )

		plane.dist = -dist

		plane.absnormal.x = math.abs(plane.normal.x)
		plane.absnormal.y = math.abs(plane.normal.y)
		plane.absnormal.z = math.abs(plane.normal.z)

	end

end

local _spoint = Vector(0,0,0)

function meta:TestPoint(p)

	self:WorldToCamera( p, _spoint )

	for k,v in pairs( self.txplanes ) do

		if _spoint:Dot(v.normal) > v.dist then
			return false
		end

	end

	return true

end

function meta:LinearZ(z)

	local mv = self.perspectiveMatrixTable
	local zclip = -z * mv[3][3] + mv[3][4]
	local wclip = -z * mv[4][3] + mv[4][4]
	return zclip / wclip

end

function meta:CameraToView(p, o)

	return MultMatrix3( self.perspectiveMatrixTable, p, 1, o or Vector() )

end

function meta:ViewToCamera(p, o)

	return MultMatrix3( self.invperspectiveMatrixTable, p, 1, o or Vector() )

end

function meta:CameraToWorld(p, o)

	return MultMatrix3( self.viewMatrixTable, p, 1, o or Vector() )

end

function meta:WorldToCamera(p, o)

	return MultMatrix3( self.invViewMatrixTable, p, 1, o or Vector() )

end

function meta:TestBox(center, halfExtent, expand )

	expand = expand or 0

	for k,v in pairs(self.wplanes) do

		local x = halfExtent:Dot(v.absnormal) + expand
		local d = center:Dot(v.normal) - v.dist

		if d > x then return false end

	end

	return true

end

local _saabbcenter = Vector(0,0,0)
local _saabbextent = Vector(0,0,0)
function meta:TestAABB( mins, maxs, expand )

	_saabbcenter:Set( mins )
	_saabbcenter:Add( maxs )
	_saabbcenter:Mul( .5 )

	_saabbextent:Set( maxs )
	_saabbextent:Sub( _saabbcenter )

	return self:TestBox( _saabbcenter, _saabbextent, expand )

end

function meta:TestEntity( ent )

	local mins, maxs = ent:GetRotatedAABB( ent:OBBMins(), ent:OBBMaxs() )
	local pos = ent:GetPos()

	mins:Add( pos )
	maxs:Add( pos )

	return self:TestAABB(mins, maxs)

end

function meta:CullEntities( entities )

	for i = #entities, 1, -1 do

		local e = entities[i]
		if not IsValid( e ) or not self:TestEntity( e ) then
			table.remove( entities, i )
		end

	end

	return entities

end

function meta:FromPlayer( ply, near, far, w, h )

	self:Setup( near or 10, far or 10000, ply:GetFOV(), w or ScrW(), h or ScrH())
	self:Orient( ply:EyePos(), ply:EyeAngles() )

end

if SERVER then return end

local LineMaterial = Material( "effects/laser1.vmt" )
local function DrawLine( startpos, endpos, thickness, color, sprite )

	render.SetMaterial( LineMaterial )
	render.DrawBeam( startpos, endpos, thickness or 8, 0, 1, color or Color( 255, 255, 255, 255 ) )

end

function meta:Draw( color )

	if not self:IsValid() then return end

	color = color or Color(255,255,255,255)

	for k,v in pairs( geometry.indices ) do

		local a = self:CameraToWorld( self.txpoints[ v[1] ] )
		local b = self:CameraToWorld( self.txpoints[ v[2] ] )

		DrawLine( a, b, 16, color )

	end

end


local convar_run_test = CreateClientConVar("jazz_test_frustum", "0", true, false, "Run frustum test.")
local test_frustum = New()

hook.Add("PostDrawOpaqueRenderables", "frustum_test", function()

	if not convar_run_test:GetBool() then return end
	if input.IsMouseDown( MOUSE_RIGHT ) then

		test_frustum:FromPlayer( LocalPlayer() )

		for k,v in pairs( ents.FindByClass("prop_physics") ) do

			v:SetNoDraw( not test_frustum:TestEntity(v) )

		end

	end

	test_frustum:Draw( Color( 255,100,100 ) )

end)



local PROFILE_TIMINGS = false
if PROFILE_TIMINGS then
	local myFrustum = New():Setup(10, 5000, 90, 1280, 720)
	local mins,maxs = Vector(-10,-10,-10), Vector(10,10,10)
	local pl = LocalPlayer()

	myFrustum:FromPlayer( pl )

	local clock = os.clock()
	for i=1, 100000 do myFrustum:TestAABB(mins, maxs) end
	print("Test 100000 AABB in " .. (os.clock() - clock) .. " seconds.")

	local clock = os.clock()
	for i=1, 100000 do myFrustum:TestEntity(pl) end
	print("Test 100000 Entities in " .. (os.clock() - clock) .. " seconds.")

	local clock = os.clock()
	for i=1, 100000 do myFrustum:TestPoint(mins) end
	print("Test 100000 Points in " .. (os.clock() - clock) .. " seconds.")

	local clock = os.clock()
	for i=1, 100000 do myFrustum:Orient(pl:EyePos(), pl:EyeAngles()) end
	print("Test 100000 Re-Orients in " .. (os.clock() - clock) .. " seconds.")

	local clock = os.clock()
	local elist
	for i=1, 1 do elist = myFrustum:CullEntities(ents.GetAll()) end
	print("Test Cull " .. #ents.GetAll() .. " Entities in " .. (os.clock() - clock) .. " seconds [ to " .. #elist .. " entities ].")

	--setups are more expensive, but won't be called often
	local clock = os.clock()
	for i=1, 100000 do myFrustum:Setup(100, 800, 90, 1280, 720) end
	print("Test 100000 Setups in " .. (os.clock() - clock) .. " seconds.")
end
