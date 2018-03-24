module( 'mapgen', package.seeall )

SpawnedShards = SpawnedShards or {}
InitialShardCount = InitialShardCount or 0

function GetShardCount()
	return table.Count(SpawnedShards), InitialShardCount
end

function GetShards()
    return SpawnedShards 
end

function CanSnatch(ent)

	--Accept only this kinda stuff
	if not IsValid(ent) then return false end
	if not ent:IsValid() then return false end
    if ent:IsNPC() then return true end  
    if ent:GetClass() == "npc_antlion_grub" then return true end
    if ent:GetClass() == "npc_grenade_frag" then return true end

    if ent:IsWeapon() and ent:GetParent() and ent:GetParent():IsPlayer() then return false end
    if CLIENT and ent:IsWeapon() and ent:IsCarriedByLocalPlayer() then return false end
    //if SERVER and not IsValid(ent:GetPhysicsObject()) then return false end

    if ent:GetClass() == "hunter_flechette" then return true end
	if ent:GetClass() == "prop_physics" then return true end
	if ent:GetClass() == "prop_physics_multiplayer" then return true end
	if ent:GetClass() == "prop_dynamic" then return true end
	if ent:GetClass() == "prop_ragdoll" then return true end
    if string.find(ent:GetClass(), "weapon_") ~= nil then return true end
    if string.find(ent:GetClass(), "prop_vehicle") ~= nil then return true end
    //if string.find(ent:GetClass(), "jazz_bus_") ~= nil then return true end
    if string.find(ent:GetClass(), "item_") ~= nil then return true end
	//if ent:IsPlayer() and ent:Alive() then return true end -- you lost your privileges

    return false
end

if SERVER then 
    util.AddNetworkString("jazz_shardcollect")

    function CollectShard(ply, shardent)

        -- It's gotta be one of our shards ;)
        local res = table.RemoveByValue(SpawnedShards, shardent, ply)
        if not res then return nil, nil end

        progress.CollectShard(game.GetMap(), shardent.ShardID, ply)
        UpdateShardCount()

        return #SpawnedShards, InitialShardCount
    end

    function CollectProp(ply, ent)
        if !CanSnatch(ent) then return nil end

        local worth = ent.JazzWorth or 1
        return worth
    end

    function UpdateShardCount(ply)
        net.Start("jazz_shardcollect")
			net.WriteUInt(#SpawnedShards, 16)
            for _, v in pairs(SpawnedShards) do
                net.WriteEntity(v)
            end

			net.WriteUInt(InitialShardCount, 16)
        if IsValid(ply) then net.Send(ply) else net.Broadcast() end
    end

    local function checkAreaTrace(pos, ang)

        local traces = {}
        local tdist = 1000000
        table.insert(traces, util.TraceLine( {
            start = pos,
            endpos = pos + ang:Up() * tdist,
            mask = MASK_SOLID
        }))

        table.insert(traces, util.TraceLine( {
            start = pos,
            endpos = pos + ang:Up() * -tdist,
            mask = MASK_SOLID
        }))

        table.insert(traces, util.TraceLine( {
            start = pos,
            endpos = pos + ang:Right() * tdist,
            mask = MASK_SOLID
        }))

        table.insert(traces, util.TraceLine( {
            start = pos,
            endpos = pos + ang:Right() * -tdist,
            mask = MASK_SOLID
        }))

        table.insert(traces, util.TraceLine( {
            start = pos,
            endpos = pos + ang:Forward() * tdist,
            mask = MASK_SOLID
        }))

        table.insert(traces, util.TraceLine( {
            start = pos,
            endpos = pos + ang:Forward() * -tdist,
            mask = MASK_SOLID
        }))

        local num = 0
        for _, v in pairs(traces) do num = num + (v.HitSky and 1 or 0) end

        -- If more than 3 cardinal directions are skybox
        -- this might be some utility entity the player can't reach
        if num >= 3 then return false end

        -- Ensure there's enough space for a player to grab this from different sides
        local minBounds = 32
        local areaUp = (traces[1].Fraction + traces[2].Fraction) * tdist
        local areaFwd = (traces[3].Fraction + traces[4].Fraction) * tdist
        local areaRight = (traces[5].Fraction + traces[6].Fraction) * tdist
        if (areaUp < minBounds or areaFwd < minBounds or areaRight < minBounds) then return false end

        return true
    end

    -- Return true if the value has any matching flags
    local function maskAny(val, ...)
        local args = {...}
        for k, v in pairs(args) do
            if bit.band(val, v) == v then return true end
        end

        return false
    end

    local function findValidSpawn(ent)
        local pos = ent:GetPos() + Vector(0, 0, 16)

        -- If moving the entity that small amount up puts it out of the world -- nah
        if !util.IsInWorld(pos) then return nil end

        -- If the point is inside something solid -- also nah
        if maskAny(util.PointContents(pos), CONTENTS_PLAYERCLIP, CONTENTS_SOLID) then return end

        -- Check if they're near a suspicious amount of sky
        if !checkAreaTrace(pos, ent:GetAngles()) then return end

        return { pos = pos, ang = ent:GetAngles() }
    end

    local function isInSkyBox(ent)
        if ent:GetClass() == "sky_camera" then return true end

        local skycam = ents.FindByClass("sky_camera")
        if #skycam == 0 then return false end -- Map has no skybox

        local sky = skycam[1]

        -- Test if ent has direct line of site of sky_camera (usually a pretty good sign)
        local tr = util.TraceLine( {
            start = ent:GetPos(),
            endpos = sky:GetPos(),
            mask = CONTENTS_SOLID
        } )
        
        return !tr.Hit
    end

    local function spawnShard(transform, id)
        if transform == nil then return nil end

        local shard = ents.Create( "jazz_shard" )
	    shard:SetPos(transform.pos)
	    shard:SetAngles(transform.ang)
        
        shard.ShardID = id
        shard:Spawn()
        shard:Activate()

        return shard
    end
    
    -- Calculate the size of this map and how many shards it's worth
    function CalculateShardCount()
        return 8 -- #TODO
    end

    function CalculatePropValues(mapWorth)
        local props = ents.GetAll()
        local counts = {}
        local function getKey(ent) return ent:GetClass() .. "_" .. (ent:GetModel() or "") end

        for _, v in pairs(props) do
            if not CanSnatch(v) then continue end

            local k = getKey(v)
            counts[k] = counts[k] or 0
            counts[k] = counts[k] + 1
        end

        PrintTable(counts)

        for _, v in pairs(props) do
            local count = counts[getKey(v)]
            if not count then continue end

            local worth = (mapWorth / table.Count(counts)) / count
            v.JazzWorth = worth
        end
        
    end

    function GenerateShards(count, seed, shardtbl)
        for _, v in pairs(SpawnedShards) do
            if IsValid(v) then v:Remove() end
        end
        seed = seed or math.random(1, 1000)
        math.randomseed(seed)
        SpawnedShards = {}

        -- Go through every _map_ entity, filter bad spots, and go from there
        local validSpawns = {}
        for _, v in pairs(ents.GetAll()) do
            if !IsValid(v) or !v:CreatedByMap() then continue end
            if isInSkyBox(v) then continue end -- god wouldn't that suck

            local posang = findValidSpawn(v) 
            if !posang then continue end

            table.insert(validSpawns, posang)
        end

        -- Select count random spawns and go
        local n = 0
        for k, v in RandomPairs(validSpawns) do      
            count = count - 1
            if count < 0 then break end
            n = n + 1
            
            -- Create a new shard only if it hasn't been collected
            local shard = nil
            if not shardtbl or not tobool(shardtbl[n].collected) then 
                shard = spawnShard(v, n)
            end

            table.insert(SpawnedShards, shard) 

        end

        InitialShardCount = n
        UpdateShardCount()
        
        print("Generated " .. InitialShardCount .. " shards. Happy hunting!")
        return InitialShardCount
    end

    function LoadHubProps()
        local hubdata = progress.LoadHubPropData()
        for _, v in pairs(hubdata) do
            mapgen.SpawnHubProp(v.model, v.transform.pos, v.transform.ang, v.toy == "1")
        end
    end

    function SaveHubProps()
        local props = {}
        for _, v in pairs(ents.GetAll()) do
            if v.JazzHubSpawned then table.insert(props, v) end
        end

        progress.SaveHubPropData(props)
    end

    function SpawnHubProp(model, pos, ang, inSphere)
        local etype = inSphere and "jazz_prop_sphere" or "prop_physics"
        local ent = ents.Create(etype)
        ent:SetModel(model)
        ent:SetPos(pos)
        ent:SetAngles(ang)
        ent:Spawn()
        ent:Activate()
        ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        ent.JazzHubSpawned = true

        return ent
    end

else //CLIENT
    net.Receive("jazz_shardcollect", function(len, ply)
        SpawnedShards = {}
		local left = net.ReadUInt(16)
        for i=1, left do
            table.insert(SpawnedShards, net.ReadEntity())
        end
        local total = net.ReadUInt(16)

        surface.PlaySound("ambient/alarms/warningbell1.wav")
        InitialShardCount = total

		-- Broadcast update
		--hook.Call("JazzShardCollected", GAMEMODE, left, total)
	end )


end