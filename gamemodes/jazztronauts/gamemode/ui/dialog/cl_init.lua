include("shared.lua")

local ScrW = ScrW
local ScrH = ScrH
local draw = draw
local surface = surface
local math = math
local string = string
local FrameTime = FrameTime
local print = print
local pairs = pairs
local net = net
local util = util
local tostring = tostring
local tonumber = tonumber
local LocalPlayer = LocalPlayer

local missions = missions

local STATE_IDLE = 0
local STATE_OPENING = 1
local STATE_OPENED = 2
local STATE_PRINTING = 3
local STATE_DONEPRINTING = 4
local STATE_CHOOSE = 5
local STATE_DONECHOOSE = 6
local STATE_CLOSING = 7
local STATE_WAIT = 8
local STATE_EXEC = 9

local _dialog = {
	options = {},
	rate = 1,
	time = 0,
	duration = 1,
	text = "Hello There",
	printed = "",
	open = 0,
	nodeiter = nil,
}

module("dialog")

Init()

surface.CreateFont( "DialogFont", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 25,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

local DialogFont = "DialogFont"
local State = nil
local DT = nil
local Done = nil
local Time = nil

local function CalcTextRect( str )

	surface.SetFont( DialogFont )

	local bw, bh = 0, 0
	local sh = 0
	local lines = string.Explode( "\n", str or _dialog.text )
	for _, line in pairs(lines) do
		local w,h = surface.GetTextSize( line )
		bw = math.max(w, bw)
		sh = math.max(h, sh)
		bh = bh + h
	end

	_dialog.textw = bw
	_dialog.texth = bh
	_dialog.singleh = sh

end

function Start( text, delay )

	_dialog.text = text
	_dialog.printed = ""
	State( STATE_OPENING, delay )

	CalcTextRect()


end

local function DrawTextArea( width, height )

	if _dialog.open == 0 then return end

	local open = math.sin( _dialog.open * math.pi / 2 )
	open = math.sqrt(open)

	local s = State()

	local w = width * open
	local h = height * open

	local x = ScrW() / 2
	local y = ScrH() - h

	surface.SetDrawColor( 0,0,0,190 )
	surface.DrawRect( x - w/2, y - h/2, w, h )

	local left = x - _dialog.textw / 2
	local top = y - _dialog.texth / 2

	surface.SetTextColor( 255, 255, 255, 255 * open )
	surface.SetFont( DialogFont )

	local lines = string.Explode( "\n", _dialog.printed )
	for k, line in pairs(lines) do
		surface.SetTextPos( left, top + _dialog.singleh * (k-1) )
		surface.DrawText( line )
	end

end

--STATE MACHINE

local edges = {
	[STATE_OPENING] = function(d) _ = Done() and State( STATE_OPENED ) end,
	[STATE_OPENED] = function(d) _ = Done() and State( STATE_PRINTING ) end,
	[STATE_PRINTING] = function(d) _ = Done() and State( string.len(d.text) == 0 and STATE_DONEPRINTING or STATE_PRINTING ) end,
	[STATE_CHOOSE] = function(d) _ = Done() and State( STATE_DONECHOOSE ) end,
	[STATE_DONECHOOSE] = function(d) State( STATE_CLOSING ) end,
	[STATE_CLOSING] = function(d) _ = Done() and State( STATE_IDLE ) end,
	[STATE_WAIT] = function(d) _ = Done() and State( d.nextstate ) end,
	[STATE_EXEC] = function(d) end,
}

local inits = {
	[STATE_OPENING] = function(d) d.rate = 2 d.printed = "" end,
	[STATE_OPENED] = function(d) d.rate = 12 d.nodeiter() end,
	[STATE_PRINTING] = function(d)
		d.rate = 60
		d.printed = d.printed .. d.text[1]
		d.text = d.text:sub(2,-1)
	end,
	[STATE_DONEPRINTING] = function(d)
		d.nodeiter()
	end,
	[STATE_CHOOSE] = function(d) d.rate = 1 end,
	[STATE_CLOSING] = function(d) d.rate = 2 d.printed = "" end,
	[STATE_EXEC] = function(d)
		print("ENTRY EXEC")

		if d.exec == "shake_screen" then
			util.ScreenShake( LocalPlayer():GetPos(), 8, 8, 1, 5000 )
			surface.PlaySound( "garrysmod/save_load4.wav" )
		elseif string.find(d.exec, "grant_") == 1 then
			local mid = tonumber(string.Split(d.exec, "_")[2])
			missions.TryStartMission(mid)
		elseif string.find(d.exec, "finish_") == 1 then
			local mid = tonumber(string.Split(d.exec, "_")[2])
			missions.TryFinishMission(mid)
		end

		d.nodeiter()
	end,
}

local ticks = {
	[STATE_OPENING] = function(d) d.open = DT() end,
	[STATE_CLOSING] = function(d) d.open = 1 - DT() end,
}

local function nop() end

Time = function( newtime )

	if newtime then _dialog.time = newtime end
	return _dialog.time

end

State = function( newstate, wait )

	if not newstate then return _dialog.state end

	if wait then
		_dialog.state = STATE_WAIT
		_dialog.rate = 1/wait
		_dialog.nextstate =  newstate
		return _dialog
	end

	Time( 0 )
	_dialog.state = newstate
	_ = ( inits[ newstate ] or nop )( _dialog )

	return _dialog

end

DT = function( advance )

	if advance then _dialog.time = _dialog.time + advance * _dialog.rate end
	return math.Clamp( _dialog.time / _dialog.duration, 0, 1 )

end

Done = function() return DT() >= 1 end

local function Update( deltatime )

	DT( deltatime )

	_ = ( ticks[ State() ] or nop )( _dialog )
	_ = ( edges[ State() ] or nop )( _dialog )

end

function PaintAll()

	Update( FrameTime() )

	DrawTextArea( 600, 200 )

end

local function ScriptCallback(cmd, data)

	print(tostring(cmd) .. " " .. tostring(data))
	if cmd == CMD_JUMP then
		State( STATE_OPENING, 2 )
		return data
	end
	if cmd == CMD_LAYOUT then
		CalcTextRect( data )
	end
	if cmd == CMD_PRINT then
		_dialog.text = data
		State( STATE_PRINTING )
	end
	if cmd == CMD_NEWLINE then
		_dialog.text = "\n"
		State( STATE_PRINTING )
	end
	if cmd == CMD_WAIT then
		State( STATE_PRINTING, .2 )
	end
	if cmd == CMD_OPTIONLIST then
		State( STATE_CLOSING, 2 )
	end
	if cmd == CMD_EXIT then
		State( STATE_CLOSING, 2 )
	end
	if cmd == CMD_EXEC then
		_dialog.exec = data
		State( STATE_EXEC, .1 )
	end

end

net.Receive( "dialog_dispatch", function( len, ply )

	local script = util.NetworkIDToString( net.ReadUInt( 16 ) )
	local camera = nil

	if net.ReadBit() then camera = net.ReadEntity() end
	if script == nil then script = "<no script>" end

	CalcTextRect("")
	_dialog.text = ""
	State( STATE_OPENING )

	_dialog.nodeiter = EnterGraph( script, ScriptCallback )
	--nodeiter()
	--nodeiter()

	--Start( , 0 )

end )

/*
Start(
[[thanks jeeves did you hear me ask for the sparknotes link
this is why your search engine is dead jeeves,
this is why google dropped don't be evil as their motto
your insistence upon triviasplaining]]
, 5)
*/