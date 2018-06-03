-- Board that displays currently selected maps
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Model = "models/Combine_Helicopter/helicopter_bomb01.mdl"

function ENT:Initialize()
	--self:SetModel( self.Model )
	self:DrawShadow( false )
	self.IsProxy = true
end

function ENT:GetID()
	return self.id
end

function ENT:SetID( id )
	self.id = id
end

if SERVER then return end

local refractParams = {
	["$basetexture"] = "_rt_FullFrameFB",
	//["$basetexture"] = "concrete/concretefloor001a",
	["$normalmap"] = "sunabouzu/JazzShell_dudv",
	//["$normalmap"] = "sunabouzu/jazzSpecks_n", //concrete/concretefloor001a_normal, "effects/fisheyelense_normal", "glass/reflectiveglass002_normal"
	["$refracttint"] = "[1 1 1]",
	["$additive"] = 0,
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 0,
	["$refractamount"] = 0.03,
	["$bluramount"] = 2,
	["$model"] = 1,
}

local refract = CreateMaterial("RefractStaticMesh" .. FrameNumber(), "Refract", refractParams)
local surfaceMaterial = Material("sunabouzu/JazzShell")

function ENT:DrawTranslucent()
	--[[local mtx = Matrix()
	mtx:SetTranslation( Vector(0,0,0) )
	--mtx:SetScale( Vector(1.001,1.001,1.001))

	self:EnableMatrix("RenderMultiply", mtx)

	render.SuppressEngineLighting(true)

	render.MaterialOverride(refract)
	self:DrawModel()
	render.MaterialOverride(surfaceMaterial)
	self:DrawModel()
	render.MaterialOverride(nil)

	render.SuppressEngineLighting(false)]]
end
