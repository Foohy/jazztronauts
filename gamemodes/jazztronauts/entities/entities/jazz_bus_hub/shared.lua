ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "The Bus - Hub"
ENT.Author			= ""
ENT.Information	= ""
ENT.Category		= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.Model			= Model( "models/matt/jazz_trolley.mdl" )


function ENT:SetupDataTables()
	self:NetworkVar("String",	0, "Destination")
	self:NetworkVar("String",	1, "WorkshopID")
	self:NetworkVar("Int",		0, "MapProgress")
end

function ENT:ToProgressMask(mapname)
	local col, total = progress.GetMapShardCount(mapname)
	if not total or total == 0 then return 0 end

	return bit.bor(bit.lshift(total, 16), col)
end

function ENT:FromProgressMask(val)
	local mask = bit.lshift(1, 16) - 1
	return bit.band(val, mask),
		bit.band(bit.rshift(val, 16), mask)
end

function ENT:SetMap(mapname, workshopID)
	self:SetDestination(mapname)
	self:SetWorkshopID(workshopID)
	self:SetMapProgress(self:ToProgressMask(mapname))
end