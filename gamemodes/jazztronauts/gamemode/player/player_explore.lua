AddCSLuaFile()
DEFINE_BASECLASS( "player_hub" )

local PLAYER = {}

PLAYER.DisplayName			= "Exploration Class"

PLAYER.WalkSpeed 			= 200		-- How fast to move when not running
PLAYER.RunSpeed				= 400		-- How fast to move when running
PLAYER.CrouchedWalkSpeed 	= 0.3		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed			= 0.1		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.1		-- How fast to go from ducking, to not ducking
PLAYER.JumpPower			= 200		-- How powerful our jump should be
PLAYER.CanUseFlashlight     = true		-- Can we use the flashlight
PLAYER.MaxHealth			= 100		-- Max health we can have
PLAYER.StartHealth			= 100		-- How much health we start with
PLAYER.StartArmor			= 0			-- How much armour we start with
PLAYER.DropWeaponOnDie		= true		-- Do we drop our weapon when we die
PLAYER.AvoidPlayers			= false		-- Automatically swerves around other players


function PLAYER:SetupDataTables()
	BaseClass.SetupDataTables( self )
end

function PLAYER:Spawn()
    BaseClass.Spawn(self)
end

--
-- Called on spawn to give the player their default loadout
--
function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()

    -- TODO: Jazz option?
	if ( cvars.Bool( "sbox_weapons", true ) ) then
	
		self.Player:GiveAmmo( 256,	"Pistol", 		true )
		self.Player:GiveAmmo( 256,	"SMG1", 		true )
		self.Player:GiveAmmo( 5,	"grenade", 		true )
		self.Player:GiveAmmo( 64,	"Buckshot", 	true )
		self.Player:GiveAmmo( 32,	"357", 			true )
		self.Player:GiveAmmo( 32,	"XBowBolt", 	true )
		self.Player:GiveAmmo( 6,	"AR2AltFire", 	true )
		self.Player:GiveAmmo( 100,	"AR2", 			true )
		
		self.Player:Give( "weapon_crowbar" )
		self.Player:Give( "weapon_pistol" )
		//self.Player:Give( "weapon_smg1" )
		//self.Player:Give( "weapon_frag" )
		self.Player:Give( "weapon_physcannon" )
		//self.Player:Give( "weapon_crossbow" )
		//self.Player:Give( "weapon_shotgun" )
		//self.Player:Give( "weapon_357" )
		//self.Player:Give( "weapon_rpg" )
		//self.Player:Give( "weapon_ar2" )
	end

	-- Give player purchased weapons
	for _, wep in pairs(unlocks.GetAll("store", self.Player)) do
		if (GAMEMODE:JazzCanSpawnWeapon(self.Player, wep)) then
			self.Player:Give(wep)
		end
	end
	
	--self.Player:Give( "gmod_tool" )
	self.Player:Give( "gmod_camera" )
	self.Player:Give( "weapon_physgun" )
	self.Player:Give( "weapon_buscaller" )
	self.Player:Give( "weapon_propsnatcher" )
	--self.Player:Give( "weapon_stan" )

    self.Player:SwitchToDefaultWeapon()
end

player_manager.RegisterClass( "player_explore", PLAYER, "player_hub" )