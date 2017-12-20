print("DIALOG CL_INIT")

local ScrW = ScrW
local ScrH = ScrH
local draw = draw
local surface = surface
local math = math
local string = string
local FrameTime = FrameTime
local print = print
local pairs = pairs

local STATE_IDLE = 0
local STATE_OPENING = 1
local STATE_OPENED = 2
local STATE_PRINTING = 3
local STATE_CHOOSE = 4
local STATE_DONECHOOSE = 5
local STATE_CLOSING = 6

local _dialog = {
	options = {},
	rate = 1,
	time = 0,
	duration = 1,
	text = "Hello There",
	printed = "",
	caret = 1,
	open = 0,
	state = STATE_OPENING,
}

module("dialog")

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

local function CalcTextRect()

	surface.SetFont( DialogFont )

	local bw, bh = 0, 0
	local sh = 0
	local lines = string.Explode( "\n", _dialog.text )
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

function Start( text, delay, options, character )

	_dialog.text = text
	State( STATE_OPENING, -(delay or 0) )

	CalcTextRect()


end

local function DrawTextArea( width, height )

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
	[STATE_PRINTING] = function(d) _ = Done() and State( string.len(d.text) == string.len(d.printed) and STATE_CHOOSE or STATE_PRINTING ) end,
	[STATE_CHOOSE] = function(d) _ = Done() and State( STATE_DONECHOOSE ) end,
	[STATE_DONECHOOSE] = function(d) State( STATE_CLOSING ) end,
	[STATE_CLOSING] = function(d) _ = Done() and State( STATE_IDLE ) end,
}

local inits = {
	[STATE_OPENING] = function(d) d.rate = 2 d.caret = 1 end,
	[STATE_OPENED] = function(d) d.rate = 12 end,
	[STATE_PRINTING] = function(d)
		d.rate = 60
		d.printed = d.printed .. d.text:sub(d.caret, d.caret)
		d.caret = d.caret + 1
	end,
	[STATE_CHOOSE] = function(d) d.rate = 1 end,
	[STATE_CLOSING] = function(d) d.rate = 2 d.printed = "" end,
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

State = function( newstate, newtime )

	if not newstate then return _dialog.state end

	Time( newtime or 0 )
	_dialog.state = newstate
	_ = ( inits[ newstate ] or nop )( _dialog )

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

Start(
[[thanks jeeves did you hear me ask for the sparknotes link
this is why your search engine is dead jeeves,
this is why google dropped don't be evil as their motto
your insistence upon triviasplaining]]
, 5)