$modelname "weapons/c_bus_summoner.mdl"

$include "..\c_arms_definebones.qci"

$body studio "bus_summoner.dmx"

$origin 0 0 -6

// Inverse kinematics stuff

//$ikchain rhand "ValveBiped.Bip01_R_Hand" Z 0 knee 0.707 0.707 0
//$ikchain lhand "ValveBiped.Bip01_L_Hand" Z 0 knee 0.707 0.707 0

$definebone "ValveBiped.Weapon_Bone"	"ValveBiped.Bip01_R_Hand"	0.000000 0.000000 0.000000	1.570796 -0.000000 0.000000
$definebone "keychain01"				"ValveBiped.Weapon_Bone"	0.000000 -0.014700 0.184757	0.000000 -0.000000 0.000000
$definebone "keychain02"				"keychain01"				-0.003300 0.010949 0.716753	0.000000 -0.000000 0.000000
$definebone "keychain03"				"keychain02"				-0.008981 0.028108 1.089909	0.000000 -0.000000 0.000000
$definebone "keychain04"				"keychain03"				0.012281 -0.024771 0.450419	0.000000 -0.000000 0.000000

$bonemerge "ValveBiped.Weapon_Bone"
$bonemerge "keychain01"
$bonemerge "keychain02"
$bonemerge "keychain03"
$bonemerge "keychain04"

$CDMaterials ""

$Attachment "muzzle" "ValveBiped.Weapon_Bone" 0 0 -2.625 rotate -0.0 -0.0 -90

$jigglebone "keychain01"
{
	is_flexible
	{
		tip_mass 1000
		length 20
		pitch_constraint -5 5
		yaw_constraint -60 20
		yaw_stiffness	10
		pitch_stiffness	10
		pitch_damping	10
		yaw_damping		10
	}
}
$jigglebone "keychain02"
{
	is_flexible
	{
		tip_mass 1000
		length 20
		pitch_constraint -60 20
		yaw_constraint -30 30
		yaw_stiffness	10
		pitch_stiffness	10
		pitch_damping	10
		yaw_damping		10
	}
}
$jigglebone "keychain03"
{
	is_flexible
	{
		tip_mass 1000
		length 20
		pitch_constraint -5 5
		yaw_constraint -60 40
		yaw_stiffness	10
		pitch_stiffness	10
		pitch_damping	10
		yaw_damping		10
	}
}
$jigglebone "keychain04"
{
	is_flexible
	{
		tip_mass 1000
		length 20
		pitch_constraint 0 0
		yaw_constraint -60 60
		yaw_stiffness	10
		pitch_stiffness	10
		pitch_damping	10
		yaw_damping		10
	}
}
// This defines the IK chains. This viewmodel uses IK so the idle sequence can actually only be
// a single frame, while the actual idle motion is an additive layer that is *always* on. Not
// having IK enabled will cause the left hand to not stick properly to the medkit.

$animation a_idle_layer "anims/idle_layer.dmx" subtract a_idle_layer 0 /*ikrule rhand touch "ValveBiped.Weapon_Bone" usesource*/ fixuploop 0 70
$sequence  anim_idle_layer a_idle_layer delta loop fps 3 frames 60 210 hidden autoplay realtime

// Sequences

$sequence anim_ref			"bus_summoner.dmx"			fps  1 					loop // Reference pose, outside of view
$sequence anim_draw			"anims/draw.dmx"			fps 30 frames 1 16	snap				ACT_VM_DRAW -1			/*ikrule rhand touch "ValveBiped.Weapon_Bone" usesource*/ angles 90 0 0
$sequence anim_idle			"anims/idle.dmx"			fps  1 frames 0 0	loop node idle		ACT_VM_IDLE -1			/*ikrule rhand touch "ValveBiped.Weapon_Bone" usesource*/ angles 90 0 0
$sequence anim_fire			"anims/fire.dmx"			fps 30 frames 42 42	loop node firing	ACT_VM_PRIMARYATTACK -1	/*ikrule rhand touch "ValveBiped.Weapon_Bone" usesource*/ angles 90 0 0
$sequence anim_holster		"anims/holster.dmx"		 	fps 30 frames 16 25						ACT_VM_HOLSTER -1		/*ikrule rhand touch "ValveBiped.Weapon_Bone" usesource*/ angles 90 0 0
$sequence anim_idle_to_fire	"anims/idle_to_fire.dmx"	fps 30 frames 30 38	transition idle firing						/*ikrule rhand touch "ValveBiped.Weapon_Bone" usesource*/ angles 90 0 0
$sequence anim_fire_to_idle	"anims/fire_to_idle.dmx"	fps 30 frames 45 55	transition firing idle						/*ikrule rhand touch "ValveBiped.Weapon_Bone" usesource*/ angles 90 0 0
