AddCSLuaFile()
DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.DisplayName			= "Hub Class"

PLAYER.WalkSpeed 			= 200		-- How fast to move when not running
PLAYER.RunSpeed				= 300		-- How fast to move when running
PLAYER.CrouchedWalkSpeed 	= 0.2		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.JumpPower			= 160		-- How powerful our jump should be
PLAYER.CanUseFlashlight     = true		-- Can we use the flashlight
PLAYER.MaxHealth			= 100		-- Max health we can have
PLAYER.StartHealth			= 100		-- How much health we start with
PLAYER.StartArmor			= 0			-- How much armour we start with
PLAYER.DropWeaponOnDie		= false		-- Do we drop our weapon when we die
PLAYER.TeammateNoCollide 	= false		-- Overwritten in ShouldCollide. See hook for more info.
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

-- Turns out TeammateNoCollide is really funky. Zombies can't attack you (among other oddities)
-- So just manually check collision here for players
hook.Add("ShouldCollide", "PlayerNoCollide", function(ent1, ent2)
    if not ent1:IsPlayer() or not ent2:IsPlayer() then return end 

    -- TODO: This might actually be useful to turn on. In-game tool?
    return false
end )

player_manager.RegisterClass( "player_hub", PLAYER, "player_default" )