module( 'mapgen', package.seeall )

SpawnedShards = SpawnedShards or {}
InitialShardCount = InitialShardCount or 0

function GetShardCount()
	return #SpawnedShards, InitialShardCount
end

function GetShards()
    return SpawnedShards 
end

function CanSnatch(ent)

	--Accept only this kinda stuff
	if ent == nil then return false end
	if not ent:IsValid() then return false end
    if not IsValid(ent:GetPhysicsObject()) then return false end
	if ent:GetClass() == "prop_physics" then return true end
	if ent:GetClass() == "prop_physics_multiplayer" then return true end
	if ent:GetClass() == "prop_dynamic" then return true end
	if ent:GetClass() == "prop_ragdoll" then return true end
	if ent:IsNPC() then return true end
	if ent:IsPlayer() and ent:Alive() then return true end

    return false
end

if SERVER then 
    util.AddNetworkString("jazz_shardcollect")

    function CollectShard(shardent)
        -- It's gotta be one of our shards ;)
        local res = table.RemoveByValue(SpawnedShards, shardent) != nil
        if not res then return false end

        -- THEY DID IT!!!!
        -- TODO: Move this logic somewhere else.
        if #SpawnedShards == 0 && InitialShardCount != 0 then 
            local res = progress.FinishMap(game.GetMap())
            if res then
                for _, v in pairs(player.GetAll()) do
                    v:ChatPrint("You collected all " .. InitialShardCount .. " shards! It only took you " 
                        .. string.NiceTime(res.endtime - res.starttime))
                end
            end
        end

        UpdateShardCount()

        return res
    end

    function CollectProp(ply, ent)
        if !CanSnatch(ent) then return end

        local worth = ent.JazzWorth or 1
        if IsValid(ply) then
            ply:ChangeNotes(worth)
        end
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

    local function findValidSpawn(ent)
        local pos = ent:GetPos() + Vector(0, 0, 16)

        -- If moving the entity that small amount up puts it out of the world -- nah
        if !util.IsInWorld(pos) then return nil end

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
            mask = MASK_SOLID_BRUSHONLY
        } )

        return !tr.Hit
    end

    local function spawnShard(transform)
        if transform == nil then return nil end

        local shard = ents.Create( "jazz_shard" )
	    shard:SetPos(transform.pos)
	    shard:SetAngles(transform.ang)
        shard:Spawn()
        shard:Activate()

        return shard
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

    function GenerateShards(count, seed)
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
        for _, v in RandomPairs(validSpawns) do
            count = count - 1
            if count < 0 then break end

            local shard = spawnShard(v)
            if IsValid(shard) then 
                table.insert(SpawnedShards, shard) 
            end
        end

        InitialShardCount = #SpawnedShards
        UpdateShardCount()
        
        print("Generated " .. InitialShardCount .. " shards. Happy hunting!")
    end

    function LoadHubProps()
        local hubdata = progress.LoadHubPropData()
        for _, v in pairs(hubdata) do
            mapgen.SpawnHubProp(v.model, v.transform.pos, v.transform.ang)
        end
    end

    function SaveHubProps()
        local props = {}
        for _, v in pairs(ents.GetAll()) do
            if v.JazzHubSpawned then table.insert(props, v) end
        end

        progress.SaveHubPropData(props)
    end

    function SpawnHubProp(model, pos, ang)
        local ent = ents.Create("prop_physics")
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