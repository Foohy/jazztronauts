if SERVER then 
	util.AddNetworkString( "unlock_msg" )
	AddCSLuaFile("sh_unlocks.lua")
end

module( "unlocks", package.seeall )

local unlock_lists = {}

function Register( list_name )

	if unlock_lists[list_name] then return end

	if CLIENT then 

		unlock_lists[list_name] = {}

	else

		local table_name = "unlocklist_" .. list_name
		local columns = "steamid bigint(64) DEFAULT '0', strkey varchar(32)"

		sql.Query( "DROP TABLE " .. table_name )

		print("REGISTER UNLOCK: " .. table_name)
		if not sql.TableExists( table_name ) then
			print("CREATE SQL")
			
			--deal with it
			if false == sql.Query( ("CREATE TABLE %s (%s)"):format(table_name, columns) ) then
				print("ERROR: " .. tostring( sql.LastError() ) )
			end
		end

		unlock_lists[list_name] = table_name

	end

end

function IsUnlocked( list_name, ply, key )

	if CLIENT then

	else
		if not unlock_lists[list_name] then return false end
		local steam_id = ply:SteamID64()
		local result = sql.Query( ("SELECT * FROM %s WHERE steamid = '%s' AND strkey = '%s'"):format( 
			unlock_lists[list_name],
			steam_id,
			key ) )

		if false == result then
			print("ERROR: " .. tostring( sql.LastError() ) )
			return false
		end

		return result ~= nil
	end

	return false

end

function Unlock( list_name, ply, key )

	if not unlock_lists[list_name] or CLIENT then return false end
	if IsUnlocked( list_name, ply, key ) then return false end

	local steam_id = ply:SteamID64()
	local result = sql.Query( ("INSERT INTO %s VALUES ('%s','%s')"):format( 
		unlock_lists[list_name],
		steam_id,
		key ) )

end

function GetAll( list_name, ply )

	local steam_id = ply:SteamID64()
	local result = sql.Query( ("SELECT * FROM %s WHERE steamid = '%s'"):format( 
		unlock_lists[list_name],
		steam_id ) )

	if false == result then
		print("ERROR: " .. tostring( sql.LastError() ) )
		return false
	end

	local t = {}
	for k,v in pairs( result or {} ) do
		table.insert(t, v.strkey)
	end

	return t

end