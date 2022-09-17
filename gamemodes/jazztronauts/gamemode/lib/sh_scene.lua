if SERVER then AddCSLuaFile("sh_scene.lua") end
if SERVER then return end

include("sh_camera.lua")

Scene = nil

module( "scene", package.seeall )

local mnode = {}
mnode.__index = mnode

local meta = {}
meta.__index = meta

for k, v in pairs( FindMetaTable("Entity") ) do

	if not string.find(k, "__") then
		mnode[k] = function(self, ...)
			return v( rawget(rawget(self, "__csent"), "Instance"), ...)
		end
	end

end

function mnode:Init()

	self.transform = Matrix()
	self.transform:Identity()
	return self

end

function mnode:Translate( vector )

	self.transform:Translate( vector )

end

function mnode:Rotate( angle )

	self.transform:Rotate( angle )

end

function mnode:Scale( vector )

	if type(vector) == "number" then
		vector = Vector(vector,vector,vector)
	end

	self.transform:Scale( vector )

end

function mnode:Identity()

	self.transform:Identity()

end

function mnode:GetMatrix()

	return self.transform

end

function mnode:SetMatrix( m )

	self.transform = m

end


function meta:Init( camera )

	self.camera = camera
	self.nodes = {}
	self.lights = {}

	for i=0,5 do
		self:SetBoxLight(i, 0, 0, 0)
	end

	return self

end

local function AllocEntityNode( id, model, ragdoll )

	local CSEnt = ManagedCSEnt( id, model, ragdoll )
	local node = {}

	if IsValid(CSEnt) then
		CSEnt:SetNoDraw( true )
		CSEnt:SetLOD( 0 )
	end

	node.__csent = CSEnt
	node.Get = function(self)
		return CSEnt
	end

	node.Render = function(self)
		if not IsValid(CSEnt) then return end
		CSEnt:EnableMatrix( "RenderMultiply", self.transform )
		CSEnt:SetupBones()
		CSEnt:DrawModel()
		CSEnt:DisableMatrix( "RenderMultiply" )
	end

	return setmetatable(node, mnode):Init()

end

function meta:SetBoxLight( iBoxface, r, g, b )

	local inv = 1 / 255
	if iBoxface < 0 or iBoxface > 5 then return end
	if IsColor( r ) then
		self.lights[ iBoxface ] = Color( r.r * inv, r.g * inv, r.b * inv )
	else
		self.lights[ iBoxface ] = Color( (r or 0) * inv, (g or 0) * inv, (b or 0) * inv )
	end
	return self

end

function meta:Clear( bCleanup )

	self.nodes = {}
	return self

end

function meta:AddModel( id, model, ragdoll )

	local m = AllocEntityNode( id, model, ragdoll )

	table.insert( self.nodes, m )
	return m

end

function meta:AddEntity( ent, bOrigin )

	local node = {}
	node.Get = function(self)
		return ent
	end

	node.Render = function(self)
		local ppos, pang
		if bOrigin then
			ppos = ent:GetPos()
			pang = ent:GetAngles()
			ent:SetPos(Vector(0,0,0))
			ent:SetAngles(Angle(0,0,0))
		end
		ent:EnableMatrix( "RenderMultiply", self.transform )
		ent:SetupBones()
		ent:DrawModel()
		ent:DisableMatrix( "RenderMultiply" )
		if bOrigin then
			ent:SetPos(ppos)
			ent:SetAngles(pang)
		end
	end

	table.insert( self.nodes, node )

	return setmetatable(node, mnode):Init()

end

function meta:Render( ... )

	self.camera:Start3D( ... )

	render.SuppressEngineLighting( not self.enable_engine_lighting )

	for k,v in pairs(self.lights) do
		render.SetModelLighting( k, v.r, v.g, v.b )
	end

	for k,v in pairs(self.nodes) do
		--cam.PushModelMatrix( v.transform )
		v:Render()
		--cam.PopModelMatrix()
	end

	render.ResetModelLighting( 1,1,1 )
	render.SuppressEngineLighting(false)

	self.camera:End3D()

end

function meta:EnableEngineLighting( bLighting )

	self.enable_engine_lighting = bLighting == true
	return self

end

function New(...)

	return setmetatable({}, meta):Init(...)

end

_G["Scene"] = New