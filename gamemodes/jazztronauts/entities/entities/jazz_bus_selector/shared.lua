-- Bus selector
AddCSLuaFile()

if SERVER then

	util.AddNetworkString( "jazz_selector_button" )

end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Model	= "models/props_combine/combine_interface001.mdl"

ENT.ScreenHeight = 640
ENT.ScreenWidth = ENT.ScreenHeight * 1.80
ENT.ScreenScale = .2

local buttons = {
	{"1","2","3",""},
	{"4","5","6",""},
	{"7","8","9",""},
	{"0","RANDOM","",""}
}

function ENT:Initialize()

	self:SetModel( self.Model )
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	self:SetAngles( Angle(0,180,0) )

	if CLIENT then

		self.canvas = worldcanvas.New()
		self.canvas:SetDrawFunc( self.DrawCanvas, self )

		self.canvas2 = worldcanvas.New()
		self.canvas2:SetDrawFunc( self.DrawNumbers, self )

	end

end

function ENT:SetupDataTables()

	self:NetworkVar("String", 0, "Readout")

end

function ENT:TryCallBus( id )
	if id == nil then return false end

	return mapcontrol.RollMapID(id)
end

function ENT:AppendNumber( num )

	local readout = self:GetReadout()
	readout = readout .. tostring( num )

	if #readout == 9 then
		self:SetReadout( tostring(num) )
		return
	end

	if #readout == 8 then

		self:SetReadout(readout)
		local success = self:TryCallBus( tonumber( readout ) )
		if success then return true end

		self:SetReadout( "" )

		return false

	else

		self:SetReadout(readout)

	end

end

function ENT:ButtonPressed( button )

	if self.locked then return end

	self:EmitSound( "buttons/blip1.wav" )

	local num = tonumber( button )

	if num then

		local success = self:AppendNumber( num )
		if success == true then

			self:EmitSound( "buttons/button6.wav" )

		elseif success == false then

			self:EmitSound( "buttons/button10.wav" )

		end

	end

	if button == "RANDOM" then

		self.locked = true

		self:SetReadout("")

		self:EmitSound( "jazztronauts/ticka_tacka_1.wav" )

		local num = mapcontrol.GetRandomMapID()
		local str = tostring( num )

		for i=1, 8 do

			timer.Simple( .5 + i / 8, function()

				self:AppendNumber( tonumber( str[i] ) )
				if i == 8 then self.locked = false end

			end )

		end

	end

end

if SERVER then

	net.Receive( "jazz_selector_button", function()

		local ent = net.ReadEntity()
		local button = net.ReadUInt(4) + 1

		button = buttons[ math.ceil( button / 4 ) ][ 1 + (button-1) % 4 ]

		ent:ButtonPressed( button )

	end )

end

if SERVER then return end

surface.CreateFont( "JazzMapSelectKey", {
	font	  = "KG Shake it Off Chunky",
	size	  = 200,
	weight	= 500,
	antialias = true
})

surface.CreateFont( "JazzMapSelectMain", {
	font	  = "KG Shake it Off Chunky",
	size	  = 200,
	weight	= 700,
	antialias = true
})

function ENT:Draw()

	self:DrawModel()

end

function ENT:DrawNumbers( canvas )

	local w,h = canvas:GetResolution()

	surface.SetDrawColor( Color(50,0,40,230) )
	surface.DrawRect( 0,0,w,h )

	local str = self:GetReadout()

	local x = w - 30
	for i=#str, 1, -1 do

		local hue = 240 + math.sin(i * 0.5 + CurTime()) * 30
		local col = HSVToColor(hue, 0.85, 1)

		draw.DrawText( tostring( str[i] ), "JazzMapSelectMain", x, 0, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		x = x - 62

	end


end


function ENT:ButtonPressed( i, j )

	net.Start( "jazz_selector_button" )
	net.WriteEntity( self.Entity )
	net.WriteUInt( (j + ( ( i - 1 ) *4)) - 1, 4 )
	net.SendToServer()

end

local cursorMat = Material("materials/ui/cursor.png", "alphatest")
function ENT:DrawControls( canvas )

	local x,y,focus,dist = canvas:GetMousePos()
	local w,h = canvas:GetResolution()

	if dist > 150 then return end

	local pressed = false
	if LocalPlayer():KeyDown( IN_USE ) then
		if not self.was_use_down then
			self.was_use_down = true
			pressed = true
		end
	else
		self.was_use_down = false
	end

	if LocalPlayer():KeyDown( IN_ATTACK ) then
		if not self.was_attack_down then
			self.was_attack_down = true
			pressed = true
		end
	else
		self.was_attack_down = false
	end

	local btw = math.ceil( w / 3 )
	local bth = h / 4

	local btx = 0
	local bty = 0
	for i=1, 4 do

		for j=1, 4 do

			--Shut up you're not my mom
			if i==4 and j==1 then btw = w/2 end

			local se = btx < x and x < btx + btw and bty < y and y < bty + bth
			local btn = buttons[i][j]

			if btn ~= "" then

				surface.SetDrawColor( Color(0,0,se and 255 or 100) )
				surface.DrawRect( btx, bty, btw, bth )

				draw.SimpleText( buttons[i][j], "JazzMapSelectKey", btx + btw/2, bty + bth/2, Color(200,200,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				if pressed and se then

					self:ButtonPressed( i, j )

				end

			end

			btx = math.floor( btx + btw )

		end

		bty = bty + bth
		btx = 0

	end

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(cursorMat)
	surface.DrawTexturedRect( x, y, 20, 30 )

end


function ENT:DrawTranslucent()

	local pos = self.Entity:GetPos() + Vector(0,0,50)
	local angles = self.Entity:GetAngles()

	angles:RotateAroundAxis( angles:Right(), 47 )
	pos = pos + angles:Up() * - 12
	pos = pos + angles:Forward() * 1.5

	self:DrawModel()

	self.canvas:EnableDebug( false )
	self.canvas:SetPos( pos )
	self.canvas:SetAngles( angles )
	self.canvas:SetSize( 40, 30 )
	self.canvas:SetResolution( 800, 600 )
	self.canvas:SetDrawFunc( self.DrawControls, self, self.canvas )
	self.canvas:Draw()

	angles = self.Entity:GetAngles()
	pos = pos + Vector(0,0,15) - angles:Forward() * 12

	self.canvas2:EnableDebug( false )
	self.canvas2:SetPos( pos )
	self.canvas2:SetAngles( angles )
	self.canvas2:SetSize( 40, 10 )
	self.canvas2:SetResolution( 500, 150 )
	self.canvas2:SetDrawFunc( self.DrawNumbers, self, self.canvas2 )
	self.canvas2:Draw()


end
