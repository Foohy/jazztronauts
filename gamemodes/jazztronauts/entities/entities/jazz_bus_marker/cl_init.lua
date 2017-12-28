include("shared.lua")



function ENT:Think()

    LocalPlayer().ActiveBusMarkers = LocalPlayer().ActiveBusMarkers or {}
    table.insert(LocalPlayer().ActiveBusMarkers, self)

end

function ENT:Draw()
    self:DrawModel()
end

local function drawSemiCircle(cx, cy, w, h, perc)
    local verts = {{x = cx, y = cy}}
    
    for i=0,127 do
        local rad = perc * 2 * math.pi * i / 127.0
        table.insert(verts, {
            x = math.cos(rad) * w + cx,
            y = math.sin(rad) * h + cy
        })
    end

    surface.DrawPoly(verts)
end

hook.Add( "PostDrawHUD", "JazzDrawBusMarker", function()
    local markers = LocalPlayer().ActiveBusMarkers
    if !markers or #markers == 0 then return end
    
    //PrintTable(Vector():ToScreen())
	cam.Start2D()
        for _, v in pairs(markers) do
            if !IsValid(v) then continue end

            -- ToScreen only works in a 3d rendering context....
            local scrpos = nil
            cam.Start3D() scrpos = v:GetPos():ToScreen() cam.End3D()

            local x = math.Clamp(scrpos.x, 100, ScrW() - 100)
            local y = math.Clamp(scrpos.y, 100, ScrH() - 100)

            local circSize = ScreenScale(20)
            surface.SetDrawColor( 255, 0, 0, 255 )
	        draw.NoTexture()
            surface.DrawCircle(x, y, circSize, 255, 255, 255, 100)
            drawSemiCircle(x, y, circSize, circSize, v:GetSpawnPercent())

            //draw.DrawText(tostring(v:GetSpawnPercent()), nil, x, y)
        end
	cam.End2D()

    LocalPlayer().ActiveBusMarkers = {}
end )