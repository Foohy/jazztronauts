AddCSLuaFile()

if SERVER then return end

print("FRICK")

local frick = CreateMaterial("Frick" .. FrameNumber(), "UnLitGeneric", {
	["$basetexture"] = "_rt_FullFrameFB",
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$model"] = 0,
	["$additive"] = 0,
})

hook.Add("PostDrawOpaqueRenderables", "drugs", function( bdepth, bsky )

	--if bsky then return end

	cam.Start2D()
	surface.SetDrawColor(255,255,255,255)
	surface.SetMaterial( frick )
	--surface.DrawTexturedRect( -2 + math.sin(CurTime())*10, -2 + math.cos(CurTime()*6)*10, ScrW()+2, ScrH()+2 )
	cam.End2D()

end)

hook.Add("HUDPaint", "drugs", function()

	--render.UpdateScreenEffectTexture()


end)