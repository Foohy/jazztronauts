AddCSLuaFile()

module( "ionode", package.seeall )

local GMOD_ENT_INDEX_FIXUP = 1234

local meta = {}
meta.__index = meta

local function ParseOutput( str, event )

	if type( str ) ~= "string" then return end

	local args = { event }
	for w in string.gmatch(str .. ",","(.-),") do
		table.insert( args, w )
	end

	if args[2] == "" then return nil end

	return args
end

function GetOutputTableForEntity( ent )

	local outputs = {}
	for _,v in ipairs(ent.outputs or {}) do
		local output = {}
		local parsed = ParseOutput( v[2], v[1] )
		if parsed then
			output.event = parsed[1]  -- the event that causes this output (On*)
			output.target = parsed[2] -- the target to affect
			output.func = parsed[3]  -- the input to call on the target
			output.param = parsed[4]  -- parameter passed to target
			output.delay = parsed[5]  -- how long to wait
			output.refire = parsed[6] -- max times to refire
			outputs[#outputs+1] = output
		end
	end

	return outputs

end

function meta:Init( ent, indexTable )

	self.ent = ent
	self.name = ent.targetname
	self.classname = ent.classname
	self.pos = ent.origin
	self.index = indexTable[ent] + GMOD_ENT_INDEX_FIXUP
	self.outputs = {}
	self.inputs = {}
	return self

end

function meta:GetIndex() return self.index end
function meta:GetName() return self.name or "<" .. self:GetClass() .. ">" end
function meta:GetClass() return self.classname or "__unknown__" end
function meta:GetOutputs() return self.outputs end
function meta:GetInputs() return self.inputs end

function meta:MatchesName( name )

	if self.name == name then return true end
	if self.name and string.Right(name, 1) == "*" then
		return string.find( self.name, string.sub( name, 1, -1 ) ) == 1
	end
	return false

end

function meta:GetMapEntityRecord()

	return self.ent

end

function meta:GetMapEntityOutputs()

	return GetOutputTableForEntity( self:GetMapEntityRecord() )

end

function New(ent, indexTable)

	return setmetatable({}, meta):Init(ent, indexTable)

end
