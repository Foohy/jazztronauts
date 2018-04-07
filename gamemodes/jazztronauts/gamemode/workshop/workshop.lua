
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

		info.author 	= #infoarr >= 1 and infoarr[1] or ""
		info.date 		= #infoarr >= 2 and infoarr[2] or ""
		info.message 	= #infoarr >= 3 and infoarr[3] or ""

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
			local comments = string.gsub(ret.comments_html, "\\%a", "")

			local comm = splitelements(comments)

			func(comm)
		end, 
		function() 
			print("Failed to get workshop comments") 
		end
	)
end

-- Async fetch the thumbnail for the provided workshop addon
function FetchThumbnail(addon, func)
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
        end
	end )
end


-- Attempt to find the addon that 'owns' this map
-- May be nil if the map is just loose in their folder
function FindOwningAddon(mapname)
	if not mapname then return 0 end

	-- First, try to see if we've cached the mapname/workshop association
	local res = progress.GetMap(mapname)
	if res and res.wsid != 0 then return res.wsid end

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

			func(addoninfo, (not addoninfo) and "Unable to parse json: \n" .. resp or nil)
		end,
		function(errmsg)
			func(nil, errmsg)
		end
	)

end


-- Given a workshop id, download the raw GMA file to disk
-- Works on both server and client (steamworks.Download does not)
function DownloadGMA(wsid, path, func)
	-- Callback for when the actual GMA file is downloaded
	local function FileDownloaded(body, size, headers, status)
		
		print("Downloaded " ..  size .. " bytes!")

		-- Decompress (LZMA), then write

		local start = SysTime()
		body = util.Decompress(body)
		print("Decompress: " .. (SysTime() - start) .. " seconds")

		print("Writing to " .. path)
		start = SysTime()
		file.Write(path, body)
		print("Write to disk: " .. (SysTime() - start) .. " seconds")

		start = SysTime()
		local fileList = gmad.FileList("data/" .. path)
		print("Reading file list: " .. (SysTime() - start) .. " seconds")

		-- Just a useful object that shows info about what we just mounted
		local res = { 
			files = fileList,
			path = path,
			wsid = wsid,
			timestamp = 0 -- TODO: timestamp of last time this addon was updated
		}

		func(res) -- holy shit it actually worked
	end

	-- Callback for when we've received information about a specific published file
	local function OnGetPublishedFileDetails(resp, len, head, status)
		print("Published file details received...")
		local json = util.JSONToTable(resp)
		local addoninfo = tryGetValue(json, "response", "publishedfiledetails", 1)
		local fileurl = addoninfo and addoninfo.file_url
		if not fileurl then
			func(nil, "Received response from GetPublishedFileDetails, but invalid JSON: " .. resp)
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
			func(nil, "Received response from GetCollectionDetails, but invalid JSON: " .. resp)
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

	-- Start the call chain, getting information about the published files for the workshop addon
	local body = { collectioncount = "1", ["publishedfileids[0]"] = tostring(wsid)}
	http.Post("http://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v0001/", body, 
		OnGetCollectionDetails,	
		function(errmsg)
			func(nil, "GetCollectionDetails request failed: " .. errmsg)
		end
	)
end