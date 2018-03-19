AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_chatmenu.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("sh_chatmenu.lua")

function ENT:Initialize()
    self:SetModel(self.Model)
    local mins, maxs = self:GetModelBounds()

    self:PhysicsInitBox(mins, maxs)
    self:SetCollisionBounds(mins, maxs)
    self:SetMoveType(MOVETYPE_NONE)

    self:SetUseType(SIMPLE_USE)

    self:SetIdleAnim(self.IdleAnim)
    self:SetNPCID(self.NPCID)
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
        local opt = self:GetSelectedOption(caller, self.BarChoices)
        self.BarChoices[opt].func(self, caller)
    else
        self:StartChat(caller)
    end
end

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