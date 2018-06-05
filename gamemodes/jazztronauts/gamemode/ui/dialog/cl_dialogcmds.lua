module("dialog", package.seeall)


local function parsePosAng(...)
    local args = table.concat({ ... }, " ")
    local posang = string.Split(args, ";")
    local tblPosAng = {}

    if posang[1] then
        tblPosAng.pos = Vector(string.Replace(posang[1], "setpos", ""))
    end
    if posang[2] then
        tblPosAng.ang = Angle(string.Replace(posang[2], "setang", ""))
    end

    return tblPosAng
end

dialog.RegisterFunc("player", function(d, time)
    return LocalPlayer():GetName()
end)

dialog.RegisterFunc("wait", function(d, time)
    local time = tonumber(time) or 0
    local waittime = CurTime() + time
    while CurTime() < waittime do
        coroutine.yield()
    end
end)

dialog.RegisterFunc("txout", function(d, nowait)
    transitionOut()
    local nowait = tobool(nowait)

    while !nowait and isTransitioning() do
        coroutine.yield()
    end
end)

dialog.RegisterFunc("txin", function(d, nowait)
    transitionIn()
    local nowait = tobool(nowait)

    while !nowait and isTransitioning() do
        coroutine.yield()
    end
end)

dialog.RegisterFunc("hide", function(d, time)
    local time = tonumber(time) or 0
    local closetime = CurTime() + time

    while CurTime() < closetime do
        d.open = (closetime - CurTime()) / time
        coroutine.yield()
    end

    d.open = 0
end)

dialog.RegisterFunc("show", function(d, time)
    local time = tonumber(time) or 0
    local closetime = CurTime() + time

    while CurTime() < closetime do
        d.open = 1 - (closetime - CurTime()) / time
        coroutine.yield()
    end

    d.open = 1
end)

local sceneModels = {}
local function removeSceneEntity(name)
    if IsValid(sceneModels[name]) then
        sceneModels[name]:SetNoDraw(true)
        sceneModels[name] = nil
    end
end
dialog.RegisterFunc("spawn", function(d, name, mdl)
    sceneModels[name] = ManagedCSEnt(name, mdl)
    sceneModels[name]:SetNoDraw(false)
end)

dialog.RegisterFunc("remove", function(d, name)
    removeSceneEntity(name)
end)

dialog.RegisterFunc("clear", function(d)
    ResetScene()
end)

dialog.RegisterFunc("setproxy", function(d, name)
    dialog.SetFocusProxy(name and sceneModels[name])
end)

dialog.RegisterFunc("setfocus", function(d, npc)
    local npcid = tonumber(npc) or missions.GetNPCID(npc)
    dialog.SetFocus(npcid and missions.FindNPCByID(npcid))
end)

dialog.RegisterFunc("setposang", function(d, name, ...)
    local prop = sceneModels[name]
    if not IsValid(sceneModels[name]) then return end

    local posang = parsePosAng(...)
    if posang.pos then
        prop:SetPos(posang.pos)
    end
    if posang.ang then
        prop:SetAngles(posang.ang)
    end
end)

dialog.RegisterFunc("setanim", function(d, name, anim)
    local prop = sceneModels[name]
    if not IsValid(sceneModels[name]) then return end

    prop:SetSequence(anim)
end)

local view = {}
dialog.RegisterFunc("setcam", function(d, ...)
    local posang = parsePosAng(...)

    if !posang.pos or !posang.ang then
        view = nil     
        sceneModels = {}
        return
    end

    view = view or {}
    view.endtime = nil
    view.origin = posang.pos
    view.angles = posang.ang

end)

dialog.RegisterFunc("tweencam", function(d, time, ...)
    local time = tonumber(time)
    local posang = parsePosAng(...)

    if !posang.pos or !posang.ang then
        view = nil     
        sceneModels = {}
        return
    end

    if view then 
        view.startpos = view.origin
        view.startang = view.angles
        view.goalpos = posang.pos
        view.goalang = posang.ang
        view.endtime = CurTime() + time
        view.tweenlen = time
    else
        view = {}
        view.origin = posang.pos
        view.angles = posang.ang
    end
end)

dialog.RegisterFunc("setfov", function(d, fov)
    local fov = tonumber(fov)

    view = view or {}
    view.fov = fov
end)

function ResetScene()
    for k, v in pairs(sceneModels) do
        removeSceneEntity(k)
    end

    sceneModels = {}
end

function ResetView(instant)
    local function reset()
        view = {}
        ResetScene()
    end

    //Only do the transition if we've actually overwritten something
    if table.Count(view) > 0 and not instant then
        transitionOut()
        timer.Simple(1.5, function()
            reset()
        transitionIn()
        end)
    else
        reset()
    end
end

hook.Add("CalcView", "JazzDialogView", function(ply, origin, angles, fov, znear, zfar)
    if not view then return end
    
    -- Maybe do some tweening
    if view.endtime then
        local p = 1 - math.Clamp((view.endtime - CurTime()) / view.tweenlen, 0, 1)

        view.origin = LerpVector(p, view.startpos, view.goalpos)
        view.angles = LerpAngle(p, view.startang, view.goalang)

        if p >= 1 then
            view.endtime = nil
        end
    end

    return view
end )

hook.Add("Think", "JazzTickClientsideAnims", function()
    for k, v in pairs(sceneModels) do
        if IsValid(v) then
            v:SetCycle(CurTime())
        end
    end
end )

-- Disable motion blur while in a dialog, as scene changes break it pretty bad
hook.Add("GetMotionBlurValues", "JazzDisableMblurDialg", function(h, v, f, r)
    if dialog.IsInDialog() then return 0, 0, 0, 0 end
end )