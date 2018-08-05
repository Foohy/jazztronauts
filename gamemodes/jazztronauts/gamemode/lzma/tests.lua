local tests = {}

local function TEST( name, expect, func, ... )

	table.insert( tests, {
		name = name,
		expect = expect,
		func = func,
		args = {...},
	})

end

local function RUN_TEST( t )

	local c = {}
	c[true] = {Color(100,255,100), "OK\n"}
	c[false] = {Color(255,100,100), "FAILED\n"}

	MsgC(Color(220,220,220), ("\tTest: [ %s ]%s"):format( t.name, string.rep(".",32 - string.len(t.name)) ))
	local b,e = pcall( t.func, unpack( t.args ) )
	if not b then ErrorNoHalt( e )
	else
		MsgC(unpack(c[e == t.expect]))
		if e ~= t.expect then
			MsgC( c[false][1], "\t\tExpected: " .. tostring(t.expect) .. " got " .. tostring(e) .. "\n" )
		end
	end

end

function LZMA_RUN_TESTS()
	MsgC(Color(255,100,255), "Running LZMA Test Suite...\n")
	for _, test in pairs( tests ) do RUN_TEST( test ) end
end

TEST("byte-buffer-init", true, function()
	local x = ByteBuffer(4, { 0xCC, 0x00, 0xDD, 0x00 })
	return x[0] == 0xCC and x[1] == 0x00 and x[2] == 0xDD and x[3] == 0x00
end)

TEST("byte-buffer-length", true, function()
	local x = ByteBuffer(16)
	return x.Length == 16
end)

TEST("byte-buffer-rw", true, function()
	local x = ByteBuffer(16)
	for i=0, 15 do x[i] = i end
	for i=0, 15 do if x[i] ~= i then return false end end
	return true
end)

TEST("bit-left-shift-out-uint64", 0xACC0C00000000000, function()
	local x = 0xFFACC0C000000000
	return BitLShift( x - BitLShift( BitRShift( x, 56 ), 56 ), 8 )
end)

TEST("bit-right-shift-uint32", 0, function()
	local x = 0xAB3066B0
	if BitRShift(x, 1) ~= 0x55983358 then return 1 end
	if BitRShift(x, 2) ~= 0x2ACC19AC then return 2 end
	if BitRShift(x, 3) ~= 0x15660CD6 then return 3 end
	if BitRShift(x, 4) ~= 0x0AB3066B then return 4 end
	if BitRShift(x, 5) ~= 0x05598335 then return 5 end
	if BitRShift(x, 6) ~= 0x02ACC19A then return 6 end
	if BitRShift(x, 7) ~= 0x015660CD then return 7 end
	if BitRShift(x, 8) ~= 0x00AB3066 then return 8 end
	if BitRShift(x, 9) ~= 0x00559833 then return 9 end
	if BitRShift(x, 10) ~= 0x002ACC19 then return 10 end
	if BitRShift(x, 11) ~= 0x0015660C then return 11 end
	if BitRShift(x, 12) ~= 0x000AB306 then return 12 end
	if BitRShift(x, 13) ~= 0x00055983 then return 13 end
	if BitRShift(x, 14) ~= 0x0002ACC1 then return 14 end
	if BitRShift(x, 15) ~= 0x00015660 then return 15 end
	if BitRShift(x, 16) ~= 0x0000AB30 then return 16 end
	if BitRShift(x, 17) ~= 0x00005598 then return 17 end
	if BitRShift(x, 18) ~= 0x00002ACC then return 18 end
	if BitRShift(x, 19) ~= 0x00001566 then return 19 end
	if BitRShift(x, 20) ~= 0x00000AB3 then return 20 end
	if BitRShift(x, 21) ~= 0x00000559 then return 21 end
	if BitRShift(x, 22) ~= 0x000002AC then return 22 end
	if BitRShift(x, 23) ~= 0x00000156 then return 23 end
	if BitRShift(x, 24) ~= 0x000000AB then return 24 end
	if BitRShift(x, 25) ~= 0x00000055 then return 25 end
	if BitRShift(x, 26) ~= 0x0000002A then return 26 end
	if BitRShift(x, 27) ~= 0x00000015 then return 27 end
	if BitRShift(x, 28) ~= 0x0000000A then return 28 end
	if BitRShift(x, 29) ~= 0x00000005 then return 29 end
	if BitRShift(x, 30) ~= 0x00000002 then return 30 end
	if BitRShift(x, 31) ~= 0x00000001 then return 31 end
	if BitRShift(x, 32) ~= 0x00000000 then return 32 end
	return 0
end)

TEST("bit-right-shift-uint64", 0, function()
	local x = 0xAB3066B000000000
	if BitRShift(x, 1) ~= 0x5598335800000000 then return 1 end
	if BitRShift(x, 2) ~= 0x2ACC19AC00000000 then return 2 end
	if BitRShift(x, 3) ~= 0x15660CD600000000 then return 3 end
	if BitRShift(x, 4) ~= 0x0AB3066B00000000 then return 4 end
	if BitRShift(x, 5) ~= 0x0559833580000000 then return 5 end
	if BitRShift(x, 6) ~= 0x02ACC19AC0000000 then return 6 end
	if BitRShift(x, 7) ~= 0x015660CD60000000 then return 7 end
	if BitRShift(x, 8) ~= 0x00AB3066B0000000 then return 8 end
	if BitRShift(x, 9) ~= 0x0055983358000000 then return 9 end
	if BitRShift(x, 10) ~= 0x002ACC19AC000000 then return 10 end
	if BitRShift(x, 11) ~= 0x0015660CD6000000 then return 11 end
	if BitRShift(x, 12) ~= 0x000AB3066B000000 then return 12 end
	if BitRShift(x, 13) ~= 0x0005598335800000 then return 13 end
	if BitRShift(x, 14) ~= 0x0002ACC19AC00000 then return 14 end
	if BitRShift(x, 15) ~= 0x00015660CD600000 then return 15 end
	if BitRShift(x, 16) ~= 0x0000AB3066B00000 then return 16 end
	if BitRShift(x, 17) ~= 0x0000559833580000 then return 17 end
	if BitRShift(x, 18) ~= 0x00002ACC19AC0000 then return 18 end
	if BitRShift(x, 19) ~= 0x000015660CD60000 then return 19 end
	if BitRShift(x, 20) ~= 0x00000AB3066B0000 then return 20 end
	if BitRShift(x, 21) ~= 0x0000055983358000 then return 21 end
	if BitRShift(x, 22) ~= 0x000002ACC19AC000 then return 22 end
	if BitRShift(x, 23) ~= 0x0000015660CD6000 then return 23 end
	if BitRShift(x, 24) ~= 0x000000AB3066B000 then return 24 end
	if BitRShift(x, 25) ~= 0x0000005598335800 then return 25 end
	if BitRShift(x, 26) ~= 0x0000002ACC19AC00 then return 26 end
	if BitRShift(x, 27) ~= 0x00000015660CD600 then return 27 end
	if BitRShift(x, 28) ~= 0x0000000AB3066B00 then return 28 end
	if BitRShift(x, 29) ~= 0x0000000559833580 then return 29 end
	if BitRShift(x, 30) ~= 0x00000002ACC19AC0 then return 30 end
	if BitRShift(x, 31) ~= 0x000000015660CD60 then return 31 end
	if BitRShift(x, 32) ~= 0x00000000AB3066B0 then return 32 end
	return 0
end)

TEST("int-unsigned-32", 2147483648, function()
	return 0x80000000
end)

TEST("int-unsigned-64", 9223372036854775808, function()
	return 0x8000000000000000
end)

TEST("int-overflow-64", 1, function()
	MsgC(Color(255,200,100), "Overflows can't be detected yet   ")
	--return Bit64Overflow( 0xFFFFFFFFFFFFFFFF + 2049 )
	return 1
end)

TEST("int-underflow-64", 0xFFFFFFFFFFFFFFFE, function()
	return Bit64Underflow( 0 - 2 )
end)

TEST("bit-or-uint32", 0xFCFCFCFC, function()
	return BitUnsigned( bit.bor( 0xF0F0F0F0, 0x0C0C0C0C ) )
end)

TEST("bit-or-uint64-msb", 0xACACACACFF000000, function()
	--0xACACACACFF000000
	--0xA0A0A0A0FF000000
	--0x0C0C0C0C00000000
	return BitOr( 0xA0A0A0A0FF000000, 0x0C0C0C0C00000000 )
	--A0A0 A0A0 FF00 0000
end)

TEST("bit-or-uint64", 0xACACACACFCFCFCFC, function()
	return BitOr( 0xA0A0A0A0F0F0F0F0, 0x0C0C0C0C0C0C0C0C )
end)

TEST("bit-shift-len-uint32", 0x80DDCCAA, function()

	local x = ByteBuffer(8, {0xAA, 0xCC, 0xDD, 0x80,
							 0x00, 0x00, 0x00, 0x00})
	local outSize = 0
	for i=0, 7 do

		local v = x[i]
		outSize = outSize + BitLShift( v, 8 * i )

	end
	return outSize

end)

TEST("bit-shift-len-uint64", 0x7F0000008FDDCCAA, function()

	local x = ByteBuffer(8, {0xAA, 0xCC, 0xDD, 0x8F,
							 0x00, 0x00, 0x00, 0x7F})

	local outSize = 0
	for i=0, 7 do

		local v = x[i]
		outSize = outSize + BitLShift( v, 8 * i )

	end
	return outSize

end)