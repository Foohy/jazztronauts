AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("jazz_propvom_effect")
util.AddNetworkString("jazz_propvom_propsavailable")

ENT.VomitVelocity = Vector(0, 0, -200)
ENT.MaxPipeSize = 50

ENT.VomitRate = 15
ENT.RandomStealAccel = 0.05

ENT.DisableDuplicator = true
ENT.VomitMusicFile = Sound("jazztronauts/music/trash_chute_music_loop.wav")
ENT.VomitFinishFile = Sound("jazztronauts/music/trash_chute_music_stop.wav")
ENT.VomitEmptyFile = Sound("jazztronauts/music/trash_chute_music_empty.wav")
ENT.StartDelay = 0 -- Delay before anything at all happens
ENT.MusicDelay = 3.5 -- Delay to let the music play before props begin to fall
ENT.ConstipateDelay = 10.5 -- Delay when the tube is constipated
ENT.FinishDelay = 2.0 -- How long to wait before closing the blinds

ENT.RandomStealRate = 0

local propr_unlock_list = "props"
unlocks.Register(propr_unlock_list)

local randomGibProps =
{
	Model("models/props_interiors/Furniture_Vanity01a.mdl"),
	Model("models/props_interiors/Furniture_Desk01a.mdl"),
	Model("models/props_junk/wood_crate001a_damaged.mdl"),
	Model("models/props_junk/wood_pallet001a.mdl"),
	Model("models/props_c17/FurnitureTable001a.mdl")
}

local groanSounds =
{
	"ambient/materials/metal_stress1.wav",
	"ambient/materials/metal_stress2.wav",
	"ambient/materials/metal_stress3.wav",
	"ambient/materials/metal_stress4.wav",
	"ambient/materials/metal_stress5.wav"
}

local bowelMovementSounds =
{
	"ambient/machines/thumper_shutdown1.wav",
	"ambient/machines/floodgate_move_short1.wav"
}

local outputs =
{
	"OnVomitEnd",
	"OnVomitStart",
	"OnVomitStartEmpty"
}

local function UpdatePlayerPropMarker(ply, enabled, marker)

	net.Start("jazz_propvom_propsavailable")
		net.WriteBool(enabled)
		net.WriteVector(marker)
	net.Send(ply)
end

function ENT:Initialize()

	-- Hook into when props/brushes are stolen and instantly poop them out
	hook.Add("CollectBrush", self, function(self, brush, players)
		return self:OnBrushStolen(brush, players)
	end)

	hook.Add("CollectDisplacement", self, function(self, brush, players)
		return self:OnDisplacementStolen(brush, players)
	end)

	hook.Add("CollectProp", self, function(self, prop, ply)
		return self:OnPropStolen(prop, ply)
	end)

	-- Catch up players
	hook.Add("PlayerInitialSpawn", self, function(self, ply)
		self:OnPlayerJoined(ply)
	end )

	hook.Add("PlayerSpawn", self, function(self, ply)
		self:OnPlayerJoined(ply)
	end )
end

function ENT:KeyValue( key, value )
	if key == "marker" then
		local marker = Vector(value) or Vector(self:GetPos())
		self:SetMarker(marker)
	end

	if table.HasValue(outputs, key) then
		self:StoreOutput(key, value)
	end
end

function ENT:OnBrushStolen(brush, players)
	local material, area = GAMEMODE:GetPrimaryBrushMaterial(brush)
	if not material then return end

	self:AddToQueue(material, "brush")
	self.RandomStealRate = self.RandomStealRate + self.RandomStealAccel
end

function ENT:OnDisplacementStolen(brush, players)
	print("TODO")
end

function ENT:OnPropStolen(prop, ply)
	local worth = mapgen.CollectProp(ply, prop)
	if not worth then return end

	self:AddToQueue(prop:GetModel(), "prop")
end

function ENT:OnPlayerJoined(ply)
	if not self:IsActive() then
		UpdatePlayerPropMarker(ply, true, self:GetMarker())
	else
		self:GivePlayerSuperSnatch(ply)
	end
end

function ENT:GivePlayerSuperSnatch(ply)
	local wep = ply:Give("weapon_propsnatcher")
	if IsValid(wep) then
		wep:MakeOverpowered()
	end
end

function ENT:StopVomit()
	--self:StartMusic(self.VomitFinishFile)
	self.SpawnQueue = nil
	self.IsStopping = true

	self:SetIsVomiting(false)
	timer.Simple(self.FinishDelay, function()
		self:TriggerOutput("OnVomitEnd", self)
		self.IsStopping = false
	end )
end

function ENT:VomitMultiple(count)
	for i=1, count do
		self:VomitProp()
	end
end

function ENT:RandomStealThink()
	if self.NextRandomSteal and self.NextRandomSteal > CurTime() then return end
	if self.RandomStealRate == 0 then return end

	self.NextRandomSteal = CurTime() + 1.0 / self.RandomStealRate

	-- Ehhhh, just grab it from the theft volume
	if not self.RandomStealBrushes then
		local theftVolume = ents.FindByClass("jazz_trigger_theft")[1]
		if not IsValid(theftVolume) then return end

		self.RandomStealBrushes = table.Copy(theftVolume:GetInsideBrushes())
	end

	-- Find a random unstolen one, steal it
	while true do
		local _, brushid = table.Random(self.RandomStealBrushes)
		if not brushid then break end

		if snatch.IsBrushStolen(brushid) then continue end

		local brushinfo = bsp2.GetCurrent().brushes[brushid]

		local yoink = snatch.New()
		yoink:SetMode(2)
		yoink:StartWorld(brushinfo.center, nil, brushid)

		hook.Run("CollectBrush", brushinfo, {})
		break
	end
end

function ENT:VomitThink()
	if self.NextVomit and self.NextVomit > CurTime() then return end
	self.NextVomit = CurTime() + 1.0 / self.VomitRate

	self:VomitMultiple(2)
end

function ENT:Think()
	if not self.SpawnQueue then return end
	if !self.StartAt or CurTime() < self.StartAt then return end
	if self.IsStopping then return end


	-- Prevent from starving rendering
	if self.LastFrameTime != RealTime() then
		self.LastFrameTime = RealTime()

		self:VomitThink()
		self:RandomStealThink()
	end

	self:NextThink(CurTime())
	return true
end

function ENT:StopMusic(fadeTime)
	if self.VomitMusic then
		if not fadeTime or fadeTime <= 0 then
			self.VomitMusic:Stop()
			self.VomitMusic = nil
		elseif not self.WasEmpty then
			self.VomitMusic:FadeOut(fadeTime)
		end
	end
end

function ENT:StartMusic(f)
	self:StopMusic()

	--local f = empty and self.VomitEmptyFile or self.VomitMusicFile
	self.VomitMusic = CreateSound(self, f)
	self.VomitMusic:SetSoundLevel(80)
	self.VomitMusic:Play()
	self.WasEmpty = empty
end

function ENT:VomitNewProps()

	-- Create new (empty) spawn queue
	self.SpawnQueue = Queue()

	-- Fire outputs
	self:TriggerOutput("OnVomitStart", self)

	-- Stop showing the dialog for everyone
	for _, v in pairs(player.GetAll()) do
		UpdatePlayerPropMarker(v, false, self:GetMarker())
		self:GivePlayerSuperSnatch(v)
	end

	-- Start the music and away we go
	self.StartAt = CurTime() + self.MusicDelay + self.StartDelay
	timer.Simple(self.StartDelay, function()
		--self:StartMusic(self.VomitMusicFile)
		self:SetIsVomiting(true)
	end )

end

function ENT:AddToQueue(prop, type)
	if not self.SpawnQueue then return end

	self.SpawnQueue:Push({
		propname = prop,
		type = type
	})
end

function ENT:SpawnRandomGibs(pos, ang)
	local e2 = mapgen.SpawnHubProp(table.Random(randomGibProps),
		pos, ang)
	e2:GetPhysicsObject():SetVelocity(self.VomitVelocity)
	e2:PrecacheGibs()
	e2:GibBreakClient(self.VomitVelocity)
	e2:Remove()
end

function ENT:SpawnPropEffect(propinfo, pos)
	local filter = RecipientFilter()
	filter:AddPVS(self:GetPos())

	net.Start("jazz_propvom_effect")
		net.WriteVector(pos)
		net.WriteString(propinfo.propname)
		net.WriteString(propinfo.type) -- #TODO: int types?
	net.Send(filter)
end


function ENT:VomitProp()
	if not self.SpawnQueue then return false end

	local prop = self.SpawnQueue:Pop()
	if not prop then return false end

	local worth = prop.worth
	local pos, ang = self:GetPos() + self:GetAngles():Up() * 100, self:GetAngles()

	--unlocks.Unlock( propr_unlock_list, self.CurrentUser, prop.propname )

	-- Spawn some placeholder gibs, this prop doesnt normally break
	--self.CurrentUser:ChangeNotes(worth)
	self:SpawnPropEffect(prop, pos)

	-- Don't do it _every_ time, but adjustable odds
	if math.Rand(0, 1) <= 0.75 then
		self:SpawnRandomGibs(pos, ang)
	end

	return true
end

function ENT:IsActive()
	return self.SpawnQueue or self.IsStopping
end

function ENT:AcceptInput( name, activator, caller, data )
	if name == "Vomit" and not self:IsActive() then
		self:VomitNewProps(activator)
		return true
	end

	if name == "StopVomit" and self:IsActive() then
		self:StopVomit()
		return true
	end

	return false
end