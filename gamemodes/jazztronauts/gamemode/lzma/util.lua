function ByteBuffer( size, init )

	local t = { Length = size }
	if init then
		for i=1, size do task.YieldPer(10000) t[i] = init[i] or 0 end
	else
		for i=1, size do task.YieldPer(10000) t[i] = 0 end
	end
	return t

end

--PrintTable(r)

function BitLShift( v, x )

	return v * (2^x)

end

function BitRShift( v, x )

	return math.floor(v / (2^x))

end

function Bit64Overflow( x )
	if x - 0xFFFFFFFFFFFFFFFF >= 0 then print("OVERFLOW") return x - 0xFFFFFFFFFFFFFFFF end
	return x
end

function Bit64Underflow( x )
	if x < 0 then return 0xFFFFFFFFFFFFFFFF - x end
	return x
end

--This is most likely slow, gotta do somethin about that
function BitUnsigned( x )
	return math.BinToInt( math.IntToBin( x ) )
end

function BitShortPart( v, n )

	local b = n*16
	return BitRShift( v - BitLShift( BitRShift( v, 64 - b ), 64 - b ), (64 - b) - 16 )

end

function BitLongPart( v, n )

	local b = n*32
	return BitRShift( v - BitLShift( BitRShift( v, 64 - b ), 64 - b ), (64 - b) - 32 )

end

local test = 0xF0040003F002000F

--[[print( BitShortPart( test, 0 ) )
print( BitShortPart( test, 1 ) )
print( BitShortPart( test, 2 ) )
print( BitShortPart( test, 3 ) )
print( BitLongPart( test, 0 ) )
print( BitLongPart( test, 1 ) )]]

local function WideBinOp( f )

	return function( a, b )

		--local c0 = f( BitShortPart( a, 0 ), BitShortPart( b, 0 ) )
		--local c1 = f( BitShortPart( a, 1 ), BitShortPart( b, 1 ) )
		--local c2 = f( BitShortPart( a, 2 ), BitShortPart( b, 2 ) )
		local c3 = f( BitShortPart( a, 3 ), BitShortPart( b, 3 ) )

		return c3 --+ BitLShift(c2, 16) --+ BitLShift(c1, 32) + BitLShift(c0, 48)

	end

end


--[[function BitOr( a, b )

	local aHI = BitRShift( a, 32 )
	local aMASK = BitLShift( aHI, 32 )
	local aLO = a - aMASK

	print( ":", math.IntToBin( aLO ), math.IntToBin( aHI ) )

	local bHI = BitRShift( b, 32 )
	local bMASK = BitLShift( aHI, 32 )
	local bLO = b - bMASK

	local cHI = BitUnsigned( bit.bor(aHI, bHI) )
	local cLO = BitUnsigned( bit.bor(aLO, bLO) )
	return BitLShift(cHI, 32) + cLO

end]]


--[[BitOr = WideBinOp( bit.bor )
BitAnd = WideBinOp( bit.band )

function BitOr( a, b )
	local x = bit.bor(a,b)
	if x < 0 then x = 0x100000000 + x end
	return x
end]]

--[[function BitAnd( a, b )
	local x = bit.band(a,b)
	if x < 0 then x = 0x100000000 + x end
	return x
end]]