$modelname "props_bar/teleportbulk.mdl"
$staticprop
$body "Body" "teleportbulk_reference.smd"

$lod 75
{
	replacemodel "teleportbulk_reference.smd" "teleportbulk_reference_lod1.smd"
	nofacial
}
$lod 95
{
	replacemodel "teleportbulk_reference.smd" "teleportbulk_reference_lod2.smd"
}
$shadowlod
{
	replacemodel "teleportbulk_reference.smd" "teleportbulk_reference_lod3.smd"
}

$surfaceprop "metalpanel"
$opaque
$contents "solid"

$illumposition -12.523 32.508 110.568

$cdmaterials "models\props_lab"

$sequence "idle" {
	"teleportbulk_reference.smd"
	fps 30
	loop
}

$collisionmodel "teleportbulk_physics.smd"
{
	$mass 400
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 20

}
