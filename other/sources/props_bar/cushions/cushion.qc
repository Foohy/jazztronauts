$modelname "props_bar/cushion.mdl"

$staticprop

$body "Body" "cushion.dmx"

$surfaceprop "carpet"
$opaque
$contents "solid"

$illumposition 0 0 1

$cdmaterials "models/props_bar"

$texturegroup skinfamilies
{
	{ "cushion1" }
	{ "cushion2" }
	{ "cushion3" }
	{ "cushion4" }
	{ "cushion5" }
}

$sequence "idle" {
	"cushion.dmx"
	activity "act_idle" -1
	fps 30
}

$collisionmodel "cushion_phys.dmx"
{
	$automass
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
}
