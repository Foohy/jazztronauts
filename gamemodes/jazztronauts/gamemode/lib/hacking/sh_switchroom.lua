AddCSLuaFile()

module( "switchroom", package.seeall )

CMD_EXIT    = 0
CMD_HACK    = 1
CMD_TRAVEL  = 2

node_graph = node_graph or nil
local function GetNodeFromIndex(nodeIdx)
    if not node_graph then
        node_graph = iograph.New()
    end

    return node_graph:GetByIndex(nodeIdx)
end

function SetSwitchroom(ply, node)
    if !IsValid(ply) then return end
    ply["HackerGogglesSwitchroom"] = node
    ply["HackerGogglesReferencePos"] = node and node:GetPos()

    if SERVER then
        net.Start("jazz_hackergoggles_switchroom")
            net.WriteInt(node and node:GetIndex() or -1, 32)
        net.Send(ply)
    end
    if CLIENT then
        if node then
            SetupRoom(node)

            ply["HackerGogglesVelocity"] = 0
            ply["HackerGogglesVertPos"]  = 0
        end
    end
end
if CLIENT then
    node_graph = node_graph or nil
    net.Receive("jazz_hackergoggles_switchroom", function(len)
        local nodeIdx = net.ReadInt(32)

        SetSwitchroom(LocalPlayer(), GetNodeFromIndex(nodeIdx))
    end )
end
if SERVER then
    net.Receive("jazz_hackergoggles_switchroom", function(len, ply)
        local cmd = net.ReadInt(8)
        if cmd == CMD_EXIT then
            Exit(ply)
        elseif cmd == CMD_HACK then
            local nodeIdx = net.ReadInt(32)
            Hack(ply, GetNodeFromIndex(nodeIdx))
        elseif cmd == CMD_TRAVEL then
            local nodeIdx = net.ReadInt(32)
            Travel(ply, GetNodeFromIndex(nodeIdx))
        end
    end )
end

function GetSwitchroom(ply)
    return IsValid(ply) and ply["HackerGogglesSwitchroom"]
end

function Exit(ply)
    if CLIENT then
        net.Start("jazz_hackergoggles_switchroom")
            net.WriteInt(CMD_EXIT, 8)
        net.SendToServer()
    elseif SERVER then
        SetSwitchroom(ply, nil)
    end
end

function Hack(ply, node)
    if CLIENT then
        net.Start("jazz_hackergoggles_switchroom")
            net.WriteInt(CMD_HACK, 8)
            net.WriteInt(node and node:GetIndex() or -1, 32)
        net.SendToServer()
    elseif SERVER then
        -- TODO
        Exit(ply)
    end
end

function Travel(ply, node)
    if CLIENT then
        net.Start("jazz_hackergoggles_switchroom")
            net.WriteInt(CMD_TRAVEL, 8)
            net.WriteInt(node and node:GetIndex() or -1, 32)
        net.SendToServer()
    elseif SERVER then
        -- TODO
        SetSwitchroom(ply, node)
    end
end


hook.Add("StartCommand", "hackergoggles_startcmd", function(ply,cmd)
    local switch = GetSwitchroom(ply)
    if (!switch) then return end
    local tryMove = cmd:GetForwardMove()
    ply["HackerGogglesVelocityGoal"] = tryMove

    cmd:ClearMovement()
    cmd:RemoveKey(IN_DUCK)
    cmd:RemoveKey(IN_JUMP)

    --cmd:ClearButtons()

end )

if SERVER then
    util.AddNetworkString( "jazz_hackergoggles_switchroom" )
end

if CLIENT then
    RegisteredFloors = RegisteredFloors or {}
    HoveredInteract = HoveredInteract or nil
    local DRAW_DEBUG_BBOX = false

    local DoorOpen = Sound("doors/door1_move.wav")
    local DoorClose = Sound("doors/door_wood_close1.wav")

    local matparam_wall_brick =
    {
        ["$basetexture"]    = "sunabouzu/jazzbrickwall02_A",
        ["$bumpmap"]        = "sunabouzu/jazzbrickwall02_N",
        ["$ssbump"]         = 1,
        ["$detail"]         = "sunabouzu/jazznoise",
        ["$detailscale"]    ="6",
        ["$detailblendfactor"] = .6,
        ["$detailblendmode"] = 0,
        ["$normalmapalphaenvmapmask"] = 1,
        ["$envmap"]         = "env_cubemap",
        ["$envmaptint"]     = "[.33 .18 .2]",
        ["$envmapcontrast"]	= 1,
        ["$envmapsaturation"] = .25,
    }

    local matparam_wall_paper =
    {
        ["$basetexture"]    = "sunabouzu/jazzwallpaper02_A",
        ["$bumpmap"]        = "sunabouzu/jazzwallpaper02_S",
        ["$ssbump"]         = 1,
        ["$detail"]         = "sunabouzu/jazznoise",
        ["$detailscale"]    = "6.283",
        ["$detailblendfactor"]  = .6,
        ["$detailblendmode"]    = 0,
        ["$envmap"]         = "env_cubemap",
        ["$envmaptint"]     = "[ .05 .09 .075 ]",
        ["$envmapcontrast"]     = .75,
        ["$envmapsaturation"]   = 2
    }

    local matparam_floor_wood =
    {
        ["$basetexture"]        = "sunabouzu/jazzwoodfloor02_a",
        ["$bumpmap"]            = "sunabouzu/jazzwoodfloor02_n",
        ["$ssbump"]             = 1,
        ["$surfaceprop"]        = "Wood_Solid",
        ["$envmap"]             = "env_cubemap",
        ["$normalmapalphaenvmapmask"] =  1,
        ["$envmapcontrast"]     =  1.5,
        ["$envmapsaturation"]   =  1,
        ["$envmaptint"]         =  "[.33 .1 .2]",
    }

    local matparam_ceiling_black =
    {
        ["$basetexture"]    = "color/white",
        ["$model"]           = 1,
        ["$translucent"]     = 1,
        ["$vertexalpha"]     = 1,
        ["$vertexcolor"]     = 1,
        ["$color"]           =  "[0 0 0]",
        ["$nocull"]         = 1,
    }


    local matparam_world_cut =
    {
        ["$basetexture"]    = "color/white",
        ["$nocull"]         = 1,
    }


    local wall_surface_material_params =
    {
        ["$basetexture"]    = "sunabouzu/jazzshell",
        ["$surfaceprop"]    = "Glass",
        ["$nocull"]         = 1,
        ["$alpha"]          = .9
    }

    local wall_floor_material_params =
    {
        ["$basetexture"]    = "sunabouzu/jazzshell",
        ["$surfaceprop"]    = "Glass",
        ["$nocull"]         = 1,
        ["$alpha"]          = .99
    }


    --local wall_outside_material = CreateMaterial("HackergogglesWallMaterial" .. FrameNumber(), "Refract", wall_outside_material_params)
    local wall_surface_material = CreateMaterial("HackergogglesWallSurfaceMaterial" .. FrameNumber(), "UnlitGeneric", wall_surface_material_params)
    local wall_floor_material = CreateMaterial("HackergogglesWallFloorMaterial" .. FrameNumber(), "UnlitGeneric", wall_floor_material_params)

    local mat_wall_brick = CreateMaterial("HackergogglesWallBrick" .. FrameNumber(), "VertexLitGeneric", matparam_wall_brick)
    local mat_wall_paper = CreateMaterial("HackergogglesWallPaper" .. FrameNumber(), "VertexLitGeneric", matparam_wall_paper)
    local mat_floor_wood = CreateMaterial("HackergogglesFloorWood" .. FrameNumber(), "VertexLitGeneric", matparam_floor_wood)
    local mat_ceiling_black = CreateMaterial("HackergogglesCeilingBlack" .. FrameNumber(), "VertexLitGeneric", matparam_ceiling_black)

    local mat_world_cut = CreateMaterial("HackergogglesWorldCut" .. FrameNumber(), "Refract", matparam_world_cut)

    local mat_decoframe = Material("decals/artdeco_frame_gold")

    local roomWidth = 200
    local roomHeight = 200

    local numInputs = 3
    local numOutputs = 4

    local function getSafeSideCount(num)
        return (num <= 3) and 4 or (num + 3)
    end
    local function getNumSides()
        return getSafeSideCount(numInputs)
    end
    local function getSelectedWall()
        local numSides = getNumSides()
        return (math.NormalizeAngle(LocalPlayer():EyeAngles().y + 360 / numSides) / 360.0) * numSides
    end
    local function getLadderCamPos()
        local ply = LocalPlayer()
        local vertPos = ply["HackerGogglesVertPos"] or 0
        return Vector(70,0,70 + vertPos)
    end
    local function getCurrentFloor()
        return math.floor(getLadderCamPos().z / roomHeight) + 1
    end
    local function getVirtualCam()
        local ply = LocalPlayer()

        local ladderPos = getLadderCamPos()
        local ladderAng = LocalPlayer():EyeAngles()

        local selectGoal = ply["HackerGogglesSelectGoal"] 
        if selectGoal then
            local t = math.pow(selectGoal.t, 2)
            ladderPos = LerpVector(t, ladderPos, selectGoal.goalPos + Vector(0, 0, 70))
            ladderAng = LerpAngle(t, ladderAng, selectGoal.goalAng + Angle(0, 90, 0))
        end
        
        return ladderPos, ladderAng
    end
    totalInteracts = totalInteracts or 0
    local function createInteract(type, bbox_min, bbox_max)
        totalInteracts = totalInteracts + 1
        return {
            type = type,
            bbox = {min = bbox_min, max = bbox_max},
            isHovered = false,
            IsHovered = function(self) return self.isHovered end,
            OnSelect = function(self) end,
            OnHoverBegin = function(self) end,
            OnHoverEnd = function(self) end,
            Think = function(self) end,
            Draw = function(self) end
        }
    end
    --local lasermat	= Material("effects/laser1.vmt")
    local function createDoor(pos, ang, doortype, info, center)
        local door = table.Merge(createInteract("door", Vector(-30, -30, 0), Vector(30,30,120)), 
        {
            pos = pos,
            ang = ang,
            doortype = doortype,
            info = info,
            trace = nil,
            OnSelect = function(self) 
                local ply = LocalPlayer()
                ply["HackerGogglesSelectGoal"] = {
                    goalPos = self.pos,
                    goalAng = self.ang,
                    interact = self,
                    t = 0
                }
                ply:ScreenFade(SCREENFADE.OUT, color_white, 0.75, 0)
            end,
            OnHoverBegin = function(self) 
                self.csent:ResetSequence(0)
                self.csent:ResetSequenceInfo()
                self.csent:SetCycle(0)
                self.csent:EmitSound(DoorOpen)
            end,
            OnHoverEnd = function(self) 
                self.csent:ResetSequence(1)
                self.csent:ResetSequenceInfo()
                self.csent:SetCycle(0)

                --oldDoor.csent:EmitSound( DoorClose)
            end,
            Think = function(self) 
                if IsValid(self.csent) then self.csent:FrameAdvance() end
            end,
            Draw = function(self)
                --render.SetMaterial( lasermat );
                if self.trace then 
                    self.trace:Draw()
                    self.trace:DrawBlips()
                    self.trace:DrawFlashes()
                end

                -- cut through behind door (look ma! no stencils!)
                render.SetMaterial(mat_world_cut)
                render.OverrideDepthEnable(true, false)
                render.DrawBox(pos + ang:Right() * -5, ang, Vector(-24, -2, 0), Vector(24, 2, 110), color_white)
                render.OverrideDepthEnable(true, true)
                self.csent:DrawModel()
            end
        })

        -- Create its own clientside ent for it
        local doorent = ManagedCSEnt("jazz_hackergoggles_door_" .. totalInteracts, "models/sunabouzu/jazzdoor.mdl")
        doorent:SetNoDraw(true)
        doorent:SetPos(pos)
        doorent:SetAngles(ang)
        doorent:SetupBones()
        doorent:ResetSequenceInfo()
        doorent:SetSequence(1)
        doorent:SetCycle(1)

        door.csent = doorent
        if center then
            door.trace = iotrace.New(center, pos + Vector(0,0,110))
            door.trace:BuildPath(true)
        end
        return door
    end
    local function createComputer(pos, ang, event)
        local compinfo = table.Merge(createInteract("computer", Vector(-30, -30, 0), Vector(30,30,30)), 
        {
            pos = pos,
            ang = ang,
            event = event,
            OnSelect = function(self) 
                print("hackerman")
            end,
            Draw = function(self)
                self.csent:SetAngles(ang + AngleRand(-5, 5) * (self:IsHovered() and 1 or 0))
                self.csent:DrawModel()

                render.OverrideDepthEnable(false, false)
                
                -- Center text
                cam.Start3D2D(self.pos + Vector(0, 0, 43), Angle(0, 90, 90), 1)
                cam.IgnoreZ(true)
                    render.PushFilterMag(TEXFILTER.POINT)
                    draw.SimpleText(self.event, "TargetID", 0, 0, color_white, TEXT_ALIGN_CENTER)
                    render.PopFilterMag()
                cam.IgnoreZ(false)
                cam.End3D2D()
            end
        })

        -- Create its own clientside ent for it
        local comp = ManagedCSEnt("jazz_hackergoggles_computer_" .. totalInteracts, "models/msx/msx_computer.mdl")
        comp:SetNoDraw(true)
        comp:SetPos(pos)
        comp:SetAngles(ang)
        comp:SetupBones()
        comp:ResetSequenceInfo()
        comp:SetSequence(1)
        comp:SetCycle(1)

        local m = Matrix()
        m:Scale(Vector(1,1,1) * 1.5)
        comp:EnableMatrix("RenderMultiply", m)

        compinfo.csent = comp
        return compinfo
    end
    local function createTeleportExit(pos, ang)
        local exitinfo = table.Merge(createInteract("exit", Vector(-20, -20, 0), Vector(20,20,10)), 
        {
            pos = pos,
            ang = ang,
            OnSelect = function(self) 
                print("buh bye")
            end,
            Draw = function(self)
                render.SetMaterial(mat_world_cut)
                render.OverrideDepthEnable(true, false)
                render.DrawBox(pos, ang, Vector(-20, -20, -2), Vector(20, 20, 1), color_white)
                render.OverrideDepthEnable(true, true)
            end
        })
    
        return exitinfo
    end
    local function createProp(pos, ang, model)
        local propinfo = table.Merge(createInteract("prop"), 
        {
            pos = pos,
            ang = ang,
            Think = function(self) 
                if IsValid(self.csent) then self.csent:FrameAdvance() end
            end,
            Draw = function(self)
                self.csent:DrawModel()
            end
        })
    
        -- Create its own clientside ent for it
        local prop = ManagedCSEnt("jazz_hackergoggles_prop_" .. totalInteracts, model)
        prop:SetNoDraw(true)
        prop:SetPos(pos)
        prop:SetAngles(ang)

        propinfo.csent = prop
        return propinfo
    end
    local function drawSemiCircle(pos, ang, width, height, numPoints)
        mesh.Begin(MATERIAL_POLYGON, numPoints)
        for i=0, numPoints-1 do
            local p = i * 1.0 / (numPoints-1)
            local rad = p * math.pi
            local x, y = math.cos(rad) * width, math.sin(rad) * height
            local circlePos = ang:Forward() * -x + ang:Up() * y
            mesh.Position(pos + circlePos)
            mesh.TexCoord(0, math.cos(rad), math.sin(rad))
            mesh.AdvanceVertex()
        end
        mesh.End()
    end
    local function drawQuadFull(pos, ang, width, height)
        local px = ang:Forward()*width/2
        local py  = ang:Up()*height/2
        local normal = ang:Forward()
        local tx, ty, tz = ang:Right():Unpack()
        local ts = 0


        mesh.Begin(MATERIAL_POLYGON, 4)

            mesh.Position(pos +px -py)
            mesh.TexCoord(0, 0, 1)
            mesh.Normal(normal)
            mesh.UserData(tx, ty, tz, ts)
            mesh.AdvanceVertex()

            mesh.Position(pos -px -py)
            mesh.TexCoord(0, 1, 1)
            mesh.Normal(normal)
            mesh.UserData(tx, ty, tz, ts)
            mesh.AdvanceVertex()

            mesh.Position(pos -px +py)
            mesh.TexCoord(0, 1, 0)
            mesh.Normal(normal)
            mesh.UserData(tx, ty, tz, ts)
            mesh.AdvanceVertex()

            mesh.Position(pos +px +py)
            mesh.TexCoord(0, 0, 0)
            mesh.Normal(normal)
            mesh.UserData(tx, ty, tz, ts)
            mesh.AdvanceVertex()

        mesh.End()
    end
    local function createWindow(pos, ang, width, height, model)
        local propinfo = table.Merge(createInteract("window"), 
        {
            pos = pos,
            ang = ang,
            Think = function(self) 
                if IsValid(self.csent) then self.csent:FrameAdvance() end
            end,
            Draw = function(self)
                render.SetMaterial(mat_world_cut)
                render.OverrideDepthEnable(true, false)
                drawSemiCircle(pos, ang, width/2 - 2, height/2 - 2, 8)
                render.OverrideDepthEnable(true, true)

                render.SetMaterial(mat_decoframe)
                drawQuadFull(pos + Vector(0, 0, 13), ang, width, height)

            end
        })
    
        -- Create its own clientside ent for it
        local prop = ManagedCSEnt("jazz_hackergoggles_window_" .. totalInteracts, model)
        prop:SetNoDraw(true)
        prop:SetPos(pos)
        prop:SetAngles(ang)

        propinfo.csent = prop
        return propinfo
    end
    local function getCurrentInteracts()
        local curFloorIdx = getCurrentFloor()
        local curFloor = RegisteredFloors[curFloorIdx]
        return curFloor and curFloor.interacts or {}
    end
    local function addFloor(name, sideCount, width, offset, interacts)
        local floorInfo = {
            name = name,
            sideCount = sideCount,
            width = width,
            offset = offset or Vector(),
            interacts = interacts or {}
        }

        -- TODO: Generate mesh here instead of dynamically?

        table.insert(RegisteredFloors, floorInfo)
    end
    local function getFloorByEvent(event)
        for k, v in pairs(RegisteredFloors) do
            if v.name == event then return v end 
        end
    end

    local function selectInteract(interact)
        if !interact then return end

        interact:OnSelect()
    end

    local function getDoorDestination(door)
        if door and door.info then
            return door.doortype == "output" and door.info.to or door.info.from
        end
    end

    local function buildRoomWalls(numSides, width, height)
        local hpos = 0
        mesh.Begin(MATERIAL_QUADS, numSides)
        for i = 0, numSides do
            local curAng = ((i + 0.5) * 1.0 / numSides) * 2.0 * math.pi
            local nextAng = ((i+1.5) * 1.0 / numSides) * 2.0 * math.pi
            local curX, curY = math.cos(curAng) * width, math.sin(curAng) * width
            local nextX, nextY = math.cos(nextAng) * width, math.sin(nextAng) * width

            local hdist = math.Distance(curX, curY, nextX, nextY)

            local avgAng = (curAng + nextAng) / 2
            local surfAng = Angle(90, math.deg(avgAng), 0)
            local normal = surfAng:Forward()
            local tangent = surfAng:Up()
            local tsidedness = -1
            mesh.Position(Vector(nextX, nextY, 0))
            mesh.TexCoord(0, hpos * 0.004, 0)
            mesh.Normal(normal)
            mesh.UserData(tangent.x, tangent.y, tangent.z, tsidedness)
            mesh.AdvanceVertex()
      
            mesh.Position(Vector(nextX, nextY, height))
            mesh.TexCoord(0, hpos * 0.004, height * 0.004)
            mesh.Normal(normal)
            mesh.UserData(tangent.x, tangent.y, tangent.z, tsidedness)
            mesh.AdvanceVertex()
     
            mesh.Position(Vector(curX, curY, height))
            mesh.TexCoord(0, (hpos + hdist) * 0.004, height * 0.004)
            mesh.Normal(normal)
            mesh.UserData(tangent.x, tangent.y, tangent.z, tsidedness)
            mesh.AdvanceVertex()

            mesh.Position(Vector(curX, curY, 0))
            mesh.TexCoord(0, (hpos + hdist) * 0.004, 0)
            mesh.Normal(normal)
            mesh.UserData(tangent.x, tangent.y, tangent.z, tsidedness)
            mesh.AdvanceVertex()

            hpos = hpos + hdist
        end
        mesh.End()
    end

    local function buildRoomFloor(numSides, width, height)
        mesh.Begin(MATERIAL_POLYGON, numSides)
        for i = numSides-1, 0, -1 do
            local curAng = ((i + 0.5) * 1.0 / numSides) * 2.0 * math.pi
            local nextAng = ((i+1.5) * 1.0 / numSides) * 2.0 * math.pi
            local curX, curY = math.cos(curAng) * width, math.sin(curAng) * width
            local nextX, nextY = math.cos(nextAng) * width, math.sin(nextAng) * width


            local avgAng = (curAng + nextAng) / 2
            local surfAng = Angle(90, math.deg(avgAng), 0)
            local normal = Vector(0,0,1)
            local tangent = surfAng:Up()
            local tsidedness = -1
            mesh.Position(Vector(curX, curY, height))
            mesh.TexCoord(0, math.cos(curAng), math.sin(curAng))
            mesh.Normal(normal)
            mesh.UserData(tangent.x, tangent.y, tangent.z, tsidedness)
            mesh.AdvanceVertex()
        end
        mesh.End()
    end

    local function buildRoomFloorHole(width, height, holeSize, holeOffsetX)
        holeOffsetX = holeOffsetX or 0
        mesh.Begin(MATERIAL_TRIANGLES, 8)
        for i = 0, 3 do
            local curAng = ((i + 0.5) * 1.0 / 4) * 2.0 * math.pi
            local nextAng = ((i+1.5) * 1.0 / 4) * 2.0 * math.pi
            local curX, curY = math.cos(curAng) * width, math.sin(curAng) * width
            local nextX, nextY = math.cos(nextAng) * width, math.sin(nextAng) * width

            local holeAng = curAng// math.Round(curAng * 4, 2) / 4
            local holeAngNext = nextAng //math.Round(nextAng * 4, 2) / 4
            local holeX, holeY = math.cos(holeAng) * holeSize + holeOffsetX, math.sin(holeAng) * holeSize
            local holeNextX, holeNextY = math.cos(holeAngNext) * holeSize + holeOffsetX, math.sin(holeAngNext) * holeSize


            local holRelCoord = holeSize * 1.0 / width
            local holCoordX = holeOffsetX * 1.0 / width 
            mesh.Position(Vector(curX, curY, height))
            mesh.TexCoord(0, math.cos(curAng), math.sin(curAng))
            mesh.AdvanceVertex()

            mesh.Position(Vector(holeX, holeY, height))
            mesh.TexCoord(0, math.cos(holeAng) * holRelCoord + holCoordX, math.sin(holeAng) * holRelCoord)
            mesh.AdvanceVertex()

            mesh.Position(Vector(holeNextX, holeNextY, height))
            mesh.TexCoord(0, math.cos(holeAngNext) * holRelCoord + holCoordX, math.sin(holeAngNext) * holRelCoord)
            mesh.AdvanceVertex()

            mesh.Position(Vector(curX, curY, height))
            mesh.TexCoord(0, math.cos(curAng), math.sin(curAng))
            mesh.AdvanceVertex()

            mesh.Position(Vector(holeNextX, holeNextY, height))
            mesh.TexCoord(0, math.cos(holeAngNext) * holRelCoord + holCoordX, math.sin(holeAngNext) * holRelCoord)
            mesh.AdvanceVertex()

            mesh.Position(Vector(nextX, nextY, height))
            mesh.TexCoord(0, math.cos(nextAng), math.sin(nextAng))
            mesh.AdvanceVertex()
        end
        mesh.End()
    end

    local function getRoomPlacement(n, numSides, actualPlaces, width)
        local curAng = ((n+0.5 + 1) * 1.0 / numSides) * 2.0 * math.pi
        local nextAng = ((n+1.5 + 1) * 1.0 / numSides) * 2.0 * math.pi

        -- special cases for small numbers
        if actualPlaces == 2 && n == 0 then 
            curAng = curAng - math.pi/2
            nextAng = nextAng - math.pi/2
        end
        if (actualPlaces == 3) then
            curAng = curAng - (1 * 1.0 / numSides) * 2.0 * math.pi
            nextAng = nextAng - (1 * 1.0 / numSides) * 2.0 * math.pi
        end

        local doorPos = LerpVector(0.5, Vector(math.cos(curAng), math.sin(curAng), 0), Vector(math.cos(nextAng), math.sin(nextAng), 0)) * width
        return doorPos, Angle(0, math.deg((curAng + nextAng)/2, 0) - 90)
    end
    -- models/matt/jazz_trolley_door.mdl

    -- models/msx/msx_computer.mdl
    -- models/sunabouzu/jazzbigtv.mdl (scale down)

    -- models/sunabouzu/jazzwalllight.mdl
    -- models/sunabouzu/jazzivy.mdl
    -- models/sunabouzu/jazzivy02.mdl (through 08)
    -- models/sunabouzu/jazzlakepole.mdl
    -- models/sunabouzu/jazzlily01.mdl
    -- models/sunabouzu/jazzlily02.mdl
    -- models/sunabouzu/jazzlotus.mdl
    -- models/sunabouzu/jazzbarlight01.mdl
    -- models/sunabouzu/jazzbarlight02.mdl
    -- models/sunabouzu/jazzpondcrystal.mdl

    -- maps/jazz_bar/sunabouzu/jazzbrickwall02
    -- maps/jazz_bar/sunabouzu/jazzmetalgold
    -- maps/jazz_bar/sunabouzu/jazzwoodfloor02
    -- maps/jazz_bar/sunabouzu/jazzwallpaper02
    -- maps/jazz_bar/sunabouzu/jazzlineoleum
    -- maps/jazz_bar/sunabouzu/jazzbrickwall01
    -- maps/jazz_bar/sunabouzu/jazzsmoothmarble01
    -- maps/jazz_bar/sunabouzu/jazztilefloor01
    -- sunabouzu/jazzmetal
    function SetupRoom(node)
        totalInteracts = 0
        RegisteredFloors = {}
        numInputs = table.Count(node:GetInputs())
        numOutputs = table.Count(node:GetOutputs())
        local numSides = getNumSides()

        -- Bottom floor has N sides for all the doors
        local bottomDoorCount = table.Count(node:GetInputs())
        local bottomSizeOffset = bottomDoorCount * 5

        -- Base floor input doors
        local floorDoors = {}
        local i = 0
        for k, v in pairs(node:GetInputs()) do
            local pos, ang = getRoomPlacement(i, getSafeSideCount(numInputs), numInputs, roomWidth + bottomSizeOffset)
            table.insert(floorDoors, createWindow(pos + Vector(-bottomSizeOffset*2, 0, 0) + Vector(0,0,115), ang, 60, 60, "models/matt/jazz_trolley_door.mdl" ))
            table.insert(floorDoors, createDoor(pos + Vector(-bottomSizeOffset*2, 0, 0), ang, "input", v))

            i = i + 1
        end
        

        -- Exit door
        local curAng = ((-0.5) * 1.0 / numSides) * 2.0 * math.pi
        local nextAng = ((0.5) * 1.0 / numSides) * 2.0 * math.pi
        local doorPos = LerpVector(0.5, Vector(math.cos(curAng), math.sin(curAng), 0), Vector(math.cos(nextAng), math.sin(nextAng), 0)) * roomWidth
        table.insert(floorDoors, createDoor(doorPos, Angle(0, math.deg((curAng + nextAng)/2, 0) - 90), "exit"))

        -- Exit (tp) hatch
        table.insert(floorDoors, createTeleportExit(Vector(-bottomSizeOffset*2, 0, 0), Angle()))

        addFloor(event, bottomDoorCount, roomWidth + bottomSizeOffset, Vector(-bottomSizeOffset*2, 0, 0), floorDoors)

        -- Output doors
        -- These are grouped based on shared events
        local groupedOutputs = {}
        for k, v in pairs(node:GetOutputs()) do  
            groupedOutputs[v.event] = groupedOutputs[v.event] and groupedOutputs[v.event] + 1 or 1
        end
        
        local floor = 1
        for event, n in SortedPairsByValue(groupedOutputs, true) do
            local sizeOffset = n * 5
            local floorInteracts = {}
            
            local centerpos = Vector(-sizeOffset*2 - 25, 0, roomHeight * floor + roomHeight - 30)

            -- Store more doors for floor lore
            local i = 0
            for k, v in pairs(node:GetOutputs()) do
                if v.event ~= event then continue end
                local pos, ang = getRoomPlacement(i, getSafeSideCount(n), n, roomWidth + sizeOffset)
                table.insert(floorInteracts, createDoor(pos + Vector(-sizeOffset*2,0,roomHeight * floor), ang, "output", v, centerpos))
                i = i + 1
            end

            -- Center computer thing
            local compy = createComputer(centerpos, Angle(), event)
            table.insert(floorInteracts, compy)

            -- Each event group is its own floor
            addFloor(event, n, roomWidth + sizeOffset, Vector(-sizeOffset*2, 0, 0), floorInteracts)

            floor = floor + 1
        end
        
    end

    local function findTrace()
        local start = getLadderCamPos()
        local dir = LocalPlayer():EyeAngles():Forward()

        for k, v in ipairs(getCurrentInteracts()) do
            if !v.bbox.min or !v.bbox.max then continue end
            local hit, t = IntersectRayBox(start, dir, v.bbox.min + v.pos, v.bbox.max + v.pos)
            if hit then
                return k, v, t
            end
        end
    end

    
    hook.Add("KeyPress", "hackergoggles_switchroom_keypress", function(ply, key)
        if !GetSwitchroom(LocalPlayer()) then return end
        if !IsFirstTimePredicted() then return end
        if (key == IN_ATTACK) then
            selectInteract(HoveredInteract)
        end
    end)


    function MoveThink(dt)
        local ply = LocalPlayer()
        local goalVel = ply["HackerGogglesVelocityGoal"] or 0
        local vel = ply["HackerGogglesVelocity"] or 0
        local pos =  ply["HackerGogglesVertPos"] or 0

        -- Acceleration
        vel = math.Approach(vel, goalVel, dt * 100000)

        -- Velocity
        pos = pos + vel * 0.03 * dt
        local maxHeight = roomHeight*(#RegisteredFloors - 1)
        if pos < 0 || pos > maxHeight then vel = 0 end
        pos = math.Clamp(pos, 0, maxHeight)
        ply["HackerGogglesVertPos"] = pos
        ply["HackerGogglesVelocity"] = vel
        --print("Goal Velocity: " ..  goalVel .. ", vel: " ..  vel .. ", pos:  " .. pos)


        -- Manually advance interact anims
        for _, v in pairs(getCurrentInteracts()) do
            if v then v:Think() end
        end


        -- Selection tween anim
        local selectGoal = ply["HackerGogglesSelectGoal"] 
        if selectGoal then
            selectGoal.t = selectGoal.t + dt * 1.5

            if selectGoal.t >= 1 then
                local dest = getDoorDestination(HoveredInteract)
                Travel(ply, dest)
                ply["HackerGogglesSelectGoal"] = nil
            end
        else -- If no goal, trace and search for interact points
            local idx, interact, t = findTrace()
            if HoveredInteract != interact then
                local oldInteract = HoveredInteract
                local newInteract = interact
                if oldInteract and IsValid(oldInteract.csent) then
                    oldInteract.isHovered = false
                    oldInteract:OnHoverEnd()
                end
                if newInteract and IsValid(newInteract.csent) then
                    newInteract.isHovered = true
                    newInteract:OnHoverBegin()
                end

                HoveredInteract = interact
            end
        end
    end

    -- I honestly, truly, have no idea why this is necessary right here
    -- For some reason OverrideDepthEnable doesn't actually set, which is super annoying
    -- So do one cycle of it not working which makes it work for later calls?!?!
    local function PurgeDepthRender()
        cam.PushModelMatrix(Matrix(), false)
        render.OverrideDepthEnable(true, true)
        render.OverrideDepthEnable(false, false)
        cam.PopModelMatrix()
    end

    function RenderRoom()
        local node = GetSwitchroom(LocalPlayer())
        if !node then return end
        render.UpdateScreenEffectTexture()
        render.ClearDepth()
        mat_world_cut:SetTexture("$basetexture", render.GetScreenEffectTexture(0))

        render.SetColorModulation(1,1,1)
        render.SuppressEngineLighting(true)
       --render.OverrideDepthEnable(false, true)
        local camPos, camAng = getVirtualCam()
        cam.Start(
            {
                x = 0,
                y = 0,
                w = w,
                h = h,
                origin = camPos,
                angles = camAng
            })


            render.ResetModelLighting(0.2,0.18,0.2)



            --render.SetAmbientLight(0.5, 0.5, 0.5)
            --render.SetLightingOrigin( node:GetPos() )
            
            -- Current floor's text
            local curFloorIdx = getCurrentFloor()
            local curFloor = RegisteredFloors[curFloorIdx]

            if curFloor then
                local floorPos = roomHeight * (curFloorIdx-1)


                local lightpos = Vector(0,0,floorPos + roomHeight/2) + curFloor.offset
                render.SetLocalModelLights({{ 
                    type = MATERIAL_LIGHT_DIRECTIONAL,
                    dir = Angle(0, 200, 0):Forward(),
                    innerAngle = 35,
                    outerAngle = 90,
                    color = Vector(1,.5,1) * .5,
                    pos = lightpos,
                    fiftyPercentDistance = 500,
                    zeroPercentDistance = 1000
                },
                { 
                    type = MATERIAL_LIGHT_POINT,
                    color = Vector(1,.8,1) * .5 * 0,
                    pos = lightpos,
                    fiftyPercentDistance = 500,
                    zeroPercentDistance = 1000
                }})

                -- Render floors
                local m = Matrix()
                m:Translate(Vector(0, 0, floorPos) + curFloor.offset)
                cam.PushModelMatrix(m, false)
                    render.OverrideDepthEnable(true, true)
                    render.SetMaterial(mat_ceiling_black)
                    buildRoomFloor(getSafeSideCount(curFloor.sideCount), curFloor.width + 5, roomHeight)

                    render.SetMaterial(mat_floor_wood)
                    buildRoomFloor(getSafeSideCount(curFloor.sideCount), curFloor.width + 5, 0)
                cam.PopModelMatrix()

                PurgeDepthRender()

                -- Now walls
                local m = Matrix()
                m:Translate(Vector(0, 0, floorPos) + curFloor.offset)
                cam.PushModelMatrix(m, false)
                    render.SetMaterial(curFloorIdx == 1 and mat_wall_paper or mat_wall_brick)
                    render.OverrideDepthEnable(true, false)
                    buildRoomWalls(getSafeSideCount(curFloor.sideCount), curFloor.width + 5, roomHeight)
                cam.PopModelMatrix()

                -- Render all doors
                render.OverrideDepthEnable(true, true)
                for _, v in ipairs(curFloor.interacts) do
                    v:Draw()

                    -- Info text for doors
                    if v.type == "door" then
                        if v.info then
                            cam.Start3D2D(v.pos + Vector(0, 0, 138), v.ang + Angle(0, 0, 90), 1)
                                render.PushFilterMag(TEXFILTER.POINT)
                                local linkedNode = getDoorDestination(v)

                                if (v.doortype == "input") then
                                    draw.SimpleText(v.info.event, "TargetID", 0, 0, color_white, TEXT_ALIGN_CENTER)
                                end
                                draw.SimpleText(linkedNode:GetName(), "DebugFixed", 0, 12, color_white, TEXT_ALIGN_CENTER)
                                render.PopFilterMag()
                            cam.End3D2D()      
                        end
                    end

                    if DRAW_DEBUG_BBOX and v.bbox.min and v.bbox.max then
                        render.DrawWireframeBox(v.pos, Angle(), v.bbox.min, v.bbox.max)
                    end
                end


            end
    
        cam.End()
        render.SuppressEngineLighting(false)
        render.OverrideDepthEnable(false, false)
        
    end

    hook.Add("HUDPaint", "hackergoggles_switchroom_hud", function()
        -- On-screen HUD
        local node = GetSwitchroom(LocalPlayer())
        if node then
            draw.DrawText(node:GetName(), "TargetID", ScrW()/2, ScrH() - ScrH()*0.07, color_white, TEXT_ALIGN_CENTER)
            draw.DrawText(node:GetClass(), "DebugFixed", ScrW()/2, ScrH() - ScrH()*0.055, color_green, TEXT_ALIGN_CENTER)
        end
    end)

    -- Render the inside of the jazz void with the default void material
    -- This void material has a rendertarget basetexture we update each frame
    hook.Add( "PreDrawEffects", "hackergoggles_switchroom_render", function()
        if !GetSwitchroom(LocalPlayer()) then return end
        RenderRoom()
    end )

    hook.Add("Think", "hackergoggles_switchroom_movethink", function()
        if !GetSwitchroom(LocalPlayer()) then return end
        MoveThink(FrameTime())
    end )

    local view = {}
    hook.Add("CalcView", "hackergoggles_switchroom_viewshift", function(ply, origin, angle, fov, znear, zfar)
        local node = GetSwitchroom(LocalPlayer())
        if !node then return end

        local pos, ang = getVirtualCam()
        view.origin = node:GetPos() + pos * 0.05
        view.znear = znear * 0.1
        return view
    end )

    -- Listen for IO events for cool blips
    hook.Add("IOEventTriggered", "hackergoggles_switchroom_blips", function(ent, event)
        print(ent, event)
        for _, v in pairs(RegisteredFloors) do
            for __, door in pairs(v.interacts) do
                if door.type == "door" && door.info && door.info.event == event && door.trace then
                    print(CurTime(), door.info.delay)
                    door.trace:AddBlip(tonumber(door.info.delay))
                end
            end
        end
    end )

end

concommand.Add("jazz_hacker_randomswitchroom", function(ply, cmd, args)
    local graph = iograph.New()
    
    -- Get a list of random interesting nodes
    local candidateNodes = {}
    for ent in graph:Ents() do
        if table.Count(ent:GetInputs()) > 0 || table.Count(ent:GetOutputs()) > 0 then
            table.insert(candidateNodes, ent)
        end
    end

    switchroom.SetSwitchroom(ply, candidateNodes[ math.random( #candidateNodes ) ])
end )

concommand.Add("jazz_hacker_setroom", function(ply, cmd, args)
    local graph = iograph.New()

    -- Get a list of random interesting nodes
    local candidateNodes = {}
    for ent in graph:EntsByName(args[1]) do
        if table.Count(ent:GetInputs()) > 0 || table.Count(ent:GetOutputs()) > 0 then
            table.insert(candidateNodes, ent)
        end
    end

    switchroom.SetSwitchroom(ply, candidateNodes[ math.random( #candidateNodes ) ])

end )