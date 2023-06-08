$modelname "sunabouzu/jazzivy02.mdl"
$scale 2.0
$body "jazzivy" "jazzivy.dmx"

$lod 40
{
	replacemodel "jazzivy.dmx" "jazzivy_lod1.dmx"
	nofacial
}
$lod 80
{
	replacemodel "jazzivy.dmx" "jazzivy_lod2.dmx"
	nofacial
}

$staticprop
$surfaceprop "default"
$opaque
$contents "solid"

$illumposition -7.853 0 -1.227

$cdmaterials "models\sunabouzu"
$cdmaterials ""

$sequence "idle" {
	"jazzivy.dmx"
	activity "ACT_IDLE" -1
	fps 30
	loop
}
