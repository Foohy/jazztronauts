-- Board that displays currently selected maps
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Model			= "models/Combine_Helicopter/helicopter_bomb01.mdl"

ENT.ScreenHeight = 640
ENT.ScreenWidth = ENT.ScreenHeight * 1.80
ENT.ScreenScale = .2

function ENT:Initialize()
	self:SetModel( self.Model )
	self:DrawShadow( false )

	if CLIENT then
		self:SetRenderBoundsWS( Vector(0,0,0), Vector(self.ScreenWidth, self.ScreenWidth, self.ScreenHeight))
	end
end

if SERVER then return end

surface.CreateFont( "SmallHeaderFont", {
	font	  = "KG Shake it Off Chunky",
	size	  = 48,
	weight	= 700,
	antialias = true
})

surface.CreateFont( "SelectMapFont", {
	font	  = "KG Shake it Off Chunky",
	size	  = 130,
	weight	= 700,
	antialias = true
})

function ENT:DrawTranslucent()
	local ang = self.Entity:GetAngles()
	local pos = self.Entity:GetPos() + ang:Right() * 0.01

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )


	render.DrawLine( pos, pos + 8 * ang:Forward(), Color( 255, 0, 0 ), true )
	render.DrawLine( pos, pos + 8 * -ang:Right(), Color( 0, 255, 0 ), true )
	render.DrawLine( pos, pos + 8 * ang:Up(), Color( 0, 0, 255 ), true )

	pos = pos - ang:Forward() * self.ScreenScale * self.ScreenWidth / 2
	pos = pos - ang:Right() * self.ScreenScale * self.ScreenHeight / 2

	cam.Start3D2D(pos, ang, self.ScreenScale)
		draw.SimpleText( "Selected Map", "SmallHeaderFont", self.ScreenWidth / 2, 40, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( mapcontrol.GetMap() or "UNKNOWN", "SelectMapFont", self.ScreenWidth / 2, 100, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	cam.End3D2D()
end
