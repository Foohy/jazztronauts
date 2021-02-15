AddCSLuaFile()

module( "switchroom", package.seeall )

CMD_EXIT    = 0
CMD_HACK    = 1
CMD_TRAVEL  = 2

function SetSwitchroom(ply, node)
    if !IsValid(ply) then return end
    ply["HackerGogglesSwitchroom"] = string.len(node) > 0 and node
    ply["HackerGogglesReferencePos"] = ply:GetPos() -- TODO: node:GetPos() or something

    if SERVER then
        net.Start("jazz_hackergoggles_switchroom")
            net.WriteString(node)
        net.Send(ply)
    end
    if CLIENT then
        SetupRoom(node)
    end
end
if CLIENT then 
    net.Receive("jazz_hackergoggles_switchroom", function(len)
        local node = net.ReadString()

        SetSwitchroom(LocalPlayer(), node)
    end )
end
if SERVER then
    net.Receive("jazz_hackergoggles_switchroom", function(len, ply)
        local cmd = net.ReadInt(8)
        if cmd == CMD_EXIT then
            Exit(ply)
        elseif cmd == CMD_HACK then
            local node = net.ReadString()
            Hack(ply, node)
        elseif cmd == CMD_TRAVEL then
            local node = net.ReadString()
            Travel(ply, node)
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
        SetSwitchroom(ply, "")
    end
end

function Hack(ply, node)
    node = node or ""
    if CLIENT then
        net.Start("jazz_hackergoggles_switchroom")
            net.WriteInt(CMD_HACK, 8)
            net.WriteString(node)
        net.SendToServer()
    elseif SERVER then
        -- TODO
        Exit(ply)
    end
end

function Travel(ply, node)
    node = node or ""
    if CLIENT then
        net.Start("jazz_hackergoggles_switchroom")
            net.WriteInt(CMD_TRAVEL, 8)
            net.WriteString(node)
        net.SendToServer()
    elseif SERVER then
        -- TODO
        Exit(ply)
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


hook.Add("SetupMove", "hackergoggles_startmove", function(ply, mv, cmd)
    local switch = GetSwitchroom(ply)
    if (!switch) then return end

end )

hook.Add("Move", "hackergoggles_move", function(ply, mv)
    local switch = GetSwitchroom(ply)
    if (!switch) then return end
    --print(mv:GetForwardSpeed())

    --return true
end )

hook.Add("FinishMove", "hackergoggles_finishmove", function(ply, mv)
    local switch = GetSwitchroom(ply)
    if (!switch) then return end
    --print(mv:GetForwardSpeed())

    --return true
end )


-- thanks zak
local fmax = math.max
local fmin = math.min
local function rayVBox(ox, oy, oz, dx, dy, dz, min, max)

	local x0,y0,z0 = min:Unpack()
	local x1,y1,z1 = max:Unpack()

	local t0 = (x0 - ox) * dx
	local t1 = (x1 - ox) * dx
	local t2 = (y0 - oy) * dy
	local t3 = (y1 - oy) * dy
	local t4 = (z0 - oz) * dz
	local t5 = (z1 - oz) * dz

	local tmin = 
	fmax(
		fmax(
			fmin(t0,t1), 
			fmin(t2,t3)
		),
		fmin(t4,t5)
	)

	local tmax = 
	fmin(
		fmin(
			fmax(t0,t1), 
			fmax(t2,t3)
		),
		fmax(t4,t5)
	)

	if tmax < 0 then return false end
	if tmin > tmax then return false end

	return true, tmin

end

if SERVER then
    util.AddNetworkString( "jazz_hackergoggles_switchroom" )
end

if CLIENT then
    --TODO: everything
    -- just play around with rendering for now

    RegisteredDoors = RegisteredDoors or {}
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

    local function getNumSides()
        return (numInputs <= 3) and 4 or (numInputs + 3)
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
    local function addDoor(pos, ang, type)
        local doorInfo = {
            pos = pos,
            ang = ang,
            type = type,
            bbox = {min = Vector(-30, -30, 0), max = Vector(30,30,120)}
        }

        -- Create its own clientside ent for it
        local door = ManagedCSEnt("jazz_hackergoggles_door_" .. table.Count(RegisteredDoors), "models/sunabouzu/jazzdoor.mdl")
        door:SetNoDraw(true)
        door:SetPos(pos)
        door:SetAngles(ang)
        door:SetupBones()
        door:ResetSequenceInfo()

        doorInfo.csent = door

        table.insert(RegisteredDoors, doorInfo)
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

    function SetupRoom(node)
        RegisteredDoors = {}
        local numSides = getNumSides()

        -- Base floor input doors
        for i=0, numInputs-1 do
            local curAng = ((i+0.5 + 1) * 1.0 / numSides) * 2.0 * math.pi
            local nextAng = ((i+1.5 + 1) * 1.0 / numSides) * 2.0 * math.pi
            -- special cases for small numbers
            if numInputs == 2 && i == 0 then 
                curAng = curAng - math.pi/2
                nextAng = nextAng - math.pi/2
            end
            if (numInputs == 3) then
                curAng = curAng - (1 * 1.0 / numSides) * 2.0 * math.pi
                nextAng = nextAng - (1 * 1.0 / numSides) * 2.0 * math.pi
            end

            local doorPos = LerpVector(0.5, Vector(math.cos(curAng), math.sin(curAng), 0), Vector(math.cos(nextAng), math.sin(nextAng), 0)) * roomWidth
            addDoor(doorPos, Angle(0, math.deg((curAng + nextAng)/2, 0) - 90), "input")
        end

        -- Exit door
        local curAng = ((-0.5) * 1.0 / numSides) * 2.0 * math.pi
        local nextAng = ((0.5) * 1.0 / numSides) * 2.0 * math.pi
        local doorPos = LerpVector(0.5, Vector(math.cos(curAng), math.sin(curAng), 0), Vector(math.cos(nextAng), math.sin(nextAng), 0)) * roomWidth
        addDoor(doorPos, Angle(0, math.deg((curAng + nextAng)/2, 0) - 90), "exit")

        -- Output doors
        for i=1, numOutputs do           
            addDoor(Vector(-roomWidth * math.sqrt(2) * 0.5 + 5, 0, roomHeight * i), Angle(0, 90, 0), "output")
        end
    end

    local function findTrace()
        local start = getLadderCamPos()
        local dir = LocalPlayer():EyeAngles():Forward()
        local ox, oy, oz = start:Unpack()
    
        local dx = 1/dir.x
        local dy = 1/dir.y
        local dz = 1/dir.z

        for k, v in ipairs(RegisteredDoors) do
            local hit, t = rayVBox(ox, oy, oz, dx, dy, dz, v.bbox.min + v.pos, v.bbox.max + v.pos)
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
        if pos < 0 || pos > roomHeight*numOutputs then vel = 0 end
        pos = math.Clamp(pos, 0, roomHeight * numOutputs)
        ply["HackerGogglesVertPos"] = pos
        ply["HackerGogglesVelocity"] = vel
        --print("Goal Velocity: " ..  goalVel .. ", vel: " ..  vel .. ", pos:  " .. pos)


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

        -- Manually advance door anims
        for _, v in pairs(RegisteredDoors) do
            if v and IsValid(v.csent) then v.csent:FrameAdvance() end
        end


        -- Selection tween anim
        local selectGoal = ply["HackerGogglesSelectGoal"] 
        if selectGoal then
            selectGoal.t = selectGoal.t + dt * 1.5

            if selectGoal.t >= 1 then
                Travel(ply, "whatevernextnode")
                ply["HackerGogglesSelectGoal"] = nil
            end
        end
    end

    function RenderRoom()

        --models/sunabouzu/jazzdoor.mdl
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
            
            -- I honestly, truly, have no idea why this is necessary right here
            -- For some reason OverrideDepthEnable doesn't work for the very bottom floor
            -- So do what it was gonna do but don't render anything
            cam.PushModelMatrix(Matrix(), false)
            render.OverrideDepthEnable(true, true)
            render.OverrideDepthEnable(false, false)
            cam.PopModelMatrix()


            -- Each output
            render.OverrideDepthEnable(true, true)
            for i=1, numOutputs do
                local m = Matrix()
                m:Translate(Vector(0, 0, roomHeight * i))
                cam.PushModelMatrix(m, false)
                    render.SetMaterial(wall_floor_material)
                    if (i==numOutputs) then
                        buildRoomFloor(4, roomWidth + 5, roomHeight)
                    end
                    buildRoomFloorHole( roomWidth + 5, 0, 25, 70)
                             
                cam.PopModelMatrix()
            end
            render.OverrideDepthEnable(false, false)

            -- Each output (walls)
            render.OverrideDepthEnable(true, false)
            for i=1, numOutputs do
                local m = Matrix()
                m:Translate(Vector(0, 0, roomHeight * i))
                cam.PushModelMatrix(m, false)
                    render.SetMaterial(wall_outside_material)
                    buildRoomWalls(4, roomWidth, roomHeight)

                    render.SetMaterial(wall_surface_material)
                    buildRoomWalls(4, roomWidth, roomHeight)
                cam.PopModelMatrix()
            end
            render.OverrideDepthEnable(false, false)

            
            -- Render all doors
            for _, v in ipairs(RegisteredDoors) do
                if IsValid(v.csent) then
                    v.csent:DrawModel()

                    if DRAW_DEBUG_BBOX then
                        render.DrawWireframeBox(v.pos, Angle(), v.bbox.min, v.bbox.max)
                    end
                end
            end
    
        cam.End()
        render.OverrideDepthEnable(false, false)
        
    end

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

    hook.Add("StartCommand", "hackergoggles_switchroom_movement", function(ply, cmd)
        --if !CurrentRoom then return end

        --cmd:ClearMovement()
    end )

    local view = {}
    hook.Add("CalcView", "hackergoggles_switchroom_viewshift", function(ply, origin, angle, fov, znear, zfar)
        if !GetSwitchroom(LocalPlayer()) then return end

        local pos, ang = getVirtualCam()
        view.origin = origin + pos * 0.05
        return view
    end )

end

for k, v in pairs(player.GetAll()) do
    --SetSwitchroom(v, "")
end