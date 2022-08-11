AddCSLuaFile()

--if true then return end

module("whiteboard", package.seeall)

NET_WHITEBOARD_CMD = "whiteboard_cmd"

MSG_MOVE_TO = 0	   --CL: ask server to move cursor to location, SV: send to all clients
MSG_LINE_TO = 1	   --CL: ask server to draw a line, SV: send a line to all clients
MSG_FLUSH_STATE = 2   --CL: ask server to dump everything that's been drawn so far, SV: packet of stuff
MSG_CLEAR = 3		 --CL: ask server to clear whiteboard, SV: clear whiteboard on all clients

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

local function getColor(i)
	return HSVToColor(i * 45, 1, 1)
end

if CLIENT then

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

	--[[local marker_mat = CreateMaterial("WhiteboardMarker" .. FrameNumber(), "UnLitGeneric", {
		["$basetexture"] = "ui/marker",
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$model"] = 0,
		["$additive"] = 0,
	})]]

	local marker_mat = Material( "materials/ui/marker.png", "mips smooth")

	function DrawMarker( x, y, size, r )

		local r = r or 45
		local c = math.cos( -r / 57.3 )
		local s = math.sin( -r / 57.3 )
		local ox = 122 * size
		local oy = 0
		surface.SetMaterial( marker_mat )
		surface.DrawTexturedRectRotated(
			x + ox * c + oy * -s,
			y + ox * s + oy * c,
			256*size, 64*size, r )

	end

	function meta:GetIRT()

		local rt = irt.New("whiteboard_" .. self.index, ScrW(), ScrH())
			:EnableDepth(false,false)
			:EnableFullscreen(true)
			:EnablePointSample(true)

		return rt

	end

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
				surface.SetDrawColor( getColor(cmd.uid + 1))
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
					local colx = getColor(lc.uid + 1)
					local col = Color(colx.r,colx.g,colx.b,255* (1-dt) )
					draw.SimpleText( v:Nick(), "Trebuchet18", x,y,col )
					surface.SetDrawColor( col )
					local out = math.sin( dt * math.pi / 2 )
					DrawMarker( x + out * 30, y - out * 30, .35, 45 - out * 10 )
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

function meta:GetRecipients( uid )


	local t = {}
	for _, p in pairs( player.GetAll() ) do
		local id = p:EntIndex()
		local c = self:GetCursor( id )
		if id == uid then continue end
		if c.flushing then continue end
		table.insert( t, p )
	end

	return t

end

function meta:SV_SendMoveTo( x, y, uid )
	self:AppendMoveTo( x, y, uid )
	self:NetBeginCmd( MSG_MOVE_TO )
	net.WriteUInt( uid, 6 )
	net.WriteUInt( x, coordinate_bits[1] )
	net.WriteUInt( y, coordinate_bits[2] )
	net.Send( self:GetRecipients( uid ) )
end

function meta:SV_SendLineTo( x, y, uid )
	self:AppendLineTo( x, y, uid )
	self:NetBeginCmd( MSG_LINE_TO )
	net.WriteUInt( uid, 6 )
	net.WriteUInt( x, coordinate_bits[1] )
	net.WriteUInt( y, coordinate_bits[2] )
	net.Send( self:GetRecipients( uid ) )
end

function meta:MoveTo( x,y,uid )

	if SERVER then self:SV_SendMoveTo( x, y, uid ) end
	if CLIENT then self:CL_SendMoveTo( x, y ) end

end

function meta:LineTo( x,y,uid )

	if SERVER then self:SV_SendLineTo( x, y, uid ) end
	if CLIENT then self:CL_SendLineTo( x, y ) end

end

function meta:CL_RecvBurst()

	local first = net.ReadBit() == 1
	local num = net.ReadUInt( 7 )
	local lu = -1

	if first then self:Clear() end

	for i=1, num do

		local c = net.ReadBit() == 1 and MSG_LINE_TO or MSG_MOVE_TO
		local uid = net.ReadUInt( 6 )
		if c == MSG_MOVE_TO then self:AppendMoveTo( net.ReadUInt(coordinate_bits[1]), net.ReadUInt(coordinate_bits[2]), uid ) end
		if c == MSG_LINE_TO then self:AppendLineTo( net.ReadUInt(coordinate_bits[1]), net.ReadUInt(coordinate_bits[2]), uid ) end
		lu = uid

	end

	if lu ~= -1 then
		local c = self:GetCursor( lu )
	end

end

function meta:SV_SendBurst( uid )

	if self:GetCursor( uid ).flushing then return end

	local t = task.New( function()

		if #self.commands == 0 then return end

		self:GetCursor( uid ).flushing = true

		local i = 1
		local first = false

		while true do
			task.Sleep(.05)

			local rem = math.max( #self.commands - i, 0 )
			local snd = math.min( rem, 127 )
			if rem == 0 then break end
			local player_send = player.GetAll()[uid]
			if not IsValid( player_send ) then break end

			self:NetBeginCmd( MSG_FLUSH_STATE )
			net.WriteBit( first and 0 or 1 )
			net.WriteUInt( snd, 7 )

			first = true

			while snd > 0 do

				local cmd = self.commands[i]
				net.WriteBit( cmd.c == MSG_LINE_TO and 1 or 0 )
				net.WriteUInt( cmd.uid, 6 )
				if cmd.c == MSG_MOVE_TO then net.WriteUInt(cmd.x, coordinate_bits[1]) net.WriteUInt(cmd.y, coordinate_bits[2]) end
				if cmd.c == MSG_LINE_TO then net.WriteUInt(cmd.x, coordinate_bits[1]) net.WriteUInt(cmd.y, coordinate_bits[2]) end

				i = i + 1
				snd = snd - 1

			end

			net.Send( player_send )
		end

		self:GetCursor( uid ).flushing = false

	end )

end

function meta:RequestFlush( uid )

	if SERVER then
		self:SV_SendBurst( uid )
	else
		self:NetBeginCmd( MSG_FLUSH_STATE )
		net.SendToServer()
	end

end

function meta:NetPlayerInput( ply )

	local cmd = net.ReadUInt( 4 )
	local uid = ply:EntIndex()
	if cmd == MSG_FLUSH_STATE then self:RequestFlush( uid ) end
	if cmd == MSG_MOVE_TO then self:MoveTo( net.ReadUInt(coordinate_bits[1]), net.ReadUInt(coordinate_bits[2]), uid ) end
	if cmd == MSG_LINE_TO then self:LineTo( net.ReadUInt(coordinate_bits[1]), net.ReadUInt(coordinate_bits[2]), uid ) end

end

function meta:NetPacket()

	local cmd = net.ReadUInt(4)
	if cmd == MSG_FLUSH_STATE then self:CL_RecvBurst() return end

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

function GetVCoordSpace()
	return virtual_coord_space
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
	--timer.Simple( .2, function() gui.EnableScreenClicker(true) end )

	--timer.Simple( .1, function() Get(0):RequestFlush() end )

	concommand.Add( "flush_whiteboard", function()

		Get(0):RequestFlush()

	end )

	local function LerpFactor( f )
		return 1 - math.exp( FrameTime() * -f )
	end

	local function TimeLerp( v, target, f )
		return v + (target - v) * LerpFactor( f )
	end

	local cmx = 0
	local cmy = 0

	local drawing = false
	local alpha = 0
	hook.Add("HUDPaint", "whiteboard_test", function()

		if true then return end

		local vs_rect = virtual_coord_space
		local sc_rect = Rect("screen")
		local wb_rect = Rect(0,0,ScrW()*.8, ScrH()*.8 ):Dock( sc_rect, DOCK_CENTER )
		local rx,ry = gui.MousePos()
		local target_alpha = 0

		cmx = TimeLerp( cmx, rx, 12 )
		cmy = TimeLerp( cmy, ry, 12 )

		if not drawing then
			--cmx = rx
			--cmy = ry
			target_alpha = 0.2
		else
			target_alpha = 1
		end

		alpha = TimeLerp( alpha, target_alpha, 15 )

		local x = cmx
		local y = cmy

		local function cursor(x,y)
			--surface.SetDrawColor(255,255,255,80)

			local colx = getColor(LocalPlayer():EntIndex() + 1)
			surface.SetDrawColor( Color(colx.r,colx.g,colx.b,255*alpha) )
			local out = math.sin( (1-alpha) * math.pi / 2 )

			--if wb_rect:ContainsPoint( rx, ry ) or drawing then
				local mx = x + out * 30
				local my = y - out * 30 + math.sin( CurTime() * 5 ) * 12 * (1-alpha)
				DrawMarker( mx, my, .35, 45 - out * 10 + math.cos( CurTime() * 5 ) * 8 * (1-alpha) )
				--surface.DrawLine( x, y, mx, my )
				surface.DrawRect( Rect(x,y,5,5):Move(-2,-2):Unpack() )
			--end
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