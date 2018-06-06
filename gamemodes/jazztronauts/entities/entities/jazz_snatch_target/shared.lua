
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "jazz_base_playermarker"

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
        ignoreents = true
	})

    local brush = res and res.Hit and res.Brush and res.Brush
    if not brush or snatch.removed_brushes[brush.id] then return nil end
    if IsValid(JazzWorldSnatches[brush.id]) then return JazzWorldSnatches[brush.id] end

    return createMarkerForBrush(res.HitPos, res.HitNormal:Angle(), brush)
end


function ENT:SetupDataTables()
    self.BaseClass.SetupDataTables(self)
    self:NetworkVar("Int", 0, "BrushID")
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
        return 600.0 / math.pow(length, 1.1)
    end

    -- Overwritten
    function ENT:ActivateMarker()
        local yoink = snatch.New()
        yoink:SetMode(2)
	    yoink:StartWorld(self:GetPos(), self:GetOwner(), self:GetBrushID())
    end

    function ENT:UpdateSpeed()
        local brushsize = self:GetBrushSizeMultiplier()
        self:SetSpeed(#self.PlayerList * brushsize)
    end
end

if CLIENT then
    JazzSnatchMeshIndex = JazzSnatchMeshIndex or 1

    ENT.BreakMaterial = Material("effects/map_monitor_noise")

    function ENT:BuildBrushMesh(brush_id)
        local map = bsp2.GetCurrent()
        if map:IsLoading() then return end

        local brush_list = map.brushes
        local brush = brush_list[brush_id]:Copy( true )

        if not brush then
            ErrorNoHalt( "Brush not found: " .. tostring( brush_id ))
            return
        end

        -- extrude out from sides (TWEAK!!)
        local extrude = -1
        for k, side in pairs( brush.sides ) do
            side.plane.dist = side.plane.dist + extrude
        end

        brush:CreateWindings()
        brush.center = (brush.min + brush.max) / 2

        local to_center = -brush.center
        
        local verts = {}
        for _, side in pairs( brush.sides ) do
            if not side.winding or not side.texinfo then continue end

            local texinfo = side.texinfo
            local texdata = texinfo.texdata
            local material = Material( texdata.material )

		    side.winding:EmitMesh(texinfo.textureVecs, texinfo.lightmapVecs, texdata.width, texdata.height, Vector(), verts)
        end

        -- From vertices, build the final mesh
        local breakmesh = ManagedMesh( "propsnatcher_voidmesh" .. brush_id .. "_" .. JazzSnatchMeshIndex, self.BreakMaterial)
        breakmesh:BuildFromTriangles(verts)
        JazzSnatchMeshIndex = JazzSnatchMeshIndex + 1

        -- Also set render bounds to match
        self:SetRenderBoundsWS(brush.min, brush.max)

        return breakmesh
    end

    function ENT:Think()
        self.BaseClass.Think(self)

        if not self.BrushMesh and self.GetBrushID then
            self.BrushMesh = self:BuildBrushMesh(self:GetBrushID())
        end
    end

    function ENT:Draw()
        if not self.BrushMesh then return end

        render.SetMaterial(self.BreakMaterial)
        self.BrushMesh:Draw()
    end
end