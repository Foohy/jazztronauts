local util = util
local file = file
local string = string
local table = table
local pairs = pairs
local ipairs = ipairs
local print = print
local tostring = tostring
local PrintTable = PrintTable
local CurTime = CurTime
local hook = hook
local SERVER = SERVER
local CLIENT = CLIENT

include("sh_scriptids.lua")

module("dialog")

CMD_LAYOUT = "layout"
CMD_PRINT = "print"
CMD_NEWLINE = "newline"
CMD_WAIT = "wait"
CMD_EXEC = "exec"
CMD_JUMP = "jump"
CMD_OPTION = "option"
CMD_OPTIONLIST = "optionlist"
CMD_EXIT = "exit"

ScriptSources = ScriptSources or {} -- Raw uncompiled script sources, transmitted to clients
g_graph = g_graph or {} 			-- Compiled script graphs

local ScriptPath = "data_static/scripts"--_"..string.lower(GetConVar("gmod_language"):GetString()).."/"
local HIGH_PRIORITY_SCRIPTS = { 
	["macros.txt"] = true,
	["jazz_bar_intro.txt"] = true,
	["jazz_bar_shardprogress.txt"] = true, 
	["no_singleplayer_allowed.txt"] = true,
}


function DetermineLineEnd(line)
	if line:find("\r\n") then return 3 end
	if line:find("\n") then return 2 end
	return 1
end

local TOK_TEXT      = 0
local TOK_ENTRY     = 1
local TOK_FIRE      = 2
local TOK_WAIT      = 3
local TOK_JUMP      = 4
local TOK_EQUAL     = 5
local TOK_NEWLINE   = 6
local TOK_EMPTY     = 7

local tokNames = {
    [TOK_TEXT]      = "TEXT",
    [TOK_ENTRY]     = "ENTRY",
    [TOK_FIRE]      = "FIRE",
    [TOK_WAIT]      = "WAIT",
    [TOK_JUMP]      = "JUMP",
    [TOK_EQUAL]     = "EQUAL",
    [TOK_NEWLINE]   = "NEWLINE",
    [TOK_EMPTY]     = "EMPTY",
}

local function lineitr(str)
	return string.gmatch(str, "[^\r\n]+")
end

local function ChopRight(str, findstr)
	local pos = str:find(findstr)
	if not pos then return str end

	return str:sub(0, pos - 1)
end

local function stripNonAscii(str)
	return string.gsub(str, "[\192-\255][\128-\191]*", "")
end

local function ParseLine(script, line)
	-- Chop off comments
	line = ChopRight(line, "#")

	-- Trim the fat
	line = line:Trim()

	local tok = ""
	local function emit(type)
		if #tok == 0 then return end
		table.insert(script.tokens, {tok = tok, type = type}) tok = ""
	end
	local i = 1
	
	local inExec = false
	repeat
		local ch = line[i]
		local nx = line[i+1] or ' '

		-- this is your punishment, zak
		if inExec then
			if ch == '\\' then tok = tok .. nx i = i + 1 -- allow escaping
			elseif ch == '*' then emit(TOK_TEXT) tok = "" inExec = false
			else tok = tok .. ch end
		else
			if ch == '\\' then tok = tok .. nx i = i + 1
			elseif ch == '&' then emit(TOK_TEXT) tok = "&" emit(TOK_JUMP)
			elseif ch == '%' then emit(TOK_TEXT) tok = "%" emit(TOK_WAIT)
			elseif ch == ':' then emit(TOK_TEXT) tok = ":" emit(TOK_ENTRY)
			elseif ch == '=' then emit(TOK_TEXT) tok = "=" emit(TOK_EQUAL)
			elseif ch == '*' then emit(TOK_TEXT) tok = "*" emit(TOK_FIRE) inExec = true
			else tok = tok .. ch end
		end
		i = i + 1
	until i > #line
	if #tok > 0 then emit(TOK_TEXT) end
	tok = " " emit(TOK_NEWLINE)
end


local ENTRY_NORMAL = 0
local ENTRY_JUMP = 1

local function TrimNewlines(entry)

	local i = 1
	repeat
		if entry[i].cmd == CMD_PRINT then break end
		if entry[i].cmd == CMD_NEWLINE then
			table.remove(entry, i)
		else i = i + 1
		end
	until #entry == 0 or i == #entry

	for i=#entry, 1, -1 do

		if entry[i].cmd == CMD_PRINT then break end
		if entry[i].cmd == CMD_NEWLINE then
			table.remove(entry, i)
		end

	end

	local text = ""
	local hastext = false
	for _, cmd in ipairs(entry) do
		if cmd.cmd == CMD_PRINT then text = text .. cmd.data hastext = true end
		if cmd.cmd == CMD_NEWLINE then text = text .. "\n" hastext = true end
	end

	if hastext then table.insert(entry, 1, {cmd = CMD_LAYOUT, data = text}) end

	for i=1, #entry do
		if entry[i].cmd == CMD_OPTION or entry[i].cmd == CMD_OPTIONLIST then
			TrimNewlines(entry[i].data)
		end
	end

end

local function tokTypeToString(token)
	local num = tonumber(token)
	return num and tokNames[num] or "INVALID TOKEN " .. tostring(token)
end

function CompileScript(script)
	local cmds = {}
	local toks = script.tokens
	local notok = {tok="", type = TOK_EMPTY}
	local entries = {}
	local entry = nil
	local jump_parent = nil
	local response_jump = nil

	local i = 1
	repeat
		local t = toks[i]
		local nt = toks[i+1] or notok

		if t.type == TOK_TEXT and nt.type == TOK_EQUAL and i+2 <= #toks then
			local key = stripNonAscii(t.tok:Trim())
			local value = stripNonAscii(toks[i+2].tok:Trim())
			script.params[ key ] = value
			i = i + 2
		elseif t.type == TOK_JUMP and nt.type == TOK_TEXT then
			if i+2 <= #toks and toks[i+2].type == TOK_ENTRY then
				if response_jump then
					table.insert(entry, response_jump)
					response_jump = nil
				end

				entry = {}
				entry.type = ENTRY_JUMP
				entry.data = nt.tok
				if jump_parent ~= nil then
					//NOTE:
					//Below command works perfectly in adding a jump command to the end of the response text
					//HOWEVER: Adding it right here makes it skip the 'print' command, added after this
					//We need to add this command specifically as the last command, after the print statement
					//table.insert(entry, {cmd=entry.data == "exit" and CMD_EXIT or CMD_JUMP, data=entry.data})
					response_jump = {cmd=entry.data == "exit" and CMD_EXIT or CMD_JUMP, data=entry.data}

					table.insert(jump_parent, {cmd=CMD_OPTION, data=entry})
				end
				i = i + 2
			else
				if entry ~= nil then table.insert(entry, {cmd=nt.tok == "exit" and CMD_EXIT or CMD_JUMP, data=nt.tok}) end
				i = i + 1
			end
		elseif t.type == TOK_TEXT and nt.type == TOK_ENTRY then
			if response_jump then
				table.insert(entry, response_jump)
				response_jump = nil
			end

			entry = {}
			entry.type = ENTRY_NORMAL
			entry.data = t.tok
			if t.tok == "player" or t.tok == "condition" then
				entry.conditional = t.tok == "condition"
				if jump_parent ~= nil then table.insert(jump_parent, {cmd=CMD_OPTIONLIST, data=entry}) end
				jump_parent = entry
			else
				jump_parent = entry
				table.insert(entries, entry)
			end
			i = i + 1

		elseif t.type == TOK_FIRE and nt.type == TOK_TEXT then
			if entry ~= nil then table.insert(entry, {cmd=CMD_EXEC, data=nt.tok}) end
			i = i + 1
		elseif t.type == TOK_WAIT then
			if entry ~= nil then table.insert(entry, {cmd=CMD_WAIT, data=t.tok}) end
		elseif t.type == TOK_TEXT then
			if entry ~= nil then table.insert(entry, {cmd=CMD_PRINT, data=t.tok}) end
		elseif t.type == TOK_NEWLINE then
			if entry ~= nil then table.insert(entry, {cmd=CMD_NEWLINE, data=t.tok}) end
		else
			print("UNPARSED token [" .. script.name .. "] index #" .. i .. ": Type " .. tokTypeToString(t.type) .. ", Token \"" .. t.tok:Trim() .. "\"")
		end

		i = i + 1
	until i > #toks

	for _, entry in pairs(entries) do
		TrimNewlines(entry)
		script.entries[entry.data] = entry
		entry.data = nil
	end

	--PrintTable(script.entries)

	script.tokens = nil
end

function LinkCommands(entry)

	for i=1, #entry do
		if i ~= #entry then
			--print(entry[i].cmd .. " => " .. entry[i+1].cmd .. " [ " .. tostring(entry[i+1].data))
			entry[i].next = entry[i+1]
		end
	end

end

function LinkRecursive(entrygraph, script, entry)

	LinkCommands(entry)
	for _, cmd in ipairs(entry) do
		if cmd.cmd == CMD_JUMP then
			if not entrygraph[cmd.data] then cmd.data = script.name .. "." .. cmd.data end
			--print(tostring(cmd.data) .. " : " .. tostring(entrygraph[cmd.data]) )
			cmd.data = entrygraph[cmd.data]
		end

		if cmd.cmd == CMD_OPTION or cmd.cmd == CMD_OPTIONLIST then
			LinkRecursive(entrygraph, script, cmd.data)
		end

		cmd.env = script
	end

end

function LinkScripts(scripts)

	g_graph = {}
	--print("LINK SCRIPTS")

	if SERVER then
		ClearScriptIDs()
	end

	for _, script in pairs(scripts) do

		local new_entries = {}
		for k, entry in pairs(script.entries) do
			k = stripNonAscii(k) -- HALT CRIMINAL SCUM
			local fullname = script.name .. "." .. k

			if SERVER then
				AddScriptID( fullname )
			end

			new_entries[fullname] = entry
			g_graph[fullname] = entry
		end
		script.entries = new_entries

	end

	for _, script in pairs(scripts) do
		for _, entry in pairs(script.entries) do
			LinkRecursive(g_graph, script, entry)
		end
		script.entries = nil
	end

	--[[local test = g_graph["dunked.intro"][1]

	for i=1, 100 do

		print( test.cmd, test.data)

		if test.cmd == CMD_JUMP then
			test = test.data[1]
		else
			if not test.next then break end
			test = test.next
		end

	end]]

	--PrintTable(g_graph)

end

local PreProcessLine = function(x) return x end

function LoadScript(name, contents)
	local lines = {}
	local script = {
		tokens = {},
		params = {},
		entries = {},
		name = name,
	}

	for line in lineitr(contents) do
		line = PreProcessLine(line)
		if line then ParseLine(script, line:sub(0,-DetermineLineEnd(line))) end
	end

	CompileScript( script )

	return script

end


function CompileMacros(sources)
	local macros = sources["macros.txt"]
	if macros == nil then ErrorNoHalt("Macros not loaded!\n") return end

	local macrolist = {}

	for line in lineitr(macros) do
		line = line:Trim()
		if line:len() == 0 or line[1] == "#" then continue end

		local x,y,z = line:gmatch("([%w_]+)%s-(%b())%s+(.+)")()
		if not x then x,z = line:gmatch("([%w_]+)%s+(.+)")() end

		local args = {}
		for a in (y and y or ""):gmatch("[%w_]+") do table.insert( args, a ) end

		local function use(iter)
			local c = z
			for i=1, #args do
				c = c:gsub(args[i], iter and ( iter() or "") or "")
			end
			return c
		end

		table.insert( macrolist, 1, {
			name = x,
			use = use,
			paren = y ~= nil,
		})
	end

	local function replace( str )
		if str == nil then return str end
		for _, macro in pairs(macrolist) do

			if not macro.paren then
				str = str:gsub(macro.name, macro.use)
			else
				str = str:gsub(macro.name .. "%s*(%b())", function( call )
					return macro.use( call:gmatch("[%w_]+") )
				end)
			end

		end
		return str
	end
	PreProcessLine = replace

	--[[local test_string = " wow, %%%% this is my test string, oncat(bob) calling macro mycoolmacro and complex_name(arg0, arg1, arg2)\n"

	MsgC( Color(255,255,255), test_string )
	MsgC( Color(100,255,100), replace( test_string ))]]
end

function CompileScripts(sources)
	-- 1. Compile macros
	CompileMacros(sources)

	-- 2. Compile scripts
	local compiled = {}

	for script, contents in pairs( sources ) do
		if #contents <= 0 then continue end -- Sources with nil content are not available yet

		local ext = script:sub(script:find(".txt"), -1)
		local name = script:sub(0, -ext:len() - 1)

		if ext == ".txt" and name ~= "macros" then
			local st, result = pcall( LoadScript, name, contents)
			if not st then
				ErrorNoHalt("Failed to load script: " .. name .. " [" .. script .. "]\n" .. tostring(result) .. "\n")
			else
				if result then table.insert(compiled, result) end
			end
		end
	end
	
	
	return compiled
end

local function GetScriptPathForLang(lang)
	return ScriptPath .. "_" .. string.lower(lang) .. "/"
end

function LoadScripts()
	local en_scriptpath = GetScriptPathForLang("en")
	local local_scriptpath = GetScriptPathForLang(GetConVar("gmod_language"):GetString())
	local en_scripts, _ = file.Find( en_scriptpath .. "*.txt", "GAME" )
	local local_scripts, _ = file.Find( local_scriptpath .. "*.txt", "GAME" )
	if SERVER then -- This info is loaded from the server

		print("[Jazz Dialog] Loading english script sources...")
		-- On server, first load specifically english scripts since that is a known complete script set
		for _, script in pairs( en_scripts ) do
			ScriptSources[script] = file.Read( en_scriptpath .. script, "GAME" )
		end

		print("[Jazz Dialog] Overlaying script sources...[" .. GetConVar("gmod_language"):GetString() .. "]")
		-- Optionally overlay with serverside local language
		for _, script in pairs( local_scripts ) do
			print(script)
			ScriptSources[script] = file.Read( local_scriptpath .. script, "GAME" )
		end
	end
	if CLIENT then
		-- It is expected that the server has sent us a complete set of all scripts used in game
		if table.Count(ScriptSources) == 0 then return end

		-- On client, overlay local language onto scripts, with server-sent scripts as backup
		for _, script in pairs( local_scripts ) do
			ScriptSources[script] = file.Read( local_scriptpath .. script, "GAME" )
		end
	end

	print("[Jazz Dialog] Compiling scripts...")
	local compiled = CompileScripts( ScriptSources )

	print("[Jazz Dialog] Linking scripts...")
	LinkScripts( compiled )

	if SERVER then -- This info is loaded from the server
		print("[Jazz Dialog] Downloading to clients...")
		for _, pl in pairs( player.GetAll() ) do
			DownloadToPlayer( ScriptSources, pl )
		end
	end

	print("[Jazz Dialog] Done!")
	hook.Run("JazzDialogReady")
end

local scripttimes = {}
local function CheckHotReload()
	local needsreload = false
	local scripts, _ = file.Find( ScriptPath .. "*", "GAME" )
	for _, script in pairs( scripts ) do
		local t = file.Time( ScriptPath .. script, "GAME" )
		if scripttimes[script] and t > scripttimes[script] then
			needsreload = true
		end
		scripttimes[script] = t
	end

	if needsreload then
		LoadScripts()
	end

end
if SERVER then
	local nexthotreloadcheck = 0
	hook.Add( "Think", "JazzScriptCheckHotReload", function()
		if nexthotreloadcheck > CurTime() then return end
		nexthotreloadcheck = CurTime() + 30
	end )
	concommand.Add("jazz_debug_refreshscripts", function()
		LoadScripts()
	end )
end
function GetGraph()

	return g_graph

end

function GetNode(name)
	return g_graph[name] or g_graph[name .. ".begin"]
end

function IsScriptValid(node)
	return node and GetNode(node) != nil
end

function IsReady()
	return g_graph and table.Count(g_graph) > 0 && !IsPartialCompile()
end

function IsPartialCompile()
	for _, contents in pairs(ScriptSources) do
		if #contents <= 0 then return true end
	end

	return false
end

function EnterGraph( node, callback )

	node = GetNode(node)
	if not node then return nil end

	local cmd = node[1]

	return EnterNode(cmd, callback)
end

function EnterNode(cmd, callback)
	if not cmd then return nil end

	local stepfunc = nil
	stepfunc = function()

		if not cmd then return nil end
		local jump = nil
		if cmd.cmd == CMD_OPTIONLIST then

			jump = callback(CMD_OPTIONLIST, cmd, stepfunc)
			for _, opt in ipairs(cmd.data) do
				callback(CMD_OPTION, opt, stepfunc)
			end

		else

			jump = callback(cmd.cmd, cmd.data)

		end

		if jump and #jump > 0 then cmd = jump[1] return end

		cmd = cmd.next
		return cmd
	end

	return stepfunc, cmd
end

function Init()

	LoadScripts()

end

local function EncodeScripts( sources, whitelist )

	local blob = ""

	for name, contents in pairs(sources) do
		if whitelist and !whitelist[name] then
			blob = blob .. name .. ':' .. '\0' -- Skip content, keep filename
		else
			blob = blob .. name .. ':' .. contents .. '\0'
		end
	end

	return blob
end

local function DecodeScripts( blob )

	local name = nil
	local sources = {}

	local lastbuf = 1
	for i=1, #blob do
		if name and blob[i] == '\0' then
			sources[name] = string.sub(blob, lastbuf, i-1)

			name = nil
			lastbuf = i+1
			
		elseif !name and blob[i] == ':' then
			name = string.sub(blob, lastbuf, i-1)
			lastbuf = i+1
		end
	end

	return sources

end

function DownloadToPlayer( sources, ply, whitelist )

	if CLIENT then return end

	local data = EncodeScripts( sources, whitelist )
	if #data > 0 then

		print("QUEUED " .. #data .. "b DOWNLOAD FOR " .. (whitelist and table.Count(whitelist) or table.Count(sources)) .. " dialog scripts TO PLAYER " .. tostring( ply ) )

		local dl = download.Start( "download_dialogscripts", data, ply, 30000 )
	end

end

hook.Add( "PlayerInitialSpawn", "jazz_dialog_download_scripts", function(ply)
	DownloadToPlayer( ScriptSources, ply, HIGH_PRIORITY_SCRIPTS )
	DownloadToPlayer( ScriptSources, ply )
end )

concommand.Add( "jazz_download_dialog_to_player", function( ply )

	if ply:IsAdmin() then

		for _, ply in pairs( player.GetAll() ) do
			DownloadToPlayer( ScriptSources, ply, HIGH_PRIORITY_SCRIPTS)
			DownloadToPlayer( ScriptSources, ply )
		end

	end

end )

-- Download serverside scripts to to clients
download.Register( "download_dialogscripts", function( cb, dl )

	if CLIENT then

		if cb == DL_FINISHED then
			ScriptSources = DecodeScripts(dl:GetData())
			LoadScripts()
		elseif cb == DL_ERROR then
			ErrorNoHalt("FAILED to download dialog scripts: " .. dl.error)
		end

	end

end )