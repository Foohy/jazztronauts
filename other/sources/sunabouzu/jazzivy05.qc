$modelname "sunabouzu/jazzivy05.mdl"

$body "jazzivy05" "jazzivy05.dmx"

$lod 20
{
	replacemodel "jazzivy05.dmx" "jazzivy05_lod1.dmx"
	nofacial
}
$lod 40
{
	replacemodel "jazzivy05.dmx" "jazzivy05_lod2.dmx"
	nofacial
}

$staticprop
$surfaceprop "default"
$opaque
$contents "solid"

$illumposition -10.946 7.347 -25.094

$cdmaterials "models\sunabouzu"
$cdmaterials ""

$sequence "idle" {
	"jazzivy05.dmx"
	activity "ACT_IDLE" -1
	fps 30
	loop
}
