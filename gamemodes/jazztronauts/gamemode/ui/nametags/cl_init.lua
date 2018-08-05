

module( "jnametag", package.seeall )

local function DrawNameTag(ply)
	local pos = ply:EyePos()
	local scr = pos:ToScreen()
	local name = ply:GetName()

	surface.SetFont("DermaDefault")
	local w, h = surface.GetTextSize(name)
	local x, y = scr.x - w/2, scr.y - h/2

	-- Draw background box
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(x, y, w, h)

	-- Draw name
	surface.SetTextColor(color_white)
	surface.SetTextPos(x, y)
	surface.DrawText(name)
end

function Paint()
	local players = player.GetAll()

	for _, v in pairs(players) do
		if v == LocalPlayer() then continue end

		DrawNameTag(v)
	end

end