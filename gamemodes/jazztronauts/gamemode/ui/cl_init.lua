print("UI INIT CL")

include("dialog/cl_init.lua")

function GM:HUDPaint()

	self.BaseClass.HUDPaint(self)

	dialog.PaintAll()

end