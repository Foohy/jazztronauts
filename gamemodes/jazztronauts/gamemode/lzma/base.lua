local meta = {}
meta.__index = meta

function meta:Init()

	self.Index = 0

end

function meta:UpdateChar()

	if self.Index < 4 then self.Index = 0
	elseif self.Index < 10 then self.Index = self.Index - 3
	else self.Index = self.Index - 6 end

end

function meta:UpdateMatch() self.Index = self.Index < 7 and 7 or 10 end
function meta:UpdateRep() self.Index = self.Index < 7 and 8 or 11 end
function meta:UpdateShortRep() self.Index = self.Index < 7 and 9 or 11 end
function meta:IsCharState() return self.Index < 7 end

local _ = {
	kNumRepDistances = 4,
	kNumStates = 12,

	State = function()
		return setmetatable({ Index = 0 }, meta)
	end,

	kNumPosSlotBits = 6,
	kDicLogSizeMin = 0,

	kNumLenToPosStatesBits = 2,
	kMatchMinLen = 2,
	kNumAlignBits = 4,
	kStartPosModelIndex = 4,
	kEndPosModelIndex = 14,

	kNumLitPosStatesBitsEncodingMax = 4,
	kNumLitContextBitsMax = 8,

	kNumPosStatesBitsMax = 4,
	kNumPosStatesBitsEncodingMax = 4,

	kNumLowLenBits = 3,
	kNumMidLenBits = 3,
	kNumHighLenBits = 8,
}

_.kNumLenToPosStates = bit.lshift( 1, _.kNumLenToPosStatesBits )

_.kAlignTableSize = bit.lshift( 1, _.kNumAlignBits )
_.kAlignMask = _.kAlignTableSize - 1

_.kNumPosModels = _.kEndPosModelIndex - _.kStartPosModelIndex
_.kNumFullDistances = bit.lshift( 1, math.floor( _.kEndPosModelIndex / 2 ) )

_.kNumPosStatesMax = bit.lshift( 1, _.kNumPosStatesBitsMax )
_.kNumPosStatesEncodingMax = bit.lshift( 1, _.kNumPosStatesBitsEncodingMax )

_.kNumLowLenSymbols = bit.lshift( 1, _.kNumLowLenBits )
_.kNumMidLenSymbols = bit.lshift( 1, _.kNumMidLenBits )
_.kNumLenSymbols = _.kNumLowLenSymbols + _.kNumMidLenSymbols + bit.lshift( 1, _.kNumHighLenBits )

_.kMatchMaxLen = _.kMatchMinLen + _.kNumLenSymbols - 1

_.GetLenToPosState = function( len )

	len = len - _.kMatchMinLen
	if len < _.kNumLenToPosStates then return len end
	return _.kNumLenToPosStates - 1

end

LZMABase = _
