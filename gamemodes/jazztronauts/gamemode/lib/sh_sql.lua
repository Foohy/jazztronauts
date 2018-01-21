module( 'jsql', package.seeall )

/*

*/
Tables = Tables or {}

function Register(tblName, columns)
    Tables[tblName] = columns
end

function Reset(tbl)
    if tbl then 
        sql.Query(string.format("DROP TABLE IF EXISTS %s", tbl))
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
        Msg(string.format("Creating '%s' table...\n", tblName))
        print(string.format("CREATE TABLE %s (%s)", tblName, tbl))
        if sql.Query(string.format("CREATE TABLE %s (%s)", tblName, tbl)) == false then
            print("TABLE CREATION FAILED:")
            print(sql.LastError())
        end
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
        local res = sql.Query(cmd)

        if res == false then 
            print("QUERY FAILED: ")
            print(cmd)
            print(sql.LastError())
        end

		return res
	end
end