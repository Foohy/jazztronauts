local MatFlare = Material("effects/blueflare1")

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