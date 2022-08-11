$ModelName "weapons/w_hackergoggles.mdl"

$Model "goggles" "w_hackergoggles.dmx" 
$bodygroup	"paw"
{
	studio "hackergoggles.dmx"
}

$SurfaceProp "weapon"

$definebone "ValveBiped.Bip01_Pelvis"		""								-0.000005 -0.533615 38.566917  0.000000   0.000000  89.999985  0.000000 0.000000  0.000000 -0.000000  0.000000  0.000000
$definebone "ValveBiped.Bip01_Spine"		"ValveBiped.Bip01_Pelvis"		 0.000005  3.345127 -2.981901  4.944224  89.999985  89.999985  0.000000 0.000000  0.000000 -0.000000 -0.000000  0.000000
$definebone "ValveBiped.Bip01_Spine1"		"ValveBiped.Bip01_Spine"		 4.018330  0.000000 -0.000000  0.000000  -1.675443   0.000000  0.000000 0.000000  0.000000  0.000000 -0.000000  0.000000
$definebone "ValveBiped.Bip01_Spine2"		"ValveBiped.Bip01_Spine1"		 3.518555 -0.000000 -0.000000  0.000000   5.748830   0.000000  0.000000 0.000000  0.000000  0.000000 -0.000000  0.000000
$definebone "ValveBiped.Bip01_Spine4"		"ValveBiped.Bip01_Spine2"		 8.942638  0.000000  0.000000  0.000000  11.120882   0.000000  0.000000 0.000000  0.000000  0.000000 -0.000000  0.000000
$definebone "ValveBiped.Bip01_R_Clavicle"	"ValveBiped.Bip01_Spine4"		 2.033356  1.000771 -1.937610 73.712051 168.618790 -95.596519  0.000000 0.000004  0.000000  0.000000 -0.000003 -0.000001
$definebone "ValveBiped.Bip01_R_UpperArm"	"ValveBiped.Bip01_R_Clavicle"	 6.028142  0.000011  0.000000 -0.462090 -33.623806  93.935234 -0.000004 0.000000  0.000000 -0.000009  0.000000  0.000001
$definebone "ValveBiped.Bip01_R_Forearm"	"ValveBiped.Bip01_R_UpperArm"	11.692549  0.000000 -0.000004 -0.000012  -3.459060   0.000001  0.000002 0.000000 -0.000004 -0.000012  0.000000  0.000001
$definebone "ValveBiped.Bip01_R_Hand"		"ValveBiped.Bip01_R_Forearm"	11.481701  0.000000  0.000004  6.108065   2.532073 -89.664284  0.000000 0.000000  0.000000 -0.000001 -0.000009 -0.000001
$definebone "ValveBiped.Bip01_Neck1"		"ValveBiped.Bip01_Spine4"		 3.307270  0.000000 -0.000000  0.000000  22.945700 179.999863  0.000000 0.000000  0.000000  0.000000  0.000000  0.000000
$definebone "ValveBiped.Bip01_Head1"		"ValveBiped.Bip01_Neck1"		 3.593716  0.000000  0.000000 -0.000057  23.295721   0.000000  0.000000 0.000000  0.000000  0.000000  0.000000  0.000000
$definebone "ValveBiped.Weapon_Bone"		"ValveBiped.Bip01_R_Hand"		 0.000000 -1.500000  0.000000 -0.000000   0.000000  90.000000  0.000000 0.000000  0.000000 -0.000000  0.000000  0.000000

$weightlist "idle" {
	"ValveBiped.Bip01_R_Hand"		1
}
$Sequence "idle" {
	"anims/idle.dmx"
	activity "ACT_IDLE" 1
	fps 30
	weightlist "idle"
}