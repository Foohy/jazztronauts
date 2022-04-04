AddCSLuaFile()

module( 'workshop', package.seeall )

local function tagdepth(str)
	if string.sub(str, 1, 3) == "div" then return 1 end
	if str == "/div" then return -1 end
	return 0
end

local function getrootelement(block, start)
	local depth = 0
	local strpos, endpos
	endpos = start or 0

	repeat
		strpos, endpos = string.find(block, "<(.-)>", endpos)

		if strpos != nil then
			local tag = string.sub(block, strpos + 1, strpos + 4)
			depth = depth + tagdepth(tag)
			//print(depth)
		else
			//print("no more matches")
		end
	until (strpos == nil or depth == 0)

	if strpos == nil then return nil end
	return string.sub(block, start or 0, endpos), endpos
end

local function splitelements(block)
	local str, pos
	local commentStr = {}
	repeat
		str, npos = getrootelement(block, pos)
		table.insert(commentStr, str)
		pos = npos and npos + 1 or nil

	until (pos == nil )

	-- Clean up html tags
	local comments = {}
	for _, v in pairs(commentStr) do
		v = string.Replace(v, "<br>", "\n")
		v = string.Replace(v, "</div></div>", "\n\n")

		local infoarr = {}
		local info = {}
		for w in string.gmatch(v, ">(.-)<") do

			-- Filter tags with no content
			if (w == nil or w:match("%S") == nil) then continue end

			-- Remove surrounding junk
			w = string.Trim(w)

			-- Just some common tags
			w = string.Replace(w, "&nbsp;", "")
			w = string.Replace(w, "&quot;", "\"")
			table.insert(infoarr, w)
		end

		info.author	= #infoarr >= 1 and infoarr[1] or ""
		info.date		= #infoarr >= 2 and infoarr[2] or ""
		info.message	= #infoarr >= 3 and infoarr[3] or ""

		table.insert(comments, info)
	end

	return comments
end

-- Async fetch comments for the provided workshop addon
function FetchComments(addon, func)
	local url = "https://steamcommunity.com/comment/PublishedFile_Public/render/%s/%s/"
	url = string.format(url, addon.owner, addon.id)

	http.Fetch(url,
		function(body, len, headers, cod)
			local ret = util.JSONToTable(body)
			if ret.comments_html then
				local comments = string.gsub(ret.comments_html, "\\%a", "")
				local comm = splitelements(comments)
				func(comm)
			else 
				print(url, body)
				func({})
			end		
		end,
		function()
			print("Failed to get workshop comments")
			func({})
		end
	)
end

-- Async fetch the thumbnail for the provided workshop addon
function FetchThumbnail(addon, func)
	if addon and type(addon.previewid) == "string" then
		steamworks.Download(addon.previewid, true, function(name)
			if name != nil then
				local mat = AddonMaterial(name)

				-- Sometimes it likes to throw you a curveball and not work
				local baseTex = mat and mat:GetTexture("$basetexture") or nil
				if baseTex == nil then

					-- But just trying it again fixes it....
					print("preview image invalid, reloading...")
					mat = AddonMaterial(name)
				end

				func(mat)
			else
				func(nil)
			end
		end )
	else
		func(nil)
	end
end


-- Attempt to find the addon that 'owns' this map
-- May be nil if the map is just loose in their folder
function FindOwningAddon(mapname)
	if not mapname then return 0 end

	-- First, try to see if we've cached the mapname/workshop association
	if progress then
		local res = progress.GetMap(mapname)
		if res and res.wsid != 0 then return tostring(res.wsid) end
	end

	local addons = engine.GetAddons()

	-- For each installed addon, search its contents for the given map file
	-- This is very slow so make ideally we only ever do this once on startup
	for _, v in pairs(addons) do
		local found = file.Find("maps/" .. mapname .. ".bsp", v.title)
		if #found > 0 then return v.wsid end
	end

	return nil
end

local function tryGetValue(jsonObj, ...)
	if not jsonObj then return nil end
	local cur = jsonObj
	for _, v in ipairs({...}) do
		if not cur[v] then return nil end
		cur = cur[v]
	end

	return cur
end

-- Retreives info about a supllied workshop addon
-- Identical to steamworks.FileInfo, but works on servers too
function FileInfo(itemid, func)
	local body = { ["itemcount"] = "1", ["publishedfileids[0]"] = tostring(itemid)}
	http.Post("http://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v0001/", body,
		function(resp, len, head, status)
			print("Published file details received...")
			local json = util.JSONToTable(resp)
			local addoninfo = tryGetValue(json, "response", "publishedfiledetails", 1)

			-- Copy the formatting of steamworks.FileInfo
			if addoninfo then
				addoninfo.owner = addoninfo.creator
				addoninfo.id = itemid
			end

			func(addoninfo, (not addoninfo) and "Unable to parse json: \n" .. resp or nil)
		end,
		function(errmsg)
			func(nil, errmsg)
		end
	)

end

-- Given a workshop id, download the raw GMA file, returning the compressed binary string
function DownloadExtractGMA(wsid, path, func)
	DownloadGMA(wsid, function(data)
		local fileList = ExtractGMA(path, data)

		-- Just a useful object that shows info about what we just mounted
		local res = {
			files = fileList,
			path = path,
			wsid = wsid,
			timestamp = 0 -- TODO: timestamp of last time this addon was updated
		}

		func(res)
	end )
end

local WORKSHOP_CACHE_PATH = "jazztronauts/cache"

function ExtractGMA(path, data)
	-- Decompress (LZMA), then write
	local start = SysTime()
	local decompd = util.Decompress(data)
	data = (decompd and #decompd > 0) and decompd or data
	print("Decompress: " .. (SysTime() - start) .. " seconds")

	-- Write to disk
	print("Writing to " .. path)
	start = SysTime()
	file.CreateDir(WORKSHOP_CACHE_PATH)
	file.Write(path, data)
	print("Write to disk: " .. (SysTime() - start) .. " seconds")

	-- Read file contents
	start = SysTime()
	local fileList = gmad.FileList("data/" .. path)
	print("Reading file list: " .. (SysTime() - start) .. " seconds")

	return fileList
end

function ClearCache()
	local files = file.Find(WORKSHOP_CACHE_PATH .. "/*", "DATA")
	for _, v in pairs(files) do
		file.Delete(WORKSHOP_CACHE_PATH .. "/" .. v)
	end
end

function IsAddonCached(wsid)
	local cachepath = WORKSHOP_CACHE_PATH .. "/" .. wsid .. ".dat"
	return file.Exists(cachepath, "DATA") and "data/" .. cachepath
end


local active_downloadgma = nil
if SERVER then
	util.AddNetworkString("jazz_workshop_downloadlisten")
end
net.Receive("jazz_workshop_downloadlisten", function(len, ply)
	if CLIENT then
		local wsid = net.ReadString()
		print("Download workshop addon " .. tostring(wsid) .. " on client via DownloadUGC")

		-- Receive what workshop thing to download and tell the server when it's done
		steamworks.DownloadUGC(wsid, function(name, file)
			print("Finished steamworks.DownloadUGC - ", name)
			net.Start("jazz_workshop_downloadlisten")
				net.WriteString(wsid) -- Tell which message we're on about
				net.WriteString(name or "")
			net.SendToServer()
		end )
	elseif SERVER then
		-- Receive a filepath from the client once they've downloaded it
		-- This filepath should exist on the server because it is assumed to be working on the listen server host
		local wsid = net.ReadString()
		local filepath = net.ReadString()
		print("Client finished with download file: " .. tostring(filepath))
		if active_downloadgma then
			if active_downloadgma.ply == ply and active_downloadgma.wsid == wsid then -- no funny business
				active_downloadgma.cb(filepath)
				active_downloadgma = nil
			else
				print("Received wrong response for file results: ", active_downloadgma.ply, (active_downloadgma.ply == ply) and "==" or "!=", ply, 
					active_downloadgma.wsid, (active_downloadgma.wsid == wsid) and "==" or "!=", wsid)
			end
		else
			print("Received file response but we weren't downloading anything!")
		end
	end
end )

-- Version to use on listen servers where we can take advantage of steamworks.DownloadUGC
local function DownloadGMA_Listen(wsid, func, decompress_func, hostply)
	if active_downloadgma then return func(nil, "Only one call to DownloadGMA_Listen is allowed at a time") end -- Whatever
	if not IsValid(hostply) or not hostply:IsPlayer() then return func(nil, "Provided host player is nil or invalid") end

	active_downloadgma = {
		wsid = tostring(wsid),
		cb = function(f)
			if f and #f > 0 then 
				func(f)
			else 
				func(nil, "Failed to download from workshop") 
			end
		end,
		ply = hostply
	}

	-- Send a message to the listen server client to download the map
	-- It'll send a message back to use once they're done
	net.Start("jazz_workshop_downloadlisten")
		net.WriteString(wsid)
	net.Send(hostply)
end

-- Works on both server and client, but only for old-style workshop addons (non-UGC items)
local function DownloadGMA_Dedicated(wsid, func, decompress_func)
	-- Callback for when the actual GMA file is downloaded
	local function FileDownloaded(body, size, headers, status)
		print("Downloaded " ..  size .. " bytes!")
		local cachepath = WORKSHOP_CACHE_PATH .. "/" .. wsid .. ".dat"

		-- Optionally, delay before decompressing if the decompress function told us to
		local delay = decompress_func and decompress_func(wsid) or 0
		timer.Simple(delay, function()

			-- Decompress and save to cache folder
			workshop.ExtractGMA(cachepath, body)

			func("data/" .. cachepath)
		end )
	end

	-- Callback for when we've received information about a specific published file
	local function OnGetPublishedFileDetails(resp, len, head, status)
		print("Published file details received...")
		local json = util.JSONToTable(resp)
		local addoninfo = tryGetValue(json, "response", "publishedfiledetails", 1)
		local fileurl = addoninfo and addoninfo.file_url

		if not fileurl then
			print("Received response from GetPublishedFileDetails, but missing file_url: " .. resp)
			func(nil, "Received response from GetPublishedFileDetails, but missing file_url. File hidden?")
			return
		end

		if #fileurl == 0 then
			--[[
				There is a fix we (Sunrust Devs) made atm, however I (ptown2) currently
				do not feel comfortable in releasing it in its current state, I will
				check alternate downloading methods or improve said fix whenever I can.
			]]

			func(nil, "Specified addon uses the new UGC workshop system, which is not compatible") -- New UGC workshop addons are not supported with this method
			return
		end

		print("Beginning file download... " .. fileurl)
		http.Fetch(fileurl, FileDownloaded,
		function(errormsg)
			func(nil, "Download file failed: " ..  errormsg)
		end)
	end

	-- Callback for when we receive information about a workshop addon
	local function OnGetCollectionDetails(resp, len, head, status)
		print("Collection details received...")
		-- Grab published fileid from collection details
		local json = util.JSONToTable(resp)
		local fileid = tryGetValue(json, "response", "collectiondetails", 1, "publishedfileid")

		if not fileid then
			print("Received response from GetCollectionDetails, but missing fileid: " .. resp)
			func(nil, "Received response from GetCollectionDetails, but missing fileid")
			return
		end

		local body = { ["itemcount"] = "1", ["publishedfileids[0]"] = fileid}
		http.Post("http://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v0001/", body,
			OnGetPublishedFileDetails,
			function(errmsg)
				func(nil, "GetPublishedFileDetails request failed: " .. errmsg)
			end
		)
	end


	-- Use cached file if it exists on disk
	local existfile = IsAddonCached(wsid)
	if existfile then
		print("Cached version of wsid " .. wsid .. " found! Using that.")
		func(existfile)
		return
	end

	-- Start the call chain, getting information about the published files for the workshop addon
	local body = { collectioncount = "1", ["publishedfileids[0]"] = tostring(wsid)}
	http.Post("http://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v0001/", body,
		OnGetCollectionDetails,
		function(errmsg)
			func(nil, "GetCollectionDetails(" .. wsid .. ") request failed: " .. errmsg)
		end
	)
end

-- Given a workshop id, download the raw GMA file to disk
function DownloadGMA(wsid, func, decompress_func)
	-- Before doing anything, see if the addon is already mounted locally, that saves us all the work

	local subscribed = engine.GetAddons()
	for _, v in pairs(subscribed) do
		print(type(v.wsid), type(wsid), v.wsid == wsid)
		if v.wsid == wsid then
			if v.mounted then
				-- It's mounted!! just return that instead
				func(v.file)
				return
			end

			break -- If we hit a match and it wasn't mounted, fallback
		end
	end



	-- Prefer using the dedicated server way, because for old addons there is always a hitch on decompress
	-- We have explicit control over this hitch since we decompress manually, so we can throw the little UI widget up to hide it
	DownloadGMA_Dedicated(wsid, function(filename, err)
		if err then
			print("DownloadGMA_Dedicated FAILED: ", err)

			-- On non-dedicated servers, we have something we can try here: telling the listen server host to install it
			for _, v in pairs(player.GetAll()) do
				if IsValid(v) and v:IsListenServerHost() then
					print("Using fallback, DownloadGMA_Listen")
					DownloadGMA_Listen(wsid, func, decompress_func, v)
					return -- Break here
				end
			end
		end

		-- Wasn't a listen server, so we couldn't try anything else
		-- Pass on the bad news
		func(filename, err)
	end, decompress_func)
end
