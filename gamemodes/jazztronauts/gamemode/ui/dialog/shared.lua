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

local g_graph = {}

function DetermineLineEnd(line)
	if line:find("\r\n") then return 3 end
	if line:find("\n") then return 2 end
	return 1
end

local TOK_TEXT = 0
local TOK_ENTRY = 1
local TOK_FIRE = 2
local TOK_WAIT = 3
local TOK_JUMP = 4
local TOK_EQUAL = 5
local TOK_NEWLINE = 6
local TOK_EMTPY = 7

local function ParseLine(script, line)
	line = line:Trim()
	if line[1] == '#' then return end
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
			if ch == '*' then emit(TOK_TEXT) tok = "" inExec = false
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

function CompileScript(script)

	local cmds = {}
	local toks = script.tokens
	local notok = {tok="", type = TOK_EMTPY}
	local entries = {}
	local entry = nil
	local jump_parent = nil

	local i = 1
	repeat
		local t = toks[i]
		local nt = toks[i+1] or notok

		if t.type == TOK_TEXT and nt.type == TOK_EQUAL and i+2 <= #toks then
			script.params[ t.tok ] = toks[i+2].tok:Trim()
			i = i + 2
		elseif t.type == TOK_JUMP and nt.type == TOK_TEXT then
			if i+2 <= #toks and toks[i+2].type == TOK_ENTRY then
				entry = {}
				entry.type = ENTRY_JUMP
				entry.data = nt.tok
				if jump_parent ~= nil then table.insert(jump_parent, {cmd=CMD_OPTION, data=entry}) end
				i = i + 2
			else
				if entry ~= nil then table.insert(entry, {cmd=nt.tok == "exit" and CMD_EXIT or CMD_JUMP, data=nt.tok}) end
				i = i + 1
			end
		elseif t.type == TOK_TEXT and nt.type == TOK_ENTRY then
			entry = {}
			entry.type = ENTRY_NORMAL
			entry.data = t.tok
			if t.tok ~= "player" then
				jump_parent = entry
				table.insert(entries, entry)
			else
				if jump_parent ~= nil then table.insert(jump_parent, {cmd=CMD_OPTIONLIST, data=entry}) end
				jump_parent = entry
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
			print("UNPARSED: " .. t.type, t.tok:Trim())
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

	for _, script in pairs(scripts) do

		local new_entries = {}
		for k, entry in pairs(script.entries) do
			if SERVER then
				local netstr = script.name .. "." .. k
				util.AddNetworkString( netstr )
			end

			new_entries[script.name .. "." .. k] = entry
			g_graph[script.name .. "." .. k] = entry
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

function LoadScript(name, filename)
	--print("Load", name, filename)

	local data = file.Open( filename, "r", "THIRDPARTY" )
	local lines = {}
	local script = {
		tokens = {},
		params = {},
		entries = {},
		name = name,
	}

	repeat
		local line = data:ReadLine()
		if line then ParseLine(script, line:sub(0,-DetermineLineEnd(line))) end
	until line == nil

	CompileScript( script )

	return script

end

function LoadScripts()

	--print("Loading scripts...")
	local scripts, _ = file.Find( "data/scripts/*", "THIRDPARTY" )
	local compiled = {}

	for _, script in pairs( scripts ) do
		local ext = script:sub(script:find(".txt"), -1)
		local name = script:sub(0, -ext:len() - 1)
		if ext == ".txt" then
			local result = LoadScript( name, "data/scripts/" .. script )
			if result then table.insert(compiled, result) end
		end
	end

	LinkScripts( compiled )

end

local scripttimes = {}
local nexthotreloadcheck = 0
local function CheckHotReload()
	if nexthotreloadcheck > CurTime() then return end
	nexthotreloadcheck = CurTime() + 1

	local needsreload = false
	local scripts, _ = file.Find( "data/scripts/*", "THIRDPARTY" )
	for _, script in pairs( scripts ) do
		local t = file.Time( "data/scripts/" .. script, "THIRDPARTY" )
		if scripttimes[script] and t > scripttimes[script] then
			needsreload = true
		end
		scripttimes[script] = t
	end

	if needsreload then
		LoadScripts()
	end

end
hook.Add( "Think", "JazzScriptCheckHotReload", CheckHotReload )

function GetGraph()

	return g_graph

end

function IsValid(node)
	return node and (g_graph[node] or g_graph[node .. ".begin"])
end

function EnterGraph( node, callback )

	node = g_graph[node] or g_graph[node .. ".begin"]
	if not node then return nil end

	local cmd = node[1]
	if not cmd then return nil end

	local stepfunc = nil
	stepfunc = function()

		if not cmd then return nil end
		if cmd.cmd == CMD_OPTIONLIST then

			callback(CMD_OPTIONLIST, cmd, stepfunc)
			for _, opt in ipairs(cmd.data) do
				callback(CMD_OPTION, opt, stepfunc)
			end

		else

			local jump = callback(cmd.cmd, cmd.data)
			if jump and #jump > 0 then cmd = jump[1] return end

		end

		cmd = cmd.next
	end

	return stepfunc

end

function Init()

	LoadScripts()

end