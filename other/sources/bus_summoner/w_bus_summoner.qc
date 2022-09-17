$modelname "weapons/w_bus_summoner.mdl"

$body studio "w_bus_summoner.dmx"

$surfaceprop	"weapon"

$definebone "ValveBiped.Bip01_R_Hand"	""							11.481697 0.000001 0.000003 6.108071 2.532072 -89.664286 0.000000 0.000000 0.000000 0.000001 0.000000 0.000000
$definebone "ValveBiped.Weapon_Bone"	"ValveBiped.Bip01_R_Hand"	0.000000 0.000000 0.000000	1.570796 -0.000000 0.000000
$definebone "keychain01"				"ValveBiped.Weapon_Bone"	0.000000 -0.014700 0.184757	0.000000 -0.000000 0.000000
//$definebone "keychain02"				"keychain01"				-0.003300 0.010949 0.716753	0.000000 -0.000000 0.000000
$definebone "keychain03"				"keychain01"				-0.012281 0.039057 1.806662	0.000000 -0.000000 0.000000	//"keychain02"				-0.008981 0.028108 1.089909	0 0 0
//$definebone "keychain04"				"keychain03"				0.012281 -0.024771 0.450419	0.000000 -0.000000 0.000000

$bonemerge "ValveBiped.Weapon_Bone"
$bonemerge "keychain01"
//$bonemerge "keychain02"
$bonemerge "keychain03"
//$bonemerge "keychain04"

$lod	11 {
	replacemodel	"w_bus_summoner.dmx"	"w_bus_summoner_lod1.dmx"
	bonetreecollapse	"keychain01"
}
$lod	22 {
	replacemodel	"w_bus_summoner.dmx"	"w_bus_summoner_lod1.dmx"
	bonetreecollapse	"ValveBiped.Weapon_Bone"
}

$jigglebone "keychain01"
{
	is_rigid
	{
		tip_mass 100
		length 20
		pitch_constraint -50 50
		yaw_constraint -60 120
	}
}
$jigglebone "keychain03"
{
	is_rigid
	{
		tip_mass 100
		length 20
		pitch_constraint -50 50
		yaw_constraint -60 120
	}
}

$illumposition 0 0 -1 ValveBiped.Weapon_Bone

$CDMaterials ""

$Attachment "muzzle" "ValveBiped.Weapon_Bone" 0 0 -2.625 rotate -0.0 -0.0 -90

$sequence anim_idle "anims/idle.dmx" fps 1 frames 0 0 loop ACT_IDLE -1 angles 180 0 0

$collisionjoints "phys.dmx"
{
    $automass
	$inertia	2.00
	$damping	0.01
	$rotdamping	0.40
	$jointskip	"ValveBiped.Bip01_R_Hand"
//	$rootbone	"ValveBiped.Weapon_Bone"
}