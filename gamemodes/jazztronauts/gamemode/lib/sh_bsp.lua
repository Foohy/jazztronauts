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

function meta:LumpIter( out, lump, func, reader, ... )

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

function meta:LoadHeader( reader )

	if self.header then return self.header end
	reader = reader or Reader( self )
	self.header = reader:Header()

end

function meta:LoadPlanes( reader )

	if self.planes then return self.planes end
	reader = reader or Reader( self )
	self:LumpIter( "planes", LUMP_PLANES, reader.Plane, reader )

end

function meta:LoadVerts( reader )

	if self.verts then return self.verts end
	reader = reader or Reader( self )
	self:LumpIter( "verts", LUMP_VERTEXES, reader.Vector, reader )

end

function meta:LoadTextureInfo( reader )

	if self.texinfo then return self.texinfo end
	reader = reader or Reader( self )

	local size = self:SeekLump( reader, LUMP_TEXDATA_STRING_DATA )
	local names = reader:TextureStringTable( size )
	self:LumpIter( "texdata", LUMP_TEXDATA, reader.TexData, reader, names, function(name) return name end )
	self:LumpIter( "texinfo", LUMP_TEXINFO, reader.TexInfo, reader, self.texdata )
	self.texdata = nil

	if self.brushsides then
		for _,v in pairs(self.brushsides) do
			if type( v.texinfo ) == "number" then
				v.texinfo = self.texinfo[ v.texinfo + 1 ]
			end
			task.Yield()
		end
	end

end

function meta:LoadBrushSides( reader )

	if self.brushsides then return self.brushsides end
	reader = reader or Reader( self )

	self:LoadPlanes( reader )
	self:LumpIter( "brushsides", LUMP_BRUSHSIDES, reader.BrushSide, reader, self.planes, self.texinfo )

end

function meta:LoadBrushes( reader )

	if self.brushes then return self.brushes end
	reader = reader or Reader( self )

	self:LoadBrushSides( reader )
	self:LumpIter( "brushes", LUMP_BRUSHES, reader.Brush, reader, self.brushsides )

end

function meta:LoadEdges( reader )

	if self.edges then return self.edges end
	reader = reader or Reader( self )

	self:LoadVerts( reader )
	self:LumpIter( "edges", LUMP_EDGES, reader.Edge, reader, self.verts )

end

function meta:LoadSurfEdges( reader )

	if self.surfedges then return self.surfedges end
	reader = reader or Reader( self )

	self:LoadEdges( reader )
	self:LumpIter( "surfedges", LUMP_SURFEDGES, reader.SurfEdge, reader, self.edges )

end

function meta:LoadFaces( reader )

	if self.surfedges then return self.surfedges end
	reader = reader or Reader( self )

	self:LoadPlanes( reader )
	self:LoadSurfEdges( reader )
	self:LumpIter( "faces", LUMP_FACES, reader.Face, reader, self.planes, self.surfedges )

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

	--Just make sure it's loaded ok?
	self:LoadHeader()

	return self

end

function meta:GetVersion()

	return self.header.version, self.header.revision

end

function meta:GetName()

	return self.filename:sub(6,-5)

end

local cache = {}
function Get( filename, path )

	local fpath = filename .. tostring(path)
	if cache[fpath] then return cache[fpath] end

	local new = setmetatable({}, meta):Init( filename, path )
	cache[fpath] = new
	return new

end

if SERVER then return end

local bsp = Get( "maps/" .. game.GetMap() .. ".bsp" )

local function load()

	print("Loading: " .. bsp:GetName())
	bsp:LoadTextureInfo()
	bsp:LoadBrushes()
	bsp:LoadFaces()

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
end