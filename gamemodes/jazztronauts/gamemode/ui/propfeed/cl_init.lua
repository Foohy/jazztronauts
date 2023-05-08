
module( "propfeed", package.seeall )

//How long an entry with no updates will stay up
StayDuration = CreateClientConVar( "jazz_propfeed_stayduration", "6", true, false, "How long an entry with no updates will stay up in the prop feed. Default 6", 0.1 )

local function strip_mdl(prop)

	if string.find(prop, ".mdl") then
		return string.sub(prop, 0, -5)
	end
	return prop

end

local function nice_prop_name(prop)

	prop = strip_mdl( prop )
	local found = string.find(prop, "/[^/]*$")
	if not found then return prop end
	return string.sub(prop, found + 1, -1)

end

local prop_streaks = {}
local brush_streaks = {}


net.Receive("brushcollect", function()

	local material = net.ReadString()
	local worth = net.ReadUInt( 32 )
	local ply = net.ReadEntity()
	local streak = brush_streaks[ply:EntIndex()]
	local prop_streak = prop_streaks[ply:EntIndex()]

	local model = Model("models/sunabouzu/worldgib02.mdl")
	local mat = brush.GetBrushMaterial( material )

	if streak == nil or streak:Done() then

		ply.bstreakcount = 1
		ply.bstreaktotal = worth

		brush_streaks[ply:EntIndex()] = eventfeed.Create()
			:Title(jazzloc.Localize("jazz.message.stole","%name","%count","%brushes"), 
				{
					name = function() return IsValid(ply) and ply:Nick() or "<player>" end, 
					count = function() return IsValid(ply) and ply.bstreakcount or 0 end,
					brushes = function() return ( IsValid(ply) and ply.bstreakcount > 1 ) and jazzloc.Localize("jazz.message.brushes") or jazzloc.Localize("jazz.message.brush") end,
				}
			)
			:Body("%total", 
				{
					total = function() return jazzloc.Localize("jazz.hud.money",jazzloc.AddSeperators( IsValid(ply) and ply.bstreaktotal or 0)) end
				}
			)
			:SetHighlighted( ply == LocalPlayer() )
			:SetIconModel( model, nil, mat )
			:Dispatch( StayDuration:GetFloat(), (prop_streak and not prop_streak:Done() and prop_streak) or "bottom" )

	elseif streak ~= nil then

		ply.bstreakcount = (ply.bstreakcount or 0) + 1
		ply.bstreaktotal = (ply.bstreaktotal or 0) + worth

		streak:Ping( StayDuration:GetFloat() )
		streak:SetIconModel( model, nil, mat )

	end

end )

net.Receive("propcollect", function()

	local model = net.ReadString()
	local skin = net.ReadUInt( 16 )
	local count = net.ReadUInt( 16 )
	local worth = net.ReadUInt( 32 )
	local ply = net.ReadEntity()
	local streak = prop_streaks[ply:EntIndex()]
	local brush_streak = brush_streaks[ply:EntIndex()]

	if streak == nil or streak:Done() then

		ply.streakcount = 1
		ply.streaktotal = worth

		prop_streaks[ply:EntIndex()] = eventfeed.Create()
			:Title(jazzloc.Localize("jazz.message.stole","%name","%count","%props"), 
				{
					name = function() return IsValid(ply) and ply:Nick() or "<player>" end, 
					count = function() return IsValid(ply)and ply.streakcount or 0 end,
					props = function() return ( IsValid(ply) and ply.streakcount > 1 ) and jazzloc.Localize("jazz.message.props") or jazzloc.Localize("jazz.message.prop") end,
				}
			)
			:Body("%total", 
				{
					total = function() return jazzloc.Localize("jazz.hud.money",jazzloc.AddSeperators( IsValid(ply) and ply.streaktotal or 0)) end
				}
			)
			:SetHighlighted( ply == LocalPlayer() )
			:SetIconModel( model, skin )
			:Dispatch( StayDuration:GetFloat(), (brush_streak and not brush_streak:Done() and brush_streak) or "bottom" )

	elseif streak ~= nil and ply.streakcount then

		ply.streakcount = ply.streakcount + 1
		ply.streaktotal = ply.streaktotal + worth

		streak:SetIconModel( model, skin )
		streak:Ping( StayDuration:GetFloat() )

	end

end)

function Paint()


end