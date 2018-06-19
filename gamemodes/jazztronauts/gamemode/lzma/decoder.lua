include( "util.lua" )
include( "base.lua" )
include( "outwindow.lua" )
include( "rangedecoder.lua" )
include( "tests.lua" )

local Base = LZMABase

-------------------
--LenDecoder
-------------------

local meta = {}
meta.__index = meta

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

		local symbol = Base.kNumLowLenSymbols
		if self.m_Choice2:Decode( rangeDecoder ) == 0 then

			symbol = symbol + self.m_MidCoder[ posState ]:Decode( rangeDecoder )

		else

			symbol = symbol + Base.kNumMidLenSymbols
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

		self.m_Decoders[i-1] = RangeCoder.BitDecoder()

	end

end

function meta:Init()

	for i=1, 0x300 do

		self.m_Decoders[i-1]:Init()

	end

end

function meta:DecodeNormal( rangeDecoder )

	local symbol = 1
	repeat
		symbol = bit.bor( symbol * 2, self.m_Decoders[ symbol ]:Decode( rangeDecoder ) )
	until symbol >= 0x100
	return bit.band( symbol, 0xFF )

end

function meta:DecodeWithMatchByte( rangeDecoder, matchByte )

	local symbol = 1
	repeat
		local matchBit = bit.rshift( matchByte, 7 ) % 2
		matchByte = matchByte * 2
		local b = self.m_Decoders[ 0x100 * (1 + matchBit) + symbol ]:Decode( rangeDecoder )
		symbol = bit.bor( symbol * 2, b )
		if matchBit ~= b then

			while symbol < 0x100 do

				symbol = bit.bor( symbol * 2, self.m_Decoders[ symbol ]:Decode( rangeDecoder ) )

			end
			break

		end
	until symbol >= 0x100
	return bit.band( symbol, 0xFF )

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
	self.m_PosMask = bit.lshift( 1, numPosBits ) - 1
	self.m_NumPrevBits = numPrevBits
	local numStates = bit.lshift( 1, self.m_NumPrevBits + self.m_NumPosBits )
	self.m_Coders = {}

	for i=1, numStates do

		self.m_Coders[i-1] = Decoder2()
		self.m_Coders[i-1]:Create()

	end

end

function meta:Init()

	local numStates = bit.lshift( 1, self.m_NumPrevBits + self.m_NumPosBits )

	for i=1, numStates do

		self.m_Coders[i-1]:Init()

	end

end

function meta:GetState( pos, prevByte )

	return BitLShift( bit.band( pos, self.m_PosMask ), self.m_NumPrevBits ) + BitRShift( prevByte, ( 8 - self.m_NumPrevBits ) )

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

		m_LenDecoder = LenDecoder(),
		m_RepLenDecoder = LenDecoder(),
		
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

		local blockSize = math.max( self.m_DictionarySizeCheck, bit.lshift( 1, 12 ) )
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
	self.m_LenDecoder:Create( numPosStates )
	self.m_RepLenDecoder:Create( numPosStates )
	self.m_PosStateMask = numPosStates - 1

end

function meta:Init( inStream, outStream )

	self.m_RangeDecoder:Init( inStream )
	self.m_OutWindow:Init( outStream )

	for i=0, Base.kNumStates-1 do

		for j=0, self.m_PosStateMask do

			local index = bit.lshift( i, Base.kNumPosStatesBitsMax ) + j
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

	self.m_LenDecoder:Init()
	self.m_RepLenDecoder:Init()
	self.m_PosAlignDecoder:Init()

end

function meta:Code( inStream, outStream, inSize, outSize, progress )

	self:Init( inStream, outStream )

	local statebitmax_shift = 2^Base.kNumPosStatesBitsMax
	local state = Base.State()
	local rep0, rep1, rep2, rep3 = 0,0,0,0

	--not actually uint64, but doubles should be good enough
	local nowPos64 = 0
	local outSize64 = outSize
	local outWindow = self.m_OutWindow
	local rangeDecoder = self.m_RangeDecoder

	if nowPos64 < outSize64 then

		if self.m_IsMatchDecoders[ BitLShift( state.Index, Base.kNumPosStatesBitsMax ) ]:Decode( rangeDecoder ) ~= 0 then
			error("Data error")
		end

		state:UpdateChar()
		local b = self.m_LiteralDecoder:DecodeNormal( rangeDecoder, 0, 0 )

		outWindow:PutByte( b )
		nowPos64 = nowPos64 + 1

	end
	while nowPos64 < outSize64 do

		if self.stop == true then break end

		task.YieldPer(4000, "progress", nowPos64, outSize64)

		local posState = BitAnd( nowPos64, self.m_PosStateMask )
		local matchIndex = (BitLShift( state.Index, Base.kNumPosStatesBitsMax ) + posState)
		local res = self.m_IsMatchDecoders[ matchIndex ]:Decode( rangeDecoder )

		if res == 0 then

			local b = 0
			if not state:IsCharState() then
				b = self.m_LiteralDecoder:DecodeWithMatchByte( rangeDecoder, nowPos64, outWindow:GetByte(0), outWindow:GetByte( rep0 ) )
			else
				b = self.m_LiteralDecoder:DecodeNormal( rangeDecoder, nowPos64, outWindow:GetByte(0) )
			end
			outWindow:PutByte( b )
			state:UpdateChar()
			nowPos64 = nowPos64 + 1

		else

			local len = 0
			if self.m_IsRepDecoders[ state.Index ]:Decode( rangeDecoder ) == 1 then

				if self.m_IsRepG0Decoders[ state.Index ]:Decode( rangeDecoder ) == 0 then

					if self.m_IsRep0LongDecoders[ state.Index * statebitmax_shift + posState ]:Decode( rangeDecoder ) == 0 then

						state:UpdateShortRep()
						outWindow:PutByte( outWindow:GetByte( rep0 ) )
						nowPos64 = nowPos64 + 1
						continue

					end

				else

					local distance = 0
					if self.m_IsRepG1Decoders[ state.Index ]:Decode( rangeDecoder ) == 0 then

						distance = rep1

					else

						if self.m_IsRepG2Decoders[ state.Index ]:Decode( rangeDecoder ) == 0 then

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

				len = self.m_RepLenDecoder:Decode( rangeDecoder, posState ) + Base.kMatchMinLen
				state:UpdateRep()

			else

				rep3 = rep2
				rep2 = rep1
				rep1 = rep0
				len = Base.kMatchMinLen + self.m_LenDecoder:Decode( rangeDecoder, posState )
				state:UpdateMatch()
				local posSlot = self.m_PosSlotDecoder[ Base.GetLenToPosState( len ) ]:Decode( rangeDecoder )
				if posSlot >= Base.kStartPosModelIndex then

					local numDirectBits = BitRShift( posSlot, 1 ) - 1
					rep0 = BitLShift( bit.bor( 2, bit.band( posSlot, 1 ) ), numDirectBits )
					if posSlot < Base.kEndPosModelIndex then

						rep0 = rep0 + ReverseDecodeModels( self.m_PosDecoders, rep0 - posSlot - 1, rangeDecoder, numDirectBits )

					else

						rep0 = rep0 + BitLShift( rangeDecoder:DecodeDirectBits( numDirectBits - Base.kNumAlignBits ), Base.kNumAlignBits )
						rep0 = rep0 + self.m_PosAlignDecoder:ReverseDecode( rangeDecoder )

					end

				else

					rep0 = posSlot

				end

			end

			if rep0 >= nowPos64 or rep0 >= self.m_DictionarySizeCheck then

				if rep0 == 0xFFFFFFFF then break end
				error("Data error on dictionary: " .. rep0)

			end

			outWindow:CopyBlock( rep0, len )
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