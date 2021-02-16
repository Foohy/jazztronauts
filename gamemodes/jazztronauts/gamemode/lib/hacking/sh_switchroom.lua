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
    --TODO: everything
    -- just play around with rendering for now

    RegisteredDoors = RegisteredDoors or {}
    RegisteredFloors = RegisteredFloors or {}
    SelectedDoor = SelectedDoor or nil
    local DRAW_DEBUG_BBOX = false

    local DoorOpen = Sound("doors/door1_move.wav")
    local DoorClose = Sound("doors/door_wood_close1.wav")

    local wall_outside_material_params =
    {
        ["$basetexture"]    = "effects/jazz_void_tooltex",
        ["$normalmap"]      = "sunabouzu/jazzshell_dudv",
        ["$refracttint"]    = "[1 1 1]",
        ["$additive"]       = 0,
        ["$vertexcolor"]    = 1,
        ["$vertexalpha"]    = 0,
        ["$refractamount"]  = 0.03,
        ["$bluramount"]     = 0,
        ["$model"]          = 1,
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


    local wall_outside_material = CreateMaterial("HackergogglesWallMaterial" .. FrameNumber(), "Refract", wall_outside_material_params)
    local wall_surface_material = CreateMaterial("HackergogglesWallSurfaceMaterial" .. FrameNumber(), "UnlitGeneric", wall_surface_material_params)
    local wall_floor_material = CreateMaterial("HackergogglesWallFloorMaterial" .. FrameNumber(), "UnlitGeneric", wall_floor_material_params)

    local roomWidth = 200
    local roomHeight = 150

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
        return math.floor(getLadderCamPos().z / roomHeight)
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
    local function addDoor(pos, ang, type, info)
        local doorInfo = {
            pos = pos,
            ang = ang,
            type = type,
            info = info,
            bbox = {min = Vector(-30, -30, 0), max = Vector(30,30,120)}
        }

        -- Create its own clientside ent for it
        local door = ManagedCSEnt("jazz_hackergoggles_door_" .. table.Count(RegisteredDoors), "models/sunabouzu/jazzdoor.mdl")
        door:SetNoDraw(true)
        door:SetPos(pos)
        door:SetAngles(ang)
        door:SetupBones()
        door:ResetSequenceInfo()
        door:SetSequence(1)
        door:SetCycle(1)

        doorInfo.csent = door

        table.insert(RegisteredDoors, doorInfo)
    end
    local function addFloor(name, sideCount, width, offset)
        local floorInfo = {
            name = name,
            sideCount = sideCount,
            width = width,
            offset = offset or Vector()
        }

        -- TODO: Generate mesh here instead of dynamically?

        table.insert(RegisteredFloors, floorInfo)
    end

    local function selectDoor(idx)
        if !idx or !RegisteredDoors[idx] then return end
        
        local doorInfo = RegisteredDoors[idx]
        local ply = LocalPlayer()
        ply["HackerGogglesSelectGoal"] = {
            goalPos = doorInfo.pos,
            goalAng = doorInfo.ang,
            dooridx = idx,
            t = 0
        }
        ply:ScreenFade(SCREENFADE.OUT, color_white, 0.75, 0)

    end

    local function getDoorDestination(door)
        if door and door.info then
            return door.type == "output" and door.info.to or door.info.from
        end
    end

    local function buildRoomWalls(numSides, width, height)
        mesh.Begin(MATERIAL_QUADS, numSides)
        for i = 0, numSides do
            local curAng = ((i + 0.5) * 1.0 / numSides) * 2.0 * math.pi
            local nextAng = ((i+1.5) * 1.0 / numSides) * 2.0 * math.pi
            local curX, curY = math.cos(curAng) * width, math.sin(curAng) * width
            local nextX, nextY = math.cos(nextAng) * width, math.sin(nextAng) * width

            mesh.Position(Vector(curX, curY, 0))
            mesh.TexCoord(0, 0, 0)
            mesh.AdvanceVertex()

            mesh.Position(Vector(curX, curY, height))
            mesh.TexCoord(0, 1, 0)
            mesh.AdvanceVertex()

            mesh.Position(Vector(nextX, nextY, height))
            mesh.TexCoord(0, 1, 1)
            mesh.AdvanceVertex()

            mesh.Position(Vector(nextX, nextY, 0))
            mesh.TexCoord(0, 0, 1)
            mesh.AdvanceVertex()
        end
        mesh.End()
    end

    local function buildRoomFloor(numSides, width, height)
        mesh.Begin(MATERIAL_POLYGON, numSides)
        for i = 0, numSides do
            local curAng = ((i + 0.5) * 1.0 / numSides) * 2.0 * math.pi
            local nextAng = ((i+1.5) * 1.0 / numSides) * 2.0 * math.pi
            local curX, curY = math.cos(curAng) * width, math.sin(curAng) * width
            local nextX, nextY = math.cos(nextAng) * width, math.sin(nextAng) * width

            mesh.Position(Vector(curX, curY, height))
            mesh.TexCoord(0, math.cos(curAng), math.sin(curAng))
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

    function SetupRoom(node)
        RegisteredDoors = {}
        RegisteredFloors = {}
        numInputs = table.Count(node:GetInputs())
        numOutputs = table.Count(node:GetOutputs())
        local numSides = getNumSides()

        -- Base floor input doors
        local i = 0
        for k, v in pairs(node:GetInputs()) do
            local pos, ang = getRoomPlacement(i, numSides, numInputs, roomWidth)
            addDoor(pos, ang, "input", v)
            i = i + 1
        end
        

        -- Exit door
        local curAng = ((-0.5) * 1.0 / numSides) * 2.0 * math.pi
        local nextAng = ((0.5) * 1.0 / numSides) * 2.0 * math.pi
        local doorPos = LerpVector(0.5, Vector(math.cos(curAng), math.sin(curAng), 0), Vector(math.cos(nextAng), math.sin(nextAng), 0)) * roomWidth
        addDoor(doorPos, Angle(0, math.deg((curAng + nextAng)/2, 0) - 90), "exit")

        -- Bottom floor has N sides for all the dors
        --addFloor(table.Count(node:GetInputs()))

        -- Output doors
        -- These are grouped based on shared events
        local groupedOutputs = {}
        for k, v in pairs(node:GetOutputs()) do  
            groupedOutputs[v.event] = groupedOutputs[v.event] and groupedOutputs[v.event] + 1 or 1
        end
        
        local floor = 1
        for event, n in SortedPairsByValue(groupedOutputs, true) do
            local sizeOffset = n * 5
            -- Each event group is its own floor
            addFloor(event, n, roomWidth + sizeOffset, Vector(-sizeOffset*2, 0, 0))

            -- Store more doors for floor lore
            local i = 0
            for k, v in pairs(node:GetOutputs()) do
                if v.event ~= event then continue end
                local pos, ang = getRoomPlacement(i, getSafeSideCount(n), n, roomWidth + sizeOffset)
                addDoor(pos + Vector(-sizeOffset*2,0,roomHeight * floor), ang, "output", v)
                i = i + 1
            end 

            floor = floor + 1
        end
        
    end

    local function findTrace()
        local start = getLadderCamPos()
        local dir = LocalPlayer():EyeAngles():Forward()

        for k, v in ipairs(RegisteredDoors) do
            local hit, t = IntersectRayBox(start, dir, v.bbox.min + v.pos, v.bbox.max + v.pos)
            if hit then
                return k, v, t
            end
        end
    end

    
    hook.Add("KeyPress", "hackergoggles_switchroom_keypress", function(ply, key)
        if !GetSwitchroom(LocalPlayer()) then return end

        if (key == IN_ATTACK) then
            selectDoor(SelectedDoor)
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
        if pos < 0 || pos > roomHeight*#RegisteredFloors then vel = 0 end
        pos = math.Clamp(pos, 0, roomHeight * #RegisteredFloors)
        ply["HackerGogglesVertPos"] = pos
        ply["HackerGogglesVelocity"] = vel
        --print("Goal Velocity: " ..  goalVel .. ", vel: " ..  vel .. ", pos:  " .. pos)




        -- Manually advance door anims
        for _, v in pairs(RegisteredDoors) do
            if v and IsValid(v.csent) then v.csent:FrameAdvance() end
        end


        -- Selection tween anim
        local selectGoal = ply["HackerGogglesSelectGoal"] 
        if selectGoal then
            selectGoal.t = selectGoal.t + dt * 1.5

            if selectGoal.t >= 1 then
                local dest = getDoorDestination(RegisteredDoors[SelectedDoor])
                Travel(ply, dest)
                ply["HackerGogglesSelectGoal"] = nil
            end
        else -- If no goal, trace and search for selected door
            local idx, door, t = findTrace()
            if (SelectedDoor != idx) then
                local oldDoor = SelectedDoor and RegisteredDoors[SelectedDoor]
                local newDoor = door
                if oldDoor and IsValid(oldDoor.csent) then
                    oldDoor.csent:ResetSequence(1)
                    oldDoor.csent:ResetSequenceInfo()
                    oldDoor.csent:SetCycle(0)
    
                    --oldDoor.csent:EmitSound( DoorClose)
                end
                if newDoor and IsValid(newDoor.csent) then
                    newDoor.csent:ResetSequence(0)
                    newDoor.csent:ResetSequenceInfo()
                    newDoor.csent:SetCycle(0)
                    newDoor.csent:EmitSound(DoorOpen)
                end
    
                SelectedDoor = idx
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
        render.UpdateScreenEffectTexture()
        render.ClearDepth()
        wall_outside_material:SetTexture("$basetexture", render.GetScreenEffectTexture(0))
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

            local numSides = getNumSides()

            render.SetColorModulation(1, 1, 1)

            render.SetMaterial(wall_floor_material)
            buildRoomFloor(numSides, roomWidth + 5, 0)
            render.OverrideDepthEnable(true, false)
                buildRoomFloor(numSides, roomWidth + 5, roomHeight)
            render.OverrideDepthEnable(true, true)


            render.SetMaterial(wall_outside_material)
            buildRoomWalls(numSides, roomWidth + 5, roomHeight)
            buildRoomFloor(numSides, roomWidth + 5, 0)

            --render.SetMaterial(wall_surface_material)
            --buildRoomWalls(numSides, roomWidth + 5, roomHeight)

            render.SetMaterial(wall_surface_material)
            buildRoomFloor(numSides, roomWidth + 5, 0)
            
            PurgeDepthRender()

            -- Each output event group
            render.SetMaterial(wall_floor_material)
            render.OverrideDepthEnable(true, true)
            for k, v in ipairs(RegisteredFloors) do
                local m = Matrix()
                m:Translate(Vector(0, 0, roomHeight * k) + v.offset)
                cam.PushModelMatrix(m, false)
                    render.OverrideDepthEnable(true, true)
                    buildRoomFloor(getSafeSideCount(v.sideCount), v.width + 5, roomHeight)
                    buildRoomFloor(getSafeSideCount(v.sideCount), v.width + 5, 0)
                cam.PopModelMatrix()
            end

            PurgeDepthRender()

            -- Once more for walls (separate pass so doors always draw on top of them)
            render.SetMaterial(wall_outside_material)
            render.OverrideDepthEnable(true, false)
            for k, v in ipairs(RegisteredFloors) do
                local m = Matrix()
                m:Translate(Vector(0, 0, roomHeight * k) + v.offset)
                cam.PushModelMatrix(m, false)
                    render.OverrideDepthEnable(true, false)
                    buildRoomWalls(getSafeSideCount(v.sideCount), v.width + 5, roomHeight)
                cam.PopModelMatrix()
            end
            render.OverrideDepthEnable(false, false)

            
            -- Render all doors
            for _, v in ipairs(RegisteredDoors) do
                if IsValid(v.csent) then
                    v.csent:DrawModel()

                    -- Info text
                    if v.info then
                        cam.Start3D2D(v.pos + Vector(0, 0, 138), v.ang + Angle(0, 0, 90), 1)
                            render.PushFilterMag(TEXFILTER.POINT)
                            local linkedNode = getDoorDestination(v)
                            if (v.type == "input") then
                                draw.SimpleText(v.info.event, "TargetID", 0, 0, color_white, TEXT_ALIGN_CENTER)
                            end
                            draw.SimpleText(linkedNode:GetName(), "DebugFixed", 0, 12, color_white, TEXT_ALIGN_CENTER)
                            render.PopFilterMag()
                        cam.End3D2D()      
                    end

                    if DRAW_DEBUG_BBOX then
                        render.DrawWireframeBox(v.pos, Angle(), v.bbox.min, v.bbox.max)
                    end
                end
            end


            -- Current floor's text
            local curFloorIdx = getCurrentFloor()
            local curFloor = RegisteredFloors[curFloorIdx]
            if curFloor then
                render.OverrideDepthEnable(false, false)
                
                -- Center text
                cam.Start3D2D(Vector(0, 0, roomHeight * curFloorIdx + 43) + curFloor.offset, Angle(0, 90, 90), 1)
                cam.IgnoreZ(true)
                    render.PushFilterMag(TEXFILTER.POINT)
                    draw.SimpleText(curFloor.name, "TargetID", 0, 0, color_white, TEXT_ALIGN_CENTER)
                    render.PopFilterMag()
                cam.IgnoreZ(false)
                cam.End3D2D()
            end
    
        cam.End()
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