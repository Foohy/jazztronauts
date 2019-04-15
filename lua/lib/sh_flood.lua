if SERVER then AddCSLuaFile("sh_flood.lua") end

local domin = Vector(-1,-1,-4)
local domax = -domin
local do2min = Vector(-2,-2,-32)
local do2max = -do2min
local height = 32
local flood_area = 65536
local cell_size = 1024
local cell_axis_count = flood_area / cell_size
local cell_count = math.pow(cell_axis_count, 2)
local half_flood_area = flood_area / 2
local half_cell_size = cell_size / 2

local function plot( pos, col, big )
	--local pz = Vector(pos.x, pos.y, -220)
	debugoverlay.Box(pos, big and do2min or domin, big and do2max or domax, 120, col or Color( 255, 255, 255 ), true)
end

function get_cell_center(id)
	id = id - 1
	local x = (id % cell_axis_count) * cell_size - half_flood_area
	local y = math.floor(id / cell_axis_count) * cell_size - half_flood_area
	return Vector(x, y, 0)
end

function get_cell(pos)
	local rx = math.ceil( (pos.x + half_flood_area - half_cell_size) / cell_size )
	local ry = math.ceil( (pos.y + half_flood_area - half_cell_size) / cell_size ) * cell_axis_count
	local cellid = 1 + rx + ry
	return cellid
end

function node_within_cell(id, pos, density)
	if not check_cell(id) then return nil end
	local center = get_cell_center(id)
	local offset = pos - center
	local size = cell_size / density
	if math.abs(offset.x) > half_cell_size then return nil end
	if math.abs(offset.y) > half_cell_size then return nil end
	local idx = math.floor( (offset.x + half_cell_size) / size)
	local idy = math.floor( (offset.y + half_cell_size) / size) * density
	local id = 1 + idx + idy
	return id
end

function node_center(id, node, density)
	node = node - 1
	local center = get_cell_center(id)
	local size = cell_size / density
	local x = (node % density) * size - half_cell_size + size/2
	local y = math.floor(node / density) * size - half_cell_size + size/2
	return center + Vector(x, y, 0)
end

function check_cell(id)
	return id > 0 and id <= cell_count
end

local fill_state = {
	queue = {}
}

local cells = {}
local ortho = { Vector(1,0,0), Vector(0,1,0), Vector(0,0,1) }

function get_cell_state(id)
	cells[id] = cells[id] or {}

	local cell = cells[id]
	cell.nodes = cell.nodes or {}
	cell.density = cell.density or 4 --or math.pow(2, math.random(3,5))
	return cell
end

function get_height(pos)

	local trace = {
		start = pos,
		endpos = pos - Vector(0,0,10000),
		mask = MASK_SOLID,
		collisiongroup = COLLISION_GROUP_PLAYER,
		filter = player.GetAll(),
	}

	local res = util.TraceLine( trace )
	if not res.Hit then return 1000000 end
	return pos.z - res.HitPos.z

end

function player_can_fit(pos)

	local tr = util.TraceHull( {
		start = pos + Vector(0,0,1),
		endpos = pos + Vector(0,0,11),
		maxs = Vector(16,16,32),
		mins = Vector(-16,-16,0),
	} )

	return not tr.Hit

end

function fill_step()

	if #fill_state.queue == 0 then return true end

	local queued = fill_state.queue[1] --node_within_cell( cell, start, density )
	table.remove(fill_state.queue, 1)

	local cell = queued[1]
	local node = queued[2]
	local z = queued[3]
	local main_state = get_cell_state( cell )
	local span = cell_size / main_state.density
	local node_location = node_center( cell, node, main_state.density )

	node_location.z = z
	local round_off = math.Round( z / 128.0 ) * 128

	local nodedata = z
	if bit.band( util.PointContents( node_location ), CONTENTS_SOLID ) ~= 0 then
		fill_step()
		return
	end

	if not player_can_fit( node_location ) then
		fill_step()
		return
	end

	if get_height( node_location ) > 32 then
		fill_step()
		return
	end

	if main_state.nodes[node] ~= nil and main_state.nodes[node][round_off] ~= nil then
		fill_step()
		return
	end
	main_state.nodes[ node ] = main_state.nodes[ node ] or {}
	main_state.nodes[ node ][ round_off ] = true

	debugoverlay.Box( get_cell_center(cell),
		Vector(-half_cell_size, -half_cell_size, -10),
		Vector(half_cell_size, half_cell_size, 10),
		10, Color( 20, 20, 20, 50 ), true)

	--plot( node_location, Color(255,0,0), true )
	debugoverlay.Box( node_location,
		Vector(-2,-2,0),
		Vector(2,2,16),
		120, Color( 100, 255, 255 ), false)

	for i=1,2 do

		for j=-1,1 do
			local adv = node_location + ortho[i] * j * span
			local adv_cell_id = get_cell( adv )

			if check_cell( adv_cell_id ) then
				local state = get_cell_state( adv_cell_id )
				local advn = node_within_cell( adv_cell_id, adv, state.density )
				if advn then

					adv.z = z

					local trace = {
						start = node_location,
						endpos = adv,
						mask = MASK_SOLID,
						collisiongroup = COLLISION_GROUP_PLAYER,
						filter = player.GetAll(),
					}
					local res = util.TraceLine( trace )
					if not res.Hit then
						table.insert( fill_state.queue, { adv_cell_id, advn, z })
					else
						table.insert( fill_state.queue, { adv_cell_id, advn, res.HitPos.z + 30 })
					end

				end
			end
		end

	end

	return false

end

function fill_start( pos )

	local cell = get_cell( pos )
	local state = get_cell_state( cell )
	local node = node_within_cell( cell, pos, state.density )
	table.insert( fill_state.queue, { cell, node, pos.z } )

end


if SERVER then return end
if true then return end

local start = Vector(-768.000000, -2048.000000, 73.000000)
--ents.FindByClass("info_player_start")[1]:GetPos()
--fill_cell( start + Vector(0,0,height) )

--local start = Vector(0,0,0) --player.GetAll()[1]:GetPos()
fill_start(start)

hook.Add("Think", "filltest", function()

	for i=1, 6 do
		fill_step()
	end

end)

print("Flood algorithm")