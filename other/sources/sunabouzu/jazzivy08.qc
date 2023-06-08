$modelname "sunabouzu/jazzivy08.mdl"
$scale 2.0
$body "jazzivy07" "jazzivy07.dmx"

$lod 128
{
	replacemodel "jazzivy07.dmx" "jazzivy07_lod1.dmx"
	nofacial
}
$lod 256
{
	replacemodel "jazzivy07.dmx" "jazzivy07_lod2.dmx"
	nofacial
}

$staticprop
$surfaceprop "default"
$opaque
$contents "solid"

$illumposition 0 0 0

$cdmaterials "models\sunabouzu"
$cdmaterials ""

$sequence "idle" {
	"jazzivy07.dmx"
	activity "ACT_IDLE" -1
	fps 30
	loop
}