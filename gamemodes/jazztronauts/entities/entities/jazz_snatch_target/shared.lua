
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "jazz_base_playermarker"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.RemoveDelay = 0

JazzWorldSnatches = JazzWorldSnatches or {}

local mask = bit.bor( MASK_SOLID, CONTENTS_DETAIL )
mask = bit.bor( mask, CONTENTS_GRATE )
mask = bit.bor( mask, CONTENTS_TRANSLUCENT )

local function createMarkerForBrush(pos, ang, brush)
    local ent = ents.Create("jazz_snatch_target")
    ent:Spawn()
    ent:Activate()
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:SetBrushID(brush.id)
    ent.BrushInfo = brush

    JazzWorldSnatches[brush.id] = ent
end

function snatch.FindOrCreateWorld(pos, dir, dist)
    local map = bsp2.GetCurrent()
    local res = map:Trace({
		pos = pos,
		dir = dir,
		tmin = 0,
		tmax = dist,
		mask = mask,
        filter = { "func_dustmotes" }
	})

    local brush = res and res.Hit and res.Brush and res.Brush
    if not brush or snatch.removed_brushes[brush.id] then return nil end
    if IsValid(JazzWorldSnatches[brush.id]) then return JazzWorldSnatches[brush.id] end

    return createMarkerForBrush(res.HitPos, res.HitNormal:Angle(), brush)
end


function ENT:SetupDataTables()
    self.BaseClass.SetupDataTables(self)
    self:NetworkVar("Int", 1, "BrushID")
end

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        --self:SetNoDraw(true)

        self.PlayerList = {}
    end

    function ENT:GetBrushSizeMultiplier()
        local size = self.BrushInfo.max - self.BrushInfo.min

        local length = size.x + size.y + size.z
        
        -- 600 is pretty good for a more upgraded value
        -- 100 is a pretty good starting value
        return 600.0 / math.pow(length, 1.1)
    end

    -- Overwritten
    function ENT:ActivateMarker()
        self.BaseClass.ActivateMarker(self)

        local yoink = snatch.New()
        yoink:SetMode(2)
	    yoink:StartWorld(self:GetPos(), self:GetOwner(), self:GetBrushID())

        GAMEMODE:CollectBrush(self.BrushInfo, self.PlayerList)
    end

    function ENT:UpdateSpeed()
        local brushsize = self:GetBrushSizeMultiplier()
        self:SetSpeed(#self.PlayerList * brushsize)
    end
end

if CLIENT then
    JazzSnatchMeshIndex = JazzSnatchMeshIndex or 1

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

            local meshid = "propsnatcher_voidmesh" .. brush_id .. "_" .. JazzSnatchMeshIndex
            side.winding:CreateMesh( meshid, material, texinfo.textureVecs, texinfo.lightmapVecs, texdata.width, texdata.height, -to_center )
            JazzSnatchMeshIndex = JazzSnatchMeshIndex + 1
        end

        -- Also set render bounds to match
        self:SetRenderBoundsWS(brush.min, brush.max)

        return brush
    end

    function ENT:Think()
        self.BaseClass.Think(self)

        if not self.Brush and self.GetBrushID then
            self.Brush = self:BuildBrushMesh(self:GetBrushID())
            local voidTex = jazzvoid.GetVoidTexture()
            voidOnly:SetTexture("$basetexture", voidTex:GetName())
            self.VoidBrush = self:BuildBrushMesh(self:GetBrushID(), -1, voidOnly)
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
        if not self.Brush then return end

        local brushCenter = (self.Brush.min + self.Brush.max) / 2

        local mtx = Matrix()
        mtx:SetTranslation(brushCenter)
		self:GetBrushOffset(mtx)

        cam.PushModelMatrix( mtx )
		    self.Brush:Render()
		cam.PopModelMatrix()
    end

    function ENT:Draw()
        if not self.Brush then return end

        local brushCenter = (self.Brush.min + self.Brush.max) / 2

        local mtx = Matrix()
		mtx:SetTranslation(brushCenter)

		cam.PushModelMatrix( mtx )
            self.VoidBrush:Render()
		cam.PopModelMatrix()

        self:GetBrushOffset(mtx)
        cam.PushModelMatrix( mtx )
		    self.Brush:Render()
		cam.PopModelMatrix()
    end
end