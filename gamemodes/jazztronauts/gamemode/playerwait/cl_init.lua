include("playerwait.lua")

surface.CreateFont( "JazzWaitingCountdown", {
	font	  = "KG Shake it Off Chunky",
	size	  = ScreenScale(32),
	weight	= 700,
	antialias = true
})

surface.CreateFont( "JazzWaitingCountdownPlayer", {
	font	  = "KG Shake it Off Chunky",
	size	  = ScreenScale(20),
	weight	= 700,
	antialias = true
})


hook.Add("JazzMapStarted", "JazzWaitingFinish", function()
	gui.EnableScreenClicker(false)
end )

local function LerpFactor( f )
	return 1 - math.exp( FrameTime() * -f )
end

local function TimeLerp( v, target, f )
	return v + (target - v) * LerpFactor( f )
end

local cmx = 0
local cmy = 0

hook.Add("InitPostEntity", "JazzFlushWhiteboardJoin", function()
	whiteboard.Get(0):RequestFlush()
end)

local drawing = false
local function DrawWhiteboard()

	local vs_rect = whiteboard.GetVCoordSpace()
	local sc_rect = Rect("screen")
	local wb_rect = Rect(0,0,ScrW()*.8, ScrH()*.8 ):Dock( sc_rect, DOCK_CENTER )
	local rx,ry = gui.MousePos()

	cmx = TimeLerp( cmx, rx, 12 )
	cmy = TimeLerp( cmy, ry, 12 )

	if not drawing then
		cmx = rx
		cmy = ry
	end

	local x = cmx
	local y = cmy

	local function cursor(x,y)
		surface.SetDrawColor(255,255,255,80)
		surface.DrawRect( Rect(x,y,5,5):Move(-2,-2):Unpack() )
	end

	if input.IsMouseDown( MOUSE_LEFT ) then
		if wb_rect:ContainsPoint( x, y ) or drawing then

			local vx, vy = wb_rect:Remap( vs_rect, x,y, true )
			vx = math.floor( vx + .5 )
			vy = math.floor( vy + .5 )

			if not drawing then
				drawing = true
				whiteboard.Get(0):MoveTo( vx, vy )
			else
				whiteboard.Get(0):LineTo( vx, vy )
			end
		end
	else
		drawing = false
	end

	whiteboard.Get(0):Draw( wb_rect )
	local mx, my = wb_rect:Remap(vs_rect,x,y,true)
	cursor( vs_rect:Remap( wb_rect, mx, my, true ) )

end

local function DrawStatusOverlay()
	draw.SimpleText("WAITING FOR PLAYERS", "JazzWaitingCountdown", ScrW() / 2, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	local w, h = surface.GetTextSize("W")
	local offset = h
	local num = 0
	for k, v in pairs(GAMEMODE:GetConnectingPlayers()) do
		local w, h = surface.GetTextSize(v)
		draw.SimpleText(v, "JazzWaitingCountdownPlayer", ScrW() / 2, 0 + h * num + offset, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		num = num + 1
	end

	local endtime = GAMEMODE:GetEndWaitTime()
	if endtime < math.huge then
		local time = math.max(0, math.Round(endtime - CurTime() + 1))
		draw.SimpleText(time, "JazzWaitingCountdownPlayer", ScrW() / 2, offset, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
end

local wasWaiting = false
hook.Add("HUDPaint", "JazzWaitingForPlayersVisuals", function()

	if not GAMEMODE:IsWaitingForPlayers() then return end
	if not wasWaiting then
		gui.EnableScreenClicker(true)
		wasWaiting = true
	end

	DrawWhiteboard()
	DrawStatusOverlay()
end)
