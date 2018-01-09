
module( "propfeed", package.seeall )

surface.CreateFont( "CountFont", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 25,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

local feed = {}

local nextPropModel = 0
local function AddPropToFeed( model, skin, ply )

	local camera = Camera( Vector(-200,0,0), Angle(0,0,0), 8 )
	local scene = Scene( camera )
	local ent = scene:AddModel( "prop_feed_model" .. nextPropModel, model)
	nextPropModel = nextPropModel + 1

	ent:SetupBones()
	ent:SetSkin( skin )
	local min, max = ent:GetModelBounds()

	scene:SetBoxLight( 1, 255,255,255 )
	scene:SetBoxLight( 2, 0,0,255 )

	local zsize = max.z - min.z
	local ysize = max.y - min.y
	local dist = 0 --(zsize / 2) / math.sin( (90 * DEG_2_RAD) / 2 )
	local tan = math.tan( (8 * DEG_2_RAD) / 2 )
	local expand = math.sqrt(2)

	for i=1, 3 do
		dist = math.max( max[i] - min[i] , dist )
	end

	--camera.pos.z = (min.z + max.z) / 2
	camera.pos.x = ( ( -dist / 2 ) / tan ) * expand

	print(dist)

	table.insert( feed,
	{
		elapsed = 0,
		center = (min + max) / 2,
		ent = ent,
		camera = camera,
		scene = scene,
		time = CurTime(),
		duration = 5,
		model = model,
		skin = skin,
		count = { [ply] = 1 },
	})

end

local function FindEntry( model, skin )

	for k,v in pairs( feed ) do
		if v.model == model and v.skin == skin then
			return v
		end
	end

end

net.Receive("propcollect", function()
	local model = net.ReadString()
	local skin = net.ReadUInt( 16 )
	local ply = net.ReadEntity()

	print("OK!!!!!!!")

	local exist = FindEntry( model, skin )
	if exist then
		exist.time = CurTime()
		exist.count[ply] = (exist.count[ply] or 0) + 1
		return
	end

	AddPropToFeed(model, skin, ply)
end)

function Paint()

	local y = 0
	local display = Rect("screen")

	for i = #feed, 1, -1 do

		local item = feed[i]
		local elapsed = item.elapsed
		local dt = (CurTime() - item.time) / item.duration
		if dt < 1 then

			local scale = math.min((1-dt) * 4, 1)
			local scale2 = math.min((1-dt) * 32, 1)
			local rect = Rect(0,0,64,64):ScreenScale()

			scale = scale * scale

			rect.h = rect.h * scale
			rect:Dock( display, DOCK_LEFT + DOCK_TOP )
			rect.y = rect.y + y
			rect:Inset( 10 )

			surface.SetDrawColor( 200,200,200,220 )
			surface.DrawRect( rect:Unpack() )

			local sub = Rect( rect )
			sub:Inset( 4 )

			item.ent:Identity()
			item.ent:Rotate( Angle(elapsed * 80,elapsed * 120,elapsed * 30) )
			item.ent:Translate( item.center * -1 )
			item.scene:Render( sub )

			local texty = (rect.y + rect.h / 2) - 10 * table.Count( item.count )
			for k,v in pairs( item.count ) do

				local nick = k:Nick()
				surface.SetFont( "CountFont" )
				surface.SetTextColor(0,0,0,255 * scale)
				surface.SetTextPos( rect.x + rect.w + 9, texty - 1 )
				surface.DrawText( nick .. ": " .. tostring( v ) .. "x" )

				surface.SetTextColor(255,255,255,255 * scale)
				surface.SetTextPos( rect.x + rect.w + 10, texty )
				surface.DrawText( nick .. ": " .. tostring( v ) .. "x" )
				texty = texty + 20

			end

			y = y + rect.h + ScreenScale(10)

			item.elapsed = item.elapsed + FrameTime()

		else
			table.remove( feed, i )
		end

	end

end