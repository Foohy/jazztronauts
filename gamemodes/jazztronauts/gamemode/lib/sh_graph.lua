AddCSLuaFile()

module("graph", package.seeall)

if SERVER then return end

local vertpool = {}
for i=1, 256 do
	vertpool[i] = {x = 0, y = 0}
end

local function drawLine( x1, y1, x2, y2, radius )

	local v = {
		vertpool[1],
		vertpool[2],
		vertpool[3],
		vertpool[4],
	}

	local dx = x2 - x1
	local dy = y2 - y1
	local a = math.atan2(dy, dx) + math.pi / 2
	local s = math.sin(a)
	local c = math.cos(a)

	v[1].x = x1 + c * radius
	v[1].y = y1 + s * radius

	v[2].x = x1 - c * radius
	v[2].y = y1 - s * radius

	v[3].x = x2 - c * radius
	v[3].y = y2 - s * radius

	v[4].x = x2 + c * radius
	v[4].y = y2 + s * radius

	draw.NoTexture()
	surface.DrawPoly( v )

end

local function drawArc( cx, cy, start, stop, radius )

	local segs = 200
	local v = {}
	local span = (stop - start) * DEG_2_RAD
	local angle = start * DEG_2_RAD
	local step = span / (segs-2)
	if span < 0 then
		angle = angle + span
		step = -step
	end
	for i=2, segs do
		local vtx = vertpool[i]
		vtx.x = cx + math.cos(angle) * radius
		vtx.y = cy + math.sin(angle) * radius
		v[i] = vtx
		angle = angle + step
	end

	local vtx = vertpool[1]
	vtx.x = cx
	vtx.y = cy
	v[1] = vtx

	draw.NoTexture()
	surface.DrawPoly( v )

end

local function drawPieElement( cx, cy, start, stop, radius, color )

	local thick = 4
	local width = 2

	surface.SetDrawColor(255,255,255,255)
	drawArc( cx, cy, start, stop, radius + thick )
	drawLine( cx, cy, cx + math.cos( start * DEG_2_RAD ) * (radius + thick), cy + math.sin( start * DEG_2_RAD ) * (radius + thick), width )
	drawLine( cx, cy, cx + math.cos( stop * DEG_2_RAD ) * (radius + thick), cy + math.sin( stop * DEG_2_RAD ) * (radius + thick), width )

	if not color then
		surface.SetDrawColor(255,100,100,255)
	else
		surface.SetDrawColor(color.r, color.g, color.b, 255)
	end
	drawArc( cx, cy, start, stop, radius )


end

local dirs = {
	{1,0},
	{-1,0},
	{0,1},
	{0,-1},
	{-1,-1},
	{1,-1},
	{1,1},
	{-1,1},
	--[[{.707,.707},
	{.707,-.707},
	{-.707,-.707},
	{-.707,.707},]]
}

local function drawTagLine( x1, y1, x2, y2, color )

	if not color then
		surface.SetDrawColor(255,100,100,255)
	else
		surface.SetDrawColor(color.r, color.g, color.b, 255)
	end

	local cx = x1
	local cy = y1

	local vx = x2 - x1
	local vy = y2 - y1

	for i=1, 3 do

		local dir = dirs[1]
		local bdot = -999
		for i=1, #dirs do

			local dot = vx * dirs[i][1] + vy * dirs[i][2]
			if dot > bdot then dir = dirs[i] bdot = dot end

		end

		if dir[1] ~= 0 and dir[2] ~= 0 then
			bdot = math.min( bdot, math.min(math.abs(vx), math.abs(vy)) )
		end

		local nx = cx + dir[1] * bdot
		local ny = cy + dir[2] * bdot

		drawLine( cx, cy, nx, ny, 1 )

		cx = nx
		cy = ny

		vx = x2 - cx
		vy = y2 - cy

	end

end

function drawPieChart( x, y, radius, values, anim, value_column, label_formatter )

	anim = anim or 1

	local total = 0
	for _, v in pairs( values ) do
		local val = v[value_column or 2]
		if not val then ErrorNoHalt("Bad value column " .. (value_column or 2) .. " for table"
			.. tostring(v) .. "\n")
			PrintTable(v)
			return
		end
		total = total + val
	end

	local rotation = 0--CurTime() * 5
	--rotation = math.fmod(rotation, 360)

	radius = radius * anim

	local angle = rotation
	local index = 0
	for k, v in pairs( values ) do

		local hue = index * 45
		local frac = v[value_column or 2] / total
		local step = frac * anim * 360

		local avg = angle + step/2

		local s = math.sin( avg * DEG_2_RAD )
		local c = math.cos( avg * DEG_2_RAD )


		drawPieElement( x, y, angle, angle + step, radius, HSVToColor(hue, .5, .8) )

		local lx = x + c * (radius + 80)
		local ly = y + s * (radius + 80)

		local tx = x + c * (radius)
		local ty = y + s * (radius)

		local left = c < 0

		--ly = ly + (ly - y) / 6

		local label = label_formatter and label_formatter(v) or tostring(v[1])

		if left then
			lx = lx - 2
			draw.SimpleText( label, "DermaDefaultBold", lx, ly, HSVToColor(hue, .2, 1), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			drawTagLine( lx + 10, ly, tx, ty, HSVToColor(hue, .8, 1) )
		else
			lx = lx + 2
			draw.SimpleText( label, "DermaDefaultBold", lx, ly, HSVToColor(hue, .2, 1), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			drawTagLine( lx - 10, ly, tx, ty, HSVToColor(hue, .8, 1) )
		end

		angle = angle + step
		index = index + 1

	end

	surface.SetDrawColor(100,100,100,255)
	drawArc( x, y, rotation, rotation + 360 * anim, 20 )

end