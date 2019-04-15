local MatFlare = Material("effects/blueflare1")

local function lpColor(ent, index, lp, gp)

	local pos = ent:GetPos() + ent:OBBCenter()
	local normal = (pos - gp):GetNormal()
	local dot = normal:Dot(LocalPlayer():EyeAngles():Forward())

	local absDot = dot
	if dot < 0 then absDot = 0 end

	return Color(255 * absDot,100 * absDot,200 * math.Clamp(math.abs(dot) + 0.4,0,1))

end

function JazzRenderGrabEffect(ent, pivot, srcPos)

	local color = nil

	if ent.GetHoldColor then
		local t = ent:GetHoldColor()
		if t:Length() > 0 then
			color = Color(t.x * 255,t.y * 255,t.z * 255)
		end
	end

	if pivot then
		gfx.renderBeam(srcPos, pivot, Color(0,0,0), color or Color(255,100,255), 35)
	end

	if not IsValid(ent) then return end

	local maxs = ent:OBBMaxs()
	local mins = ent:OBBMins()

	--maxs = maxs + Vector(10,10,10)
	--mins = mins - Vector(10,10,10)

	local localPoints = {
		Vector(mins.x, mins.y, maxs.z),
		Vector(maxs.x, mins.y, maxs.z),
		Vector(maxs.x, maxs.y, maxs.z),
		Vector(mins.x, maxs.y, maxs.z),
		Vector(mins.x, mins.y, mins.z),
		Vector(maxs.x, mins.y, mins.z),
		Vector(maxs.x, maxs.y, mins.z),
		Vector(mins.x, maxs.y, mins.z)
	}

	local grabColors = {}
	local grabPoints = {}

	for i=1, #localPoints do
		local gp = ent:LocalToWorld(localPoints[i])
		grabColors[i] = color or lpColor(ent, i, localPoints[i], gp)
		grabPoints[i] = gp
		gfx.renderBeam(srcPos, gp, Color(50,25,50), Color(0,0,0), 6)
	end

	render.SetMaterial( MatFlare )
	for i=1, #localPoints do
		render.DrawSprite( grabPoints[i], 10, 10, grabColors[i] )
	end

	for i=1, 4 do
		local n = i + 1
		local p = i + 4
		local j = i + 5
		if i == 4 then n = 1 end
		if i == 4 then j = 5 end
		gfx.renderBeam(grabPoints[i], grabPoints[n], grabColors[i], grabColors[n], 20)
		gfx.renderBeam(grabPoints[i], grabPoints[p], grabColors[i], grabColors[p], 20)
		gfx.renderBeam(grabPoints[p], grabPoints[j], grabColors[p], grabColors[j], 20)
	end

	if pivot then
		gfx.renderBox(pivot, Vector(-4,-4,-4), Vector(4,4,4), color or Color(255,100,255) )
	end
end
