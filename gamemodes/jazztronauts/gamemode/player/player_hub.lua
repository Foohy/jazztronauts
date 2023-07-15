AddCSLuaFile()
DEFINE_BASECLASS( "player_sandbox" )

local PLAYER = {}

PLAYER.DisplayName			= "Hub Class"

PLAYER.WalkSpeed			= 200		-- How fast to move when not running
PLAYER.RunSpeed				= 300		-- How fast to move when running
PLAYER.SlowWalkSpeed		= 150		-- How fast to move when slow walking
PLAYER.CrouchedWalkSpeed	= 0.2		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.JumpPower			= 200		-- How powerful our jump should be
PLAYER.CanUseFlashlight	 = true		-- Can we use the flashlight
PLAYER.MaxHealth			= 100		-- Max health we can have
PLAYER.StartHealth			= 100		-- How much health we start with
PLAYER.StartArmor			= 0			-- How much armour we start with
PLAYER.DropWeaponOnDie		= false		-- Do we drop our weapon when we die
PLAYER.TeammateNoCollide	= false		-- Overwritten in ShouldCollide. See hook for more info.
PLAYER.AvoidPlayers			= false		-- Automatically swerves around other players


function PLAYER:SetupDataTables()
	BaseClass.SetupDataTables( self )
	self.Player:NetworkVar( "Int", 0, "Notes" )
end

function PLAYER:Spawn()
	BaseClass.Spawn(self)
	self.Player:SetCustomCollisionCheck(true)
end

--
-- Called on spawn to give the player their default loadout
--
function PLAYER:Loadout()

	self.Player:RemoveAllAmmo()
	self.Player:SwitchToDefaultWeapon()

end

local meta = FindMetaTable("Player")
function meta:ChangeNotes(delta)
	return jazzmoney.ChangeNotes(self, delta)
end

function meta:GetNotes()
	return jazzmoney.GetNotes(self)
end


if CLIENT then
	-- Clientside only version of player:Lock()
	function meta:JazzLock(lock)
		self.JazzIsCurrentlyLocked = lock
		self.JazzLastLockAngles = lock and (self.JazzLastLockAngles or self:EyeAngles())
	end

	hook.Add("StartCommand", "JazzLockPlayer", function(ply, usercmd)
		if not ply.JazzIsCurrentlyLocked then return end

		ply.JazzLastLockAngles = ply.JazzLastLockAngles or usercmd:GetViewAngles()
		usercmd:ClearMovement()
		usercmd:SetViewAngles(ply.JazzLastLockAngles)
	end )
end


local convarCollide = CreateConVar("jazz_player_collide", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY },
	"Toggles players colliding with each other. Default is 0. Should be enabled when jazz_player_pvp enabled, or hitscan weapons won't function.")
cvars.AddChangeCallback("jazz_player_collide", function(_, old, new)
	if tobool(new) == false and cvars.Bool("jazz_player_pvp") then
		print("WARNING: Disabling jazz_player_collide will break jazz_player_pvp, as hitscan weapons won't function!")
	end
end )

-- Turns out TeammateNoCollide is really funky. Zombies can't attack you (among other oddities)
-- So just manually check collision here for players
hook.Add("ShouldCollide", "JazzPlayerCollide", function(ent1, ent2)
	if not (ent1:IsPlayer() and ent2:IsPlayer()) then return end
	if convarCollide:GetBool() then return end
	return false
end )

-- Called from JazzPlayerSpawnLogic
-- By now we're certain ply1 is really a player, and player_collide is on
hook.Add("JazzPlayerOnPlayer", "JazzPlayerCollideUnstuck", function(ply1, spawn)
	local function checkPlayer()
		local pos = ply1:GetPos()
		local min,max = ply1:GetCollisionBounds()
		return util.TraceHull({
			start = pos,
			endpos = pos,
			mins = min,
			maxs = max,
			filter = ply1,
			ignoreworld = true,
			mask = MASK_PLAYERSOLID
		})
	end

	-- determine who we could be stuck on
	local ply2 = false
	if spawn:IsPlayer() then ply2 = spawn end
	-- it's possible they didn't spawn *on* a player, but one happened to be standing there
	if !ply2 then
		local initTrace = checkPlayer()
		if initTrace.Hit then ply2 = initTrace.Entity end
	end
	-- if we've got nothing, probably safe to check out
	if !ply2 then return end

	-- stops everything and lets them collide again
	local function WrapItUp()
		hook.Remove("ShouldCollide", "JazzUnstuckCollision")
		hook.Remove("Think", "JazzUnstuckLoop")
	end

	-- make sure everyone's still here, stop if not
	local function StillValid()
		if ply1:IsValid() and ply2:IsValid() then
			return true
		end

		WrapItUp()
		return false
	end

	-- constantly checks if they're still in each other, stop once they aren't
	hook.Add("Think", "JazzUnstuckLoop", function()
		if not StillValid() then return end
		if not checkPlayer().Hit then WrapItUp() end
	end)

	-- stop them from colliding
	hook.Add("ShouldCollide", "JazzUnstuckCollision", function(ent1, ent2)
		if not StillValid() then return end

		-- both ents should equal one of the players
		if not (ent1 == ply1 or ent2 == ply1) then return end
		if not (ent1 == ply2 or ent2 == ply2) then return end

		return false
	end)
end)

player_manager.RegisterClass( "player_hub", PLAYER, "player_default" )
