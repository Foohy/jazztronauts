include("shared.lua")

ENT.ScreenHeight = 0
ENT.ScreenWidth = ENT.ScreenHeight * 1.80
ENT.ScreenScale = .2

ENT.BusWidth = 70
function ENT:Initialize()
	
end

function ENT:Draw()
	self:DrawModel()
	local ang = self.Entity:GetAngles()
	local pos = self.Entity:GetPos() - ang:Forward() * self.BusWidth
	pos = pos + ang:Up() * 80
	
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )


	render.DrawLine( pos, pos + 8 * ang:Forward(), Color( 255, 0, 0 ), true )
	render.DrawLine( pos, pos + 8 * -ang:Right(), Color( 0, 255, 0 ), true )
	render.DrawLine( pos, pos + 8 * ang:Up(), Color( 0, 0, 255 ), true )

	pos = pos - ang:Forward() * self.ScreenScale * self.ScreenWidth / 2
	pos = pos - ang:Right() * self.ScreenScale * self.ScreenHeight / 2

	cam.Start3D2D(pos, ang, self.ScreenScale)
		draw.SimpleText( "Selected Map", "SmallHeaderFont", 0, 0, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( self:GetDestination() or mapcontrol.GetMap() or "UNKNOWN", "SelectMapFont", 0, 60, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	cam.End3D2D()
end

function ENT:Think()

end

function ENT:OnRemove()

end

