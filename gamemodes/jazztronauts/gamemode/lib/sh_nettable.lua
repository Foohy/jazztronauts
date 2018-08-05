if SERVER then
	util.AddNetworkString( "nettable_msg" )
	AddCSLuaFile()
end

module( "nettable", package.seeall )

TRANSMIT_AUTO   = 1 -- Automatically broadcast changes
TRANSMIT_MANUAL = 2 -- Changes must be manually broadcasted
TRANSMIT_ONCE   = 3 -- Changes are only broadcasted once for each player

nettables = nettables or {}
hooks = hooks or {}
broadcastinterval = 0.2

local nextBroadcast = 0

WriteVars =
{
	[TYPE_NIL]			= function ( v )							end,
	[TYPE_STRING]		= function ( v )	net.WriteString( v )	end,
	[TYPE_NUMBER]		= function ( v )	net.WriteDouble( v )	end,
	[TYPE_TABLE]		= function ( v )	net.WriteTable( v )		end,
	[TYPE_BOOL]			= function ( v )	net.WriteBool( v )		end,
	[TYPE_ENTITY]		= function ( v )	net.WriteEntity( v )	end,
	[TYPE_VECTOR]		= function ( v )	net.WriteVector( v )	end,
	[TYPE_ANGLE]		= function ( v )	net.WriteAngle( v )		end,
	[TYPE_MATRIX]		= function ( v )	net.WriteMatrix( v )	end,
	[TYPE_COLOR]		= function ( v )	net.WriteColor( v )		end,
}

ReadVars =
{
	[TYPE_NIL]		= function ()	return nil end,
	[TYPE_STRING]	= function ()	return net.ReadString() end,
	[TYPE_NUMBER]	= function ()	return net.ReadDouble() end,
	[TYPE_TABLE]	= function ()	return net.ReadTable() end,
	[TYPE_BOOL]		= function ()	return net.ReadBool() end,
	[TYPE_ENTITY]	= function ()	return net.ReadEntity() end,
	[TYPE_VECTOR]	= function ()	return net.ReadVector() end,
	[TYPE_ANGLE]	= function ()	return net.ReadAngle() end,
	[TYPE_MATRIX]	= function ()	return net.ReadMatrix() end,
	[TYPE_COLOR]	= function ()	return net.ReadColor() end,
}

local function CallHook(name, ...)
	if not hooks[name] then return end

	for _, v in pairs(hooks[name]) do
		if v then v( ... ) end
	end
end

function Get(name)
	if not nettables[name] then return {} end

	return nettables[name].data or {}
end

function Set(name, tbl)
	if not nettables[name] then return nil end

	nettables[name].data = tbl
end

function Create(name, transmitMode, updateRate)
	print("Creating new nettable " .. name)
	nettables[name] =
	{
		data = {},
		sentData = {},
		transmitMode = transmitMode or TRANSMIT_AUTO,
		updateRate = updateRate or broadcastinterval
	}

	return nettables[name].data
end

function Hook(name, id, func)
	hooks[name] = hooks[name] or {}
	hooks[name][id] = func
end


local function diffTable(new, old)
	local changed = {}
	local removed = {}

	-- Check for changes/additions
	for k, v in pairs(new) do
		if not old[k] or old[k] != v then
			changed[k] = v
		end
	end

	-- Check for deletions
	for k, v in pairs(old) do
		if not new[k]then
			table.insert(removed, k)
		end
	end

	return changed, removed
end

local function tableRemoveKeys(tbl, keys)
	for _, v in pairs(keys) do
		tbl[v] = nil
	end
end

-- Write a table, but assumes the types for keys and values are the same for the whole table
local function writeTableHomogenous(tbl, valuesOnly)
	local count = table.Count(tbl)
	net.WriteUInt(count, 32)

	-- If table is empty, don't bother with type information
	if count == 0 then return end

	-- Write the types out based on the first table entry
	local ktype, vtype = next(tbl)
	ktype = TypeID(ktype)
	vtype = TypeID(vtype)

	if not valuesOnly then net.WriteUInt(ktype, 8) end
	net.WriteUInt(vtype, 8)

	-- Write each table entry
	for k, v in pairs(tbl) do
		if not valuesOnly then WriteVars[ktype](k) end
		WriteVars[vtype](v)
	end
end

local function readTableHomogenous(valuesOnly)
	local tbl = {}
	local count = net.ReadUInt(32)

	if count == 0 then
		return tbl
	end

	-- Read type info
	local ktype, vtype
	if not valuesOnly then ktype = net.ReadUInt(8) end
	vtype = net.ReadUInt(8)

	-- Read each table entry
	for i=1, count do
		local k, v
		k = i

		if not valuesOnly then k = ReadVars[ktype]() end
		v = ReadVars[vtype]()

		tbl[k] = v
	end

	return tbl
end

if SERVER then
	function Broadcast(name, ply, fullupdate)
		local nettable = nettables[name]
		if not nettable then return end

		local changed, removed = diffTable(nettable.data, fullupdate and {} or nettable.sentData)
		if table.Count(changed) == 0 and #removed == 0 then return end

		net.Start("nettable_msg")
			net.WriteString(name)
			net.WriteBool(fullupdate)
			writeTableHomogenous(changed)

			if not fullupdate then
				writeTableHomogenous(removed, true)
			end
		_ = IsValid(ply) and net.Send(ply) or net.Broadcast()

		-- Only store diffs for actual broadcasts
		if not IsValid(ply) and not fullupdate then
			nettable.sentData = table.Copy(nettable.data)

			CallHook(name, changed, removed)
		end
	end

	function UpdatePlayer(ply, initialSpawn)
		for k, v in pairs(nettables) do
			if initialSpawn and v.transmitMode == TRANSMIT_MANUAL then continue end

			Broadcast(k, ply, initialSpawn)
		end
	end

	hook.Add("Think", "NetTableAutoBroadcast", function()
		if nextBroadcast > CurTime() then return end
		nextBroadcast = CurTime() + broadcastinterval

		for k, v in pairs(nettables) do
			if v.transmitMode != TRANSMIT_AUTO then continue end
			if v.lastTransmit and v.lastTransmit + v.updateRate >= CurTime() then continue end

			v.lastTransmit = CurTime()
			Broadcast(k)
		end
	end )

	hook.Add("PlayerInitialSpawn", "NetTableInitialSpawn", function(ply)
		UpdatePlayer(ply, true)
	end )
end

if CLIENT then
	net.Receive("nettable_msg", function()
		local name = net.ReadString()
		local fullupdate= net.ReadBool()

		local changed, removed = {}, {}
		changed = readTableHomogenous()

		if not fullupdate then
			removed = readTableHomogenous(true)
		end

		if not nettables[name] then
			Create(name)
		end

		if fullupdate then
			nettables[name].data = changed
		else
			table.Merge(nettables[name].data, changed)
			tableRemoveKeys(nettables[name].data, removed)
		end

		CallHook(name, changed, removed)
	end )

end