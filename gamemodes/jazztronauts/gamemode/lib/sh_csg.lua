if SERVER then AddCSLuaFile("sh_csg.lua") end
if SERVER then return end

module("csg", package.seeall )

local function CanBiteBrush(a, b)

	if bit.band( a.contents, CONTENTS_WATER ) ~= 0 or
		bit.band( b.contents, CONTENTS_WATER ) ~= 0 then
		return false
	end

	if ( bit.band( a.contents, CONTENTS_DETAIL ) ~= 0 ) and
		not ( bit.band( b.contents, CONTENTS_DETAIL ) ~= 0 ) then
		return false
	end

	if bit.band( a.contents, CONTENTS_SOLID ) ~= 0 then
		return true
	end

	return false

end

function Subtract(a, b, out)

	if type(out) ~= "table" then error("Expected output table to 'csg.Subtract'") end

	local tosplit = a
	for k,side in pairs(b.sides) do
		if not tosplit then break end
		local front, back = tosplit:Split( side.plane.back )
		if front then
			table.insert( out, 1, front )
		end
		tosplit = back
	end

	if not tosplit then
		return false
	end
	return true

end

function Intersect(a, b)

	local tosplit = a
	for _,side in pairs(b.sides) do
		if not tosplit then break end
		local front, back = tosplit:Split( side.plane.back )
		tosplit = back
	end

	if tosplit == a then return false end
	return tosplit

end

function CheckDisjoint(a, b)

	for i=1, 3 do
		if a.min[i] >= b.max[i] or a.max[i] <= b.min[i] then return true end
	end

	for i=1, #a.sides do
		for j=1, #b.sides do
			if a.sides[i].plane == b.sides[j].plane.back then
				return true
			end
		end
	end

	return false

end

local function LinkList(list)

	for i=1, #list-1 do
		list[i].next = list[i+1]
	end

	return list[1]

end

local function UnlinkList(list)

	local out = {}
	while list ~= nil do
		--local a = list
		table.insert(out, list)
		list = list.next
		--a.next = nil
	end
	return out

end

local function AddToTail(list, tail)

	local walk = list
	local wnext = nil
	while walk ~= nil do
		wnext = walk.next
		walk.next = nil
		tail.next = walk
		tail = walk
		walk = wnext
	end
	return tail

end

local function CullList(list, skip)

	local new = nil
	local wnext = nil
	while list ~= nil do
		wnext = list.next
		if list ~= skip then
			list.next = new
			new = list
		end
		list = wnext
	end
	return new

end

local yieldCounter = 0
function ChopBrushes(list)

	if #list == 0 then return end

	local keep = nil
	local anext = nil
	local tail = nil
	local a,b = nil, nil
	local c1,c2 = nil, nil

	list = LinkList(list)

	::start::

	if not list then print("LIST IS EMPTY!") return {} end
	tail = list repeat tail = tail.next until not tail.next

	a = list while a ~= nil do
		anext = a.next
		yieldCounter = yieldCounter + 1 if yieldCounter % 20 == 1 then task.Yield("progress") end
		b = a.next while b ~= nil do
		repeat
			if CheckDisjoint(a, b) then --[[print("DISJOINT")]] break end

			yieldCounter = yieldCounter + 1 if yieldCounter % 50 == 1 then task.Yield() end

			b.fade2 = 1
			a.fade2 = 1

			c1 = 999999
			c2 = 999999
			local subAB = nil
			local subBA = nil

			if CanBiteBrush(b, a) then
				--print("BITE: " .. i .. " -> " .. j)
				local out = {}
				if not Subtract(a, b, out) then --[[print("No Subtract")]] break end
				if #out == 0 then
					list = CullList(a, a)
					goto start
				end

				c1 = #out
				subAB = out
			end

			if CanBiteBrush(a, b) then
				--print("BITE: " .. j .. " -> " .. i)
				local out = {}
				if not Subtract(b, a, out) then --[[print("No Subtract")]] break end
				if #out == 0 then
					list = CullList(a, b)
					goto start
				end

				c2 = #out
				subBA = out
			end

			if not subAB and not subBA then break end
			if c1 > 1 and c2 > 1 then --[[print("FRAGMENT: " .. c1 .. " " .. c2)]] break end

			if c1 < c2 then
				tail = AddToTail( LinkList( subAB ), tail )
				list = CullList(a, a)
				goto start
			else
				tail = AddToTail( LinkList( subBA ), tail )
				list = CullList(a, b)
				goto start
			end

		until true
		b = b.next
		end

		if not b then
			a.next = keep
			keep = a
		end

	a = anext
	end

	return UnlinkList( keep )

end

function ChopBrushes_OLD(list)

	if #list == 0 then return end

	local keep = {}
	local a,b = nil, nil
	local c1,c2 = nil, nil

	::start::

	for i=1, #list do
		if i % 10 == 1 then task.Yield("progress") end
		for j=i+1, #list do
		repeat
			--print("TEST: " .. i .. " " .. j)
			a = list[i]
			b = list[j]
			c1 = 999999
			c2 = 999999

			yieldCounter = yieldCounter + 1
			if yieldCounter % 20000 == 1 then task.Yield() end

			if CheckDisjoint(a, b) then --[[print("DISJOINT")]] break end
			local subAB = nil
			local subBA = nil

			if CanBiteBrush(b, a) then
				--print("BITE: " .. i .. " -> " .. j)
				local out = {}
				if not Subtract(a, b, out) then --[[print("No Subtract")]] break end
				if #out == 0 then
					print("No Result: " .. i .. " -> " .. j)
					table.remove( list, i )
					goto start
				end

				subAB = out
				c1 = #subAB
			end

			if CanBiteBrush(a, b) then
				--print("BITE: " .. j .. " -> " .. i)
				local out = {}
				if not Subtract(b, a, out) then --[[print("No Subtract")]] break end
				if #out == 0 then
					print("No Result: " .. i .. " <- " .. j)
					table.remove( list, j )
					goto start
				end

				subBA = out
				c2 = #subBA
			end

			if not subAB and not subBA then break end

			if c1 > 1 and c2 > 1 then break end --print("FRAGMENT: " .. c1 .. " " .. c2) break end
			if c1 < c2 then
				for k,v in pairs(subAB) do table.insert( list, v ) end
				table.remove( list, i )
				goto start
			else
				for k,v in pairs(subBA) do table.insert( list, v ) end
				table.remove( list, j )
				goto start
			end

		until true
		end

		if a then table.insert(keep, a) end

	end

	return keep

end