local DT_CURRENCY = 0
-- local DT_ 			= 0


// ========== DTVARS ============
local meta = FindMetaTable( "Player" )
function meta:SetupDataTables()
	self:DTVar( "Int", DT_CURRENCY, "Notes" )
end


function meta:GetNotes()
	return self:GetDTInt( DT_CURRENCY )
end

function meta:SetNotes( num )
	self:SetDTInt( DT_CURRENCY, num )
	return num
end

function meta:AddNotes( num )
	self:SetNotes( self:GetNotes() + num )
	return self:GetNotes()
end
// ========== DTVARS ============
