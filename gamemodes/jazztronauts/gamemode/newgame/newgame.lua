
module( "newgame", package.seeall )

local nettbl = "jazz_newgame_info"

if SERVER then

    local ngsql = include("sql.lua")

    -- Network reset information once
    local tbl = nettable.Create(nettbl, nettable.TRANSMIT_ONCE)
    tbl["resets"] = ngsql.GetResetCount()

    -- Reset the game, incrementing the reset counter and restarting from scratch
    -- Automatically reloads the tutorial map
    function ResetGame()

        -- Mark every player that participated in this session
        -- #TODO: needed?

        -- Store this as a end-game reset
        local totalPlayers = progress.GetTotalPlayers()
        ngsql.AddResetInfo(0, totalPlayers)

        -- Reset non-persistent sql stuff
        jsql.ResetExcept(GetPersistent())

        -- Changelevel to intro again
        mapcontrol.Launch("jazz_intro")
    end
   
    -- Return information about every single reset
    function GetResets()
        return ngsql.GetResets()
    end

end

-- How many times the game has been finished and restarted
function GetResetCount()
    return (nettable.Get(nettbl) or {}).resets or 0
end

function GetMultiplier()
    return GetResetCount() + 1
end