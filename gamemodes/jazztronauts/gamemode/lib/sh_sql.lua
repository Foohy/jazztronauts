module( 'jsql', package.seeall )

/*

*/
Tables = Tables or {}

function Register(tblName, columns)
    Tables[tblName] = columns
end

function Reset(tbl)
    if tbl then 
        sql.Query(string.format("DROP TABLE IF EXISTS ", tbl))
    else 
        for k, _ in pairs(Tables) do
            Reset(k)
        end
    end
end

local function ensureTable(tblName)
    local tbl = Tables[tblName]
    if not tbl then print("Invalid SQL table: ", tblName) end

    if not sql.TableExists(tblName) then
        Msg("Creating '%s' table...\n", tblName)
        sql.Query(string.format("CREATE TABLE %s (%s)", tblName, v)) 
    end
end

local function ensureTables()
    for k, v in pairs(Tables) do
        ensureTable(k)
    end
end

function Query(tblName, cmd)
    if cmd == nil then
        cmd = tblName
        ensureTables()
    else
	    ensureTable(tblName)
    end

	if cmd then 
		return sql.Query(cmd)
	end
end