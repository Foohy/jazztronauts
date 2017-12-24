module( 'mapgen', package.seeall )

SpawnedShards = SpawnedShards or {}
InitialShardCount = InitialShardCount or 0

function GetShardCount()
	return #SpawnedShards, InitialShardCount
end

function GetShards()
    return SpawnedShards 
end

if SERVER then 
    util.AddNetworkString("jazz_shardcollect")

    function CollectShard(shardent)
        -- It's gotta be one of our shards ;)
        local res = table.RemoveByValue(SpawnedShards, shardent) != nil
        for _, v in pairs(player.GetAll()) do
            v:ChatPrint(#SpawnedShards .. "/" .. InitialShardCount .. " shards left.")
        end

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

    function UpdateShardCount(ply)
        net.Start("jazz_shardcollect")
			net.WriteUInt(#SpawnedShards, 16)
            for _, v in pairs(SpawnedShards) do
                net.WriteEntity(v)
            end

			net.WriteUInt(InitialShardCount, 16)
        if IsValid(ply) then net.Send(ply) else net.Broadcast() end
    end

    local function findValidSpawn(ent)
        local pos = ent:GetPos() + Vector(0, 0, 16)

        -- If moving the entity that small amount up puts it out of the world -- nah
        if !util.IsInWorld(pos) then return nil end

        -- If more than 3 cardinal directions are skybox
        -- this might be some utility entity the player can't reach
        local traces = {}
        table.insert(traces, util.TraceLine( {
            start = pos,
            endpos = pos + ent:GetAngles():Up() * 1000,
            mask = MASK_SOLID_BRUSHONLY
        }))

        table.insert(traces, util.TraceLine( {
            start = pos,
            endpos = pos + ent:GetAngles():Up() * -1000,
            mask = MASK_SOLID_BRUSHONLY
        }))

        table.insert(traces, util.TraceLine( {
            start = pos,
            endpos = pos+ ent:GetAngles():Right() * 1000000,
            mask = MASK_SOLID_BRUSHONLY
        }))

        table.insert(traces, util.TraceLine( {
            start = pos,
            endpos = pos + ent:GetAngles():Right() * -1000000,
            mask = MASK_SOLID_BRUSHONLY
        }))

        table.insert(traces, util.TraceLine( {
            start = pos,
            endpos = pos + ent:GetAngles():Forward() * 1000000,
            mask = MASK_SOLID_BRUSHONLY
        }))

        table.insert(traces, util.TraceLine( {
            start = pos,
            endpos = pos + ent:GetAngles():Forward() * -1000000,
            mask = MASK_SOLID_BRUSHONLY
        }))

        local num = 0
        for _, v in pairs(traces) do num = num + (v.HitSky and 1 or 0) end

        -- Disqualify if it hit a suspicious number of skyboxes
        if num >= 2 then print("Disqualifying ", ent) return nil end

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

    function GenerateShards(count)
        for _, v in pairs(SpawnedShards) do
            if IsValid(v) then v:Remove() end
        end

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

else //CLIENT
    net.Receive("jazz_shardcollect", function(len, ply)
        SpawnedShards = {}
		local left = net.ReadUInt(16)
        for i=1, left do
            table.insert(SpawnedShards, net.ReadEntity())
        end
        local total = net.ReadUInt(16)

        InitialShardCount = total

        print(left .. "/" .. total .. " shards.")

		-- Broadcast update
		--hook.Call("JazzShardCollected", GAMEMODE, left, total)
	end )


end