$ModelName "weapons/c_hackergoggles.mdl"

$Model "goggles" "hackergoggles.dmx" 

$SurfaceProp "weapon"

$include "..\c_arms_definebones.qci"

$definebone "ValveBiped.Weapon_Bone"		""							 0.000000 -1.125000  0.000000 -0.000000 0.000000 90.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_Index"		"ValveBiped.Weapon_Bone"	-2.190916 -0.000000 -1.483477 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_Middle"		"ValveBiped.Weapon_Bone"	-0.963419  0.000000 -2.805463 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_Ring"		"ValveBiped.Weapon_Bone"	 0.963419  0.000000 -2.805463 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_Pinkie"		"ValveBiped.Weapon_Bone"	 2.190913 -0.000000 -1.483477 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_IndexL"		"ValveBiped.ToeBean_Index"	-1.131350  0.000000 -0.010664 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_IndexR"		"ValveBiped.ToeBean_Index"	 1.083494  0.000000 -0.010664 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_IndexT"		"ValveBiped.ToeBean_Index"	-0.023928  0.000000 -1.118086 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_IndexB"		"ValveBiped.ToeBean_Index"	-0.023928  0.000000  1.096758 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_MiddleL"	"ValveBiped.ToeBean_Middle"	-1.343710 -0.000000 -0.072955 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_MiddleR"	"ValveBiped.ToeBean_Middle"	 1.609415 -0.000000 -0.072955 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_MiddleT"	"ValveBiped.ToeBean_Middle"	 0.132853 -0.000000 -1.549517 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_MiddleB"	"ValveBiped.ToeBean_Middle"	 0.132853 -0.000000  1.403608 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_RingL"		"ValveBiped.ToeBean_Ring"	-1.609416  0.000000 -0.072955 -0.000002 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_RingR"		"ValveBiped.ToeBean_Ring"	 1.343709  0.000000 -0.072955 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_RingT"		"ValveBiped.ToeBean_Ring"	-0.132853  0.000000 -1.549517 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_RingB"		"ValveBiped.ToeBean_Ring"	-0.132853  0.000000  1.403608 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_PinkieR"	"ValveBiped.ToeBean_Pinkie"	 1.131352  0.000000 -0.010664 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_PinkieL"	"ValveBiped.ToeBean_Pinkie"	-1.083492  0.000000 -0.010664 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_PinkieT"	"ValveBiped.ToeBean_Pinkie"	 0.023930  0.000000 -1.118086 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.ToeBean_PinkieB"	"ValveBiped.ToeBean_Pinkie"	 0.023930  0.000000  1.096758 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.Weapon_BonePawL"	"ValveBiped.Weapon_Bone"	-3.543750  0.000000  1.532813 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.Weapon_BonePawR"	"ValveBiped.Weapon_Bone"	 3.543750  0.000000  1.532813 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.Weapon_BonePawT"	"ValveBiped.Weapon_Bone"	-0.000000 -0.000000 -2.010937 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.Weapon_BoneBL"		"ValveBiped.Weapon_Bone"	-2.953125 -0.098438  1.828125 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.Weapon_BoneBR"		"ValveBiped.Weapon_Bone"	 2.953125 -0.098438  1.828125 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.Weapon_BoneTR"		"ValveBiped.Weapon_Bone"	 2.953125 -0.098438 -4.078125 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000
$definebone "ValveBiped.Weapon_BoneTL"		"ValveBiped.Weapon_Bone"	-2.953125 -0.098438 -4.078125 -0.000000 0.000000  0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000

$bbox -64 -64 -64 64 64 64 //little "hack" to make sure we can see it while working in SFM

$Sequence "idle" {
	"hackergoggles.dmx"
	fps 30
}

$Sequence "shrinkgrow" {
	"anims/shrinkgrow.dmx"
	fps 30
	hidden //hide once we're animated properly, just using this as an easy source for shrink/growing while animating in SFM
}
$origin -3 1 -1 
$sequence anim_draw		"anims/draw.dmx"	fps 26 /*30*/ numframes 45 	 ACT_VM_DRAW -1
$weightlist "idle_subtle" {
	"ValveBiped.Bip01_Spine4"		1
	"ValveBiped.Bip01_R_Hand"		1
	"ValveBiped.Bip01_R_Finger0"	0.7
	"ValveBiped.Bip01_R_Finger1"	0.7
	"ValveBiped.Bip01_R_Finger2"	0.7
	"ValveBiped.Bip01_R_Finger3"	0.7
	"ValveBiped.Bip01_R_Finger4"	0.7
	"ValveBiped.Bip01_R_Finger01"	0.4
	"ValveBiped.Bip01_R_Finger11"	0.4
	"ValveBiped.Bip01_R_Finger21"	0.4
	"ValveBiped.Bip01_R_Finger31"	0.4
	"ValveBiped.Bip01_R_Finger41"	0.4
	"ValveBiped.Weapon_Bone"		1
}
$sequence anim_idle		"anims/idle.dmx"	fps 30 frames 0 300 loop ACT_VM_IDLE		  2 weightlist "idle_subtle"
$sequence anim_idle2	"anims/idle.dmx"	fps 30 frames 0 300 loop ACT_VM_IDLE		  1
$sequence anim_fire1	"anims/attack1.dmx"	fps 30 frames 0  30 	 ACT_VM_PRIMARYATTACK 2 //1 1
$sequence anim_fire2	"anims/attack2.dmx"	fps 30 frames 0  30 	 ACT_VM_PRIMARYATTACK 2 //1 3 1 2
$sequence anim_fire3	"anims/attack3.dmx"	fps 30 frames 0  30 	 ACT_VM_PRIMARYATTACK 1 //pound

$weightlist "scale" {
	"ValveBiped.ToeBean_IndexL"		1
	"ValveBiped.ToeBean_IndexR"		1
	"ValveBiped.ToeBean_IndexT"		1
	"ValveBiped.ToeBean_IndexB"		1
	"ValveBiped.ToeBean_MiddleL"	1
	"ValveBiped.ToeBean_MiddleR"	1
	"ValveBiped.ToeBean_MiddleT"	1
	"ValveBiped.ToeBean_MiddleB"	1
	"ValveBiped.ToeBean_RingL"		1
	"ValveBiped.ToeBean_RingR"		1
	"ValveBiped.ToeBean_RingT"		1
	"ValveBiped.ToeBean_RingB"		1
	"ValveBiped.ToeBean_PinkieL"	1
	"ValveBiped.ToeBean_PinkieR"	1
	"ValveBiped.ToeBean_PinkieT"	1
	"ValveBiped.ToeBean_PinkieB"	1
	"ValveBiped.Weapon_BonePawL"	1
	"ValveBiped.Weapon_BonePawR"	1
	"ValveBiped.Weapon_BonePawT"	1
	"ValveBiped.Weapon_BoneBL"		1
	"ValveBiped.Weapon_BoneBR"		1
	"ValveBiped.Weapon_BoneTR"		1
	"ValveBiped.Weapon_BoneTL"		1
}
$animation a_glitch_min	"anims/glitchless.dmx"	fps 30 fixuploop 0 300 subtract a_glitch_min 0
$animation a_glitch_max	"anims/glitch.dmx"		fps 30 fixuploop 0 300 subtract a_glitch_max 0
$sequence  "glitch" {
	a_glitch_max
	a_glitch_min
	autoplay
	blend "glitch" 1 0
	blendwidth 2
	fps 30
	frames 0 300
	loop
	delta
	weightlist "scale"
}