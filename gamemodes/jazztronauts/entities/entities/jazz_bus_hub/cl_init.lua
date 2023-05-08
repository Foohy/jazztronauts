include("shared.lua")

ENT.ScreenHeight = 0
ENT.ScreenWidth = ENT.ScreenHeight * 1.80
ENT.ScreenScale = .1

ENT.CommentOffset = Vector(-160, 16, 0)

ENT.BusWidth = 71
ENT.BusLength = 280

surface.CreateFont( "SteamCommentFont", {
	font	  = "KG Shake it Off Chunky",
	size	  = 70,
	weight	= 700,
	antialias = true
})

surface.CreateFont( "SteamAuthorFont", {
	font	  = "Dancing Script",
	size	  = 65,
	weight	= 700,
	antialias = true
})

surface.CreateFont( "JazzDestinationFont", {
	font	  = "Dancing Script",
	size	  = 53,
	weight	= 700,
	antialias = true
})

local destRTWidth = 256
local destRTHeight = 256
function ENT:Initialize()
	self.IRT = irt.New("jazz_bus_destination", destRTWidth, destRTHeight )
	self.DestMat = self.IRT:GetUnlitMaterial()
	self:UpdateDestinationMaterial()
	self:RefreshWorkshopInfo()
end


function ENT:StartLaunchEffects()
	print("Starting clientside launch")
	self.IsLaunching = true
	self.StartLaunchTime = CurTime()
	LocalPlayer().LaunchingBus = self
end

-- Shared version of table.Random
function ENT:TableSharedRandom(tbl, seedOffset )
	local seed = self:GetCreationTime() + (seedOffset or 0)
	local rand = util.SharedRandom("busRand", 1, table.Count(tbl), seed)
	rand = math.Round(rand)
	local i = 1
	for k, v in pairs(tbl) do
		if (i == rand) then return v, k end
		i = i + 1
	end
end

function ENT:RefreshWorkshopInfo()
	if self:GetWorkshopID() == "" then return end

	-- First download information about the given workshopid
	steamworks.FileInfo( self:GetWorkshopID(), function( result )
		if !IsValid(self) or !result then return end

		self.Title = result.title

		-- Try to get the comments for this workshop
		workshop.FetchComments(result, function(comments)
			if !self then return end
			
			local function parseComment(cmt, width)
				if not cmt then return end

				return markup.Parse(
					"<font=SteamCommentFont>" .. cmt.message .. "</font>\n "
					.."<font=SteamAuthorFont> -" .. cmt.author .. "</font>",
				width)
			end

			-- Select 2 random comments for the side and back of the bus
			self.Description = comments and parseComment(self:TableSharedRandom(comments), 1400)
			self.BackBusComment = comments and parseComment(self:TableSharedRandom(comments, 1), 1400)
		end )

		-- Also try grabbing the thumbnail material
		workshop.FetchThumbnail(result, function(material)
			if !self then return end
			self.ThumbnailMat = material
		end )
	end )
end

local function ProgressString(col, total)
	if col == total then
		return jazzloc.Localize("jazz.shards.all",total)
	end

	return jazzloc.Localize("jazz.shards.partial",col,total)
end

-- HOLY FUCK MAKE THESE INHERIT ALREADY
function JazzRenderDestinationMaterial(self, dest)
	self.IRT:Render(function()
		cam.Start2D()
			surface.SetDrawColor(HSVToColor(RealTime() * 20 % 360, .7, 0.4))
			surface.DrawRect(0, 0, destRTWidth, destRTHeight)
			surface.SetFont("JazzDestinationFont")
			local w, h = surface.GetTextSize(dest)
			local mwidth = destRTWidth
			local mat = Matrix()
			if w > mwidth then
				mat:Scale(Vector(mwidth/w, 1, 1))

			else
				mat:Translate(Vector(mwidth/2 - w/2, 0, 0))
			end

			cam.PushModelMatrix(mat)
				draw.SimpleText(dest, "JazzDestinationFont", 0, h * -0.2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			cam.PopModelMatrix()
		cam.End2D()
	end)
end

function ENT:UpdateDestinationMaterial()
	JazzRenderDestinationMaterial(self, self:GetDestination())
end

function ENT:DrawSideInfo()
	local ang = self.Entity:GetAngles()
	local pos = self.Entity:GetPos() - ang:Forward() * self.BusWidth
	pos = pos + ang:Up() * 76

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	//render.DrawLine( pos, pos + 8 * ang:Forward(), Color( 255, 0, 0 ), true )
	//render.DrawLine( pos, pos + 8 * -ang:Right(), Color( 0, 255, 0 ), true )
	//render.DrawLine( pos, pos + 8 * ang:Up(), Color( 0, 0, 255 ), true )

	pos = pos - ang:Forward() * self.ScreenScale * self.ScreenWidth / 2
	pos = pos - ang:Right() * self.ScreenScale * self.ScreenHeight / 2

	cam.Start3D2D(pos, ang, self.ScreenScale)
		if self.ThumbnailMat then
			surface.SetMaterial(self.ThumbnailMat)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(-156, 0, 356, 356)
		end

		if self.Title then
			draw.SimpleText( self.Title, "SmallHeaderFont", 220, 160, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end
		draw.SimpleText( self:GetDestination(), "SelectMapFont", 220, 0, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

		if self:GetMapProgress() > 0 then
			local coll, total = self:FromProgressMask(self:GetMapProgress())
			local str = ProgressString(coll, total)
			local col = coll == total and Color(243, 235, 0, 255) or color_white
			draw.SimpleText(str, "SmallHeaderFont", 220, 195, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end

		if self.Description then
			local w = self.Description:GetWidth()
			local h = self.Description:GetHeight()
			local scaleOff = self.CommentOffset / self.ScreenScale
			self.Description:Draw(w/2 + scaleOff.x, scaleOff.y, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

	cam.End3D2D()
end

function ENT:DrawRearInfo()
	local ang = self.Entity:GetAngles()
	local pos = self.Entity:GetPos() - ang:Right() * self.BusLength
	pos = pos + ang:Up() * 80

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 180 )


	//render.DrawLine( pos, pos + 8 * ang:Forward(), Color( 255, 0, 0 ), true )
	//render.DrawLine( pos, pos + 8 * -ang:Right(), Color( 0, 255, 0 ), true )
	//render.DrawLine( pos, pos + 8 * ang:Up(), Color( 0, 0, 255 ), true )

	cam.Start3D2D(pos, ang, self.ScreenScale)
		if self.BackBusComment then
			local w = self.BackBusComment:GetWidth()
			local h = self.BackBusComment:GetHeight()
			local scaleOff = self.CommentOffset / self.ScreenScale
			self.BackBusComment:Draw(0, 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

	cam.End3D2D()
end

function ENT:Draw()
	self:UpdateDestinationMaterial()
	render.MaterialOverrideByIndex(2, self.DestMat)
	self:DrawModel()
	render.MaterialOverrideByIndex(1, nil)

	self:DrawSideInfo()
	self:DrawRearInfo()
end

function ENT:Think()
	if self.IsLaunching then
		local factor = (CurTime() -  self.StartLaunchTime) * 15
		util.ScreenShake(LocalPlayer():GetPos(), factor, 5, 0.01, 100)
	end
end

function ENT:OnRemove()
	if self.IsLaunching then

		LocalPlayer():SetDSP(25)
		LocalPlayer():ScreenFade(SCREENFADE.STAYOUT, Color(0, 0, 0, 255), 0, 5)
		LocalPlayer():EmitSound("ambient/explosions/exp4.wav", 100, 100)
	end
end

hook.Add( "GetMotionBlurValues", "BusLaunchBlur", function( horiz, vert, fwd, rot)
	local bus = LocalPlayer().LaunchingBus
	if !IsValid(bus) then return end

	fwd = fwd + (CurTime() - bus.StartLaunchTime) * 0.3
	return horiz, vert, fwd, rot
end )

hook.Add( "CalcView", "BusLaunchView", function(ply, pos, angles, fov )
	local bus = LocalPlayer().LaunchingBus
	if !IsValid(bus) then return end

	local view = {}

	view.origin = pos
	view.angles = angles
	view.fov = fov + (CurTime() - bus.StartLaunchTime) * 20

	return view
end )

local fadewhite = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

hook.Add( "RenderScreenspaceEffects", "BusLaunchScreenspaceEffects", function()
	local bus = LocalPlayer().LaunchingBus
	if !IsValid(bus) then return end

	local factor = math.max((CurTime() - bus.StartLaunchTime) * 0.2 - 0.2, 0)
	fadewhite["$pp_colour_brightness"] = factor
	fadewhite["$pp_colour_colour"] = 1 + factor
	DrawColorModify(fadewhite)
end )

net.Receive("jazz_bus_launcheffects", function(len, ply)
	local busEnt = net.ReadEntity()
	if IsValid(busEnt) then
		busEnt:StartLaunchEffects()
	end

	--transitionOut(2.5)
end )