AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Initialize()

    if SERVER then

        self:SetModel( Model("models/sunabouzu/jazzdinnertable.mdl") )
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_NONE)
        self.treats = {}

    end

    self:DrawShadow(false)

end

function ENT:KeyValue( key, value )

    if key == "order" then
        self.order = tonumber(value)
    end

end

function ENT:GetOrder()

    return self.order or 0

end

local plate_offsets = {
    Vector(14.3, -1, 0),
    Vector(18, 0, 0.2),
    Vector(15.5, 1.2, 0),
    Vector(18, 0.2, 0.1),
}

function ENT:PlaceTreats( num_treats )

    if num_treats > 4 or num_treats <= 0 then return end

    self:RemoveTreats()

    for i=1, num_treats do

        if num_treats == 1 then i = 4 end
        if num_treats == 2 and i == 2 then i = 3 end
        local offset = plate_offsets[i]
        local angle = Angle(0,i * 90,0)
        local pos = self:GetPos()
        local treat = ents.Create("jazz_treat")
        treat:SetPos( pos + Vector(0,0,40.3) + angle:Forward() * offset.x + angle:Right() * offset.y + angle:Up() * offset.z )
        treat:SetAngles( angle )
        treat:SetOwner( player.GetAll()[1] )
        treat:Spawn()

        self.treats[#self.treats+1] = treat

    end

end

function ENT:RemoveTreats()

    for _,v in ipairs(self.treats) do
        if IsValid(v) then v:Remove() end
    end

end

function ENT:OnRemove()

    if SERVER then self:RemoveTreats() end

end

function ENT:Draw()

    self:DrawModel()

end

if SERVER then

    concommand.Add("jazz_test_treats", function(p,c,a)
        if not IsValid(p) or not p:IsAdmin() then return end

        for _,v in ipairs( ents.FindByClass("jazz_treat_table") ) do

            v:PlaceTreats(4)

        end
    end)

end