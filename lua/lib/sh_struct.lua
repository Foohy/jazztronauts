AddCSLuaFile()

local file_meta = FindMetaTable("File")
local decl_type = nil

decl_type = function( read, write, size, tsfunc )

	return setmetatable({
		read = read,
		write = write,
		__size = size,
		is_type_decl = true
	},
	{
		__index = function( self, k )
			if type(k) == "number" then

				local yieldpoints = math.ceil( 10000 / size )
				local params = rawget( self, "__params" )
				local key = params and params["key"]
				local decl = decl_type( function( f )

					local t = {}
					for i=1, k do
						if i % yieldpoints == yieldpoints-1 then task.Yield("progress", i) end
						if not key then
							table.insert( t, read(f) )
						else
							local d = read(f)
							t[d[key]] = d
						end
					end
					return t

				end,
				function( f, data )

					assert( #data == k )

					for i=1, k do
						write( f, data[i] )
					end

				end, size * k, tsfunc )
				rawset( decl, "__name", rawget( self, "__name" ))
				rawset( decl, "__length", k * ( rawget( self, "__length" ) or 1 ) )
				rawset( decl, "__params", rawget( self, "__params" ) )
				return decl
			elseif k == "sizeof" then return rawget( self, "__size" )
			elseif type(k) == "string" then
				local decl = decl_type( read, write, size, tsfunc )
				if rawget( self, "__name" ) == nil then
					rawset( decl, "__name", k )
				else
					rawset( decl, "__count", k )
					rawset( decl, "__name", rawget(self, "__name"))
				end
				rawset( decl, "__params", rawget( self, "__params" ) )
				return decl
			end
		end,
		__tostring = function( self )
			local str = rawget( self, "__name" ) or "<unnamed>"
			if rawget( self, "__length" ) or 0 > 0 then
				str = str .. "[" .. rawget( self, "__length" ) .. "]"
			end
			if tsfunc ~= nil then
				str = str .. ":\n" .. tsfunc()
			end
			return str
		end,
	})

end

function Struct( def, params )

	local function read( f, full )

		local out = {}

		for _,v in pairs( def ) do

			local count = rawget(v, "__count")
			if count ~= nil then
				out[ rawget(v, "__name") ] = v[ out[ count ] ].read(f)
			else
				out[ rawget(v, "__name") ] = v.read( f )
			end

		end

		local ret = params and rawget(params, "returns")
		if ret and not full then return out[ret] end

		return out

	end

	local function write( f, data )

		for _,v in pairs( def ) do

			local count = rawget(v, "__count")
			if count ~= nil then
				for i=1, data[ count ] do
					v.write( f, data[ rawget(v, "__name") ][i] )
				end
			else
				v.write( f, data[ rawget(v, "__name") ] )
			end

		end

	end

	local size = 0
	for _,v in pairs( def ) do

		size = size + v.sizeof

	end

	local decl = decl_type( read, write, size, function()

		local str = ""
		for _,v in pairs( def ) do

			str = str .. tostring( v ) .. "\n"

		end
		return str:sub(1,-2)

	end )

	rawset( decl, "__params", params )

	return decl

end

StructDecl = decl_type

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
		rawset( decl, "__name", rawget( self, "__name" ))
		rawset( decl, "__length", k )
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

IVECTOR = decl_type(
	function(f) return Vector( INT32.read(f), INT32.read(f), INT32.read(f) ) end,
	function(f, v) INT32.write(f, v.x) INT32.write(f, v.y) INT32.write(f, v.z) end,
	12
)

VECTOR4 = decl_type(
	function(f) return Vector4( FLOAT.read(f), FLOAT.read(f), FLOAT.read(f), FLOAT.read(f) ) end,
	function(f, v) FLOAT.write(f, v.x) FLOAT.write(f, v.y) FLOAT.write(f, v.z) FLOAT.write(f, v.w) end,
	16
)

QANGLE = decl_type(
	function(f) return Angle( FLOAT.read(f), FLOAT.read(f), FLOAT.read(f) ) end,
	function(f, v) FLOAT.write(f, v.x) FLOAT.write(f, v.y) FLOAT.write(f, v.z) end,
	12
)

IQANGLE = decl_type(
	function(f) return Angle( INT32.read(f), INT32.read(f), INT32.read(f) ) end,
	function(f, v) INT32.write(f, v.x) INT32.write(f, v.y) INT32.write(f, v.z) end,
	12
)

IFLOAT = decl_type(
	function(f) return INT32.read(f) end,
	function(f,v) return INT32.write(f, v) end,
	4
)

VECTOR2D = Struct({
	FLOAT.x,
	FLOAT.y,
})


if SERVER then return end

