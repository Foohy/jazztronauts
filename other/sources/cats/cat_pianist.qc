$ModelName "andy/pianist/cat_pianist.mdl"

$Body "cat_pianist" "cat_pianist.dmx"

$SurfaceProp "default"

$Contents "solid"

$CDMaterials "models\andy\pianist"

$TextureGroup "skinfamilies"
{
	{ "cat_pianist_01" }
	{ "cat_pianist_02" }
	{ "cat_pianist_03" }
	{ "cat_pianist_04" }
	{ "cat_pianist_05" }
	{ "cat_pianist_06" }
}

$BBox -1.351 -28.936 -13.766 70.293 13.151 14.382

$SectionFrames 30 119

$illumposition 0 -1 0

$animation "a_standard_size" "cat_bartender.dmx"
$animation "a_pianist_adjust" "cat_pianist.dmx" subtract a_standard_size 0 

$sequence "pianist_adjust" {
	a_pianist_adjust 
	delta
	hidden
	autoplay
	fps 24
	loop
}

$Sequence "idle" {
	"cat_bartender_anims\idle.smd"
	activity "ACT_IDLE" -1
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "pose_elegant" {
	"cat_bartender_anims\pose_elegant.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "pose_hangingout" {
	"cat_bartender_anims\pose_hangingout.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "pose_leanwallback" {
	"cat_bartender_anims\pose_leanwallback.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "pose_passedout" {
	"cat_bartender_anims\pose_passedout.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "pose_relax" {
	"cat_bartender_anims\pose_relax.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "gesture_sweep" {
	"cat_bartender_anims\gesture_sweep.smd"
	fadein 0.2
	fadeout 0.2
	snap
	fps 24
}

$Sequence "gesture_dryhands" {
	"cat_bartender_anims\gesture_dryhands.smd"
	fadein 0.2
	fadeout 0.2
	snap
	fps 24
}

$Sequence "gesture_washing" {
	"cat_bartender_anims\gesture_washing.smd"
	fadein 0.1
	fadeout 0.1
	fps 24
	loop
}

$Sequence "gesture_jab" {
	"cat_bartender_anims\gesture_jab.smd"
	fadein 0.2
	fadeout 0.2
	snap
	fps 24
}

$Sequence "gesture_foldarms" {
	"cat_bartender_anims\gesture_foldarms.smd"
	fadein 0.2
	fadeout 0.2
	snap
	fps 30
}

$Sequence "gesture_agree" {
	"cat_bartender_anims\gesture_agree.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_disagree" {
	"cat_bartender_anims\gesture_disagree.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_laugh" {
	"cat_bartender_anims\gesture_laugh.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_sigh" {
	"cat_bartender_anims\gesture_sigh.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_anger" {
	"cat_bartender_anims\gesture_anger.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_clap" {
	"cat_bartender_anims\gesture_clap.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_confused" {
	"cat_bartender_anims\gesture_confused.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_embarass" {
	"cat_bartender_anims\gesture_embarass.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_exchange" {
	"cat_bartender_anims\gesture_exchange.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_facepalm" {
	"cat_bartender_anims\gesture_facepalm.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_shock" {
	"cat_bartender_anims\gesture_shock.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "bartender_search" {
	"cat_bartender_anims\bartender_search.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "cellist_bendgesture" {
	"cat_bartender_anims\cellist_bendgesture.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "singer_crawl" {
	"cat_bartender_anims\singer_crawl.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "singer_reveal" {
	"cat_bartender_anims\singer_reveal.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "singer_showshard" {
	"cat_bartender_anims\singer_showshard.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "singer_survey" {
	"cat_bartender_anims\singer_survey.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "singer_whistle" {
	"cat_bartender_anims\singer_whistle.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_shrug" {
	"cat_bartender_anims\gesture_shrug.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "pose_sit01" {
	"cat_bartender_anims\pose_sit01.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "pose_sit02" {
	"cat_bartender_anims\pose_sit02.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "pianist_drunk_idle" {
	"cat_bartender_anims\pianist_drunk_idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "pianist_drunk_to_player" {
	"cat_bartender_anims\pianist_drunk_to_player.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "pianist_drunk_to_idle" {
	"cat_bartender_anims\pianist_drunk_to_idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "pianist_drunk_slam" {
	"cat_bartender_anims\pianist_drunk_slam.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}
