AddCSLuaFile()

--if true then return end

module("whiteboard", package.seeall)

NET_WHITEBOARD_CMD = "whiteboard_cmd"

MSG_MOVE_TO = 0       --CL: ask server to move cursor to location, SV: send to all clients
MSG_LINE_TO = 1       --CL: ask server to draw a line, SV: send a line to all clients
MSG_FLUSH_STATE = 2   --CL: ask server to dump everything that's been drawn so far
MSG_CLEAR = 3         --CL: ask server to clear whiteboard, SV: clear whiteboard on all clients

--MoveTo: [X. Y. userid]
--LineTo: [X, Y, userid]
--FlushState: []

if SERVER then
	util.AddNetworkString(NET_WHITEBOARD_CMD)
end

local coordinate_bits = { 11, 10 }
local virtual_coord_space = Rect(0,0,2^coordinate_bits[1]-1,2^coordinate_bits[2]-1)
local whiteboards = {}
local meta = {}
meta.__index = meta


function meta:NetBeginCmd( cmd )
	net.Start( NET_WHITEBOARD_CMD )
	net.WriteUInt( self.index, 2 )
	net.WriteUInt( cmd, 4 )
end

function meta:Init()

	self.cursors = {}

	for i = -1, 64 do
		self.cursors[i] = {x=0,y=0}
	end

	self:Clear()
	return self

end

function meta:Clear()

	self.commands = {}

	self:ResetCursors()

	if SERVER then
		self:NetBeginCmd( MSG_CLEAR )
		net.Broadcast()
	else
		self:GetIRT():Clear(0,0,0,0)
	end

	return self

end

function meta:ResetCursors()

	for i = -1, 64 do
		self.cursors[i].x = 0
		self.cursors[i].y = 0
	end

end

function meta:GetCursor( uid )

	return self.cursors[ uid ]

end

function meta:GetLastCmd( uid )

	local c = self:GetCursor( uid )
	if not c then return nil end

	return c.lastcmd

end

local colors = {
	Color(255,100,100),
	Color(255,255,100),
	Color(100,255,100),
	Color(100,255,255),
	Color(255,100,255),
	Color(100,100,255),
}


if CLIENT then

	function meta:GetIRT()

		local rt = irt.New("whiteboard_" .. self.index, ScrW(), ScrH())
			:EnableDepth(false,false)
			:EnableFullscreen(true)
			:EnablePointSample(true)

		return rt

	end

	local whiteboard_mat = CreateMaterial("WhiteboardMat" .. FrameNumber(), "UnLitGeneric", {
		["$basetexture"] = "concrete/concretefloor001a",
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$model"] = 0,
		["$additive"] = 1,
	})

	local brush_mat = CreateMaterial("WhiteboardBrushMat" .. FrameNumber(), "UnLitGeneric", {
		["$basetexture"] = "effects/flashlight/soft",
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$model"] = 0,
		["$additive"] = 1,
	})

	function meta:Draw( rect )

		local rt = self:GetIRT()

		surface.SetDrawColor(0,0,0,200)
		surface.DrawRect( Rect(rect):Inset(-20):Unpack() )

		surface.SetDrawColor(100,150,200,50)
		surface.DrawRect( rect:Unpack() )
		
		render.PushRenderTarget(rt:GetTarget())

		surface.SetDrawColor(200,200,200,200)
		draw.NoTexture()

		surface.SetMaterial( brush_mat )

		for _, cmd in pairs( self.commands ) do

			local cursor = self:GetCursor( cmd.uid )
			if cmd.c == MSG_MOVE_TO then
				cursor.x, cursor.y = virtual_coord_space:Remap( rect, cmd.x, cmd.y )
			elseif cmd.c == MSG_LINE_TO then
				local lx, ly = cursor.x, cursor.y
				cursor.x, cursor.y = virtual_coord_space:Remap( rect, cmd.x, cmd.y )
				surface.SetDrawColor( colors[ cmd.uid + 1 ] )
				--surface.DrawLine( lx, ly, cursor.x, cursor.y )
				local dx = (cursor.x - lx)
				local dy = (cursor.y - ly)
				local d = dx*dx + dy*dy
				local rd = math.sqrt(d)

				for i=0, math.ceil( rd ) do
					local f = i / rd
					surface.DrawTexturedRectRotated( lx + dx * f, ly + dy * f, 4, 4, math.random()*360 )
				end

				--surface.DrawTexturedRectRotated( (lx+cursor.x)/2, (ly+cursor.y)/2, math.sqrt(d)+1, 4, -math.atan2( ly-cursor.y, lx-cursor.x ) * 57.3 )
				--surface.DrawTexturedRectRotated( cursor.x, cursor.y, 50,50, math.random() * math.pi * 2 )
			end

		end

		self.commands = {}

		render.PopRenderTarget()

		whiteboard_mat:SetTexture("$basetexture", rt:GetTarget())

		surface.SetDrawColor(255,255,255,255)
		render.SetMaterial(whiteboard_mat)
		render.DrawScreenQuad()

		for _,v in pairs( player.GetAll() ) do

			if v == LocalPlayer() then continue end

			local lc = self:GetLastCmd( v:EntIndex() )
			if not lc then continue end

			local dt = CurTime() - lc.t
			if dt < 1 then
				if lc.c == MSG_MOVE_TO or lc.c == MSG_LINE_TO then
					local x,y = virtual_coord_space:Remap( rect, lc.x, lc.y )
					local col = Color(255,255,255,255* (1-dt) )
					draw.SimpleText( v:Nick(), "Trebuchet18", x,y,col )
				end
			end

		end

	end

end

function meta:AppendMoveTo( x, y, uid )
	local lc = self:GetCursor( uid ).lastcmd
	if lc and lc.c == MSG_MOVE_TO and lc.x == x and lc.y == y then return end
	table.insert( self.commands, {c=MSG_MOVE_TO, x=x, y=y, uid = uid or -1, t = CurTime()} )
	self:GetCursor( uid ).lastcmd = self.commands[#self.commands]
end

function meta:AppendLineTo( x, y, uid )
	local lc = self:GetCursor( uid ).lastcmd
	if lc and lc.c == MSG_LINE_TO and lc.x == x and lc.y == y then return end
	table.insert( self.commands, {c=MSG_LINE_TO, x=x, y=y, uid = uid or -1, t = CurTime()} )
	self:GetCursor( uid ).lastcmd = self.commands[#self.commands]
end

function meta:CL_SendMoveTo( x, y )
	self:AppendMoveTo( x, y, LocalPlayer():EntIndex() )
	self:NetBeginCmd( MSG_MOVE_TO )
	net.WriteUInt( x, coordinate_bits[1] )
	net.WriteUInt( y, coordinate_bits[2] )
	net.SendToServer()
end

function meta:CL_SendLineTo( x, y )
	self:AppendLineTo( x, y, LocalPlayer():EntIndex() )
	self:NetBeginCmd( MSG_LINE_TO )
	net.WriteUInt( x, coordinate_bits[1] )
	net.WriteUInt( y, coordinate_bits[2] )
	net.SendToServer()
end

function meta:SV_SendMoveTo( x, y, uid )
	self:AppendMoveTo( x, y, uid )
	self:NetBeginCmd( MSG_MOVE_TO )
	net.WriteUInt( uid, 6 )
	net.WriteUInt( x, coordinate_bits[1] )
	net.WriteUInt( y, coordinate_bits[2] )
	net.SendOmit( player.GetAll()[uid] )
end

function meta:SV_SendLineTo( x, y, uid )
	self:AppendLineTo( x, y, uid )
	self:NetBeginCmd( MSG_LINE_TO )
	net.WriteUInt( uid, 6 )
	net.WriteUInt( x, coordinate_bits[1] )
	net.WriteUInt( y, coordinate_bits[2] )
	net.SendOmit( player.GetAll()[uid] )
end

function meta:MoveTo( x,y,uid )

	if SERVER then self:SV_SendMoveTo( x, y, uid ) end
	if CLIENT then self:CL_SendMoveTo( x, y ) end

end

function meta:LineTo( x,y,uid )

	if SERVER then self:SV_SendLineTo( x, y, uid ) end
	if CLIENT then self:CL_SendLineTo( x, y ) end

end

function meta:RequestFlush()

	if SERVER then

	else
		self:NetBeginCmd( MSG_FLUSH_STATE )
		net.SendToServer()
	end

end

function meta:NetPlayerInput( ply )

	local cmd = net.ReadUInt( 4 )
	local uid = ply:EntIndex()
	if cmd == MSG_FLUSH_STATE then self:RequestFlush() end
	if cmd == MSG_MOVE_TO then self:MoveTo( net.ReadUInt(coordinate_bits[1]), net.ReadUInt(coordinate_bits[2]), uid ) end
	if cmd == MSG_LINE_TO then self:LineTo( net.ReadUInt(coordinate_bits[1]), net.ReadUInt(coordinate_bits[2]), uid ) end

end

function meta:NetPacket()

	local cmd = net.ReadUInt(4)
	local uid = net.ReadUInt(6)
	if cmd == MSG_MOVE_TO then self:AppendMoveTo( net.ReadUInt(coordinate_bits[1]), net.ReadUInt(coordinate_bits[2]), uid ) end
	if cmd == MSG_LINE_TO then self:AppendLineTo( net.ReadUInt(coordinate_bits[1]), net.ReadUInt(coordinate_bits[2]), uid ) end
	if cmd == MSG_CLEAR then self:Clear() end

end

function meta:NetUpdate( ply )

	if SERVER then 
		self:NetPlayerInput( ply )
	else
		self:NetPacket()
	end

end

for i=0,3 do
	whiteboards[i] = setmetatable({ index = i }, meta):Init()
end

function Get( index )

	assert( type( index ) == "number", "index must be a number" )
	assert( index >= 0 and index < 4, "index out of range" )

	return whiteboards[ index ]

end

net.Receive(NET_WHITEBOARD_CMD, function( _, ply ) Get( net.ReadUInt(2) ):NetUpdate( ply ) end )

if SERVER then

	concommand.Add( "clear_whiteboards", function()

		for i=0, 3 do
			Get(i):Clear()
		end

	end )

end

if CLIENT then
	gui.EnableScreenClicker(false)

	local function LerpFactor( f )
		return 1 - math.exp( FrameTime() * -f )
	end

	local function TimeLerp( v, target, f )
		return v + (target - v) * LerpFactor( f )
	end

	local cmx = 0
	local cmy = 0

	local drawing = false
	hook.Add("HUDPaint", "whiteboard_test", function()

		if true then return end

		local vs_rect = virtual_coord_space
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
					Get(0):MoveTo( vx, vy )
				else
					Get(0):LineTo( vx, vy )
				end
			end
		else
			drawing = false
		end

		Get(0):Draw( wb_rect )
		local mx, my = wb_rect:Remap(vs_rect,x,y,true)
		cursor( vs_rect:Remap( wb_rect, mx, my, true ) )

	end)

end