AddCSLuaFile()

module( "iograph", package.seeall )

--[[

graph is made of nodes, each node is an entity.

a node contains:
- an index which corresponds to the entity in the map.
- the position of the entity
- the name of the entity
- inputs and outputs

each input:
- points to the originator of the event
- contains the parameters

each output:
- points to target of the event
- contains parameters

]]

local meta = {}
meta.__index = meta

function meta:Init( mapData )

	self.ents = mapData.entities
	self.entsByID = {}
	self.nodes = {}

	local indices = {}
	for k,v in ipairs(self.ents) do
		indices[v] = k
	end

	for _, ent in ipairs(self.ents) do
		local node = ionode.New( ent, indices )
		self.nodes[#self.nodes+1] = node
		self.entsByID[node:GetIndex()] = node
	end

	self:Link()

	return self

end

function meta:Link()

	for ent in self:Ents() do

		local name = ent:GetName()
		local rawOutputs = ent:GetMapEntityOutputs()
		for _, output in ipairs(rawOutputs) do

			for target in self:EntsByName(output.target) do

				local eventData = {
					from = ent,
					to = target,
					event = output.event,
					func = output.func,
					param = output.param,
					delay = output.delay,
					refire = output.refire,
				}

				ent.outputs[#ent.outputs+1] = eventData
				target.inputs[#ent.outputs+1] = eventData

			end

		end

	end

end

function meta:GetByIndex( index )

	return self.entsByID[index]

end

function meta:Ents()

	local i = 1
	return function()
		local n = self.nodes[i]
		i = i + 1
		return n
	end

end

function meta:EntsByClass( classname )

	local i = 1
	return function()
		local n = self.nodes[i]
		while n and n:GetClass() ~= classname do 
			i = i + 1
			n = self.nodes[i]
		end
		i = i + 1
		return n
	end

end

function meta:EntsByName( name )

	local i = 1
	return function()
		local n = self.nodes[i]
		while n and not n:MatchesName( name ) do 
			i = i + 1
			n = self.nodes[i]
		end
		i = i + 1
		return n
	end

end

function New(mapData)

	if mapData == nil then
		mapData = bsp2.GetCurrent()
	end

	if mapData == nil then return nil end
	return setmetatable({}, meta):Init(mapData)

end

if CLIENT then

	local graph = New()

end