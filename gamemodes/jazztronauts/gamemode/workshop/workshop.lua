
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
		func(AddonMaterial(name))
	end )
end