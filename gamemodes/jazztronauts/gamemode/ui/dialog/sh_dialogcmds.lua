AddCSLuaFile()

module("dialog", package.seeall)


-- Use of the map trigger command must be on entity names prefixed with this
local mapTriggerPrefix = "jazzio_"

if SERVER then
    util.AddNetworkString( "dialog_requestcommand" )

    net.Receive("dialog_requestcommand", function(len, ply)
        if not IsValid(ply) or not mapcontrol.IsInGamemodeMap() then 
            ErrorNoHalt("Dialog map triggers only work within jazztronaut gamemode maps!")
            return 
        end
        local entName = net.ReadString()
        local inp = net.ReadString()
        local param = net.ReadString()

        if string.sub(entName, 0, #mapTriggerPrefix) != mapTriggerPrefix then 
            ErrorNoHalt("Dialog map triggers only work on entities prefixed with \"" .. mapTriggerPrefix .. "\"")
            return 
        end

        local entities = ents.FindByName(entName)
        for _, v in pairs(entities) do
            v:Fire(inp, param)
        end
    end )

    util.AddNetworkString( "dialog_requestpvs" )
    net.Receive("dialog_requestpvs", function(len, ply)
        if not IsValid(ply) or not mapcontrol.IsInGamemodeMap() then 
            print("*setcam* will only add to PVS in gamemode maps!")
            return 
        end
        local pos = net.ReadVector()
        ply.JazzDialogPVS = pos
    end )

    hook.Add("JazzDialogFinished", "JazzRemoveDialogPVS", function(ply, script, mark)
        ply.JazzDialogPVS = nil
    end)

    hook.Add("SetupPlayerVisibility", "JazzAddDialogPVS", function(ply, view)
        if ply.JazzDialogPVS then
            AddOriginToPVS(ply.JazzDialogPVS)
        end
    end )

end

if not CLIENT then return end

-- Fires an output on a named entity on the server
-- Try to avoid using this unless specifically needed for something
dialog.RegisterFunc("fire", function(d, entityName, inputName, fireParams)
    if not entityName or not inputName then 
        ErrorNoHalt("*fire <entityName> <inputName> [fireParams]* requires an entity name and input name!")
        return
    end

    net.Start("dialog_requestcommand")
        net.WriteString(entityName)
        net.WriteString(inputName)
        net.WriteString(fireParams or "")
    net.SendToServer()
end)

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

local function FindNPCByName(name)
    local lookid = missions.GetNPCID(name)
    local npcs = ents.FindByClass("jazz_cat")
    for _, v in pairs(npcs) do
        if v.GetNPCID and v:GetNPCID() == lookid then 
            return v
        end
    end
end

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

local function FindByName(name)
    if not name then return nil end
    if name == "player" then return LocalPlayer() end
    if name == "focus" then return dialog.GetFocus() end
    if IsValid(sceneModels[name]) then return sceneModels[name] end

    return FindNPCByName(name)
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
    transitionOut(0, nil, true)
    local nowait = tobool(nowait)

    while !nowait and isTransitioning() do
        coroutine.yield()
    end
end)

dialog.RegisterFunc("txin", function(d, nowait)
    transitionIn(0, nil, true)
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

dialog.RegisterFunc("setspeaker", function(d, name)
    dialog.SetFocusProxy(FindByName(name))
end)

dialog.RegisterFunc("setnpcid", function(d, name, npc)
    local prop = FindByName(name)
    if not IsValid(prop) then return end

    -- npc can be the name or npcid, we support both
    prop.JazzDialogID = tonumber(npc) or missions.GetNPCID(npc)
end)

dialog.RegisterFunc("setname", function(d, name, visualname)
    local prop = FindByName(name)
    if not IsValid(prop) then return end

    -- npc can be the name or npcid, we support both
    prop.JazzDialogName = visualname
end)

dialog.RegisterFunc("setposang", function(d, name, ...)
    local prop = FindByName(name)
    if not IsValid(sceneModels[name]) then return end

    local posang = parsePosAng(...)
    if posang.pos then
        prop:SetPos(posang.pos)
    end
    if posang.ang then
        prop:SetAngles(posang.ang)
    end
end)

dialog.RegisterFunc("setanim", function(d, name, anim, speed, finishIdleAnim)
    local prop = FindByName(name)
    if not IsValid(prop) then return end

    prop:SetSequence(anim)
    prop:SetPlaybackRate(tonumber(speed) or 1)

    prop.starttime = CurTime()

    -- If finish anim is specified, this animation won't loop and will return
    -- to the specified idle animation when finished
    prop.finishanim = finishIdleAnim
end)

dialog.RegisterFunc("setskin", function(d, name, skinid)
    local skinid = tonumber(skinid) or 0
    local prop = FindByName(name)

    if IsValid(prop) then
	    prop:SetSkin(skinid)
    end
end )

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

    -- Tell server to load in the specific origin into our PVS
    net.Start("dialog_requestpvs")
        net.WriteVector(posang.pos)
    net.SendToServer()

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

dialog.RegisterFunc("punch", function(d)
    LocalPlayer():ViewPunch(Angle(45, 0, 0))
end )

dialog.RegisterFunc("emitsound", function(d, snd)
    surface.PlaySound(snd)
end )

dialog.RegisterFunc("slam", function(d, ...)
    return table.concat({...}, " ")
end )

dialog.RegisterFunc("shake", function(d, time)
    util.ScreenShake(LocalPlayer():GetPos(), 8, 8, time or 1, 256)
end )

dialog.RegisterFunc("fadeblind", function(d)
    LocalPlayer():ScreenFade(SCREENFADE.IN, color_white, 2, 2)
end )

dialog.RegisterFunc("dsp", function(d, dspid)
    local dspid = tonumber(dspid) or 0
    LocalPlayer():SetDSP(dspid, true)
end )

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
    if not (view and (view.origin or view.fov or view.angles)) then return end

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
            local time = CurTime() - (v.starttime or 0)
            local length = v:SequenceDuration(v:GetSequence())
            local p = v:GetPlaybackRate() * time / length

            v:SetCycle(p)

            -- Handle non-looping animations, reset to specified idle
            if p >= 1.0 and v.finishanim then
                v:SetSequence(v.finishanim)
                v:SetPlaybackRate(1.0)
                v.starttime = CurTime()
                v.finishanim = nil
            end
        end
    end
end )

-- Disable motion blur while in a dialog, as scene changes break it pretty bad
hook.Add("GetMotionBlurValues", "JazzDisableMblurDialg", function(h, v, f, r)
    if dialog.IsInDialog() then return 0, 0, 0, 0 end
end )


-- Background music
local bgmeta = {}

function bgmeta:OnReady(channel, err, errname)
    if not channel then 
        self.failure = true 
        ErrorNoHalt("Failed to play background music " .. self.song .. "\n" .. errname .. "\n") 
        return 
    end
    if channel.endtime then return end -- Already fading out

    channel:SetVolume(0)
    channel:EnableLooping(true)
    channel:Play()
    self.channel = channel
    self.fadetime = self.fadein + RealTime()
end

function bgmeta:Stop(fade)
    fade = fade or 0
    self.fadeout = fade
    self.fadetime = fade + RealTime()
end

function bgmeta:Update()
    if not IsValid(self.channel) then return not self.failure end

    local volume = 0
    if self.fadeout then
        local perc = self.fadeout > 0 and (self.fadetime - RealTime()) / self.fadeout or -1
        volume = perc * self.maxvol
    elseif self.fadein then
        local perc = self.fadein > 0 and (self.fadetime - RealTime()) / self.fadein or 0
        volume = (1 - perc) * self.maxvol
    end

    if volume < 0 then
        self.channel:Stop()
        return false
    end

    self.channel:SetVolume(math.Clamp(volume, 0, 1))
    return true
end

bgmeta.__index = bgmeta

local curBGMusic = nil
local activeMusic = {}
local function playBGMusic(song, volume, fadein)

    -- Stop any existing songs
    StopBGMusic(fadein)

    -- Construct our new song object
    local newsong = setmetatable({song = song, maxvol = volume, fadein = fadein }, bgmeta)
    sound.PlayFile(song, "noblock", function(...) newsong:OnReady(...) end)

    -- add 2 list
    table.insert(activeMusic, newsong)
    curBGMusic = newsong
end

function StopBGMusic(fadeout)
    if not curBGMusic then return end

    curBGMusic:Stop(fadeout)
    curBGMusic = nil
end

hook.Add("Think", "JazzDialogBGMusicThink", function()
    for k, v in pairs(activeMusic) do
        if not v:Update() then
           table.remove(activeMusic, k) 
        end 
    end
end )

dialog.RegisterFunc("bgmplay", function(d, song, volume, fadetime)
    playBGMusic(song, tonumber(volume) or 1.0, tonumber(fadetime) or 0.0)
end )

dialog.RegisterFunc("bgmstop", function(d, fadetime)
    StopBGMusic(fadetime)
end )
