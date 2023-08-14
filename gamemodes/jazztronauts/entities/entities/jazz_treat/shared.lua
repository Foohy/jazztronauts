AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Models	=
{
    "models/props_junk/garbage_plasticbottle002a.mdl",
    "models/props_junk/garbage_takeoutcarton001a.mdl",
    "models/props_junk/garbage_milkcarton001a.mdl",
    "models/props_junk/popcan01a.mdl",
}

ENT.Treats = {
    {
        model = "models/props_junk/garbage_takeoutcarton001a.mdl",
        interact = "Eat Snickerdoodles",
        script = "treats.treat_cookie",
    },
    {
        model = "models/props_junk/popcan01a.mdl",
        interact = "Drink Soda",
        script = "treats.treat_soda",
    },
    {
        model = "models/props_junk/garbage_plasticbottle002a.mdl",
        interact = "Drink 'Health Potion'",
        script = "treats.treat_bleach",
    },
    {
        model = "models/weapons/w_pistol.mdl",
        interact = "Eat... Gun?",
        script = "treats.treat_gun",
        angles = Angle(0,-40,90),
        pos = Vector(-0.4,0,-5.4),
    },
}

for k, v in ipairs(ENT.Treats) do v.index = k end

local sprite_material
local placard_material

if CLIENT then

    surface.CreateFont( "TreatHeadingFont", {
        font	  = "Dancing Script",
        size	  = 85,
        weight	= 700,
        antialias = true
    })

    surface.CreateFont( "TreatBodyFont", {
        font	  = "Dancing Script",
        size	  = 110,
        weight	= 700,
        antialias = true
    })

    sprite_material = Material( "sprites/light_ignorez" )
    placard_material = Material( "zak/treat_placard.png" )

end

local i_treat = 1
function ENT:Initialize()

    if SERVER then

        self:SetTreat( self.Treats[1 + (i_treat % #self.Treats)] )
        self:PhysicsInitSphere( 8 )
        self:SetMoveType(MOVETYPE_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        self:PhysWake()
        i_treat = i_treat + 1

    else

        self.canvas = worldcanvas.New()
        self.canvas:SetDrawFunc( self.Draw2D, self )

        local mins, maxs = self:GetModelBounds()

        self.offset = Vector((maxs.x + mins.x),(maxs.y + mins.y),-mins.z)
        self.offset_mtx = Matrix()

        local treat = self:GetTreat()
        if treat then

            if treat.angles then self.offset_mtx:SetAngles( treat.angles ) end
            if treat.pos then self.offset:Add( treat.pos ) end
        end

        self.offset_mtx:SetTranslation( self.offset.x * self:GetForward() + self.offset.y * self:GetRight() + self.offset.z * Vector(0,0,1) )

    end

    self:DrawShadow(false)

end

function ENT:SetupDataTables()

    self:NetworkVar("Int", 0, "TreatIndex")

end

function ENT:SetTreat( treat )

    self.treat = treat
    if treat.model then self:SetModel( treat.model ) end
    self:SetTreatIndex( treat.index )

end

function ENT:GetTreat()

    if SERVER then return self.treat end
    return self.Treats[ self:GetTreatIndex() ]

end

function ENT:GetConsumeSound()

    return "npc/barnacle/barnacle_gulp" .. math.random(1,2) .. ".wav"

end

function ENT:Use(activator, caller, useType, value)

    if not IsValid(activator) or not activator:IsPlayer() then return end
    if (activator.treat_use_debounce or 0) > CurTime() then return end

    if activator ~= self:GetOwner() then
        dialog.Dispatch("treats.treat_steal", activator)
        return
    end

    self:EmitSound(self:GetConsumeSound(), 150, 100, 1, CHAN_AUTO)
    self:Remove()

    if self.treat.script then
        dialog.Dispatch(self.treat.script, activator)
    end

    activator.treat_use_debounce = CurTime() + 2

end

function ENT:Draw2D()

    local ply = self:GetOwner()
    local w,h = 600, 200
    surface.SetDrawColor(92,33,141)
    surface.DrawRect(0,0,w,h)

    surface.SetDrawColor(255,255,255)

    surface.SetMaterial(placard_material)
    surface.DrawTexturedRect(0,0,w,h)

    local header_str = "For"
    local body_str = "Player Name Here"

    if IsValid(ply) then body_str = ply:Nick() end

    surface.SetFont("TreatHeadingFont")
    local tw,th = surface.GetTextSize(header_str)
    surface.SetTextPos((w-tw)/2,10)
    surface.SetTextColor(255,192,75)
    surface.DrawText(header_str)

    surface.SetFont("TreatBodyFont")
    local tw,th = surface.GetTextSize(body_str)
    surface.SetTextPos((w-tw)/2,20 + (h-th)/2)
    surface.SetTextColor(255,194,82)
    surface.DrawText(body_str)

end

function ENT:Draw()

    local pos = self:GetPos()
    local dist = EyePos():Distance(pos)
    local time = CurTime()

    self:EnableMatrix("RenderMultiply", self.offset_mtx)
    self:DrawModel()

    if dist < 1000 then

        self.canvas:SetDrawFunc( self.Draw2D, self )
        self.canvas:Anchor("bottom")
        self.canvas:SetSize(15,5)
        self.canvas:SetResolution(600,200)
        self.canvas:SetPos(pos + self:GetForward() * 10)
        self.canvas:SetAngles(self:GetAngles() - Angle(45,0,0))
        self.canvas:Draw()

    end

    self.t_twinkle = self.t_twinkle or time

    local dt = ( time - self.t_twinkle )
    if dt > 4 then self.t_twinkle = time end

    local dist_fade = math.min(math.max(dist - 1000, 0) / 500, 1)
    local duration = 1
    if dt < duration and dist_fade > 0 and self:GetOwner() == LocalPlayer() then

        local sdt = (time - self.t_twinkle ) / duration
        local sc = 0.25 * (sdt * (1-sdt)) * dist_fade

        render.SetMaterial( sprite_material )
        render.DrawSprite( pos, 3000 * sc, 3000 * sc, Color(255,225,126) )
        render.DrawSprite( pos, 800 * sc, 6000 * sc, Color(255,166,0) )
        render.DrawSprite( pos, 6000 * sc, 800 * sc, Color(255,166,0) )

    end

end
