local chatmenu = {}

ENT.ScreenWidth = 500
ENT.ScreenHeight = 340

-- Base values multiplied with distance
chatmenu.ScreenScale = 0.05
chatmenu.verticalOffset = 30

-- Center offset ofthe radial menu in 3d2d screen space
ENT.RadialOffset = 0

-- How far away until the chat is unusable
ENT.ChatFadeDistance = 150

-- Chat menu color scheme
chatmenu.textColor = Color(159, 100, 128)
chatmenu.selectColor = Color(238, 19, 122)
chatmenu.selectBGColor = Color(215, 195, 151)

-- Size of the virtual screen
chatmenu.scaleW = 150
chatmenu.scaleH = 60

-- Size of the virtual cursor
chatmenu.cursorW = 20
chatmenu.cursorH = 30

chatmenu.flipChat = false
chatmenu.showperc = 1.0

function ENT:GetMenuPosAng(ply)
	local pos = self:GetPos()
	local playpos = ply:EyePos()

	local dist = pos:Distance(playpos)
	self.ScreenScale = chatmenu.ScreenScale * (dist / 30)

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Forward(), -90)
	ang:RotateAroundAxis(ang:Right(), -90)

	local offset
	if chatmenu.flipChat then
		offset = (chatmenu.verticalOffset + ((dist-50) / 6 )) * 2.3
	else
		offset = chatmenu.verticalOffset - ((dist-50) / 2 )
	end
	offset = ang:Up() * offset
	if not chatmenu.flipChat then
		local fwdAng = (pos - playpos):Angle()
		fwdAng.p = 0
		fwdAng.r = 0
		offset = offset + fwdAng:Forward() * -10
	end
	pos = pos + offset

	ang = (pos - playpos):Angle()
	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)

	return pos, ang, dist
end

function ENT:IsWithinScreen(x, y)
	local w = self.ScreenWidth * self.ScreenScale
	local h = self.ScreenHeight * self.ScreenScale

	return x > -w/2 && x < w/2 && y > -h/2 && y < h/2
end

function ENT:GetSelectedOption(ply, choices)
	local pos, ang, dist = self:GetMenuPosAng(ply)

	-- If physically too far away before offset, nothing is selected
	if dist > self.ChatFadeDistance then
		return nil, nil
	end

	-- Calculate the world position of the center of the dialog
	local dialogCenter = pos +
		self:GetAngles():Up() * self.ScreenScale * -self.RadialOffset
	local eye = ply:GetEyeTrace()

	-- Intersect with dialog plane so we can see which option they're looking at
	local hitpos = util.IntersectRayWithPlane(eye.StartPos, eye.Normal, dialogCenter, ang:Up())
	local hitoption = nil
	local localPos = nil
	if hitpos then

		-- Convert into local coordinates relative to the center of the options screen
		local ratio = chatmenu.scaleW / chatmenu.scaleH
		localPos = WorldToLocal(hitpos, Angle(), dialogCenter, ang)
		local lpos = Vector(localPos.x, localPos.y * ratio, localPos.z)

		-- Do a test to make sure we're within the screen
		//surface.DrawTexturedRectRotated(0, 0, self.ScreenWidth, self.ScreenHeight, 180)
		if not self:IsWithinScreen(lpos.x, lpos.y) then
			return hitoption, localPos
		end

		-- Grab the angle, this is basically a hidden radial menu
		local ang = -math.deg(math.atan2(lpos.y, lpos.x)) + 90
		ang = math.NormalizeAngle(ang) + 180
		hitoption = ((math.Round((#choices - 1) * ang / 360) + 1) % #choices) + 1
	end

	return hitoption, localPos
end

function ENT:SetChoiceIcon(choices, index, icon)
	if not choices or not choices[index] then return end
	choices[index].icon = icon
end

-- Everything from here on is just client rendering stuff
if SERVER then

	-- Adds a new choice (serverside)
	function chatmenu.AddChoice(choicetable, text, func)
		return table.insert(choicetable, {
			text = text,
			func = func,
		})
	end

	return chatmenu
end

surface.CreateFont( "JazzDialogAsk", {
	font	  = "KG Shake it Off Chunky",
	size	  = 32,
	weight	= 500,
	antialias = true
})
surface.CreateFont( "JazzDialogOption", {
	font	  = "KG Shake it Off Chunky",
	size	  = 40,
	weight	= 500,
	antialias = true
})


local bubbleMat = Material("materials/ui/chatbubble.png", "alphatest")
local cursorMat = Material("materials/ui/cursor.png", "alphatest")

-- Render a specific line of text to a texture
function chatmenu.RenderText(text, font, idx)
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

	local rt = irt.New("jazz_storeopt_" .. idx, w, h)
	rt:SetAlphaBits( 8 )
	rt:EnableDepth( false, false )
	rt:Render( function()

		local oldW, oldH = ScrW(), ScrH()
		render.Clear( 0,0,0,0 )
		render.SetViewPort( 0, 0, w, h )
		render.OverrideAlphaWriteEnable( true, true )
		cam.Start2D()
			surface.SetTextPos(0, 0)
			surface.SetFont(font)
			surface.SetTextColor(255, 255, 255)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawText(text)

		cam.End2D()
		render.OverrideAlphaWriteEnable( false )
		render.SetViewPort( 0, 0, oldW, oldH )

	end )

	return rt, w, h
end

-- Render the 'selected' text background to a texture
function chatmenu.RenderSelectBG(font, thick, round)
	surface.SetFont( font )
	local w, h = surface.GetTextSize( "average option" )

	local rt = irt.New("jazz_storeopt_select", w, h)
	rt:SetAlphaBits( 8 )
	rt:EnableDepth( false, false )
	rt:Render( function()

		local oldW, oldH = ScrW(), ScrH()
		render.Clear( 0,0,0,0 )
		render.SetViewPort( 0, 0, w, h )
		render.OverrideAlphaWriteEnable( true, true )
		cam.Start2D()
			draw.RoundedBox(round, 0, 0, w, h, chatmenu.selectColor)
			draw.RoundedBox(round, thick, thick, w - thick *2, h - thick * 2, chatmenu.selectBGColor)
		cam.End2D()
		render.OverrideAlphaWriteEnable( false )
		render.SetViewPort( 0, 0, oldW, oldH )

	end )

	return rt, w, h
end

-- Adds a new choice
function chatmenu.AddChoice(choicetable, text, func)
	-- Render the text to a texture
	-- cam.PushModelMatrix doesn't seem to want to work in a 3D2D render context, so thanks for that
	local textRT, w, h = chatmenu.RenderText(text, "JazzDialogOption", #choicetable + 1)

	return table.insert(choicetable, {
		text = text,
		func = func,
		texture = textRT,
		material = textRT:GetUnlitMaterial(true,false,true,true),
		width = w,
		height = h
	})
end

ENT.SelectBG = chatmenu.RenderSelectBG("JazzDialogOption", 3, 5)
ENT.SelectBGMat = ENT.SelectBG:GetUnlitMaterial(true,false,true,true)

function ENT:DrawChoice(choice, centerX, centerY, highlighted, ang, scale, scaleBump)

	ang = math.NormalizeAngle(ang)
	scale = scale or 1
	scaleBump = scaleBump or 1
	local rot = -ang + 180
	if ang > 0 then
		-- Slightly rotate a bit more to not be as sideways
		rot = math.NormalizeAngle(rot + 90) * 1.3 + 90
	end

	local pX = math.cos(math.rad(ang)) * chatmenu.scaleW * scaleBump + centerX
	local pY = math.sin(math.rad(ang)) * chatmenu.scaleH * scaleBump + centerY

	-- Render the select border, if highlighted
	local pad = 20
	local wpad = choice.icon and choice.height * 1.5 or 20
	local woff = (-wpad / 2 + pad/2)
	if highlighted then
		surface.SetDrawColor(color_white)
		surface.SetMaterial(self.SelectBGMat)
		surface.DrawTexturedRectRotated(pX + woff,
			pY,
			choice.width * scale + wpad,
			choice.height * scale + pad,
			rot + 90)
	end

	-- Render the text itself
	surface.SetDrawColor(highlighted and chatmenu.selectColor or chatmenu.textColor)
	surface.SetMaterial(choice.material)
	surface.DrawTexturedRectRotated(pX, pY, choice.width * scale, choice.height * scale, rot + 90)

	-- Render the optional icon too
	if choice.icon then
		local move = choice.width * scale / 2 + pad
		local iX = pX + math.cos(math.rad(-rot + 90)) * move
		local iY = pY + math.sin(math.rad(-rot + 90)) * move

		surface.SetMaterial(choice.icon)
		surface.DrawTexturedRectRotated(iX, //woff - choice.width * scale / 2
			iY,
			choice.height * scale,
			choice.height * scale,
			rot + 90)
	end
end

function ENT:DrawDialogEntry(choices, showperc)
	local pos, ang = self:GetMenuPosAng(LocalPlayer())
	local hitoption, localPos = self:GetSelectedOption(LocalPlayer(), choices)

	-- Draw the chat bubble background + welcome text
	-- Draw this backing panel with depth write enabled to prevent artifacts
	local sizeperc = math.EaseInOut(math.Clamp(showperc * 2, 0, 1), 0.25, 0.35)

	cam.IgnoreZ(true)
	render.OverrideDepthEnable(true, true)
	cam.Start3D2D(pos + ang:Right() * (1-sizeperc) * 10, ang, self.ScreenScale * sizeperc)
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(bubbleMat)

		if chatmenu.flipChat then
			surface.DrawTexturedRectRotated(0, 0, self.ScreenWidth, self.ScreenHeight, 180)
		else
			surface.DrawTexturedRect(-self.ScreenWidth * 0.5, -220, self.ScreenWidth, self.ScreenHeight)
		end

	cam.End3D2D()
	render.OverrideDepthEnable(false)

	-- Draw the contents of the panel (with depth write disabled)
	local fadeperc = math.Clamp(showperc * 2 - 1, 0, 1)
	cam.Start3D2D(pos + ang:Up()*0.1, ang, self.ScreenScale)
		surface.SetAlphaMultiplier(fadeperc)
		draw.DrawText(choices.WelcomeText, "JazzDialogAsk", 0, -130, Color(0,0,0), TEXT_ALIGN_CENTER)

		-- Draw the choice options + highlight nearby one
		for i=1, #choices do
			local drawCenter = #choices == 1
			local ang = (i * 1.0 / 3) * 360 - 90
			if drawCenter then ang = -85 end
			self:DrawChoice(choices[i], 0, self.RadialOffset, i == hitoption, ang, drawCenter and 2.5, drawCenter and 0.5)
		end

		-- Draw the virtual mouse cursor for where we're currently pointing
		if hitoption and localPos then
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(cursorMat)
			surface.DrawTexturedRect(-chatmenu.cursorW/2 + localPos.x / self.ScreenScale,
			self.RadialOffset - chatmenu.cursorH/2 + localPos.y / -self.ScreenScale,
			chatmenu.cursorW, chatmenu.cursorH)
		end
		surface.SetAlphaMultiplier(1)
	cam.End3D2D()
	cam.IgnoreZ(false)
end


return chatmenu
