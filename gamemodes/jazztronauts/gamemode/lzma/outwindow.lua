include("util.lua")

local meta = {}
meta.__index = meta

function meta:Create( windowSize )

	print("WINDOW SIZE: " .. windowSize )

	if self.m_WindowSize ~= windowSize then

		self.m_Buffer = ByteBuffer( windowSize )

	end
	self.m_WindowSize = windowSize
	self.m_Pos = 0
	self.m_StreamPos = 0

end

function meta:Init( outStream )

	self.m_Stream = outStream
	self.m_StreamPos = 0
	self.m_Pos = 0
	return self

end

function meta:ReleaseStream()

	self:Flush()

end

function meta:Flush()

	local size = self.m_Pos - self.m_StreamPos
	if size == 0 then return end

	local len = self.m_StreamPos + size - 1
	for i=self.m_StreamPos, len do

		task.YieldPer(10000, "writefile", i, len)
		self.m_Stream:WriteByte( self.m_Buffer[i] )

	end

	if self.m_Pos >= self.m_WindowSize then self.m_Pos = 0 end

	self.m_StreamPos = self.m_Pos

end

function meta:CopyBlock( distance, len )

	local pos = self.m_Pos - distance - 1
	if pos < 0 then pos = pos + self.m_WindowSize end

	while len > 0 do

		if pos >= self.m_WindowSize then pos = 0 end

		self.m_Buffer[ self.m_Pos ] = self.m_Buffer[ pos ]
		self.m_Pos = self.m_Pos + 1

		if self.m_Pos >= self.m_WindowSize then
			self:Flush()
		end

		pos = pos + 1
		len = len - 1

	end

end

function meta:PutByte( b )

	self.m_Buffer[ self.m_Pos ] = b
	self.m_Pos = self.m_Pos + 1

	if self.m_Pos >= self.m_WindowSize then
		self:Flush()
	end

end

function meta:GetByte( distance )

	local pos = self.m_Pos - distance - 1
	if pos < 0 then pos = pos + self.m_WindowSize end
	return self.m_Buffer[ pos ]

end

local function OutWindow()

	return setmetatable({
	}, meta)

end

LZ = { OutWindow = OutWindow }