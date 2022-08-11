$ModelName "weapons/c_run.mdl" 
$upaxis y
$Model "model" "blank.smd" 

$SurfaceProp "weapon"

$include "..\c_arms_definebones.qci" 

$cdmaterials "models/weapons/jazztronauts" 

$origin 0 0 0 

$definevariable "shared_fps" 45 

$sequence idle "blank.smd" fps 30 
//$sequence anim_draw		"anims/draw.dmx"	fps 30 frames 0  45 	 ACT_VM_DRAW -1

$animation a_neutral	  "anims/neutral.dmx"		fps $shared_fps$ loop numframes 24 
$animation a_forward	  "anims/forward.dmx"		fps $shared_fps$ loop numframes 24 
$animation a_left		  "anims/left.dmx"			fps $shared_fps$ loop numframes 24 
$animation a_right		  "anims/right.dmx"			fps $shared_fps$ loop numframes 24 
$animation a_forwardleft  "anims/forwardleft.dmx"	fps $shared_fps$ loop numframes 24 
$animation a_forwardright "anims/forwardright.dmx"	fps $shared_fps$ loop numframes 24 
$animation a_back		  "anims/forward.dmx"		fps $shared_fps$ loop numframes 24 
$animation a_backleft  	  "anims/forwardright.dmx"	fps $shared_fps$ loop numframes 24 
$animation a_backright	  "anims/forwardleft.dmx"	fps $shared_fps$ loop numframes 24 

$sequence anim_idle { 
	a_forwardleft  a_forward a_forwardright 
	a_left		   a_neutral		a_right 
	a_backleft	   a_back	    a_backright 
	blendwidth 3 
	blend move_y -1  1 
	blend move_x  1 -1 //-1 1 
	fps $shared_fps$ 
	loop 
	ACT_VM_IDLE -1 
}

