
module( "propfeed", package.seeall )

//How long an entry with no updates will stay up
StayDuration = 6

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

function comma_value(amount)

	local formatted = amount
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end

	return formatted

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
			:Title("%name STOLE %count %brushes", 
				{
					name = function() return ply:IsValid() and ply:Nick() or "<player>" end, 
					count = function() return ply:IsValid() and ply.bstreakcount or 0 end,
					brushes = function() return ply.bstreakcount > 1 and "brushes" or "brush" end,
				}
			)
			:Body("%total", 
				{
					total = function() return "$" .. comma_value( ply.bstreaktotal ) end
				}
			)
			:SetHighlighted( ply == LocalPlayer() )
			:SetIconModel( model, nil, mat )
			:Dispatch( StayDuration, (prop_streak and not prop_streak:Done() and prop_streak) or "bottom" )

	elseif streak ~= nil then

		ply.bstreakcount = ply.bstreakcount + 1
		ply.bstreaktotal = ply.bstreaktotal + worth

		streak:Ping( StayDuration )
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
			:Title("%name STOLE %count %props", 
				{
					name = function() return ply:IsValid() and ply:Nick() or "<player>" end, 
					count = function() return ply:IsValid() and ply.streakcount or 0 end,
					props = function() return ply.streakcount > 1 and "props" or "prop" end,
				}
			)
			:Body("%total", 
				{
					total = function() return "$" .. comma_value( ply.streaktotal ) end
				}
			)
			:SetHighlighted( ply == LocalPlayer() )
			:SetIconModel( model, skin )
			:Dispatch( StayDuration, (brush_streak and not brush_streak:Done() and brush_streak) or "bottom" )

	elseif streak ~= nil then

		ply.streakcount = ply.streakcount + 1
		ply.streaktotal = ply.streaktotal + worth

		streak:SetIconModel( model, skin )
		streak:Ping( StayDuration )

	end

end)

function Paint()


end