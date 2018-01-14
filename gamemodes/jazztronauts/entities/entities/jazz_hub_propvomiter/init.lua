ENT.Type = "point"
ENT.DisableDuplicator = true
ENT.VomitMusicFile = Sound("jazztronauts/music/trash_chute_music_loop.wav")
ENT.VomitEmptyFile = Sound("jazztronauts/music/trash_chute_music_empty.wav")
ENT.MusicDelay = 3.5

util.AddNetworkString("jazz_vomiter_gib")

local randomGibProps = 
{
	"models/props_interiors/Furniture_Vanity01a.mdl",
	"models/props_interiors/Furniture_Desk01a.mdl",
	"models/props_junk/wood_crate001a_damaged.mdl",
	"models/props_junk/wood_pallet001a.mdl",
	"models/props_c17/FurnitureTable001a.mdl"
}

-- How many props to spawn before just throwing broken prop gibs instead
local maxpropsconvar = CreateConVar("jazz_trash_max_props", "2", FCVAR_ARCHIVE, 
	"The maximum number of props per model to spawn from the trash chute before just spawning gibs" )

ENT.VomitVelocity = Vector(0, 0, -200)
ENT.MaxPipeSize = 50
function ENT:Initialize()
	//self:VomitNewProps()
end

function ENT:KeyValue( key, value )

	print( "KV: " .. key .. " => " .. tostring(value) .. " [" .. type(value) .. "]" )

end

function ENT:Think()
	if !self.StartAt or CurTime() < self.StartAt then return end 

	for i=1, 2 do
		if not self:VomitProp() then 
			self:StopMusic(1)
			self.SpawnQueue = nil
			break 
		end
	end
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

function ENT:StartMusic(empty)
	self:StopMusic()

	local f = empty and self.VomitEmptyFile or self.VomitMusicFile
	self.VomitMusic = CreateSound(self, f)
	self.VomitMusic:SetSoundLevel(80)
	self.VomitMusic:Play()
	self.WasEmpty = empty
end

function ENT:VomitNewProps()
	local counts = progress.GetPropCounts()
	progress.ClearRecentProps()

	-- Store original use counts
	self.SpawnQueue = {}
	for k, v in pairs(counts) do 

		local spawnCount = math.min((v.recent or 0) + maxpropsconvar:GetInt(), v.collected)
		self.SpawnQueue[k] = 
		{
			propname = v.propname,
			total = spawnCount,
			left = spawnCount
		}
	end

	-- Ignore already-spawned props
	for _, v in pairs(ents.GetAll()) do
		local mdl = v:GetModel()
		if IsValid(v) and v.JazzHubSpawned then
			self:DecrementProp(mdl)
		end
	end

	self.StartAt = CurTime() + self.MusicDelay
	self:StartMusic(table.Count(self.SpawnQueue) == 0)
end

function ENT:DecrementProp(model)
	if not self.SpawnQueue or not self.SpawnQueue[model] then return end

	local newCount = self.SpawnQueue[model].left - 1
	self.SpawnQueue[model].left = newCount
	
	if newCount <= 0 then 
		self.SpawnQueue[model] = nil
	end
end

function ENT:SpawnRandomGibs(pos, ang)
	local e2 = mapgen.SpawnHubProp(table.Random(randomGibProps), 
		pos, ang)
	e2:GetPhysicsObject():SetVelocity(self.VomitVelocity)
	e2:PrecacheGibs()
	e2:GibBreakClient(self.VomitVelocity)
	e2:Remove()
end

function ENT:ShouldToy(ent)
	return ent:BoundingRadius() > self.MaxPipeSize or util.IsValidRagdoll(ent:GetModel())
end

function ENT:VomitProp()
	if not self.SpawnQueue then return false end

	local prop = table.Random(self.SpawnQueue)
	if not prop then return false end
	local pos, ang = self:GetPos() + self:GetAngles():Up() * 100, self:GetAngles()
	local ent = mapgen.SpawnHubProp(prop.propname, pos, ang)

	-- If certain amount of props already exist, spawn gibs instead
	if prop.total - prop.left >= maxpropsconvar:GetInt() then

		if ent:Health() > 0 then
			ent:PrecacheGibs()
			ent:GibBreakClient(self.VomitVelocity)
		else 
			-- Spawn some placeholder gibs, this prop doesnt normally break
			self:SpawnRandomGibs(ent:GetPos(), ent:GetAngles())
		end

		ent:Remove()
	elseif self:ShouldToy(ent) then 
		ent:Remove()

		-- Recreate as a sphere capsule
		ent = mapgen.SpawnHubProp(prop.propname, pos, ang, true)
	end
	
	if IsValid(ent) and IsValid(ent:GetPhysicsObject()) then
		ent:GetPhysicsObject():SetVelocity(self.VomitVelocity)
	end

	-- Decrement
	self:DecrementProp(prop.propname)

	return true
end

function ENT:AcceptInput( name, activator, caller, data )

	if name == "Vomit" then self:VomitNewProps( ) return true end

	return false
end
