$modelname "sunabouzu/jazzivy04.mdl"
$scale 2.0
$body "jazzivy03" "jazzivy03.dmx"

$lod 20
{
	replacemodel "jazzivy03.dmx" "jazzivy03_lod1.dmx"
	nofacial
}
$lod 40
{
	replacemodel "jazzivy03.dmx" "jazzivy03_lod2.dmx"
	nofacial
}

$staticprop
$surfaceprop "default"
$opaque
$contents "solid"

$illumposition -10.714 7.347 -78.789

$cdmaterials "models\sunabouzu"
$cdmaterials ""

$sequence "idle" {
	"jazzivy03.dmx"
	activity "ACT_IDLE" -1
	fps 30
	loop
}

