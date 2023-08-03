ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OTHER

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "IsVomiting")
	self:NetworkVar("Vector", 0, "Marker")
end
