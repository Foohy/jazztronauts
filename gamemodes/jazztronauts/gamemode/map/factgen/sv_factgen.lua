module("factgen", package.seeall)

-- Create a task that is finished once a callback is called
-- While waiting, it simply sleeps indefinitely
local function taskCreateCallback(func)
    local t = nil
    local results = {}
    local done = false
    local function doneFunc(...)
        if t then 
            t.sleep = 0 -- Wake up the thread
        end 

        results = { ... }
        done = true
    end

    t = task.New(function() 
        func(doneFunc)

        -- Allow calls that exit immediately
        if not done then
            task.Sleep(999999)
        end

        return unpack(results)
    end, 1)

    return t
end

local function getComment(bsp)
    local winfo = bsp.entities and bsp.entities[1]
    if not winfo then return "Unknown" end

    return winfo.comment or winfo.description or "None"
end

local function getSkybox(bsp)
    local winfo = bsp.entities and bsp.entities[1]
    if not winfo then return "Unknown" end

    return winfo.skyname
end

local function getMapSize(bsp)

    local winfo = bsp.entities and bsp.entities[1]
    if not winfo then return "Unknown" end

    local maxs, mins = Vector(winfo.world_maxs), Vector(winfo.world_mins)
    local size = maxs - mins

    return size.x .. " wide, " .. size.y .. " deep, " .. size.z .. " tall"
end

local function getWorkshopFacts(wsid, addFact)
    if not wsid then return end

    -- Get workshop file info
    local fileinfoTask = taskCreateCallback(function(done) 
        workshop.FileInfo(wsid, function(info)
            done(info)
        end)
    end)

    local info = task.Await(fileinfoTask)
    if info then
        PrintTable(info)
        addFact("ws_owner", info.owner)
        addFact("ws_views", "Views:\n" .. info.views)
        addFact("ws_filesize", "Filesize:\n" .. string.NiceSize(tonumber(info.file_size) or 0))
        addFact("ws_favorites", "Favorites:\n" .. info.favorited)
        addFact("ws_subscriptions", "Subscriptions:\n" .. info.subscriptions)
        addFact("ws_upload_date", "Upload Date:\n" .. os.date("%H:%M:%S - %d/%m/%Y", tonumber(info.time_created) or 0))
        addFact("ws_update_date", "Last Modified:\n" .. os.date("%H:%M:%S - %d/%m/%Y", tonumber(info.time_updated) or 0))
        addFact("ws_update_date", "Last Modified:\n" .. os.date("%H:%M:%S - %d/%m/%Y", tonumber(info.time_updated) or 0))
        addFact("ws_screenshots", info.preview_url) --#TODO: How to grab ALL preview images?

        -- Fetch a random comment
        local commentTask = taskCreateCallback(function(done) 
            workshop.FetchComments(info, function(comments)
                done(comments)
            end)
        end)

        local comments = task.Await(commentTask)
        if #comments > 0 then
            local comm = table.Random(comments)
            addFact("random_comment", "\"" .. comm.message .. "\"\n-" .. comm.author)
        end
    end
end
local loadLumps = {
    LUMP_ENTITIES,				--All in-map entities
    --LUMP_PLANES,				--Plane equations for map geometry
    LUMP_BRUSHES,				--Brushes
    --LUMP_BRUSHSIDES,			--Sides of brushes
    LUMP_GAME_LUMP,				--Static props and detail props
    --LUMP_NODES,					--Spatial partitioning nodes
    --LUMP_LEAFS,					--Spatial partitioning leafs
    LUMP_MODELS,				--Brush models (trigger_* / func_*)
    --LUMP_LEAFBRUSHES,			--Indexing between leafs and brushes
    --LUMP_TEXDATA,				--Texture data (width / height / name)
    --LUMP_TEXDATA_STRING_DATA,	--Names of textures
    --LUMP_TEXINFO				--Surface texture info
}
local function getBSPFacts(mapname, wsid, addFact)

    -- Load the map asynchronously first
    local bsp = bsp2.LoadBSP( mapname, nil, loadLumps )
    task.Await(bsp:GetLoadTask())

    -- Now grab map facts
    addFact("map_size", "Map Size:\n" .. getMapSize(bsp))
    addFact("skybox", "Skybox:\n" .. getSkybox(bsp))
    addFact("comment", "Comment:\n" .. getComment(bsp)) -- Almost all decompiled maps will have a comment
    addFact("brush_count", "Brush Count:\n" .. table.Count(bsp.brushes or {}))
    addFact("static_props", "Static Props:\n" .. table.Count(bsp.props or {}))
    addFact("entity_count", "Entity Count:\n" .. table.Count(bsp.entities or {}))
    addFact("map_name", "Map Name:\n" .. mapname)
end

local function loadMapFacts(mapname, wsid)
    local facts = {}
    local function addFact(name, fact) 
        facts[name] = fact
        task.Yield()
    end

    -- Start loading workshop facts
    local workshopTask = task.New(getWorkshopFacts, 1, wsid, addFact)

    -- Start loading map facts
    local bspTask = task.New(getBSPFacts, 1, mapname, wsid, addFact)
    
    -- Await both, so they're both running concurrently
    task.Await(bspTask)
    task.Await(workshopTask)
    
    return facts
end

-- Returns a task that loads and grabs map data/facts
function GetMapFacts(mapname, wsid)
    return task.New(loadMapFacts, 1, mapname, wsid)
end
