$ModelName "weapons\bus_summoner_marker.mdl"

$StaticProp

$Body "Body" "trolleysign.dmx"

$LOD 11
{
	replacemodel "trolleysign.dmx" "trolleysign_LoD1.dmx"
}
$LOD 33
{
	replacemodel "trolleysign.dmx" "trolleysign_LoD2.dmx"
}
$LOD 150
{
	replacemodel "trolleysign.dmx" "trolleysign_LoD3.dmx"
}
$ShadowLOD
{
	replacemodel "trolleysign.dmx" "trolleysign_LoD2.dmx"
}

$SurfaceProp "metal"

$Contents "solid"

$CDMaterials "models/props_bar"
$CDMaterials ""

$Sequence "idle" {
	"trolleysign.dmx"
	activity ACT_IDLE -1
	fps 30
}

$CollisionModel "trolleysign_phy.dmx"
{
	$automass
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
}
