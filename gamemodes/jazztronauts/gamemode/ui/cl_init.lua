include("dialog/cl_init.lua")
--include("radar/cl_init.lua")
include("transition/cl_init.lua")
include("propfeed/cl_init.lua")
include("missions/cl_init.lua")
include("spawnmenu/cl_init.lua")
include("store/cl_init.lua")
include("worldmarker/cl_init.lua")
include("nametags/cl_init.lua")
include("cl_skin.lua")

function GM:HUDPaint()

	self.BaseClass.HUDPaint(self)

	if jazzHideHUD then return end

	dialog.PaintAll()
	--radar.Paint()
	propfeed.Paint()
	eventfeed.Paint()
	jnametag.Paint()
	loadicon.Paint()

end

hook.Add("Think", "JazzTickDialog", function()

	dialog.Update( FrameTime() )

end )
