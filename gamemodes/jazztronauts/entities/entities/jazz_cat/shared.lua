AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.Model = "models/krio/jazzcat1.mdl"
ENT.NPCID = 0 -- TODO
ENT.IdleAnim = "standerino"
ENT.AutomaticFrameAdvance = true


function ENT:Initialize()

    if SERVER then 
        self:SetModel(self.Model)
        local mins, maxs = self:GetModelBounds()
        self:PhysicsInitBox(mins, maxs)
        self:SetCollisionBounds(mins, maxs)
        self:SetMoveType(MOVETYPE_NONE)

        self:SetUseType(SIMPLE_USE)

        self:SetIdleAnim(self.IdleAnim)
        self:SetNPCID(self.NPCID)
    end

    if CLIENT then

    end
end

function ENT:SetupDataTables()

	self:NetworkVar("Int", 0, "NPCID")
end

function ENT:Think()

end

function ENT:KeyValue( key, value )
	if key == "idleanim" then
		self:StoreOutput(key, value)
	end

    if key == "npcid" then
        self.NPCID = tonumber(value)
    end
end

function ENT:SetIdleAnim(anim)
    self.IdleAnim = anim 

    self:ResetSequence(self:LookupSequence(self.IdleAnim))
    self:SetPlaybackRate(1.0)
end

function ENT:Use(activator, caller)
    if !IsValid(caller) || not caller:IsPlayer() then return end

    -- Incredibly TODO until we've got the actual input ui going
    if self.NPCID == missions.NPC_CAT_BAR then
        caller:ConCommand("jazz_open_store")
    else
        local script = converse.GetMissionScript(caller, self.NPCID)
        script = dialog.IsValid(script) and script or "idle.begin"
        dialog.Dispatch(script, caller)
    end
end

if SERVER then

    -- In the map, entities are placed in all possible cat locations
    -- Randomly choose which ones to keep so only a single cat is spawned
    hook.Add("InitPostEntity", "JazzPlaceSingleCat", function()
        local NPCS = {}
        local cats = ents.FindByClass("jazz_cat")

        -- Sort into distinct lists based on each cat id
        for _, v in pairs(cats) do
            NPCS[v.NPCID] = NPCS[v.NPCID] or {}
            table.insert(NPCS[v.NPCID], v)
        end

        -- Select a random only to keep, destroy the rest
        for id, npcs in pairs(NPCS) do
            local survivor = table.Random(npcs)

            -- Kill the rest
            for _, v in pairs(npcs) do
                if v != survivor then v:Remove() end
            end
        end
    end )

elseif CLIENT then
    ENT.ScreenWidth = 10

    function ENT:Draw()
        if not self.GetNPCID then return end 

        local ang = self:GetAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)

        local offset = self:GetAngles():Up() * 75
        local right = self:GetAngles():Right()

        cam.Start3D2D(self:GetPos() + offset, ang, 0.1)
            draw.DrawText(missions.GetNPCName(self:GetNPCID()), "SteamCommentFont", 0, 0, color_white, TEXT_ALIGN_CENTER)
        cam.End3D2D()

        self:DrawModel()
    end

end
