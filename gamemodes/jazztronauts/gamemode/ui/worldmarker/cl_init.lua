
module("worldmarker", package.seeall)

markers = markers or {}
local screenSize = ScreenScale(16)
function Register(name, icon, radius)
    markers[name] = 
    {
        name = name,
        icon = icon,
        radius = radius,
        vishandle = util.GetPixelVisibleHandle(),
        pos = Vector(),
        enabled = true
    }
end

function SetEnabled(name, enabled)
    if not markers[name] then return end
    markers[name].enabled = enabled
end

function SetIcon(name, icon)
    if not markers[name] then return end
    markers[name].icon = icon
end

function Update(name, pos)
    if not markers[name] then return end
    markers[name].pos = pos
end

hook.Add("HUDPaint", "JazzWorldMarkerDraw", function()
    for _, v in pairs(markers) do
        if not v.enabled then continue end
        local visible = util.PixelVisible(v.pos, v.radius, v.vishandle)
        if not visible or visible <= 0 then continue end
        
        cam.Start3D()
            local scrpos = v.pos:ToScreen()
        cam.End3D() 
        render.SetBlend(visible)
        surface.SetDrawColor( 255, 255, 255, visible * 255 )
        surface.SetMaterial(v.icon)
        surface.DrawTexturedRect(scrpos.x - screenSize/2, scrpos.y - screenSize/2, screenSize, screenSize)
        render.SetBlend(1)
    end
end )