include( "util.lua" )
include( "base.lua" )
include( "outwindow.lua" )
include( "rangedecoder.lua" )
include( "tests.lua" )

local Base = LZMABase
local BitLShift = BitLShift
local BitRShift = BitRShift
local BitAnd = bit.band
local BitOr = bit.bor

-------------------
--LenDecoder
-------------------

local meta = {}
meta.__index = meta

local function LenDecoderFast( numPosStates )

	local choice = BitDecoderFast()
	local choice2 = BitDecoderFast()
	local lowcoder = {}
	local midcoder = {}
	local highcoder = RangeCoder.BitTreeDecoder( Base.kNumHighLenBits ):Init()

	for i = 0, numPosStates - 1 do
		lowcoder[i] = RangeCoder.BitTreeDecoder( Base.kNumLowLenBits ):Init()
		midcoder[i] = RangeCoder.BitTreeDecoder( Base.kNumMidLenBits ):Init()
	end

	return function( rangeDecoder, posState )

		if choice( rangeDecoder ) == 0 then

			return lowcoder[ posState ]:Decode( rangeDecoder )

		else

			local symbol = 8
			if choice2( rangeDecoder ) == 0 then

				symbol = symbol + midcoder[ posState ]:Decode( rangeDecoder )

			else

				symbol = symbol + 8
				symbol = symbol + highcoder:Decode( rangeDecoder )

			end
			return symbol

		end

	end

end

local function LenDecoder()

	return setmetatable({
		m_Choice = RangeCoder.BitDecoder(),
		m_Choice2 = RangeCoder.BitDecoder(),
		m_LowCoder = {},
		m_MidCoder = {},
		m_HighCoder = RangeCoder.BitTreeDecoder( Base.kNumHighLenBits ),
		m_NumPosStates = 0,
	}, meta)

end

function meta:Create( numPosStates )

	for i = self.m_NumPosStates, numPosStates - 1 do

		self.m_LowCoder[i] = RangeCoder.BitTreeDecoder( Base.kNumLowLenBits )
		self.m_MidCoder[i] = RangeCoder.BitTreeDecoder( Base.kNumMidLenBits )

	end
	self.m_NumPosStates = numPosStates

end

function meta:Init()

	self.m_Choice:Init()

	for i = 0, self.m_NumPosStates - 1 do

		self.m_LowCoder[i]:Init()
		self.m_MidCoder[i]:Init()

	end

	self.m_Choice2:Init()
	self.m_HighCoder:Init()

end

function meta:Decode( rangeDecoder, posState )


	if self.m_Choice:Decode( rangeDecoder ) == 0 then

		return self.m_LowCoder[ posState ]:Decode( rangeDecoder )

	else

		local symbol = 8
		if self.m_Choice2:Decode( rangeDecoder ) == 0 then

			symbol = symbol + self.m_MidCoder[ posState ]:Decode( rangeDecoder )

		else

			symbol = symbol + 8
			symbol = symbol + self.m_HighCoder:Decode( rangeDecoder )

		end
		return symbol

	end

end

-------------------
--Decoder2
-------------------

local meta = {}
meta.__index = meta

local function Decoder2()

	return setmetatable({
		m_Decoders = {}
	}, meta)

end

function meta:Create()

	for i=1, 0x300 do

		self.m_Decoders[i-1] = BitDecoderFast() --RangeCoder.BitDecoder()

	end

end

function meta:Init()

	for i=1, 0x300 do

		self.m_Decoders[i-1] = BitDecoderFast() --:Init()

	end

end

function meta:DecodeNormal( rangeDecoder )

	local symbol = 1
	repeat
		symbol = BitOr( symbol + symbol, self.m_Decoders[ symbol ]( rangeDecoder ) )
	until symbol >= 0x100
	return BitAnd( symbol, 0xFF )

end

function meta:DecodeWithMatchByte( rangeDecoder, matchByte )

	local symbol = 1
	repeat
		local matchBit = BitRShift( matchByte, 7 ) % 2
		matchByte = matchByte * 2
		local b = self.m_Decoders[ 0x100 * (1 + matchBit) + symbol ]( rangeDecoder )
		symbol = BitOr( symbol + symbol, b )
		if matchBit ~= b then

			while symbol < 0x100 do

				symbol = BitOr( symbol + symbol, self.m_Decoders[ symbol ]( rangeDecoder ) )

			end
			break

		end
	until symbol >= 0x100
	return BitAnd( symbol, 0xFF )

end

-------------------
--LiteralDecoder
-------------------

local meta = {}
meta.__index = meta

local function LiteralDecoder()

	return setmetatable({
		m_Coders = nil,
		m_NumPrevBits = 0,
		m_NumPosBits = 0,
		m_PosMask = 0,
	}, meta)

end

function meta:Create( numPosBits, numPrevBits )

	self.m_NumPosBits = numPosBits
	self.m_PosMask = BitLShift( 1, numPosBits ) - 1
	self.m_NumPrevBits = numPrevBits
	local numStates = BitLShift( 1, self.m_NumPrevBits + self.m_NumPosBits )
	self.m_Coders = {}

	for i=1, numStates do

		self.m_Coders[i-1] = Decoder2()
		self.m_Coders[i-1]:Create()

	end

end

function meta:Init()

	local numStates = BitLShift( 1, self.m_NumPrevBits + self.m_NumPosBits )

	for i=1, numStates do

		self.m_Coders[i-1]:Init()

	end

end

function meta:GetState( pos, prevByte )

	return BitLShift( BitAnd( pos, self.m_PosMask ), self.m_NumPrevBits ) + BitRShift( prevByte, ( 8 - self.m_NumPrevBits ) )

end

function meta:DecodeNormal( rangeDecoder, pos, prevByte )

	return self.m_Coders[ self:GetState( pos, prevByte ) ]:DecodeNormal( rangeDecoder )

end

function meta:DecodeWithMatchByte( rangeDecoder, pos, prevByte, matchByte )

	return self.m_Coders[ self:GetState( pos, prevByte ) ]:DecodeWithMatchByte( rangeDecoder, matchByte )

end

-------------------
--Decoder
-------------------

local meta = {}
meta.__index = meta

local function Decoder()

	local tab = setmetatable({
		m_OutWindow = LZ.OutWindow(),
		m_RangeDecoder = RangeCoder.Decoder(),

		m_IsMatchDecoders = {},
		m_IsRepDecoders = {},
		m_IsRepG0Decoders = {},
		m_IsRepG1Decoders = {},
		m_IsRepG2Decoders = {},
		m_IsRep0LongDecoders = {},

		m_PosSlotDecoder = {},
		m_PosDecoders = {},

		m_PosAlignDecoder = RangeCoder.BitTreeDecoder( Base.kNumAlignBits ),

		m_LiteralDecoder = LiteralDecoder(),

		m_DictionarySize = 0xFFFFFFFF,
		m_DictionarySizeCheck = 0,

		m_PosStateMask = 0,
	}, meta)

	for i=0, Base.kNumLenToPosStates do
		tab.m_PosSlotDecoder[i] = RangeCoder.BitTreeDecoder( Base.kNumPosSlotBits )
	end

	for i=0, Base.kNumFullDistances - Base.kEndPosModelIndex do
		tab.m_PosDecoders[i] = RangeCoder.BitDecoder()
	end

	for i=0, bit.lshift( Base.kNumStates, Base.kNumPosStatesBitsMax )-1 do

		tab.m_IsMatchDecoders[ i ] = RangeCoder.BitDecoder()
		tab.m_IsRep0LongDecoders[ i ] = RangeCoder.BitDecoder()

	end

	for i=0, Base.kNumStates-1 do

		tab.m_IsRepDecoders[i] = RangeCoder.BitDecoder()
		tab.m_IsRepG0Decoders[i] = RangeCoder.BitDecoder()
		tab.m_IsRepG1Decoders[i] = RangeCoder.BitDecoder()
		tab.m_IsRepG2Decoders[i] = RangeCoder.BitDecoder()

	end

	return tab

end

-- OK
function meta:SetDictionarySize( dictionarySize )

	if self.m_DictionarySize ~= dictionarySize then

		self.m_DictionarySize = dictionarySize
		self.m_DictionarySizeCheck = math.max( dictionarySize, 1 )

		local blockSize = math.max( self.m_DictionarySizeCheck, 2^12 )
		self.m_OutWindow:Create( blockSize )

	end

end

function meta:SetLiteralProperties( lp, lc )

	if lp > 8 then error("Invalid param for 'lp'") end
	if lc > 8 then error("Invalid param for 'lc'") end
	self.m_LiteralDecoder:Create( lp, lc )

end

function meta:SetPosBitsProperties( pb )

	if pb > Base.kNumPosStatesBitsMax then
		error("Invalid param for 'pb'")
	end

	local numPosStates = bit.lshift( 1, pb )
	self.m_LenDecoder = LenDecoderFast( numPosStates ) --:Create( numPosStates )
	self.m_RepLenDecoder = LenDecoderFast( numPosStates ) --:Create( numPosStates )
	self.m_PosStateMask = numPosStates - 1

end

function meta:Init( inStream, outStream )

	self.m_RangeDecoder:Init( inStream )
	self.m_OutWindow:Init( outStream )

	for i=0, Base.kNumStates-1 do

		for j=0, self.m_PosStateMask do

			local index = BitLShift( i, Base.kNumPosStatesBitsMax ) + j
			self.m_IsMatchDecoders[ index ]:Init()
			self.m_IsRep0LongDecoders[ index ]:Init()

		end

		self.m_IsRepDecoders[i]:Init()
		self.m_IsRepG0Decoders[i]:Init()
		self.m_IsRepG1Decoders[i]:Init()
		self.m_IsRepG2Decoders[i]:Init()

	end

	self.m_LiteralDecoder:Init()
	for i=0, Base.kNumLenToPosStates-1 do
		self.m_PosSlotDecoder[i]:Init()
	end

	for i=0, Base.kNumFullDistances - Base.kEndPosModelIndex-1 do
		self.m_PosDecoders[i]:Init()
	end

	self.m_PosAlignDecoder:Init()

end

function meta:Code( inStream, outStream, inSize, outSize, progress )

	self:Init( inStream, outStream )

	local index = 0
	local rep0, rep1, rep2, rep3 = 0,0,0,0

	--not actually uint64, but doubles should be good enough
	local nowPos64 = 0

	if nowPos64 < outSize then

		if self.m_IsMatchDecoders[ BitLShift( index, Base.kNumPosStatesBitsMax ) ]:Decode( self.m_RangeDecoder ) ~= 0 then
			error("Data error")
		end

		if index < 4 then index = 0 elseif index < 10 then index = index - 3 else index = index - 6 end
		self.m_OutWindow:PutByte( self.m_LiteralDecoder:DecodeNormal( self.m_RangeDecoder, 0, 0 ) )
		nowPos64 = nowPos64 + 1

	end
	while nowPos64 < outSize do

		if self.stop == true then break end

		task.YieldPer(4000, "progress", nowPos64, outSize)

		local posState = BitAnd( nowPos64, self.m_PosStateMask )
		local res = self.m_IsMatchDecoders[ BitLShift( index, Base.kNumPosStatesBitsMax ) + posState ]:Decode( self.m_RangeDecoder )

		if res == 0 then

			if index >= 7 then
				self.m_OutWindow:PutByte( self.m_LiteralDecoder:DecodeWithMatchByte( self.m_RangeDecoder, nowPos64, self.m_OutWindow:GetByte(0), self.m_OutWindow:GetByte( rep0 ) ) )
			else
				self.m_OutWindow:PutByte( self.m_LiteralDecoder:DecodeNormal( self.m_RangeDecoder, nowPos64, self.m_OutWindow:GetByte(0) ) )
			end
			if index < 4 then index = 0 elseif index < 10 then index = index - 3 else index = index - 6 end
			nowPos64 = nowPos64 + 1

		else

			local len = 0
			if self.m_IsRepDecoders[ index ]:Decode( self.m_RangeDecoder ) == 1 then

				if self.m_IsRepG0Decoders[ index ]:Decode( self.m_RangeDecoder ) == 0 then

					if self.m_IsRep0LongDecoders[ index * 2^Base.kNumPosStatesBitsMax + posState ]:Decode( self.m_RangeDecoder ) == 0 then

						index = index < 7 and 9 or 11
						self.m_OutWindow:PutByte( self.m_OutWindow:GetByte( rep0 ) )
						nowPos64 = nowPos64 + 1
						continue

					end

				else

					local distance = 0
					if self.m_IsRepG1Decoders[ index ]:Decode( self.m_RangeDecoder ) == 0 then

						distance = rep1

					else

						if self.m_IsRepG2Decoders[ index ]:Decode( self.m_RangeDecoder ) == 0 then

							distance = rep2

						else

							distance = rep3
							rep3 = rep2

						end

						rep2 = rep1

					end

					rep1 = rep0
					rep0 = distance

				end

				len = self.m_RepLenDecoder( self.m_RangeDecoder, posState ) + Base.kMatchMinLen
				index = index < 7 and 8 or 11

			else

				rep3 = rep2
				rep2 = rep1
				rep1 = rep0
				len = Base.kMatchMinLen + self.m_LenDecoder( self.m_RangeDecoder, posState )
				index = index < 7 and 7 or 10
				local posSlot = self.m_PosSlotDecoder[ Base.GetLenToPosState( len ) ]:Decode( self.m_RangeDecoder )
				if posSlot >= Base.kStartPosModelIndex then

					local numDirectBits = BitRShift( posSlot, 1 ) - 1
					rep0 = BitLShift( BitOr( 2, BitAnd( posSlot, 1 ) ), numDirectBits )
					if posSlot < Base.kEndPosModelIndex then

						rep0 = rep0 + ReverseDecodeModels( self.m_PosDecoders, rep0 - posSlot - 1, self.m_RangeDecoder, numDirectBits )

					else

						rep0 = rep0 + BitLShift( self.m_RangeDecoder:DecodeDirectBits( numDirectBits - Base.kNumAlignBits ), Base.kNumAlignBits )
						rep0 = rep0 + self.m_PosAlignDecoder:ReverseDecode( self.m_RangeDecoder )

					end

				else

					rep0 = posSlot

				end

			end

			self.m_OutWindow:CopyBlock( rep0, len )
			nowPos64 = nowPos64 + len

		end

	end

	self.m_OutWindow:Flush()
	self.m_OutWindow:ReleaseStream()
	self.m_RangeDecoder:ReleaseStream()

end

function meta:SetDecoderProperties( props )

	if props.Length < 5 then error("Invalid property set") end

	local lc = props[0] % 9
	local remainder = math.floor( props[0] / 9 )
	local lp = remainder % 5
	local pb = math.floor( remainder / 5 )
	if pb > Base.kNumPosStatesBitsMax then error("Invalid 'pb' in property set") end

	print(props[0], lp, lc, pb)
	print(props[1], props[2], props[3], props[4])

	local dictionarySize = 0
	for i=1, 4 do

		dictionarySize = dictionarySize + bit.lshift( props[i], (i-1) * 8 )

	end

	self:SetDictionarySize( dictionarySize )
	self:SetLiteralProperties( lp, lc )
	self:SetPosBitsProperties( pb )
	return self

end

LZMADecoder = Decoder