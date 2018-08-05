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

local function renderVMFx(weapon, vm, pos)

	local brt = weapon.JazzProngs

	if weapon.animPuntPos then
		if not weapon.animPuntPos.done then
			local dt = 1 - math.min( (CurTime() - weapon.animPuntPos.start) * 4, 1.0 )
			brt = brt + dt * 3
		end
	end

	local corePulse = (math.cos(CurTime() * 3)/2 + 0.5) * 10
	local corePulse2 = (math.sin(CurTime() * 3)/2 + 0.5) * 10
	if brt == 0.0 then return end

	render.SetMaterial( MatFlare )
	render.DrawSprite( pos, 50 * brt + corePulse, 50 * brt + corePulse, Color( 255,100,255 ) )
	render.DrawSprite( pos, 50 * brt + corePulse2, 50 * brt + corePulse2, Color( 50,50,255 ) )

	local pins = {
		vm:GetAttachment(2).Pos,
		vm:GetAttachment(3).Pos,
		vm:GetAttachment(4).Pos,
		vm:GetAttachment(5).Pos,
		vm:GetAttachment(6).Pos,
		vm:GetAttachment(7).Pos
	}

	local col = Color( 255*brt,100*brt,255*brt )
	for i=1, #pins do
		local size = 10 * brt + math.cos(CurTime() * 4 + i) * 3
		render.DrawSprite( pins[i], size, size, col )
	end

	gfx.renderBeam(pins[1], pins[2], col, col, 80 - brt * 70)
	gfx.renderBeam(pins[1], pins[3], col, col, 80 - brt * 70)
	gfx.renderBeam(pins[4], pins[6], col, col, 80 - brt * 70)
	gfx.renderBeam(pins[4], pins[5], col, col, 80 - brt * 70)

end

function GM:DrawPhysgunBeam(ply, physgun, enabled, target, physbone, hitpos)

	if ( !enabled ) then
		return false
	end

	local tpos = ply:GetEyeTrace().HitPos
	if IsValid( target ) then
		local mt = target:GetBoneMatrix( physbone )
		local pos, ang
		if physbone > 0 and target:TranslatePhysBoneToBone( physbone ) >= 0 then
			mt = target:GetBoneMatrix( target:TranslatePhysBoneToBone( physbone ) )
		end

		if mt then
			pos = mt:GetTranslation()
			ang = mt:GetAngles()
		else
			pos = target:GetPos()
			ang = target:GetAngles()
		end

		tpos = LocalToWorld( hitpos, Angle( 0, 0, 0 ), pos, ang )
	end


	physgun.JazzProngs = physgun.JazzProngs or 0
	if IsValid(target) then
		physgun.JazzProngs = physgun.JazzProngs + FrameTime() * 4
	else
		physgun.JazzProngs = physgun.JazzProngs - FrameTime() * 4
	end
	physgun.JazzProngs = math.Clamp(physgun.JazzProngs, 0, 1)

	local srcPos = physgun:GetAttachment( 1 ).Pos
	if ply == LocalPlayer() && !ply:ShouldDrawLocalPlayer() then
		srcPos = ply:GetViewModel():GetAttachment( 1 ).Pos
		renderVMFx(physgun, ply:GetViewModel(), srcPos)
	else
		srcPos = physgun:GetAttachment(1).Pos
	end

	//vm:SetPoseParameter( "active", physgun.JazzProngs )
	cam.IgnoreZ(true)
		JazzRenderGrabEffect(target, tpos, srcPos)
	cam.IgnoreZ(false)
	return false
end