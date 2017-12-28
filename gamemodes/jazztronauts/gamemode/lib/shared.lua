include("sh_gc.lua")
include("sh_task.lua")
include("sh_mesh.lua")
include("sh_csent.lua")
include("sh_matrix.lua")
include("sh_quat.lua")
include("sh_geomutils.lua")
include("sh_rect.lua")
include("sh_camera.lua")
include("sh_scene.lua")
include("sh_irt.lua")

include("sh_poly.lua")
include("sh_brush.lua")
include("sh_bsp.lua")

if SERVER then AddCSLuaFile("shared.lua") end