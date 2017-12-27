if SERVER then AddCSLuaFile("sh_geomutils.lua") end

print("GEOM UTILS")

function AABBToSphere( mins, maxs )

	local center = (mins + maxs) / 2
	local diagonal = (maxs - mins):Length()

	return center, diagonal / 2

end