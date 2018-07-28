include("sql.lua")
include("mapcontrol.lua")
include("mapgen.lua")
include("factgen/sh_facts.lua")

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "mapgen.lua" )
AddCSLuaFile( "mapcontrol.lua" )

-- Network total shard count once
local tbl = nettable.Create("jazz_shard_info", nettable.TRANSMIT_ONCE)
local collected, total = progress.GetMapShardCount()
tbl["collected"] = collected
tbl["total"] = total
tbl["corrupted_collected"] = progress.GetMapBlackShardCount()