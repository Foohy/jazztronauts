local chatmenu = include("sh_chatmenu.lua")

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.AutomaticFrameAdvance = true

ENT.Model = "models/krio/jazzcat1.mdl"
ENT.IdleAnim = "standerino"

local function ClientRun(ply, str) if SERVER then ply:SendLua(str) else RunString(str, "JazzChatMenu") end end

ENT.BarChoices = {}
chatmenu.AddChoice(ENT.BarChoices, "Upgrade tools!", function(self, ply) ClientRun(ply, "JazzOpenUpgradeStore()") end)
chatmenu.AddChoice(ENT.BarChoices, "Store, please!", function(self, ply) ClientRun(ply, "JazzOpenStore()") end)
chatmenu.AddChoice(ENT.BarChoices, "Just here to chat!", function(self, ply) self:StartChat(ply) end)

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "NPCID")
end

function ENT:GetIdleScript()
    local npcidle = "idle.begin" .. self.NPCID
    return dialog.IsScriptValid(npcidle) and npcidle or "idle.begin"
end

function ENT:StartChat(ply)
    if SERVER then
        local script = converse.GetNextScript(ply, self.NPCID)
        script = dialog.IsScriptValid(script) and script or self:GetIdleScript()
        //REMOVE:
        //script = "dunked.begin"
        dialog.Dispatch(script, ply, self)
    else
        net.Start("JazzRequestChatStart")
            net.WriteEntity(self)
        net.SendToServer()
    end
end