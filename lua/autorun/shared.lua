include( "lib/shared.lua")

if CLIENT then
    include( "snatch/cl_init.lua" )
    include( "store/cl_init.lua" )
end
if SERVER then
    AddCSLuaFile("snatch/cl_init.lua" )
    include( "snatch/init.lua" )

    AddCSLuaFile("store/init.lua" )
    include( "store/init.lua" )
end

print(engine.ActiveGamemode())