$ModelName "weapons/w_run.mdl" 
$Model "model" "w_run.dmx" 

$SurfaceProp "weapon"


$JiggleBone "jiggle1"
{
	is_flexible
	{
		length 60
		tip_mass 5
		pitch_stiffness 100
		pitch_damping 5
		yaw_stiffness 100
		yaw_damping 5
		along_stiffness 100
		along_damping 0
		pitch_constraint -5 75
		pitch_friction 0
		pitch_bounce 0
		yaw_constraint -25 15
		yaw_friction 5
		yaw_bounce 0
	}
}

$illumposition 2 0 0 ValveBiped.Bip01_Head1

$sequence idle "w_run.dmx" ACT_IDLE -1 fps 30 

$collisionjoints "phys.dmx"
{
    $automass
	$inertia	2.00
	$damping	0.01
	$rotdamping	0.40
	$jointskip	"ValveBiped.Bip01_Neck1"
//	$rootbone	"ValveBiped.Bip01_Head1"
}