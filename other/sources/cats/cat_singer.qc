$ModelName "andy/singer/cat_singer.mdl"

$Body "cat_singer" "cat_singer.dmx"

$SurfaceProp "default"

$Contents "solid"

$CDMaterials "models\andy\singer"

$TextureGroup "skinfamilies"
{
	{ "cat_singer_01" }
	{ "cat_singer_02" }
	{ "cat_singer_03" }
	{ "cat_singer_04" }
	{ "cat_singer_05" }
	{ "cat_singer_06" }
	{ "cat_singer_07" }
	{ "cat_singer_08" }
}

$BBox -1.314 -23.646 -11.263 57.513 10.76 11.443

$SectionFrames 30 119

$Sequence "idle" {
	"cat_singer_anims\idle.smd"
	activity "ACT_IDLE" -1
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "gesture_sweep" {
	"cat_singer_anims\gesture_sweep.smd"
	fadein 0.2
	fadeout 0.2
	snap
	fps 24
}

$Sequence "gesture_dryhands" {
	"cat_singer_anims\gesture_dryhands.smd"
	fadein 0.2
	fadeout 0.2
	snap
	fps 24
}

$Sequence "gesture_washing" {
	"cat_singer_anims\gesture_washing.smd"
	fadein 0.1
	fadeout 0.1
	fps 24
	loop
}

$Sequence "gesture_jab" {
	"cat_singer_anims\gesture_jab.smd"
	fadein 0.2
	fadeout 0.2
	snap
	fps 24
}

$Sequence "gesture_foldarms" {
	"cat_singer_anims\gesture_foldarms.smd"
	fadein 0.2
	fadeout 0.2
	snap
	fps 30
}

$Sequence "pose_elegant" {
	"cat_singer_anims\pose_elegant.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "pose_hangingout" {
	"cat_singer_anims\pose_hangingout.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "pose_leanwallback" {
	"cat_singer_anims\pose_leanwallback.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "pose_passedout" {
	"cat_singer_anims\pose_passedout.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "pose_relax" {
	"cat_singer_anims\pose_relax.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "gesture_agree" {
	"cat_singer_anims\gesture_agree.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_disagree" {
	"cat_singer_anims\gesture_disagree.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_laugh" {
	"cat_singer_anims\gesture_laugh.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_sigh" {
	"cat_singer_anims\gesture_sigh.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "bartender_search" {
	"cat_singer_anims\bartender_search.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "cellist_bendgesture" {
	"cat_singer_anims\cellist_bendgesture.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "singer_crawl" {
	"cat_singer_anims\singer_crawl.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "singer_reveal" {
	"cat_singer_anims\singer_reveal.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "singer_showshard" {
	"cat_singer_anims\singer_showshard.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "singer_survey" {
	"cat_singer_anims\singer_survey.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "singer_whistle" {
	"cat_singer_anims\singer_whistle.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_anger" {
	"cat_singer_anims\gesture_anger.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_clap" {
	"cat_singer_anims\gesture_clap.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_confused" {
	"cat_singer_anims\gesture_confused.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_embarass" {
	"cat_singer_anims\gesture_embarass.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_exchange" {
	"cat_singer_anims\gesture_exchange.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_facepalm" {
	"cat_singer_anims\gesture_facepalm.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_shock" {
	"cat_singer_anims\gesture_shock.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "gesture_shrug" {
	"cat_singer_anims\gesture_shrug.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "pose_sit01" {
	"cat_singer_anims\pose_sit01.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "pose_sit02" {
	"cat_singer_anims\pose_sit02.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
	loop
}

$Sequence "pianist_drunk_idle" {
	"cat_singer_anims\pianist_drunk_idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "pianist_drunk_to_player" {
	"cat_singer_anims\pianist_drunk_to_player.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "pianist_drunk_to_idle" {
	"cat_singer_anims\pianist_drunk_to_idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}

$Sequence "pianist_drunk_slam" {
	"cat_singer_anims\pianist_drunk_slam.smd"
	fadein 0.2
	fadeout 0.2
	fps 24
}
