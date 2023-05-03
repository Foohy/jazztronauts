$modelname "props_bar/teleportbulkeli.mdl"

$staticprop

$body "Body" "teleportbulkeli_reference.smd"

$lod 55
{
	replacemodel "teleportbulkeli_reference.smd" "teleportbulkeli_reference_lod1.smd"
}
$lod 85
{
	replacemodel "teleportbulkeli_reference.smd" "teleportbulkeli_reference_lod2.smd"
}
$shadowlod
{
	replacemodel "teleportbulkeli_reference.smd" "teleportbulkeli_reference_lod2.smd"
}

$surfaceprop "metalpanel"
$opaque
$contents "solid"

$illumposition -25.617 33.366 110.322

$cdmaterials "models\props_lab"

$sequence "idle" {
	"teleportbulkeli_reference.smd"
	fps 30
	loop
}

$collisionmodel "teleportbulkeli_physics.smd"
{
	$mass 400
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 20

}
