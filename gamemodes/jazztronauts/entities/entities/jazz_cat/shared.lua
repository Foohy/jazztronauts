local chatmenu = include("sh_chatmenu.lua")

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.AutomaticFrameAdvance = true

ENT.Model = "models/krio/jazzcat1.mdl"
ENT.IdleAnim = "standerino"

ENT.BarChoices = {}
chatmenu.AddChoice(ENT.BarChoices, "Upgrade tools!", function(self, ply) ply:SendLua("JazzOpenUpgradeStore()") end)
chatmenu.AddChoice(ENT.BarChoices, "Store, please!", function(self, ply) ply:SendLua("JazzOpenStore()") end)
chatmenu.AddChoice(ENT.BarChoices, "Just here to chat!", function(self, ply) self:StartChat(ply) end)

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "NPCID")
end

function ENT:StartChat(ply)
    local script = converse.GetMissionScript(ply, self.NPCID)
    script = dialog.IsValid(script) and script or "idle.begin"

    dialog.Dispatch(script, ply, self)
end