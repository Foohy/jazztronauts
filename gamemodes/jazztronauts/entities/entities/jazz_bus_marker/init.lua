AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
 
include("shared.lua")


function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInitSphere( 16 )
    self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    self:PhysWake()

    self.PlayerList = {}
end

-- Shards should be always networked, even if they're out of the player's PVS
-- Will be necessary if they need help locating them
function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end


function ENT:AddPlayer(ply)
    if table.HasValue(self.PlayerList, ply) then return end

    table.insert(self.PlayerList, ply)
    self:CheckPlayerCount()
end

function ENT:RemovePlayer(ply)
    table.RemoveByValue(self.PlayerList, ply)
    self:CheckPlayerCount()
end

local function filterByPredicate(tbl, func)
    for i=#tbl, 1, -1 do
        if func(tbl[i]) then 
            table.remove(tbl, i)
        end
    end
end

function ENT:ValidPlayer(ply)
    if !IsValid(ply) then return false end

    local w = ply:GetWeapon("weapon_buscaller")
    return IsValid(w) and w:GetBusMarker() == self 
end

function ENT:RemoveInvalid()
    filterByPredicate(self.PlayerList, function(ply)
        return !self:ValidPlayer(ply)
    end )
end

function ENT:HasEnoughPlayers()
    return #self.PlayerList >= 2 * player.GetCount() / 3
end


function ENT:CheckPlayerCount()
    self:RemoveInvalid() 

    if #self.PlayerList == 0 then
        self:Remove()
    end

    if self:HasEnoughPlayers() and !self:CountdownStarted() then 
        self:StartCountdown()
    end
end

function ENT:StartCountdown()
    self:SetSpawnTime(CurTime() + self.SpawnDelay)
end

function ENT:StopCountdown() 
    self:SetSpawnTime(0)
end

function ENT:Think() 
    self:CheckPlayerCount()

    if self:CountdownStarted() then 
        if !self:HasEnoughPlayers() then
            self:StopCountdown()
            return
        end

        if CurTime() > self:GetSpawnTime() then 
            self:CallBus()
            self:Remove()
        end
    end
end


function ENT:CallBus()
    mapcontrol.SpawnExitBus(self:GetPos(), self:GetAngles())
end