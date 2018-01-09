include("dialog/cl_init.lua")
include("radar/cl_init.lua")
include("transition/cl_init.lua")

function GM:HUDPaint()

	self.BaseClass.HUDPaint(self)

	dialog.PaintAll()
	radar.Paint()

end