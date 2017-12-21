include("shared.lua")

ENT.ScreenHeight = 0
ENT.ScreenWidth = ENT.ScreenHeight * 1.80
ENT.ScreenScale = .1

ENT.CommentOffset = Vector(-200, 12, 0)

ENT.BusWidth = 70
ENT.BusLength = 248

surface.CreateFont( "SteamCommentFont", {
	font      = "Adine Kirnberg",
	size      = 80,
	weight    = 700,
	antialias = true
})

surface.CreateFont( "SteamAuthorFont", {
	font      = "Adine Kirnberg",
	size      = 65,
	weight    = 700,
	antialias = true
})


function ENT:Initialize()
	self:RefreshWorkshopInfo()
end

function ENT:RefreshWorkshopInfo()
	if self:GetWorkshopID() == 0 then return end

	-- First download information about the given workshopid
	steamworks.FileInfo( self:GetWorkshopID(), function( result ) 
		if !self then return end

		self.Title = result.title

		-- Try to get the comments for this workshop
		workshop.FetchComments(result, function(comments) 
			if !self then return end

			local function parseComment(cmt) return markup.Parse(
				"<font=SteamCommentFont>" .. cmt.message .. "</font>\n " 
				.."<font=SteamAuthorFont> -" .. cmt.author .. "</font>",
				1700) 
			end

			-- Select 2 random comments for the side and back of the bus
			self.Description = parseComment(table.Random(comments))
			self.BackBusComment = parseComment(table.Random(comments))
		end )

		-- Also try grabbing the thumbnail material
		workshop.FetchThumbnail(result, function(material)
			if !self then return end

			self.ThumbnailMat = material
		end )
	end )
end

function ENT:DrawSideInfo()
	local ang = self.Entity:GetAngles()
	local pos = self.Entity:GetPos() - ang:Forward() * self.BusWidth
	pos = pos + ang:Up() * 80
	
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
			surface.DrawTexturedRect(-256, -70, 456, 456)
		end

		if self.Title then
			draw.SimpleText( self.Title, "SmallHeaderFont", 220, 0, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
		draw.SimpleText( self:GetDestination(), "SelectMapFont", 220, 60, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( "WSID: " .. self:GetWorkshopID(), "SmallHeaderFont", 220, 130, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

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
	self:DrawModel()

	self:DrawSideInfo()
	self:DrawRearInfo()

end

function ENT:Think()

end

function ENT:OnRemove()

end

