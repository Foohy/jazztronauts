module( "newgame", package.seeall )

function MarkPersistent(tableName)
	PersistentTables = PersistentTables or {}
	PersistentTables[tableName] = tableName
end

function GetPersistent()
	return PersistentTables or {}
end
