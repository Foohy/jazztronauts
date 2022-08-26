module("factgen", package.seeall)

local function getComment(bsp)
	local winfo = bsp.entities and bsp.entities[1]
	if not winfo then return "jazz.fact.unknown" end

	return winfo.comment or winfo.description or "jazz.fact.none"
end

local function getSkybox(bsp)
	local winfo = bsp.entities and bsp.entities[1]
	if not winfo then return "jazz.fact.unknown" end

	return winfo.skyname
end

local function getMapSize(bsp)

	local winfo = bsp.entities and bsp.entities[1]
	if not winfo then return "jazz.fact.unknown" end

	local maxs, mins = Vector(winfo.world_maxs), Vector(winfo.world_mins)
	local size = maxs - mins

	return size.x..","..size.y..","..size.z
end

local function getAddonTags(info)
	local tags = {}
	for k, v in pairs(info.tags) do
		table.insert(tags, v.tag)
	end

	return string.Implode(", ", tags)
end

local function getWorkshopFacts(wsid, addFact)
	print("----------------------", wsid, addFact)
	if not wsid or wsid == 0 then return end

	-- Get workshop file info
	local fileinfoTask = task.NewCallback(function(done)
		workshop.FileInfo(wsid, done)
	end)

	local info = task.Await(fileinfoTask)
	if info and info.result != 9 then
		PrintTable(info)
		addFact("ws_owner", info.owner)
		addFact("ws_views", "jazz.fact.views,"..tostring(info.views))
		addFact("ws_filesize", "jazz.fact.filesize,"..string.NiceSize(tonumber(info.file_size) or 0))
		addFact("ws_favorites", "jazz.fact.favs,"..tostring(info.favorited))
		addFact("ws_subscriptions", "jazz.fact.subs,"..tostring(info.subscriptions))
		addFact("ws_upload_date", "jazz.fact.uploaded,"..tostring(os.date("%H:%M:%S - %d/%m/%Y", tonumber(info.time_created) or 0)))
		addFact("ws_update_date", "jazz.fact.modified,"..tostring(os.date("%H:%M:%S - %d/%m/%Y", tonumber(info.time_updated) or 0)))
		addFact("ws_screenshots", info.preview_url) --#TODO: How to grab ALL preview images?
		addFact("ws_tags", "jazz.fact.tags,"..tostring(getAddonTags(info)))

		-- Fetch a random comment
		local commentTask = task.NewCallback(function(done)
			workshop.FetchComments(info, done)
		end)

		local comments = task.Await(commentTask)
		if #comments > 0 then
			local comm = table.Random(comments)
			addFact("comment", "\"" .. comm.message .. "\"\n-" .. comm.author)
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
	addFact("map_size", "jazz.fact.mapsize,"..tostring(getMapSize(bsp)))
	addFact("skybox", "jazz.fact.skybox,"..tostring(getSkybox(bsp)))
	addFact("map_comment", "jazz.fact.metadata,"..tostring(getComment(bsp))) -- Almost all decompiled maps will have a comment
	addFact("brush_count", "jazz.fact.brushes,"..tostring(table.Count(bsp.brushes or {})))
	addFact("static_props", "jazz.fact.staticprops,"..tostring(table.Count(bsp.props or {})))
	addFact("entity_count", "jazz.fact.entities,"..tostring(table.Count(bsp.entities or {})))
	addFact("map_name", "jazz.fact.map,"..tostring(mapname))
end

local function loadMapFacts(mapname, wsid)
	wsid = wsid or 0
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
