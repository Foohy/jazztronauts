-- Board that displays currently selected maps
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
local testModel = Model("models/props_vehicles/wagon001a_phy.mdl")
ENT.OuterSphereModel = Model("models/sunabouzu/toycapsule.mdl")

function ENT:Initialize()
	if self:GetRadius() == 0 then
		self:SetRadius(math.Rand(20, 35))
	end
	local outerRadius = self:GetRadius()

	if SERVER then
		self:EnableCustomCollisions(true)
		self:PhysicsInitSphere(outerRadius, "glass")
		self:GetPhysicsObject():SetMass(50)

		if not self:GetModel() then
			self:SetModel(testModel)
		end

		self:GetPhysicsObject():AddAngleVelocity(VectorRand() * 1000)


		//self:PhysicsInit(SOLID_VPHYSICS)
		//self:SetMoveType( MOVETYPE_VPHYSICS )
		//self:SetSolid( SOLID_VPHYSICS )
		//self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		//self:SetStoredModel(testModel)
	end

	local maxs = Vector(1, 1, 1) * outerRadius/2
	self:SetCollisionBounds(-maxs, maxs)

	if CLIENT then
		//ParticleEffect( "shard_glow", self:GetPos(), self:GetAngles(), self )
		self:SetupModel()
	end
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage( dmginfo )
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Radius")
end

function ENT:OnRemove()

end

if SERVER then return end

local function getInnerRadius(ent)
	local min, max = ent:GetModelBounds()
	local rad = 0
	for i=1, 3 do
		rad = math.max( max[i] - min[i] , rad )
	end

	return rad / 2
end

local function getBoundingRadius(ent)
	local min, max = ent:GetModelBounds()
	local center = (min + max) / 2

	return center:Distance(max)
end

function ENT:SetupModel()
	local maxs = Vector(1, 1, 1) * self:GetRadius()/2
	self:SetRenderBounds(-maxs, maxs)

	self.SphereModel = ClientsideModel(self.OuterSphereModel)

	/*

	local scale = getInnerRadius(self) / radius
	*/

	self:UpdateMeshes()
end

function ENT:GetRandomColor()
	local h = util.SharedRandom("jazz_toycolor", 0, 360, self:EntIndex())

	return HSVToColor(h, 1, 1)
end

function ENT:UpdateMeshes()
	if self.SphereModel:GetParent() != self then
		local min, max = self:GetModelBounds()
		local center = (max + min) / 2
		local radius = getInnerRadius(self.SphereModel)
		local sphereScale = self:GetRadius() / radius
		local propScale = self:GetRadius() / getBoundingRadius(self)

		-- Update outer sphere model scale
		self.SphereModel:SetPos(self:GetPos())
		self.SphereModel:SetAngles(self:GetAngles())
		self.SphereModel:SetParent(self)
		self.SphereModel:SetModelScale(sphereScale)
		self.SphereModel:SetColor(self:GetRandomColor())

		-- Update render transform for the inside prop
		local scaleMat = Matrix()
		scaleMat:SetTranslation(-center * propScale)
		scaleMat:SetScale(Vector(propScale, propScale, propScale))

		//self:DisableMatrix("RenderMultiply")
		self:EnableMatrix("RenderMultiply", scaleMat)
	end
end

function ENT:Think()

end

function ENT:OnRemove()
	if IsValid(self.SphereModel) then
		self.SphereModel:Remove()
	end
end

function ENT:Draw()
	self:UpdateMeshes()
	self.SphereModel:DrawModel()
	render.SuppressEngineLighting(true)
	self:DrawModel()
	render.SuppressEngineLighting(false)

end
