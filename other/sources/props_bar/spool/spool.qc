$staticprop
$modelname "props_bar/spool.mdl"
$opaque
$body "Body" "spool_ref.dmx"
$cdmaterials "models/props_bar"
$sequence idle "spool_ref.dmx"
$surfaceprop "wood"

$collisionmodel "phys.dmx"
{
	$automass
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
}

$keyvalues
{
	prop_data
	{
		base			Wooden.Huge 
		allowstatic		1
	}
}