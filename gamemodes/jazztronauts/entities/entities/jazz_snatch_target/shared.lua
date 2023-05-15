
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "jazz_base_playermarker"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.RemoveDelay = 0

local STEAL_BRUSH = "brush"
local STEAL_DISPL = "displacement"

JazzWorldSnatches 				= JazzWorldSnatches or {}
JazzWorldSnatches[STEAL_BRUSH]	= JazzWorldSnatches[STEAL_BRUSH] or {}
JazzWorldSnatches[STEAL_DISPL]	= JazzWorldSnatches[STEAL_DISPL] or {}


local mask = bit.bor( MASK_SOLID, CONTENTS_DETAIL )
mask = bit.bor( mask, CONTENTS_GRATE )
mask = bit.bor( mask, CONTENTS_TRANSLUCENT )

local function createMarkerForBrush(pos, ang, data, type, id)
	local ent = ents.Create("jazz_snatch_target")
	ent:Spawn()
	ent:Activate()
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetBrushID(type == STEAL_BRUSH and id or -id)
	ent.BrushInfo = data

	JazzWorldSnatches[type][id] = ent
end

function snatch.FindOrCreateWorld(pos, dir, dist)
	local map = bsp2.GetCurrent()
	local res = map:Trace({
		pos = pos,
		dir = dir,
		tmin = 0,
		tmax = dist,
		mask = mask,
		ignoreents = true,
		filter = { "func_dustmotes" }
	})

	-- Must have hit something
	if not res or not res.Hit then return nil end

	-- Hit a brush?
	if res.Brush and not snatch.removed_brushes[res.Brush.id] then
		if not IsValid(JazzWorldSnatches[STEAL_BRUSH][res.Brush.id]) then
			createMarkerForBrush(res.HitPos, res.HitNormal:Angle(), res.Brush, STEAL_BRUSH, res.Brush.id)
		end

		return JazzWorldSnatches[STEAL_BRUSH][res.Brush.id]
	end

	-- Hit a displacement?
	if res.Displacement and not snatch.removed_displacements[res.Displacement] then
		if not IsValid(JazzWorldSnatches[STEAL_DISPL][res.Displacement]) then
			createMarkerForBrush(res.HitPos, res.HitNormal:Angle(), map.displacements[res.Displacement], STEAL_DISPL, res.Displacement)
		end

		return JazzWorldSnatches[STEAL_DISPL][res.Displacement]
	end

	return nil
end

function ENT:IsDisplacement()
	return self.GetBrushID && self:GetBrushID() < 0
end

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)
	self:NetworkVar("Int", 1, "BrushID")
end

function ENT:GetBrushBounds()
	local size = 0
	if self:IsDisplacement() then
		return self.BrushInfo.mins, self.BrushInfo.maxs
	else
		return self.BrushInfo.min, self.BrushInfo.max
	end
end

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		--self:SetNoDraw(true)

		self.PlayerList = {}
	end

	function ENT:GetBrushSizeMultiplier()
		local min, max = self:GetBrushBounds()
		local size = max - min

		local length = size.x + size.y + size.z

		return 100.0 / math.pow(length, 1.1)
	end

	function ENT:GetPlayerMultiplier()
		local playerSpeeds = 0
		local numPlayers = 0.0
		for _, v in pairs(self.PlayerList) do
			if not IsValid(v) then continue end
			local wep = v:GetWeapon("weapon_propsnatcher")
			if not IsValid(wep) or v:GetActiveWeapon() != wep then continue end
			local plyStealSpeed = math.pow(1.5, math.pow((wep.WorldStealSpeed or 0), 1.1))

			playerSpeeds = playerSpeeds + plyStealSpeed
			numPlayers = numPlayers + 1.0
		end

		return playerSpeeds
	end

	-- Overwritten
	function ENT:ActivateMarker()
		self.BaseClass.ActivateMarker(self)

		local yoink = snatch.New()
		yoink:SetMode(2)

		if self:IsDisplacement() then
			yoink:StartDisplacement(self:GetPos(), self:GetOwner(), math.abs(self:GetBrushID()))
			hook.Run("CollectDisplacement", self.BrushInfo, self.PlayerList)
		else
			yoink:StartWorld(self:GetPos(), self:GetOwner(), self:GetBrushID())
			hook.Run("CollectBrush", self.BrushInfo, self.PlayerList)
		end
	end

	function ENT:UpdateSpeed()
		local brushsize = self:GetBrushSizeMultiplier()
		local playerspeeds = self:GetPlayerMultiplier()

		self:SetSpeed(playerspeeds * brushsize)
	end
end

if CLIENT then

	-- Void material, but zero refraction on it
	-- This is so we don't get any z-fighting/flickering when shaking the brush
	local refractParams = {

		["$basetexture"] = "concrete/concretefloor001a",
		["$additive"] = 0,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 0,
		["$refractamount"] = 0.0,
		["$model"] = 1,
		["$nocull"] = 1,
	}

	local voidOnly = CreateMaterial("RefractBrushModel_NoRefract" .. FrameNumber(), "Refract", refractParams)

	function ENT:Initialize()
		self.BaseClass.Initialize(self)

		hook.Add("JazzDrawVoid", self, function(self) self:OnPortalRendered() end)
	end

	function ENT:BuildBrushMesh(brush_id, extrude, matOverride)
		local map = bsp2.GetCurrent()
		if map:IsLoading() then return end

		local brush_list = map.brushes
		local brush = brush_list[brush_id]:Copy( true )

		if not brush then
			ErrorNoHalt( "Brush not found: " .. tostring( brush_id ))
			return
		end

		-- extrude out from sides (TWEAK!!)
		extrude = extrude or -1
		for k, side in pairs( brush.sides ) do
			side.plane.dist = side.plane.dist + extrude
		end

		brush:CreateWindings()
		brush.center = (brush.min + brush.max) / 2

		local to_center = -brush.center

		local verts = {}
		for _, side in pairs( brush.sides ) do
			if not side.winding or not side.texinfo then continue end
			side.winding:Move( to_center )

			local texinfo = side.texinfo
			local texdata = texinfo.texdata
			local material = matOverride or Material( texdata.material )

			side.winding:CreateMesh(material, texinfo.textureVecs, texinfo.lightmapVecs, texdata.width, texdata.height, -to_center )
		end

		-- Also set render bounds to match
		self:SetRenderBoundsWS(brush.min, brush.max)

		return brush
	end
	local lightmapTex = nil
	if CLIENT then
		local lightmaprt = irt.New("jazz_snatch_lightmaptex", 64, 64)
		lightmapTex = lightmaprt:GetTarget()
		lightmaprt:Render(function() render.Clear(12, 12, 12, 255) end )
	end
	function ENT:BuildDisplacementMesh(disp_id, extrude, matOverride)
		local map = bsp2.GetCurrent()
		if map:IsLoading() then return end
		local displacement = table.Copy(map.displacements[disp_id])
		local material = matOverride or Material( displacement.face.texinfo.texdata.material )

		local displacementMesh, center = map:CreateDisplacementMesh(disp_id, 0.5, material)
		self:SetRenderBoundsWS(displacement.mins, displacement.maxs)

		-- Make a sneaky render fn to imitate sh_poly from brushes
		displacement.Render = function(self)

			render.SetLightmapTexture(lightmapTex)
			render.SetLightingOrigin( center)
			render.SetMaterial(material)

			displacementMesh:Draw()

			local col = Color(255,100,255, 40)

			local indices = self.indices
			local positions = self.positions
			for i=1, #indices, 3 do

				local v0 = positions[ indices[i] ] - center
				local v1 = positions[ indices[i+1] ] - center
				local v2 = positions[ indices[i+2] ] - center

				render.DrawLine( v0, v1, col, false )
				render.DrawLine( v1, v2, col, false )
				render.DrawLine( v2, v0, col, false )

			end
		end

		return displacement
	end

	function ENT:BuildMesh(inputId, extrude, matOverride)
		local id = math.abs(inputId)
		if inputId < 0 then return self:BuildDisplacementMesh(id, extrude, matOverride) end
		return self:BuildBrushMesh(id, extrude, matOverride)
	end

	function ENT:Think()
		self.BaseClass.Think(self)

		if not self.BrushInfo and self.GetBrushID then
			self.BrushInfo = self:BuildMesh(self:GetBrushID())
			local voidTex = jazzvoid.GetVoidTexture()
			voidOnly:SetTexture("$basetexture", voidTex:GetName())
			self.VoidBrush = self:BuildMesh(self:GetBrushID(), -1, voidOnly)
		end

		-- Random shake think
		self.NextRandom = self.NextRandom or 0
		self.GoalRand = self.GoalRand or Vector()
		self.CurRand = self.CurRand or Vector()
		if self.NextRandom < UnPredictedCurTime() then
			self.NextRandom = UnPredictedCurTime() + 0.02
			self.GoalRand = Vector(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
		end

		for i=1, 3 do
			self.CurRand[i] = math.Approach(self.CurRand[i], self.GoalRand[i], FrameTime() / 0.02)
		end
	end

	function ENT:GetBrushOffset(mtx)
		local function rand(min, max, i)
			return util.SharedRandom("ass", min, max, CurTime() * 1000 + i)
		end
		local prog = math.pow(self:GetProgress(), 1) * 5
		mtx:Translate(self.CurRand * prog)
		//mtx:SetAngles(Angle(rand(-1, 1, 4), rand(-1, 1, 5), rand(-1, 1, 6)))
	end

	function ENT:OnPortalRendered()
		if not self.BrushInfo then return end
		local min, max = self:GetBrushBounds()
		local brushCenter = (min + max) / 2

		local mtx = Matrix()
		mtx:SetTranslation(brushCenter)
		self:GetBrushOffset(mtx)

		cam.PushModelMatrix( mtx )
			self.BrushInfo:Render()
		cam.PopModelMatrix()
	end

	function ENT:Draw()
		if not self.BrushInfo then return end
		local min, max = self:GetBrushBounds()
		local brushCenter = (min + max) / 2

		local mtx = Matrix()
		mtx:SetTranslation(brushCenter)

		cam.PushModelMatrix( mtx )
			self.VoidBrush:Render()
		cam.PopModelMatrix()

		self:GetBrushOffset(mtx)
		cam.PushModelMatrix( mtx )
			self.BrushInfo:Render()
		cam.PopModelMatrix()
	end
end