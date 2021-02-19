AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Model = Model("models/sunabouzu/jazzshard.mdl")

ENT.ShardSound = "jazz_shard_idle"
ENT.ShardNearSound = "jazz_shard_idle_near"

function ENT:Initialize()

	if SERVER then

		self:SetModel( self.Model )
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:PhysicsInitSphere( 16 )

	else

		self.DrawMatrix = Matrix()

	end

end

function ENT:CanProperty()
	return false
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:SetupDataTables()

end

function ENT:SetActiveTrace( trace )

end

function ENT:OnRemove()

	local ply = self:GetOwner()
	if ply then
		ply:SetActiveTrace( nil )
	end

end

if SERVER then return end

local flaremat = Material("effects/blueflare1")

function ENT:DrawDynLight()
	local dlight = DynamicLight( self:EntIndex() )
	if dlight then
		dlight.pos = self:GetPos()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 2
		dlight.Decay = 100
		dlight.Size = 256
		dlight.DieTime = CurTime() + 1
	end
end

function ENT:DrawTranslucent()


end

function ENT:Draw()

	--self.DrawMatrix:Identity()
	--self.DrawMatrix:Scale(Vector(.2, .2, .2))

	--self:EnableMatrix("RenderMultiply", self.DrawMatrix)
	--self:DrawModel()

	self:DrawShadow(false)
	self:DrawDynLight()

	render.SetMaterial(flaremat)
	render.DrawSprite( self:GetPos(), 16, 16 )

end
