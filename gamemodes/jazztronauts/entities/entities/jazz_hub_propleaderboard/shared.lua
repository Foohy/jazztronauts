-- Board that displays currently selected maps
AddCSLuaFile()

include("jazzboards.lua")

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Editable = true
ENT.Model = "models/Combine_Helicopter/helicopter_bomb01.mdl"

ENT.ScreenHeight = 640
ENT.ScreenWidth = ENT.ScreenHeight * 1.30
ENT.ScreenScale = .1

ENT.DefaultLeaderboard = 1

function ENT:Initialize()
	self:SetModel( self.Model )
	self:DrawShadow( false )

	if CLIENT then
		//self:SetRenderBoundsWS( Vector(0,0,0), Vector(self.ScreenWidth, self.ScreenWidth, self.ScreenHeight))
		self:RebuildPanel()
		self.LastLeaderboardID = self:GetLeaderboardID()

		-- Hook into when leaderboards change
		hook.Add("JazzLeaderboardsUpdated", self, function(self, id)
			if self:GetLeaderboardID() == id then
				self:RebuildPanel()
			end
		end)
	end

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetLeaderboardID(self.DefaultLeaderboard or 1)
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "LeaderboardID", { KeyName = "leaderboardid", Edit = { type = "Int", min = 1, max = 4 } })
end

function ENT:KeyValue(key, value)
	if key == "leaderboardid" then
		self.DefaultLeaderboard = tonumber(value) or 1
	end
end

if SERVER then return end

surface.CreateFont( "JazzLeaderboardEntryFont", {
	font	  = "Impact",
	size	  = 60,
	weight	= 700,
	antialias = true
})

surface.CreateFont( "JazzLeaderboardTitleFont", {
	font	  = "Impact",
	size	  = 100,
	weight	= 700,
	antialias = true
})

function ENT:AddPlayerPanel(id, name, count)
	local panel = vgui.Create("DPanel")
	panel:SetPaintBackground(false)

	local avatar = vgui.Create("AvatarImage", panel)
	avatar:SetSize(128, 128)
	avatar:SetSteamID(id)
	avatar:Dock(LEFT)

	local nameLabel = vgui.Create("DLabel", panel)
	nameLabel:SetText(name)
	nameLabel:SetFont("JazzLeaderboardEntryFont")
	nameLabel:DockMargin(10, 0, 0, 0)
	nameLabel:Dock(FILL)

	local countLabel = vgui.Create("DLabel", panel)
	countLabel:SetText(count .. " props")
	countLabel:SetFont("JazzLeaderboardEntryFont")
	countLabel:SetContentAlignment(6)
	countLabel:Dock(FILL)

	panel:InvalidateLayout()
	panel:SizeToChildren(true, true)

	return panel
end

function ENT:RebuildPanel()
	if IsValid(self.Panel) then
		self.Panel:Remove()
	end

	local id = self:GetLeaderboardID()
	if not jazzboards.Leaderboards[id] then
		return
	end

	local lst = vgui.Create("DListLayout")
	lst:SetSize(self.ScreenWidth, 200)
	lst:SetPaintedManually(true)

	local titleLabel = vgui.Create("DLabel", lst)
	titleLabel:SetText(jazzboards.Boards[id].title)
	titleLabel:SetFont("JazzLeaderboardTitleFont")
	titleLabel:SetContentAlignment(8)
	titleLabel:DockMargin(0, 0, 0, 80.0)

	for k, v in ipairs(jazzboards.Leaderboards[id]) do
		lst:Add(self:AddPlayerPanel(v.steamid, v.name, v.count))
	end

	lst:InvalidateLayout(true)
	lst:SizeToChildren(true, true)

	self.Panel = lst
end

function ENT:OnRemove()
	if IsValid(self.Panel) then
		self.Panel:Remove()
	end
end

function ENT:Think()
	-- Regenerate if our ID changed
	-- Thanks for still not having a hook on the client for this, gmod
	if self.LastLeaderboardID != self:GetLeaderboardID() then
		self.LastLeaderboardID = self:GetLeaderboardID()

		self:RebuildPanel()
	end
end

function ENT:Draw()
	if not IsValid(self.Panel) then return end

	local ang = self:GetAngles()
	local pos = self:GetPos() + ang:Right() * 0.01

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	pos = pos - ang:Forward() * self.ScreenScale * self.ScreenWidth / 2
	pos = pos - ang:Right() * self.ScreenScale * self.ScreenHeight / 2

	cam.Start3D2D(pos, ang, self.ScreenScale)
		self.Panel:PaintManual()
	cam.End3D2D()

	--self:DrawModel()
end