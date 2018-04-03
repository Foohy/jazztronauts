include("shared.lua")

local function CopyMaterial(mat, name)
    local vals = mat:GetKeyValues()
    for k, v in pairs(vals) do if type(v) == "ITexture" then vals[k] = v:GetName() end end
    vals["$translucent"] = 1 -- Why isn't this copied??
    return CreateMaterial(name, mat:GetShader(), vals)
end

local ReticleCircleMaterial 	= CopyMaterial(Material("ui/jazztronauts/circle"), "BusMarkerMaterial" .. FrameNumber())
local ReticleCenterMaterial     = Material("icon16/car.png")

ENT.SpawnScale = 0
function ENT:Initialize()

end


function ENT:Think()

    if not self:GetIsBeingDeleted() then
        LocalPlayer().ActiveBusMarkers = LocalPlayer().ActiveBusMarkers or {}
        table.insert(LocalPlayer().ActiveBusMarkers, self)
    end

    -- Approach spawn scale for a nice womp in
    local goalScale = self.GetIsBeingDeleted and self:GetIsBeingDeleted() and 0 or 1
    self.SpawnScale = math.Approach(self.SpawnScale, goalScale, FrameTime() * 5)
    self:SetModelScale(self.SpawnScale)

end

function ENT:Draw()
    self:DrawModel()
end

local function drawSemiCircle(cx, cy, w, h, perc)
    local verts = {{x = cx, y = cy}}
    
    for i=0,32 do
        local rad = perc * 2 * math.pi * i / 32.0
        table.insert(verts, {
            x = math.cos(rad) * w + cx,
            y = math.sin(rad) * h + cy
        })
    end

    surface.DrawPoly(verts)
end

local function isMarkerLocallyHeld(marker)
    local wep = LocalPlayer():GetWeapon("weapon_buscaller")
    if not IsValid(wep) or wep != LocalPlayer():GetActiveWeapon() then return false end

    return marker == wep:GetBusMarker()
end

hook.Add( "PostDrawHUD", "JazzDrawBusMarker", function()
    local markers = LocalPlayer().ActiveBusMarkers
    if !markers or #markers == 0 then return end
 
	cam.Start2D()
        local pfov = LocalPlayer():GetFOV()

        for _, v in pairs(markers) do
            if !IsValid(v) then continue end
            local isLook = v:IsLookingAt(EyePos(), EyeAngles():Forward(), LocalPlayer():GetFOV()) or isMarkerLocallyHeld(v)
            local isMoving = v:GetSpawnPercent() > 0
            v.SmoothPercent = v.SmoothPercent or 0     
            v.SmoothPercent = math.Approach(v.SmoothPercent, v:GetSpawnPercent(), FrameTime() * 0.25)

            -- ToScreen only works in a 3d rendering context....
            local scrpos = nil
            cam.Start3D() scrpos = v:GetPos():ToScreen() cam.End3D()

            local x = math.Clamp(scrpos.x, 100, ScrW() - 100)
            local y = math.Clamp(scrpos.y, 100, ScrH() - 100)

	        local radius = (ScrW() / 2) * math.tan(math.rad(90 - pfov/2)) * math.tan(math.rad(v.CircleCone))
            surface.SetDrawColor( 255, 0, 0, 255 )
	        draw.NoTexture()
            //surface.DrawCircle(x, y, radius, 255, isLook and 0 or 255, 255, 100)

            draw.NoTexture()
            surface.SetDrawColor(255, 255, 255, 100)
            drawSemiCircle(x, y, radius * 0.73, radius* 0.73, v:GetSpawnPercent())
            
            local size = radius * 2.55
            ReticleCircleMaterial:SetFloat("$glowstart", isLook and 0 or 1)
            ReticleCircleMaterial:SetFloat("$glowend", 1.0)
            ReticleCircleMaterial:SetFloat("$glowalpha", 1)

            ReticleCircleMaterial:SetFloat("$edgesoftnessstart", .48)
            ReticleCircleMaterial:SetFloat("$edgesoftnessend", 0.4 - v:GetSpawnPercent() * 0.4)

            ReticleCircleMaterial:SetVector("$glowcolor", Vector(255/255.0, 247/255.0, 114/255.0))
            surface.SetMaterial(ReticleCircleMaterial)
            surface.SetDrawColor(isLook and 30 or 255, 255, isLook and 30 or 255, 255)
	        surface.DrawTexturedRect(x - size/2, y - size/2, size, size)

            local size = radius * 1
            surface.SetMaterial(ReticleCenterMaterial)
            surface.SetDrawColor(255, 255, 255, 255)
            local rot = math.sin(CurTime()* 4) * 20
            rot = rot + ( v.SmoothPercent + math.pow(v.SmoothPercent * 100, 2))

            surface.DrawTexturedRectRotated(x, y, size, size, rot)


            //draw.DrawText(tostring(v:GetSpawnPercent()), nil, x, y)
        end
	cam.End2D()

    LocalPlayer().ActiveBusMarkers = {}
end )