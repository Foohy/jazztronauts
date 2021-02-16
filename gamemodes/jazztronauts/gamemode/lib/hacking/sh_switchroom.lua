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
    local function createDoor(pos, ang, doortype, info)
        local door = table.Merge(createInteract("door", Vector(-30, -30, 0), Vector(30,30,120)), 
        {
            pos = pos,
            ang = ang,
            doortype = doortype,
            info = info,
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

    -- models/msx/msx_computer.mdl
    -- models/sunabouzu/jazzbigtv.mdl (scale down)
    function SetupRoom(node)
        totalInteracts = 0
        RegisteredFloors = {}
        numInputs = table.Count(node:GetInputs())
        numOutputs = table.Count(node:GetOutputs())
        local numSides = getNumSides()

        -- Base floor input doors
        local floorDoors = {}
        local i = 0
        for k, v in pairs(node:GetInputs()) do
            local pos, ang = getRoomPlacement(i, numSides, numInputs, roomWidth)
            table.insert(floorDoors, createDoor(pos, ang, "input", v))
            i = i + 1
        end
        

        -- Exit door
        local curAng = ((-0.5) * 1.0 / numSides) * 2.0 * math.pi
        local nextAng = ((0.5) * 1.0 / numSides) * 2.0 * math.pi
        local doorPos = LerpVector(0.5, Vector(math.cos(curAng), math.sin(curAng), 0), Vector(math.cos(nextAng), math.sin(nextAng), 0)) * roomWidth
        table.insert(floorDoors, createDoor(doorPos, Angle(0, math.deg((curAng + nextAng)/2, 0) - 90), "exit"))

        -- Bottom floor has N sides for all the doors
        -- addFloor(table.Count(node:GetInputs()))
        local bottomDoorCount = table.Count(node:GetInputs())
        local bottomSizeOffset = bottomDoorCount * 5
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

            -- Store more doors for floor lore
            local i = 0
            for k, v in pairs(node:GetOutputs()) do
                if v.event ~= event then continue end
                local pos, ang = getRoomPlacement(i, getSafeSideCount(n), n, roomWidth + sizeOffset)
                table.insert(floorInteracts, createDoor(pos + Vector(-sizeOffset*2,0,roomHeight * floor), ang, "output", v))
                i = i + 1
            end

            -- Center computer thing
            table.insert(floorInteracts, createComputer(Vector(-sizeOffset*2 - 25, 0, roomHeight * floor), Angle(), event))

            -- Each event group is its own floor
            addFloor(event, n, roomWidth + sizeOffset, Vector(-sizeOffset*2, 0, 0), floorInteracts)

            floor = floor + 1
        end
        
    end

    local function findTrace()
        local start = getLadderCamPos()
        local dir = LocalPlayer():EyeAngles():Forward()

        for k, v in ipairs(getCurrentInteracts()) do
            local hit, t = IntersectRayBox(start, dir, v.bbox.min + v.pos, v.bbox.max + v.pos)
            if hit then
                return k, v, t
            end
        end
    end

    
    hook.Add("KeyPress", "hackergoggles_switchroom_keypress", function(ply, key)
        if !GetSwitchroom(LocalPlayer()) then return end

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
            
            -- Current floor's text
            local curFloorIdx = getCurrentFloor()
            local curFloor = RegisteredFloors[curFloorIdx]

            if curFloor then
                local floorPos = roomHeight * (curFloorIdx-1)
                -- Render floors
                local m = Matrix()
                m:Translate(Vector(0, 0, floorPos) + curFloor.offset)
                cam.PushModelMatrix(m, false)
                    render.SetMaterial(wall_surface_material)
                    render.OverrideDepthEnable(true, true)
                    buildRoomFloor(getSafeSideCount(curFloor.sideCount), curFloor.width + 5, roomHeight)
                    buildRoomFloor(getSafeSideCount(curFloor.sideCount), curFloor.width + 5, 0)
                cam.PopModelMatrix()

                PurgeDepthRender()

                -- Now walls
                local m = Matrix()
                m:Translate(Vector(0, 0, floorPos) + curFloor.offset)
                cam.PushModelMatrix(m, false)
                    render.SetMaterial(wall_outside_material)
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

                    if DRAW_DEBUG_BBOX then
                        render.DrawWireframeBox(v.pos, Angle(), v.bbox.min, v.bbox.max)
                    end
                end


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