module( "lzma", package.seeall )

include( "decoder.lua")

function FileReader( filename, path )

	local inFile = file.Open( filename, "rb", path or "DATA" )
	if not inFile then print("Can't open file: " .. tostring(filename) ) return end

	local rd = {
		f = inFile,
		p = math.min(0x800000, inFile:Size()),
		c = nil,
		r = true,
	}
	rd.s = rd.p
	function rd:Close() self.f:Close() end
	function rd:Size() return self.f:Size() end
	function rd:Tell() return self.p end
	function rd:Skip(n) self.p = self.p + n end
	function rd:ReadByte()
		if self.p == self.s then
			self.c = self.f:Read( self.s )
			self.p = 0
		end
		self.p = self.p + 1
		return string.byte(self.c[ self.p ])
	end
	function rd:ReadLong() return self.f:ReadLong() end
	return rd

end

function FileWriter( filename, path )

	local outFile = file.Open( filename, "wb", "DATA" )
	if not outFile then print("Can't open file: " .. tostring(filename) ) return end

	local wr = {
		f = outFile,
		p = 0,
		c = 0,
		s = 4,
		m = 1,
		w = true,
	}
	function wr:Close() wr:Flush() self.f:Close() end
	function wr:Size() return self.f:Size() end
	function wr:Flush()
		if self.p ~= self.s then
			for i=1, self.p do
				self.f:WriteByte( bit.band(self.c, 0xFF) )
				self.c = BitRShift( self.c, 8 )
			end
			return
		end
		self.f:WriteULong( self.c )
		self.c = 0
		self.p = 0
		self.m = 1
	end
	function wr:WriteByte(b)
		self.p = self.p + 1
		self.c = self.c + b * self.m
		self.m = self.m * 0x100
		if self.p == self.s then self:Flush() end
	end
	return wr

end

function FileWriter2( filename, path )

	local outFile = file.Open( filename, "wb", "DATA" )
	if not outFile then print("Can't open file: " .. tostring(filename) ) return end

	local lut = {}
	for i=0, 255 do
		lut[i] = string.char(i)
	end

	local wr = {
		f = outFile,
		p = 0,
		c = 0,
		s = 64,
		m = 1,
		w = true,
		d = {},
	}
	function wr:Close() wr:Flush() self.f:Close() end
	function wr:Size() return self.f:Size() end
	function wr:Flush()
		if self.p == 0 then return end
		--self.f:WriteULong( self.c )
		self.f:Write( table.concat( self.d ) )
		self.c = 0
		self.p = 0
		self.m = 1
	end
	function wr:WriteByte(b)
		self.p = self.p + 1
		self.d[ self.p ] = lut[b] --string.char( b )
		if self.p == self.s then self:Flush() end
	end
	return wr

end

function ByteReader( bytes, length )

	local rd = {
		p = 0,
		c = bytes,
		l = length or string.len( bytes ),
		r = true,
	}
	function rd:Close() end
	function rd:Size() return self.l end
	function rd:Tell() return self.p end
	function rd:Skip(n) self.p = self.p + n end
	function rd:ReadByte() self.p = self.p + 1 return string.byte(self.c[ self.p ]) end
	function rd:ReadLong() return bit.bor( rd:ReadByte() + BitLShift( rd:ReadByte(), 8 ) + BitLShift( rd:ReadByte(), 16 ) + BitLShift( rd:ReadByte(), 24 ), 0 ) end
	function rd:ReadULong() return rd:ReadByte() + BitLShift( rd:ReadByte(), 8 ) + BitLShift( rd:ReadByte(), 16 ) + BitLShift( rd:ReadByte(), 24 ) end
	return rd

end

function ByteBufferReader( bytes )

	local rd = {
		p = 0,
		c = bytes,
		l = bytes.Length,
		r = true,
	}
	function rd:Close() end
	function rd:Size() return self.l end
	function rd:Tell() return self.p end
	function rd:Skip(n) self.p = self.p + n end
	function rd:ReadByte() self.p = self.p + 1 return bytes[self.p] end
	function rd:ReadLong() return bit.bor( rd:ReadByte() + BitLShift( rd:ReadByte(), 8 ) + BitLShift( rd:ReadByte(), 16 ) + BitLShift( rd:ReadByte(), 24 ), 0 ) end
	function rd:ReadULong() return rd:ReadByte() + BitLShift( rd:ReadByte(), 8 ) + BitLShift( rd:ReadByte(), 16 ) + BitLShift( rd:ReadByte(), 24 ) end
	return rd

end

local meta = {}
meta.__index = meta

function meta:SetProgressCallback( cbDecompress )

	self.cbDecompress = cbDecompress

end

function meta:SetFlushCallback( cbFlush )

	self.cbFlush = cbFlush

end

function meta:SetCompleteCallback( cbComplete )

	self.cbComplete = cbComplete

end

function meta:GetWindowReader()

	return ByteBufferReader( self.decoder.m_OutWindow.m_Buffer )

end

function meta:Cancel()

	self.decoder.stop = true

end

function meta:Start()

	local s = self
	local t = task.New( function()

		print("SET PROPERTIES")
		self.decoder:SetDecoderProperties( self.props )
		print("DECODE")

		local b,e = pcall( function()
			self.decoder:Code( self.reader, self.writer, self.compressed, self.outSize, nil )
		end )

		if not b then ErrorNoHalt( e ) end

		self.decoder.m_OutWindow:Flush()
		self.writer:Close()
		self.reader:Close()

		if self.cbDecompress then self.cbDecompress( self.outSize, self.outSize, 100 ) end
		if self.cbComplete then self.cbComplete( self.decoder.stop ) end

	end )

	function t:progress( decompressed, total )
		local percent = 100 * (decompressed / total)
		if s.cbDecompress then s.cbDecompress( decompressed, total, percent ) end
	end

	function t:writefile( written, total )
		local percent = 100 * (written / total)
		if s.cbFlush then s.cbFlush( written, total, percent ) end
	end

end

function Decompressor( reader, writer )

	assert( reader.r and writer.w )

	local props = ByteBuffer(5)
	local decoder = LZMADecoder()

	for i=0, 4 do props[i] = reader:ReadByte() end

	local outSize = 0
	for i=0, 7 do

		local v = reader:ReadByte()
		if v < 0 then error("Can't read size") end
		outSize = outSize + BitLShift( v, 8 * i )

	end

	local compressed = reader:Size() - reader:Tell()

	return setmetatable({
		props = props,
		decoder = decoder,
		reader = reader,
		writer = writer,
		compressed = compressed,
		outSize = outSize,
	}, meta)

end