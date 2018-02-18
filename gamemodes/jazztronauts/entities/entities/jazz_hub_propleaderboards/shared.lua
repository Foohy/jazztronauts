-- Board that displays currently selected maps
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Model			= "models/Combine_Helicopter/helicopter_bomb01.mdl"

ENT.ScreenHeight = 640
ENT.ScreenWidth = ENT.ScreenHeight * 1.80
ENT.ScreenScale = .2

if SERVER then
	util.AddNetworkString("jazz_vomiter_leaderboards")
end

function ENT:Initialize()
	self:SetModel( self.Model )
	self:DrawShadow( false )

	if CLIENT then
		self:SetRenderBoundsWS( Vector(0,0,0), Vector(self.ScreenWidth, self.ScreenWidth, self.ScreenHeight))
	end

	if SERVER then 
		self:UpdateLeaderboards()
	end
end

function ENT:UpdateLeaderboards()
	local counts = progress.GetPropCounts()
	local all = {}

	for _, v in pairs(counts) do
		all[v.steamid] = (all[v.steamid] or 0) + v.total
	end

	local num = math.min(table.Count(all), 3)
	net.Start("jazz_vomiter_leaderboards")
		net.WriteUInt(num, 8)

		for k, v in SortedPairsByValue(all, true) do
			net.WriteString(k)
			net.WriteUInt(v, 32)
			
			num = num - 1 
			if num == 0 then break end
		end
	net.Broadcast()
end

if SERVER then return end
JazzPlayerLeaderboard = JazzPlayerLeaderboard or {}
surface.CreateFont( "SmallHeaderFont", {
	font      = "Impact",
	size      = 48,
	weight    = 700,
	antialias = true
})

surface.CreateFont( "SelectMapFont", {
	font      = "Impact",
	size      = 100,
	weight    = 700,
	antialias = true
})

function ENT:drawPlayer(name, count, offset)
	draw.SimpleText(name, "SmallHeaderFont", 0, offset, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText(count, "SmallHeaderFont", self.ScreenWidth, offset, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
end

function ENT:DrawTranslucent()
	local ang = self:GetAngles()
	local pos = self:GetPos() + ang:Right() * 0.01
	
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )


	render.DrawLine( pos, pos + 8 * ang:Forward(), Color( 255, 0, 0 ), true )
	render.DrawLine( pos, pos + 8 * -ang:Right(), Color( 0, 255, 0 ), true )
	render.DrawLine( pos, pos + 8 * ang:Up(), Color( 0, 0, 255 ), true )

	pos = pos - ang:Forward() * self.ScreenScale * self.ScreenWidth / 2
	pos = pos - ang:Right() * self.ScreenScale * self.ScreenHeight / 2

	cam.Start3D2D(pos, ang, self.ScreenScale)
		local offset = 0
		for k, v in SortedPairsByMemberValue(JazzPlayerLeaderboard, "count", true) do

			self:drawPlayer(v.name, v.count, offset * 40)
			offset = offset + 1
		end
	cam.End3D2D()

	self:DrawModel()
end

net.Receive("jazz_vomiter_leaderboards", function(len, ply)
    local num = net.ReadUInt(8)
	JazzPlayerLeaderboard = {}
	for i=1, num do
		local plyID = net.ReadString()
		local num = net.ReadUInt(32)

		JazzPlayerLeaderboard[plyID] = {}
		JazzPlayerLeaderboard[plyID].count = num
		steamworks.RequestPlayerInfo(plyID, function(name)
			print(plyID, name)
			if JazzPlayerLeaderboard[plyID] then
				JazzPlayerLeaderboard[plyID].name = name
			end
		end )
	end
end )