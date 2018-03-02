-- Controls incredibly advanced honking system
local StormApproachTime = 10 -- How many seconds of constant honking before we're at full shitstorm
local DefaultHonkDelay = 0.75 -- Cooldown between honks
local StormApproachDeadTime = 1.5 -- Maximum time between honks that contribute to the storm
local soundPath = "jazztronauts/honks/"
local normalSounds = { 
    Sound("honk1.wav"),
    Sound("honk2.wav"),
    Sound("honk3.wav"),
    Sound("honk4.wav")
}

local shitpostSounds = file.Find("sound/" .. soundPath .. "*.wav", "GAME")
for _, v in pairs(normalSounds) do
    table.RemoveByValue(shitpostSounds, v)
end

-- Insert into total sound list
-- Note that the 'normal' sounds are first
local sounds = {}
table.Add(sounds, normalSounds)
table.Add(sounds, shitpostSounds)

local honkCount = 0
local lastHonk = 0

if SERVER then
    util.AddNetworkString( "jazz_bus_honk" )

    function JazzHonk(pos)
        -- Ignore too-soon honks
        local honkDelay = math.max(0, DefaultHonkDelay - honkCount * 0.01)
        if CurTime() - lastHonk < honkDelay then
            return 
        end

        -- Reset if no honks in a certain amount of time
        if CurTime() - lastHonk > StormApproachDeadTime then
            honkCount = 0
        end

        -- Controls when we start feeding in the random shitstorm of sounds
        local allowShitpost = math.random(0, honkCount) > 30

        -- First entries are the normal sounds anyway
        local idx = math.random(1, allowShitpost and #sounds or #normalSounds)

        lastHonk = CurTime()
        honkCount = honkCount + 1

        net.Start("jazz_bus_honk")
            net.WriteVector(pos)
            net.WriteUInt(idx, 8)
        net.Broadcast()
    end

    local busNames = { "jazz_bus_explore", "jazz_bus_hub" }
    local function IsInBus(ply)
        if not IsValid(ply) then return false end 

        local vehicle = ply:GetVehicle()
        if not IsValid(ply:GetVehicle()) then return false end
        if not IsValid(vehicle:GetParent()) then return false end

        return table.HasValue(busNames, vehicle:GetParent():GetClass())
    end

    -- Honk if the player presses left click while in a bus
    hook.Add("KeyPress", "JazzBusHonk", function(ply, key)
        if SERVER and key == IN_ATTACK and IsInBus(ply) then 
            JazzHonk(ply:GetPos())
        end
    end )
end

if CLIENT then
    net.Receive("jazz_bus_honk", function(len, ply)
        local pos = net.ReadVector()
        local sidx = net.ReadUInt(8)

        if not sounds or #sounds < sidx then
            print("Bad honk: " .. sidx)
            return
        end

        EmitSound(soundPath .. sounds[sidx], pos, 1, CHAN_AUTO, 1, 95)
    end )
end