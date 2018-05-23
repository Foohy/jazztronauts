AddCSLuaFile()

local file_meta = FindMetaTable("File")
local decl_type = nil

decl_type = function( read, write, size, tsfunc )

	return setmetatable({
		read = read,
		write = write,
		size = size,
		is_type_decl = true
	},
	{
		__index = function( self, k )
			if type(k) == "number" then
				local decl = decl_type( function( f )

					local t = {}
					for i=1, k do
						table.insert( t, read(f) )
					end
					return t

				end, 
				function( f, data )

					assert( #data == k )

					for i=1, k do
						write( f, data[i] )
					end

				end, size * k, tsfunc )
				rawset( decl, "name", rawget( self, "name" ))
				rawset( decl, "length", k )
				return decl
			elseif k == "read" then return rawget( self, "read" )
			elseif k == "write" then return rawget( self, "write" )
			elseif k == "size" then return rawget( self, "size" )
			elseif type(k) == "string" then
				local decl = decl_type( read, write, size, tsfunc )
				rawset( decl, "name", k )
				return decl
			end
		end,
		__tostring = function( self )
			local str = rawget( self, "name" ) or "<unnamed>"
			if rawget( self, "length" ) or 0 > 0 then
				str = str .. "[" .. rawget( self, "length" ) .. "]"
			end
			if tsfunc ~= nil then
				str = str .. ":\n" .. tsfunc()
			end
			return str
		end,
	})

end

function Struct( def )

	local function read( f )

		local out = {}

		for _,v in pairs( def ) do

			out[ rawget(v, "name") ] = v.read( f )

		end

		return out

	end

	local function write( f, data )

		for _,v in pairs( def ) do

			v.write( f, data[ rawget(v, "name") ] )

		end

	end

	local size = 0
	for _,v in pairs( def ) do

		size = size + v.size

	end

	local decl = decl_type( read, write, size, function()

		local str = ""
		for _,v in pairs( def ) do

			str = str .. tostring( v ) .. "\n"

		end
		return str:sub(1,-2)

	end )

	return decl

end

CHAR = decl_type(
	function( f ) return file_meta.Read( f, 1 ) end,
	function( f, d ) file_meta.Write( f, tostring(d)[1] ) end,
	1
)

local ch_meta = getmetatable( CHAR )
local thru = ch_meta.__index
ch_meta.__index = function( self, k )

	if type(k) == "number" then
		local decl = decl_type( function( f )

			local str = file_meta.Read( f, k )
			for i=1, k do
				if str[i] == '\0' then
					str = str:sub(1, i-1)
					break
				end
			end

			return str

		end, 
		function( f, data )

			file_meta.Write( f, data )

		end, k )
		rawset( decl, "name", rawget( self, "name" ))
		rawset( decl, "length", k )
		return decl
	end
	local x = thru( self, k )
	if type(x) == "table" then setmetatable( x, ch_meta ) end
	return x

end

setmetatable( CHAR, ch_meta )

FLOAT = decl_type(
	file_meta.ReadFloat,
	file_meta.WriteFloat,
	4
)

INT8 = decl_type(
	file_meta.ReadByte,
	file_meta.WriteByte,
	1
)

INT16 = decl_type(
	file_meta.ReadShort,
	file_meta.WriteShort,
	2
)

INT32 = decl_type( 
	file_meta.ReadLong, 
	file_meta.WriteLong,
	4
)

UINT8 = decl_type(
	file_meta.ReadByte,
	file_meta.WriteByte,
	1
)

UINT16 = decl_type(
	file_meta.ReadUShort,
	file_meta.WriteUShort,
	2
)

UINT32 = decl_type(
	file_meta.ReadULong,
	file_meta.WriteULong,
	4
)

VECTOR = decl_type(
	function(f) return Vector( FLOAT.read(f), FLOAT.read(f), FLOAT.read(f) ) end,
	function(f, v) FLOAT.write(f, v.x) FLOAT.write(f, v.y) FLOAT.write(f, v.z) end,
	12
)

QANGLE = decl_type(
	function(f) return Angle( FLOAT.read(f), FLOAT.read(f), FLOAT.read(f) ) end,
	function(f, v) FLOAT.write(f, v.x) FLOAT.write(f, v.y) FLOAT.write(f, v.z) end,
	12
)

VECTOR4 = Struct({
	FLOAT.x,
	FLOAT.y,
	FLOAT.z,
	FLOAT.w
})

VECTOR2D = Struct({
	FLOAT.x,
	FLOAT.y,
})


if SERVER then return end

