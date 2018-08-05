-------------------
--RangeCoder.Decoder
-------------------

local meta = {}
meta.__index = meta

local BitLShift = BitLShift
local BitRShift = BitRShift
local BitAnd = bit.band
local BitOr = bit.bor
local RShift = bit.rshift

function meta:Init( inStream )

	self.m_Stream = inStream
	self.m_Code = 0
	self.m_Range = 0xFFFFFFFF

	for i=0, 4 do

		self.m_Code = self.m_Code * 0x100 + inStream:ReadByte()

	end

	return self

end

function meta:ReleaseStream() end --nothing to do

function meta:CloseStream()

	self.m_Stream:Close()

end

function meta:Normalize()

	while self.m_Range < 0x1000000 do

		self.m_Code = self.m_Code * 0x100 + self.m_Stream:ReadByte()
		self.m_Range = self.m_Range * 0x100

	end

end

function meta:Decode( start, size, total )

	self.m_Code = self.m_Code - start * self.m_Range
	self.m_Range = self.m_Range * size
	self:Normalize()

end

function meta:DecodeDirectBits( numTotalBits )

	local range = self.m_Range
	local code = self.m_Code
	local result = 0

	while numTotalBits > 0 do

		range = BitRShift( range, 1 )

		local t = 1 - RShift( code - range, 31 )

		code = code - range * t
		result = result*2 + t

		if range < 0x1000000 then

			code = code * 0x100 + self.m_Stream:ReadByte()
			range = range * 0x100

		end

		numTotalBits = numTotalBits - 1

	end

	self.m_Range = range
	self.m_Code = code
	return result

end

function meta:DecodeBit( size0, numTotalBits )

	local newBound = BitRShift( self.m_Range, numTotalBits ) * size0
	local symbol = 0

	if self.m_Code < newBound then
		self.m_Range = newBound
	else
		symbol = 1
		self.m_Code = self.m_Code - newBound
		self.m_Range = self.m_Range - newBound
	end

	self:Normalize()
	return symbol

end

local function Decoder()

	return setmetatable({
		m_Range = 0,
		m_Code = 0,
	}, meta)

end

-------------------
--BitDecoder
-------------------

local meta = {}
meta.__index = meta

local kNumBitModelTotalBits = 11
local kBitModelTotal = BitLShift( 1, kNumBitModelTotalBits )
local kNumMoveBits = 5

function BitDecoderFast()

	local prob = BitRShift( 0x800, 1 )
	return function( rangeDecoder )

		local newBound = RShift( rangeDecoder.m_Range, 11 ) * prob

		if rangeDecoder.m_Code < newBound then

			rangeDecoder.m_Range = newBound
			prob = prob + RShift( 0x800 - prob, 5 )

			if rangeDecoder.m_Range < 0x1000000 then

				rangeDecoder.m_Code = rangeDecoder.m_Code * 0x100 + rangeDecoder.m_Stream:ReadByte()
				rangeDecoder.m_Range = rangeDecoder.m_Range * 0x100

			end
			return 0

		else

			rangeDecoder.m_Range = rangeDecoder.m_Range - newBound
			rangeDecoder.m_Code = rangeDecoder.m_Code - newBound
			prob = prob - RShift( prob, 5 )

			if rangeDecoder.m_Range < 0x1000000 then

				rangeDecoder.m_Code = rangeDecoder.m_Code * 0x100 + rangeDecoder.m_Stream:ReadByte()
				rangeDecoder.m_Range = rangeDecoder.m_Range * 0x100

			end
			return 1

		end

	end

end

function meta:Init()

	self.m_Prob = BitRShift( kBitModelTotal, 1 )
	return self

end

--[[function meta:UpdateModel( numMoveBits, symbol )

	if symbol == 0 then

		self.m_Prob = self.m_Prob + bit.rshift( kBitModelTotal - self.m_Prob, numMoveBits )

	else

		self.m_Prob = self.m_Prob - bit.rshift( self.m_Prob, numMoveBits )

	end

end]]

function meta:Decode( rangeDecoder )

	local newBound = RShift( rangeDecoder.m_Range, kNumBitModelTotalBits ) * self.m_Prob

	if rangeDecoder.m_Code < newBound then

		rangeDecoder.m_Range = newBound
		self.m_Prob = self.m_Prob + RShift( kBitModelTotal - self.m_Prob, kNumMoveBits )

		if rangeDecoder.m_Range < 0x1000000 then

			rangeDecoder.m_Code = rangeDecoder.m_Code * 0x100 + rangeDecoder.m_Stream:ReadByte()
			rangeDecoder.m_Range = rangeDecoder.m_Range * 0x100

		end
		return 0

	else

		rangeDecoder.m_Range = rangeDecoder.m_Range - newBound
		rangeDecoder.m_Code = rangeDecoder.m_Code - newBound
		self.m_Prob = self.m_Prob - RShift( self.m_Prob, kNumMoveBits )

		if rangeDecoder.m_Range < 0x1000000 then

			rangeDecoder.m_Code = rangeDecoder.m_Code * 0x100 + rangeDecoder.m_Stream:ReadByte()
			rangeDecoder.m_Range = rangeDecoder.m_Range * 0x100

		end
		return 1

	end

end

function BitDecoder()

	return setmetatable({
		m_Prob = 0
	}, meta)

end

-------------------
--BitTreeDecoder
-------------------

local meta = {}
meta.__index = meta

function meta:Init()

	for i=1, BitLShift( 1, self.m_NumBitLevels ) - 1 do

		local decoder = BitDecoder()
		decoder:Init()
		self.m_Models[i] = decoder

	end
	return self

end

function meta:Decode( rangeDecoder )

	local m = 1
	local bitIndex = self.m_NumBitLevels

	while bitIndex > 0 do

		m = (m * 2) + self.m_Models[m]:Decode( rangeDecoder )
		bitIndex = bitIndex - 1

	end

	return m - 2^self.m_NumBitLevels

end

function meta:ReverseDecode( rangeDecoder )

	local m = 1
	local bitIndex = 0
	local symbol = 0

	while bitIndex < self.m_NumBitLevels do

		local b = self.m_Models[m]:Decode( rangeDecoder )
		m = (m * 2) + b
		symbol = BitOr( symbol, BitLShift( b, bitIndex ) )

		bitIndex = bitIndex + 1

	end

	return symbol

end

function ReverseDecodeModels( models, startIndex, rangeDecoder, numBitLevels )

	local m = 1
	local bitIndex = 0
	local symbol = 0

	while bitIndex < numBitLevels do

		local b = models[startIndex + m]:Decode( rangeDecoder )
		m = (m * 2) + b
		symbol = BitOr( symbol, BitLShift( b, bitIndex ) )

		bitIndex = bitIndex + 1

	end

	return symbol

end

local function BitTreeDecoder( numBitLevels )

	return setmetatable({
		m_NumBitLevels = numBitLevels,
		m_Models = {},
	}, meta)

end

RangeCoder = {
	Decoder = Decoder,
	BitDecoder = BitDecoder,
	BitTreeDecoder = BitTreeDecoder
}