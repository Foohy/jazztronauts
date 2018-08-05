AddCSLuaFile()

local meta = {}
meta.__index = meta

function meta:Init()
	self.first = 0
	self.last = 0
	self.buffer = {}

	return self
end

function meta:Enqueue(o)
	self.last = self.last + 1
	self.buffer[self.last] = o
end

function meta:Push(o)
	return self:Enqueue(o)
end

function meta:Dequeue()
	if self.first == self.last then return nil end

	self.first = self.first + 1
	local o = self.buffer[self.first]
	self.buffer[self.first] = nil

	return o
end

function meta:Pop()
	return self:Dequeue()
end

function Queue()
	return setmetatable({}, meta):Init()
end