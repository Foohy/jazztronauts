if SERVER then AddCSLuaFile("sh_gmad.lua") end

module( "gmad", package.seeall )

-- GMA addon format we are supporting
Ident   = 0x44414D47
Version = 3
AppID   = 4000

local function IsEOF(f)
	return f:Tell() >= f:Size()
end

local function ReadString(f)
	local str = ""
	local c = f:ReadByte()
	while c != 0 do
		str = str .. string.char(c)
		c = f:ReadByte()
	end

	return str
end

-- Just hope to god we don't have numbers bigger than 2^~53 ish, that's lua's integer precision
local function ReadULongLong(f)
	local val = bit.lshift(f:ReadULong(), 32)
	val = bit.bor(val, f:ReadULong())

	return val
end

local function ReadHeader(f)
	local read = f:ReadULong()
	if read != Ident then print("IDENT MISMATCH: " .. bit.tohex(read) .. " != " .. bit.tohex(Ident)) return false end
	local ver = f:ReadByte()
	if ver > Version then return false end

	f:Skip(8) -- Steamid
	f:Skip(8) -- Timestamp

	return (not IsEOF(f)) and ver or false
end

local function ReadRequiredContent(f)
	local req = { }
	local str = ReadString(f)
	while #str > 0 do
		table.insert(req, str)
		str = ReadString(f)
	end
	return req
end

function ReadFileEntries(f)
	local res = {}

	-- Read Header
	res.version = ReadHeader(f)
	if not res.version then
		print("Invalid header!")
		return nil
	end

	-- If version > 1, read some extra info
	if res.version > 1 then
		res.required = ReadRequiredContent(f)
	end

	-- Addon info
	res.name = ReadString(f)
	res.desc = ReadString(f)
	res.auth = ReadString(f)
	res.addonver = f:ReadLong()

	-- Read file listing
	local filenum = 0
	local offset = 0

	local n = f:ReadULong()
	res.files = {}
	while n and n != 0 do
		local entry =
		{
			strName = ReadString(f),
			size = ReadULongLong(f),
			crc = f:ReadULong(),
			offset = offset,
			filenum = filenum
		}

		table.insert(res.files, entry)
		offset = offset + entry.size
		filenum = filenum + 1

		-- Iterate to next file
		n = f:ReadULong()
	end

	-- File listing over, now begins file block
	res.fileblock = f:Tell()

	return res
end


-- Extract files from the provided gma package to the output folder
-- Optionally, a pattern can be specified for specific files to be output
function ExtractFiles(filepath, outputfolder, pattern)
	local f = file.Open(filepath, "r", "GAME")
	if not f then return nil end

	print("Not implemented")

end

-- Get a reading of all the filenames contained in this addon
function FileList(filepath)
	local f = file.Open(filepath, "r", "GAME")
	if not f then return nil end

	local succ, res = pcall(ReadFileEntries, f)
	if not succ then
		ErrorNoHalt("Failed to parse GMA \"" .. filepath .. "\"!")
	end

	return res
end