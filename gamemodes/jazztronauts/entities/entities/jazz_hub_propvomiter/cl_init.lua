JazzVomitProps = JazzVomitProps or {}

local Lifetime = 10
local FadeBegin = 2
local PipeRadius = 40

local function TickVomitProps()
    for i=#JazzVomitProps, 1, -1 do
        local p = JazzVomitProps[i]
        local t = (p and p.RemoveAt or 0) - UnPredictedCurTime()
        if not IsValid(p) or t < 0 then
            table.remove(JazzVomitProps, i)
            if IsValid(p) then p:Remove() end 
            continue
        end

        if t < FadeBegin then
            local alpha = 255.0 * t / FadeBegin
            p:SetRenderMode(RENDERMODE_TRANSADD)
            p:SetColor(Color(255, 255, 255, alpha))
        end
    end
end

local function resize(ent)
    ent:PhysicsInitSphere(32)

    local scale = 32 / ent:BoundingRadius()
    ent:SetModelScale(scale)
end

local function tooBig(ent)
    return ent:BoundingRadius() > PipeRadius
end

local function AddVomitProp(model)
    local ent = nil
    if util.IsValidRagdoll(model) and false then
        ent = ClientsideRagdoll(model)
        ent:SetModel(model)
        ent:Spawn()
        for i=0, ent:GetPhysicsObjectCount()-1 do
			local boneid = ent:TranslatePhysBoneToBone( i )
            if boneid > -1 then
                local phys = ent:GetPhysicsObjectNum( i )
                if phys then
                    phys:Wake()
                    phys:SetVelocity( VectorRand() * 100 )
                    phys:AddAngleVelocity( VectorRand() * 100 )
                end
            end
        end
    else
        ent = ents.CreateClientProp(model)
        ent:SetModel(model)
        ent:Spawn()
        
        if not ent:PhysicsInit(SOLID_VPHYSICS) or tooBig(ent) then
            resize(ent)
        end
    end

    ent:SetNoDraw(false)
    ent:DrawShadow(true)
    ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
    ent:GetPhysicsObject():SetMass(500)
    ent:GetPhysicsObject():Wake()
    ent:GetPhysicsObject():SetVelocity(Vector(0, 0, math.Rand(-1000, -100)))
    ent:GetPhysicsObject():AddAngleVelocity(VectorRand() * 1000)

    ent.RemoveAt = UnPredictedCurTime() + Lifetime
    table.insert(JazzVomitProps, ent)
    //SafeRemoveEntityDelayed(ent, 10)

    return ent
end

hook.Add("Think", "TickVomitProps", TickVomitProps)

net.Receive("jazz_propvom_effect", function(len, ply)
    local pos = net.ReadVector()
    local model = net.ReadString()

    local ent = AddVomitProp(model, pos)
    ent:SetPos(pos)
end )