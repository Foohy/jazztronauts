if true then return end --Not using this anymore, use bsp2

if SERVER then AddCSLuaFile("sh_bsp.lua") end

module( "bsp", package.seeall )

LUMP_ENTITIES					= 0
LUMP_PLANES						= 1
LUMP_TEXDATA					= 2
LUMP_VERTEXES					= 3
LUMP_VISIBILITY					= 4
LUMP_NODES						= 5
LUMP_TEXINFO					= 6
LUMP_FACES						= 7
LUMP_LIGHTING					= 8
LUMP_OCCLUSION					= 9
LUMP_LEAFS						= 10
LUMP_FACEIDS					= 11
LUMP_EDGES						= 12
LUMP_SURFEDGES					= 13
LUMP_MODELS						= 14
LUMP_WORLDLIGHTS				= 15
LUMP_LEAFFACES					= 16
LUMP_LEAFBRUSHES				= 17
LUMP_BRUSHES					= 18
LUMP_BRUSHSIDES					= 19
LUMP_AREAS						= 20
LUMP_AREAPORTALS				= 21
LUMP_UNUSED0					= 22
LUMP_UNUSED1					= 23
LUMP_UNUSED2					= 24
LUMP_UNUSED3					= 25
LUMP_DISPINFO					= 26
LUMP_ORIGINALFACES				= 27
LUMP_PHYSDISP					= 28
LUMP_PHYSCOLLIDE				= 29
LUMP_VERTNORMALS				= 30
LUMP_VERTNORMALINDICES			= 31
LUMP_DISP_LIGHTMAP_ALPHAS		= 32
LUMP_DISP_VERTS					= 33
LUMP_DISP_LIGHTMAP_SAMPLE_POSITIONS = 34
LUMP_GAME_LUMP					= 35
LUMP_LEAFWATERDATA				= 36
LUMP_PRIMITIVES					= 37
LUMP_PRIMVERTS					= 38
LUMP_PRIMINDICES				= 39
LUMP_PAKFILE					= 40
LUMP_CLIPPORTALVERTS			= 41
LUMP_CUBEMAPS					= 42
LUMP_TEXDATA_STRING_DATA		= 43
LUMP_TEXDATA_STRING_TABLE		= 44
LUMP_OVERLAYS					= 45
LUMP_LEAFMINDISTTOWATER			= 46
LUMP_FACE_MACRO_TEXTURE_INFO	= 47
LUMP_DISP_TRIS					= 48
LUMP_PHYSCOLLIDESURFACE			= 49
LUMP_WATEROVERLAYS              = 50
LUMP_LEAF_AMBIENT_INDEX_HDR		= 51
LUMP_LEAF_AMBIENT_INDEX         = 52
LUMP_LIGHTING_HDR				= 53
LUMP_WORLDLIGHTS_HDR			= 54
LUMP_LEAF_AMBIENT_LIGHTING_HDR	= 55
LUMP_LEAF_AMBIENT_LIGHTING		= 56
LUMP_XZIPPAKFILE				= 57
LUMP_FACES_HDR					= 58
LUMP_MAP_FLAGS                  = 59
LUMP_OVERLAY_FADES				= 60

local meta = {}
meta.__index = meta

local rmeta = {}
rmeta.__index = rmeta

local function LoadLumps( file )

	local lump_data = {}
	for i=1, 64 do
		lump_data[i] = {
			offset = file:ReadLong(),
			length = file:ReadLong(),
			version = file:ReadLong(),
			fourcc = file:ReadLong(),
		}
	end
	return lump_data

end

function rmeta:Init( filename, path )
	
	self.file = file.Open( filename, "rb", path or "GAME" )
	if not self.file then error( "Unable to load file: " .. tostring(filename) ) return nil end
	return self

end

function rmeta:Tell() return self.file:Tell() end
function rmeta:Seek(p) self.file:Seek(p) end
function rmeta:Line() return self.file:ReadLine() end
function rmeta:Byte() return self.file:ReadByte() end
function rmeta:Long() return self.file:ReadLong() end
function rmeta:Short() return self.file:ReadShort() end
function rmeta:UShort() return bit.band( self:Short(), 0x0000FFFF ) end
function rmeta:Float() return self.file:ReadFloat() end
function rmeta:Vector() return Vector( self:Float(), self:Float(), self:Float() ) end
function rmeta:ShortVector() return Vector( self:Short(), self:Short(), self:Short() ) end
function rmeta:Vector4() return Vector4( self:Float(), self:Float(), self:Float(), self:Float() ) end
function rmeta:TexMatrix() return TexMatrix( self:Vector4(), self:Vector4() ) end
function rmeta:Plane() return Plane( self:Vector(), self:Float(), self:Long() ) end

function rmeta:Header()

	return {
		ident = self:Long(),
		version = self:Long(),
		lumps = LoadLumps( self.file ),
		revision = self:Long(),
	}

end

function rmeta:GameLump()

	return {
		id = self:Long(),
		flags = self:UShort(),
		version = self:UShort(),
		offset = self:Long(),
		len = self:Long(),
	}

end

function rmeta:TextureStringTable( size )

	local names = {}
	local texstringEnd = self:Tell() + size
	local str = ""
	local i = 0

	task.Yield("chunk", "texture_strings", -1)
	while ( self:Tell() < texstringEnd ) do
		local ch = string.char(self:Byte())
		if ch == '\0' then
			table.insert(names, str)
			str = ""
		else
			str = str .. ch
		end
		i = i + 1
		if i % 1000 == 1 then task.Yield("progress", i) end
	end
	task.Yield("chunkdone", "texture_strings", #names, names)

	return names

end

function rmeta:TexData( stringtable, resolver )

	return {
		reflectivity = self:Vector(),
		material = resolver( stringtable[ self:Long() + 1 ] ),
		width = self:Long(),
		height = self:Long(),
		view_width = self:Long(),
		view_height = self:Long(),
	}

end

function rmeta:TexInfo( texdatas )

	return {
		st = self:TexMatrix(),
		lst = self:TexMatrix(),
		flags = self:Long(),
		texdata = texdatas[ self:Long() + 1 ],
	}

end

function rmeta:BrushSide( planes, texinfoarray )

	return {
		plane = planes[ self:UShort() + 1 ],
		texinfo = texinfoarray and texinfoarray[ self:Short() + 1 ] or self:Short(),
		dispinfo = self:Short(),
		bevel = self:Short(),
	}

end

function rmeta:Brush( brushsides )

	local firstbrushside = self:Long()
	local numsides = self:Long()
	local contents = self:Long()

	local sides = {}
	for i=firstbrushside+1, firstbrushside+numsides do
		table.insert( sides, brushsides[i] )
		task.Yield()
	end

	return {
		contents = contents,
		sides = sides,
	}

end

function rmeta:Edge( verts )

	local long = self:Long()
	local a = bit.rshift( bit.band( long, 0xFFFF0000 ), 16 ) + 1
	local b = bit.band( long, 0x0000FFFF ) + 1

	return { 
		verts[a], 
		verts[b]
	}

end

function rmeta:SurfEdge( edges )

	local id = self:Long()
	if id > 0 then
		return edges[id+1]
	else
		return { edges[-id + 1][2], edges[-id + 1][1] }
	end

end

function rmeta:Face( planes, surfedges, texinfoarray )

	local plane = planes[ self:UShort() + 1 ]
	local st = self:Short()

	local side = bit.rshift( st, 8 )
	local onNode = bit.band( st, 0xFF )

	local firstedge = self:Long()
	local numedges = self:Short()
	local texinfo = self:Short()
	local dispinfo = self:Short()
	local fogvolume = self:Short()
	local styles = self:Long()

	--skip stuff we don't need
	self:Seek( self:Tell() + 24)

	local original = self:Long()
	local numPrims = self:UShort()
	local firtPrimID = self:UShort()
	local smoothing = self:Long()

	local edges = {}
	for i=firstedge+1, firstedge+numedges do
		table.insert( edges, surfedges[i] )
		if i % 500 == 1 then task.Yield() end
	end

	return {
		plane = plane,
		side = side,
		onNode = onNode,
		edges = edges,
		texinfo = texinfoarray and texinfoarray[ texinfo + 1 ] or texinfo,
		dispinfo = dispinfo,
		original = original,
	}

end

local function Reader( bsp )

	return setmetatable({}, rmeta):Init( bsp.filename, bsp.path )

end

function meta:LumpSize( lump ) return self.header.lumps[ lump+1 ].length end
function meta:SeekLump( reader, lump ) 

	reader:Seek( self.header.lumps[ lump+1 ].offset )
	return self:LumpSize( lump )

end

function meta:LumpElementSize( lump )

	if lump == LUMP_PLANES then return 20 end
	if lump == LUMP_VERTEXES then return 12 end
	if lump == LUMP_TEXDATA then return 32 end
	if lump == LUMP_TEXINFO then return 72 end
	if lump == LUMP_BRUSHSIDES then return 8 end
	if lump == LUMP_BRUSHES then return 12 end
	if lump == LUMP_EDGES then return 4 end
	if lump == LUMP_SURFEDGES then return 4 end
	if lump == LUMP_FACES then return 56 end
	if lump == LUMP_ORIGINALFACES then return 56 end
	if lump == LUMP_LEAFFACES then return 2 end
	if lump == LUMP_LEAFBRUSHES then return 2 end
	if lump == LUMP_LEAFS then return ( self.header.version == 20 and 32 or 56 ) end
	if lump == LUMP_NODES then return 32 end
	if lump == LUMP_MODELS then return 48 end
	return 1

end

function meta:_LoadArray( name, num, func, ... )

	local t = {}
	local yieldpoints = math.ceil( 5000 / num )
	task.Yield("chunk", name, num)

	for i=1, num do
		table.insert(t, func(...))
		if i % yieldpoints == 1 or i == num then task.Yield("progress", i) end
	end

	task.Yield("chunkdone", name, num, t)
	return t

end

function meta:_LumpIter( out, lump, func, reader, ... )

	local t = {}
	local size = self:LumpElementSize( lump )
	local count = self:SeekLump( reader, lump ) / size
	local yieldpoints = math.ceil( 5000 / size )

	self[out] = t
	task.Yield("chunk", out, count)

	for i=1, count do
		table.insert( t, func( reader, ... ) )
		if i % yieldpoints == 1 or i == count then task.Yield("progress", i) end
	end

	task.Yield("chunkdone", out, count, t)

end

function meta:_Lock( id )

	self._locks = self._locks or {}

	while self._locks[id] == true do
		task.Yield("resource_locked")
	end

	self._locks[id] = true

end

function meta:_Unlock( id )

	self._locks = self._locks or {}
	self._locks[id] = false

end

function meta:_LoadHeader( reader )

	if self.header then return self.header end

	reader = reader or Reader( self )
	self.header = reader:Header()

end

function meta:_LoadPlanes( reader )

	self:_Lock( LUMP_PLANES )

		if self.planes then self:_Unlock( LUMP_PLANES ) return self.planes end

		reader = reader or Reader( self )
		self:_LumpIter( "planes", LUMP_PLANES, reader.Plane, reader )

	self:_Unlock( LUMP_PLANES )

end

function meta:_LoadVerts( reader )

	self:_Lock( LUMP_VERTEXES )

		if self.verts then self:_Unlock( LUMP_VERTEXES ) return self.verts end

		reader = reader or Reader( self )
		self:_LumpIter( "verts", LUMP_VERTEXES, reader.Vector, reader )

	self:_Unlock( LUMP_VERTEXES )

end

function meta:_LoadTextureInfo( reader )

	self:_Lock( LUMP_TEXINFO )

		if self.texinfo then self:_Unlock( LUMP_TEXINFO ) return self.texinfo end

		reader = reader or Reader( self )

		self:_LoadBrushSides( reader )

		local size = self:SeekLump( reader, LUMP_TEXDATA_STRING_DATA )
		local names = reader:TextureStringTable( size )
		self:_LumpIter( "texdata", LUMP_TEXDATA, reader.TexData, reader, names, function(name) return name end )
		self:_LumpIter( "texinfo", LUMP_TEXINFO, reader.TexInfo, reader, self.texdata )
		self.texdata = nil

		if self.brushsides then
			for _,v in pairs(self.brushsides) do
				if type( v.texinfo ) == "number" then
					v.texinfo = self.texinfo[ v.texinfo + 1 ]
				end
				task.Yield()
			end
		end

	self:_Unlock( LUMP_TEXINFO )

end

function meta:_LoadBrushSides( reader )

	self:_Lock( LUMP_BRUSHSIDES )

		if self.brushsides then self:_Unlock( LUMP_BRUSHSIDES ) return self.brushsides end

		reader = reader or Reader( self )

		self:_LoadPlanes( reader )
		self:_LumpIter( "brushsides", LUMP_BRUSHSIDES, reader.BrushSide, reader, self.planes, self.texinfo )

	self:_Unlock( LUMP_BRUSHSIDES )

end

function meta:_LoadBrushes( reader )

	self:_Lock( LUMP_BRUSHES )

		if self.brushes then self:_Unlock( LUMP_BRUSHES ) return self.brushes end

		reader = reader or Reader( self )

		self:_LoadBrushSides( reader )
		self:_LumpIter( "brushes", LUMP_BRUSHES, reader.Brush, reader, self.brushsides )

	self:_Unlock( LUMP_BRUSHES )

end

function meta:_LoadEdges( reader )

	self:_Lock( LUMP_EDGES )

		if self.edges then self:_Unlock( LUMP_EDGES ) return self.edges end

		reader = reader or Reader( self )

		self:_LoadVerts( reader )
		self:_LumpIter( "edges", LUMP_EDGES, reader.Edge, reader, self.verts )

	self:_Unlock( LUMP_EDGES )

end

function meta:_LoadSurfEdges( reader )

	self:_Lock( LUMP_SURFEDGES )

		if self.surfedges then self:_Unlock( LUMP_SURFEDGES ) return self.surfedges end

		reader = reader or Reader( self )

		self:_LoadEdges( reader )
		self:_LumpIter( "surfedges", LUMP_SURFEDGES, reader.SurfEdge, reader, self.edges )

	self:_Unlock( LUMP_SURFEDGES )

end

function meta:_LoadFaces( reader )

	self:_Lock( LUMP_FACES )

		if self.faces then self:_Unlock( LUMP_FACES ) return self.faces end

		reader = reader or Reader( self )

		self:_LoadPlanes( reader )
		self:_LoadSurfEdges( reader )
		self:_LumpIter( "faces", LUMP_FACES, reader.Face, reader, self.planes, self.surfedges )

	self:_Unlock( LUMP_FACES )

end

local GameLump_t = Struct({
	CHAR.id[4],
	UINT16.flags,
	UINT16.version,
	INT32.fileofs,
	INT32.filelen,
})

local StaticPropLump_t = {}
StaticPropLump_t[4] = Struct({
	VECTOR.origin,
	QANGLE.angles,
	
	UINT16.proptype,
	UINT16.firstleaf,
	UINT16.leafcount,

	UINT8.solid,
	UINT8.flags,

	INT32.skin,
	FLOAT.fademindist,
	FLOAT.fademaxdist,

	VECTOR.lightingorigin,
})
StaticPropLump_t[5] = Struct({
	VECTOR.origin,
	QANGLE.angles,
	
	UINT16.proptype,
	UINT16.firstleaf,
	UINT16.leafcount,

	UINT8.solid,
	UINT8.flags,

	INT32.skin,
	FLOAT.fademindist,
	FLOAT.fademaxdist,

	VECTOR.lightingorigin,
	FLOAT.forcedfadescale,
})
StaticPropLump_t[6] = Struct({
	VECTOR.origin,
	QANGLE.angles,
	
	UINT16.proptype,
	UINT16.firstleaf,
	UINT16.leafcount,

	UINT8.solid,
	UINT8.flags,

	INT32.skin,
	FLOAT.fademindist,
	FLOAT.fademaxdist,

	VECTOR.lightingorigin,
	FLOAT.forcedfadescale,

	UINT16.mindxlevel,
	UINT16.maxdxlevel,
})
StaticPropLump_t[7] = Struct({
	VECTOR.origin,
	QANGLE.angles,
	
	UINT16.proptype,
	UINT16.firstleaf,
	UINT16.leafcount,

	UINT8.solid,
	UINT8.flags,

	INT32.skin,
	FLOAT.fademindist,
	FLOAT.fademaxdist,

	VECTOR.lightingorigin,
	FLOAT.forcedfadescale,

	UINT16.mindxlevel,
	UINT16.maxdxlevel,

	INT32.color,
})
StaticPropLump_t[8] = Struct({
	VECTOR.origin,
	QANGLE.angles,
	
	UINT16.proptype,
	UINT16.firstleaf,
	UINT16.leafcount,

	UINT8.solid,
	UINT8.flags,

	INT32.skin,
	FLOAT.fademindist,
	FLOAT.fademaxdist,

	VECTOR.lightingorigin,
	FLOAT.forcedfadescale,

	UINT8.mincpulevel,
	UINT8.maxcpulevel,
	UINT8.mingpulevel,
	UINT8.maxgpulevel,

	INT32.color,
})

function meta:_LoadGameLumps( reader )

	self:_Lock( LUMP_GAME_LUMP )

		if self.gamelumps then self:_Unlock( LUMP_GAME_LUMP ) return self.gamelumps end
		self.gamelumps = {}

		reader = reader or Reader( self )

		local lump = self.header.lumps[ LUMP_GAME_LUMP+1 ]
		local file = reader.file

		file:Seek( lump.offset )

		local count = INT32.read( file )
		for i=1, count do
			local lump = GameLump_t.read( file )
			self.gamelumps[lump.id] = lump
		end

		local props = self.gamelumps["prps"]
		if props == nil then print("NO PROP LUMP") self:_Unlock( LUMP_GAME_LUMP ) return self.gamelumps end

		local struct = StaticPropLump_t[ props.version ]
		if struct == nil then print("VERSION NOT SUPPORTED") self:_Unlock( LUMP_GAME_LUMP ) return self.gamelumps end

		file:Seek( props.fileofs )

		self.props = {}

		local dict = {}
		local leafs = {}

		local dict = self:_LoadArray( "prop-dict", INT32.read( file ), CHAR[128].read, file )
		local leafs = self:_LoadArray( "prop-leafs", INT32.read( file ), UINT16.read, file )
		local nextpropid = 0

		self.props = self:_LoadArray( "props", INT32.read( file ), function()
			local prop = struct.read( file )
			prop.model = dict[ prop.proptype + 1 ]
			prop.leaf = leafs[ prop.firstleaf + 1 ]
			prop.id = nextpropid
			nextpropid = nextpropid + 1

			return prop
		end )

	self:_Unlock( LUMP_GAME_LUMP )

end

function meta:_ConvertBrushes()

	if self.converted_brushes ~= nil then return end

	self.converted_brushes = {}
	for k, origbrush in pairs( self.brushes ) do

		local newbrush = brush.Brush()
		newbrush.contents = origbrush.contents

		for _, origside in pairs( origbrush.sides ) do
			local side = brush.Side( origside.plane.back )
			side.texinfo = origside.texinfo
			side.bevel = origside.bevel != 0
			newbrush:Add( side )
		end

		newbrush.center = (newbrush.min + newbrush.max) / 2
		table.insert( self.converted_brushes, newbrush )

		task.Yield()

	end

end

function meta:GetBrushes()

	return self.converted_brushes

end

function meta:Init( filename, path )

	self.filename = filename
	self.path = path
	self.header = nil --done
	self.planes = nil --done
	self.verts = nil --done
	self.texinfo = nil --done
	self.brushsides = nil --done
	self.brushes = nil --done
	self.edges = nil --done
	self.surfedges = nil --done
	self.faces = nil --done
	self.leaffaces = nil
	self.leafbrushes = nil
	self.leafs = nil
	self.nodes = nil
	self.models = nil
	self.gamelumps = nil --done
	self.props = nil --done

	--Just make sure it's loaded ok?
	self:_LoadHeader()

	return self

end

function meta:GetVersion()

	return self.header.version, self.header.revision

end

function meta:GetName()

	return self.filename:sub(6,-5)

end

function meta:Load( lump )

	if lump == LUMP_PLANES then return self:_LoadPlanes() end
	if lump == LUMP_VERTEXES then return self:_LoadVerts() end
	if lump == LUMP_TEXINFO then return self:_LoadTextureInfo() end
	if lump == LUMP_BRUSHSIDES then return self:_LoadBrushSides() end
	if lump == LUMP_BRUSHES then return self:_LoadBrushes() end
	if lump == LUMP_EDGES then return self:_LoadEdges() end
	if lump == LUMP_SURFEDGES then return self:_LoadSurfEdges() end
	if lump == LUMP_FACES then return self:_LoadFaces() end
	if lump == LUMP_GAME_LUMP then return self:_LoadGameLumps() end

	ErrorNoHalt("UNKNOWN LUMP: " .. tostring(lump))

end

function meta:IsLoading()

	return self.loaders > 0

end

function meta:LoadLumps( lumps, cb_finished )

	if lumps == nil or #lumps == 0 then print("NO LUMPS TO LOAD") return end

	print("LOAD " .. #lumps .. " LUMPS")

	local function load()

		self.loaders = self.loaders + 1

		print("Loading: " .. self:GetName())
		for _, l in pairs( lumps ) do
			self:Load( l )
		end

		print("Converting Brushes")
		self:_ConvertBrushes()
		print("Done")

		self.loaders = math.max( self.loaders - 1, 0 )
		if type(cb_finished) == "function" then cb_finished() end

	end

	local t = task.New( load, 1 )
	function t:chunk( name, count ) Msg("LOADING: " .. string.upper(name) .. " : " .. count ) end
	function t:progress() Msg(".") end
	function t:chunkdone( name, count, tab ) Msg("DONE\n") end

end

_BSP_CACHE = _BSP_CACHE or {}
function Get( filename, path, nocache )

	local fpath = filename .. tostring(path)
	if _BSP_CACHE[fpath] and not nocache then return _BSP_CACHE[fpath] end

	local new = setmetatable({ loaders = 0 }, meta):Init( filename, path )

	if nocache then return new end

	_BSP_CACHE[fpath] = new
	return new

end

function GetCurrent(...)

	return Get( "maps/" .. game.GetMap() .. ".bsp", ... )

end

if SERVER then return end

local bsp = Get( "maps/" .. game.GetMap() .. ".bsp", nil, true )

if CLIENT then

	print("TEST LOAD GAMELUMPS")
	bsp:_LoadGameLumps()

end

--[[local function load()

	print("Loading: " .. bsp:GetName())
	bsp:_LoadTextureInfo()
	bsp:_LoadBrushes()
	bsp:_LoadFaces()

end

local t = task.New( load, 1 )
function t:chunk( name, count )
	Msg("LOADING: " .. string.upper(name) .. " : " .. count )
end

function t:progress()
	Msg(".")
end

function t:chunkdone( name, count, tab )
	Msg("DONE\n")
end]]