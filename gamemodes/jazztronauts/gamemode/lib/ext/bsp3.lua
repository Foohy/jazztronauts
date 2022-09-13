--[[
This file is a part of the Loaders repository:
https://github.com/ZakBlystone/loaders

BSP3: source-engine map parser:
loads a .bsp file and converts it into readable data.

Usage:
bsp3.LoadBSP( filename, requested_lumps, path )
returns an object containing raw data for the requested lumps and some accessor utility functions

MIT License

Copyright (c) 2022 ZakBlystone

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local BSP3_VERSION = 1

if bsp3 ~= nil and bsp3.VERSION > BSP3_VERSION then return end

module("bsp3", package.seeall)

VERSION = BSP3_VERSION

LUMP_ENTITIES                        = 0  --done
LUMP_PLANES                          = 1  --done
LUMP_TEXDATA                         = 2  --done
LUMP_VERTEXES                        = 3  --done
LUMP_VISIBILITY                      = 4  --done
LUMP_NODES                           = 5  --done
LUMP_TEXINFO                         = 6  --done
LUMP_FACES                           = 7  --done
LUMP_LIGHTING                        = 8  --done
LUMP_OCCLUSION                       = 9  --done
LUMP_LEAFS                           = 10 --done
LUMP_FACEIDS                         = 11 --done
LUMP_EDGES                           = 12 --done
LUMP_SURFEDGES                       = 13 --done
LUMP_MODELS                          = 14 --done
LUMP_WORLDLIGHTS                     = 15 --done
LUMP_LEAFFACES                       = 16 --done
LUMP_LEAFBRUSHES                     = 17 --done
LUMP_BRUSHES                         = 18 --done
LUMP_BRUSHSIDES                      = 19 --done
LUMP_AREAS                           = 20 --done
LUMP_AREAPORTALS                     = 21 --done
LUMP_UNUSED0                         = 22 --unused
LUMP_UNUSED1                         = 23 --unused
LUMP_UNUSED2                         = 24 --unused
LUMP_UNUSED3                         = 25 --unused
LUMP_DISPINFO                        = 26 --done
LUMP_ORIGINALFACES                   = 27 --done
LUMP_PHYSDISP                        = 28 --NYI
LUMP_PHYSCOLLIDE                     = 29 --done
LUMP_VERTNORMALS                     = 30 --done
LUMP_VERTNORMALINDICES               = 31 --done
LUMP_DISP_LIGHTMAP_ALPHAS            = 32 --done
LUMP_DISP_VERTS                      = 33 --done
LUMP_DISP_LIGHTMAP_SAMPLE_POSITIONS  = 34 --done
LUMP_GAME_LUMP                       = 35 --done
LUMP_LEAFWATERDATA                   = 36 --done
LUMP_PRIMITIVES                      = 37 --done
LUMP_PRIMVERTS                       = 38 --done
LUMP_PRIMINDICES                     = 39 --done
LUMP_PAKFILE                         = 40 --done
LUMP_CLIPPORTALVERTS                 = 41 --done
LUMP_CUBEMAPS                        = 42 --done
LUMP_TEXDATA_STRING_DATA             = 43 --done
LUMP_TEXDATA_STRING_TABLE            = 44 --done
LUMP_OVERLAYS                        = 45 --done
LUMP_LEAFMINDISTTOWATER              = 46 --done
LUMP_FACE_MACRO_TEXTURE_INFO         = 47 --done
LUMP_DISP_TRIS                       = 48 --done
LUMP_PHYSCOLLIDESURFACE              = 49 --DEPRECATED
LUMP_WATEROVERLAYS                   = 50 --done
LUMP_LEAF_AMBIENT_INDEX_HDR          = 51 --done
LUMP_LEAF_AMBIENT_INDEX              = 52 --done
LUMP_LIGHTING_HDR                    = 53 --done
LUMP_WORLDLIGHTS_HDR                 = 54 --done
LUMP_LEAF_AMBIENT_LIGHTING_HDR       = 55 --done
LUMP_LEAF_AMBIENT_LIGHTING           = 56 --done
LUMP_XZIPPAKFILE                     = 57 --DEPRECATED
LUMP_FACES_HDR                       = 58 --done
LUMP_MAP_FLAGS                       = 59 --done
LUMP_OVERLAY_FADES                   = 60 --done

VIS_PVS = 1
VIS_PAS = 2

local lump_names = {
    "ENTITIES",
    "PLANES",
    "TEXDATA",
    "VERTEXES",
    "VISIBILITY",
    "NODES",
    "TEXINFO",
    "FACES",
    "LIGHTING",
    "OCCLUSION",
    "LEAFS",
    "FACEIDS",
    "EDGES",
    "SURFEDGES",
    "MODELS",
    "WORLDLIGHTS",
    "LEAFFACES",
    "LEAFBRUSHES",
    "BRUSHES",
    "BRUSHSIDES",
    "AREAS",
    "AREAPORTALS",
    "UNUSED0",
    "UNUSED1",
    "UNUSED2",
    "UNUSED3",
    "DISPINFO",
    "ORIGINALFACES",
    "PHYSDISP",
    "PHYSCOLLIDE",
    "VERTNORMALS",
    "VERTNORMALINDICES",
    "DISP_LIGHTMAP_ALPHAS",
    "DISP_VERTS",
    "DISP_LIGHTMAP_SAMPLE_POSITIONS",
    "GAME_LUMP",
    "LEAFWATERDATA",
    "PRIMITIVES",
    "PRIMVERTS",
    "PRIMINDICES",
    "PAKFILE",
    "CLIPPORTALVERTS",
    "CUBEMAPS",
    "TEXDATA_STRING_DATA",
    "TEXDATA_STRING_TABLE",
    "OVERLAYS",
    "LEAFMINDISTTOWATER",
    "FACE_MACRO_TEXTURE_INFO",
    "DISP_TRIS",
    "PHYSCOLLIDESURFACE",
    "WATEROVERLAYS",
    "LEAF_AMBIENT_INDEX_HDR",
    "LEAF_AMBIENT_INDEX",
    "LIGHTING_HDR",
    "WORLDLIGHTS_HDR",
    "LEAF_AMBIENT_LIGHTING_HDR",
    "LEAF_AMBIENT_LIGHTING",
    "XZIPPAKFILE",
    "FACES_HDR",
    "MAP_FLAGS",
    "OVERLAY_FADES",
}

local lump_size = 16
local header_size = 12 + lump_size * 64
local str_byte = string.byte
local str_sub = string.sub
local str_find = string.find
local str_char = string.char
local lshift, rshift, band, bor, bnot = bit.lshift, bit.rshift, bit.band, bit.bor, bit.bnot
local m_ptr = 1
local m_data = nil

local function begin_data( data )
    m_data, m_ptr = data, 1
end

local function end_data()
    m_data = nil
end

local function seek_data( pos )
    m_ptr = pos + 1
end

local function tell_data()
    return m_ptr - 1
end

local function float32()
    local a,b,c,d = str_byte(m_data, m_ptr, m_ptr + 4)
    m_ptr = m_ptr + 4
    local fr = bor( lshift( band(c, 0x7F), 16), lshift(b, 8), a )
    local exp = bor( band( d, 0x7F ) * 2, rshift( c, 7 ) )
    if exp == 0 then return 0 end

    local s = d > 127 and -1 or 1
    local n = math.ldexp( ( math.ldexp(fr, -23) + 1 ) * s, exp - 127 )
    return n
end

local function uint32()
    local a,b,c,d = str_byte(m_data, m_ptr, m_ptr + 4)
    m_ptr = m_ptr + 4
    local n = bor( lshift(d,24), lshift(c,16), lshift(b, 8), a )
    if n < 0 then n = (0x1p32) - 1 - bnot(n) end
    return n
end

local function uint16()
    local a,b = str_byte(m_data, m_ptr, m_ptr + 2)
    m_ptr = m_ptr + 2
    return bor( lshift(b, 8), a )
end

local function uint8()
    local a = str_byte(m_data, m_ptr, m_ptr)
    m_ptr = m_ptr + 1
    return a
end

local function int32()
    local a,b,c,d = str_byte(m_data, m_ptr, m_ptr + 4)
    m_ptr = m_ptr + 4
    local n = bor( lshift(d,24), lshift(c,16), lshift(b, 8), a )
    return n
end

local function int16()
    local a,b = str_byte(m_data, m_ptr, m_ptr + 2)
    m_ptr = m_ptr + 2
    local n = bor( lshift(b, 8), a )
    if band( b, 0x80 ) ~= 0 then n = -(0x1p16) + n end
    return n
end

local function int8()
    local a = str_byte(m_data, m_ptr, m_ptr)
    m_ptr = m_ptr + 1
    if band( a, 0x80 ) ~= 0 then a = -(0x100) + a end
    return a
end

local function char()
    local a = str_sub(m_data, m_ptr, m_ptr)
    m_ptr = m_ptr + 1
    return a
end

local function charstr(n)
    local a = str_sub(m_data, m_ptr, m_ptr + n - 1)
    m_ptr = m_ptr + n
    return a
end

local function vector32()
    return Vector( float32(), float32(), float32() )
end

local function angle32()
    return Angle( float32(), float32(), float32() )
end

local function array_of( f, count )

    local t = {}
    for i=1, count do
        t[#t+1] = f()
    end
    return t

end

local function vcharstr(n)

    local str = charstr(n)
    local k = str_find(str, "\0", 0, true)
    if k then str = str_sub(str, 1, k-1) end
    return str

end

local function lump_array( func, element_size )

    return function( lump )

        local res = {}
        local count = lump.length / element_size
        assert(math.floor(count) == count, "Array element size not multiple of array data: " .. lump.length .. "/" .. element_size)

        for i=1, count do
            res[#res+1] = func( lump )
        end
        return res

    end

end

local function str_int32(x)
    return str_char( band(x,0xFF), band(rshift(x, 8),0xFF), band(rshift(x, 16),0xFF), rshift(x, 24) )
end

local function ColorRGBExp32()
    return { uint8(), uint8(), uint8(), int8(), }
end

local function CompressedLightCube()
    return array_of( ColorRGBExp32, 6 )
end

local function LeafAmbientLighting()
    return {
        cube = CompressedLightCube(),
        x = uint8(),
        y = uint8(),
        z = uint8(),
        pad = uint8(),
    }
end

local lump_handlers = {}


local function lines(str)
    local setinel = 0
    return function()
        local k, b = str_find(str, "\n", setinel+1)
        if not k then return end
        b, setinel = setinel, k
        return str_sub(str, b+1, k-1)
    end
end

-- LUMP DATA HANDLERS
lump_handlers[LUMP_ENTITIES] = function()

    local match_rule = [[%"([^%"]+)%"%s+%"([^%"]+)%"]]
    local entities = {}
    local current = {}
    for x in lines(m_data) do
        if x == "{" then current.id = #entities+1 continue end
        if x == "}" then
            entities[#entities+1] = current
            current = {}
            continue
        end
        if not current.id then continue end
        local key, value = x:match(match_rule)
        if key == nil or value == nil then continue end
        current[#current+1] = {key = key, value = value}
    end

    return entities

end

lump_handlers[LUMP_VERTEXES] = lump_array( function()

    return vector32()

end, 12 )

lump_handlers[LUMP_PLANES] = lump_array( function()

    local p = {
        normal = vector32(),
        dist = float32(),
        type = int32(),
    }
    return p

end, 20 )

lump_handlers[LUMP_TEXDATA] = lump_array( function()

    return {
        reflectivity = vector32(),
        nameStringTableID = int32(),
        width = int32(),
        height = int32(),
        view_width = int32(),
        view_height = int32(),
    }

end, 32 )

lump_handlers[LUMP_TEXDATA_STRING_DATA] = function( lump )

    local str = ""
    local names = {}
    while tell_data() < lump.length do

        local ch = char()
        if ch == '\0' then
            names[#names+1] = str
            str = ""
        else
            str = str .. ch
        end

    end
    return names

end

lump_handlers[LUMP_TEXDATA_STRING_TABLE] = lump_array( function()

    return uint32()

end, 4 )

lump_handlers[LUMP_CUBEMAPS] = lump_array( function()

    return {
        origin = Vector( int32(), int32(), int32() ),
        size = uint8(),
        padding = array_of(uint8, 3),
    }

end, 16 )

lump_handlers[LUMP_OVERLAYS] = lump_array( function()

    return {
        Id = int32(),
        TexInfo = int16(),
        FaceCountAndRenderOrder = uint16(),
        OFaces = array_of( int32, 64 ),
        U = array_of( float32, 2 ),
        V = array_of( float32, 2 ),
        UVPoints = array_of( vector32, 4 ),
        Origin = vector32(),
        BasisNormal = vector32(),
    }

end, 352 )

lump_handlers[LUMP_WATEROVERLAYS] = lump_array( function()

    return {
        nId = int32(),
        nTexInfo = int16(),
        m_nFaceCountAndRenderOrder = uint16(),
        aFaces = array_of( int32(), 256 ),
        flU = array_of( float32, 2 ),
        flV = array_of( float32, 2 ),
        vecUVPoints = array_of( vector32, 4 ),
        vecOrigin = vector32(),
        vecBasisNormal = vector32(),
    }

end, 1120 )

lump_handlers[LUMP_LEAFMINDISTTOWATER] = lump_array( uint16, 2 )
lump_handlers[LUMP_FACE_MACRO_TEXTURE_INFO] = lump_array( uint16, 2 )

-- Don't unpack lightmaps, slow to load + lots of memory overhead (1 byte -> 8 bytes )
-- Instead index directly into the string
lump_handlers[LUMP_LIGHTING] = function() return m_data end --[[lump_array( function()

    return { uint8(), uint8(), uint8(), int8() }

end, 4 )]]

lump_handlers[LUMP_LIGHTING_HDR] = lump_handlers[LUMP_LIGHTING]

lump_handlers[LUMP_AREAS] = lump_array( function()

    return {
        numareaportals = int32(),
        firstareaportal = int32(),
    }

end, 8 )

lump_handlers[LUMP_AREAPORTALS] = lump_array( function()

    return {
        m_PortalKey = uint16(),
        otherarea = uint16(),
        m_FirstClipPortalVert = uint16(),
        m_nClipPortalVerts = uint16(),
        planenum = int32(),
    }

end, 12 )

lump_handlers[LUMP_EDGES] = lump_array( function()

    return {
        uint16(),
        uint16(),
    }

end, 4 )

lump_handlers[LUMP_SURFEDGES] = lump_array( int32, 4 )
lump_handlers[LUMP_LEAFFACES] = lump_array( int16, 2 )
lump_handlers[LUMP_LEAFBRUSHES] = lump_array( int16, 2 )
lump_handlers[LUMP_FACEIDS] = lump_array( uint16, 2 )

local faces = lump_array( function()

    return {
        planenum = uint16(),
        side = uint8(),
        onNode = uint8(),
        firstedge = int32(),
        numedges = int16(),
        texinfo = int16(),
        dispinfo = int16(),
        surfaceFogVolumeID = int16(),
        styles = { uint8(),uint8(),uint8(),uint8() },
        lightofs = int32(),
        area = float32(),
        lightmaptextureminsinluxels = { int32(), int32() },
        lightmaptexturesizeinluxels = { int32(), int32() },
        origFace = int32(),
        numPrims = uint16(),
        firstPrimID = uint16(),
        smoothingGroups = uint32(),
    }

end, 56 )

lump_handlers[LUMP_FACES] = faces
lump_handlers[LUMP_ORIGINALFACES] = faces
lump_handlers[LUMP_FACES_HDR] = faces
lump_handlers[LUMP_VERTNORMALS] = lump_array( vector32, 12 )
lump_handlers[LUMP_VERTNORMALINDICES] = lump_array( uint16, 2 )

lump_handlers[LUMP_PHYSCOLLIDE] = function( lump )

    local solids = {}
    local numeric_keys = {
        ["contents"] = true,
        ["index"] = true,
        ["damping"] = true,
        ["mass"] = true,
        ["volume"] = true,
    }

    for i=1, 100 do

        local modelIndex = int32()
        local dataSize = int32()
        local keydataSize = int32()
        local solidCount = int32()

        if dataSize > 0 then

            local ptr = tell_data() + 1
            local vcollide = str_sub( m_data, ptr, ptr + dataSize )
            local keydata = str_sub( m_data, ptr + dataSize, ptr + dataSize + keydataSize )

            local match_kv = [[%"([^%"]+)%"%s+%"([^%"]+)%"]]
            local match_header = [[(%w+) {]]
            local segments = {}
            local current = nil
            for x in lines(keydata) do
                local h = x:match(match_header)
                if h then
                    current = {
                        type = h,
                        values = {},
                    }
                elseif x == "}" then
                    segments[#segments+1] = current
                    current = nil
                elseif current ~= nil then
                    local key, value = x:match(match_kv)
                    if numeric_keys[key] then value = tonumber(value) end
                    if key == "currentvelocity" then value = Vector(value) end

                    current.values[key] = value
                end
            end

            solids[#solids+1] = {
                data = segments,
                vcollide = vcollide,
                count = solidCount,
            }

        end

        seek_data( tell_data() + dataSize + keydataSize )

        if dataSize <= 0 or tell_data() >= lump.length then break end

    end

    return solids

end

lump_handlers[LUMP_OCCLUSION] = function()

    local count = int32()
    local occluder_data = {}
    for i=1, count do
        occluder_data[#occluder_data+1] = {
            flags = int32(),
            firstpoly = int32(),
            polycount = int32(),
            mins = vector32(),
            maxs = vector32(),
            area = int32(),
        }
    end
    local polyDataCount = int32()
    local poly_data = {}
    for i=1, polyDataCount do
        poly_data[#poly_data+1] = {
            firstvertexindex = int32(),
            vertexcount = int32(),
            planenum = int32(),
        }
    end
    local vertexCount = int32()
    local vertexIndicies = {}
    for i=1, vertexCount do
        vertexIndicies[#vertexIndicies+1] = int32()
    end

    return {
        occluders = occluder_data,
        polygons = poly_data,
        vertexIndicies = vertexIndicies,
    }   

end

lump_handlers[LUMP_NODES] = lump_array( function()

    return {
        planenum = int32(),
        children = { int32(), int32() },
        mins = Vector( int16(), int16(), int16() ),
        maxs = Vector( int16(), int16(), int16() ),
        firstface = uint16(),
        numfaces = uint16(),
        area = int16(),
        padding = int16(),
    }

end, 32 )

lump_handlers[LUMP_TEXINFO] = lump_array( function()

    local tmeta = {}

    local __dot = FindMetaTable("Vector").Dot
    function tmeta:GetUV(p)
        return __dot(p, self.uAxis) + self.uOffset, __dot(p, self.vAxis) + self.vOffset
    end

    tmeta.__index = tmeta

    local function TexMatrix()
        return setmetatable({
            uAxis = vector32(),
            uOffset = float32(),
            vAxis = vector32(),
            vOffset = float32(),
        }, tmeta)
    end

    return {
        textureVecs = TexMatrix(),
        lightmapVecs = TexMatrix(),
        flags = int32(),
        texdata = int32(),
    }

end, 72 )

local leaf_v0_array = lump_array( function()

    local function light_cube()
        local t = {}
        for i=1,6 do
            t[#t+1] = { r = uint8(), g = uint8(), b = uint8(), exponent = int8(), }
        end
        return t
    end

    return {
        contents = int32(),
        cluster = int16(),
        areaflags = int16(),
        mins = Vector( int16(), int16(), int16() ),
        maxs = Vector( int16(), int16(), int16() ),
        firstleafface = uint16(),
        numleaffaces = uint16(),
        firstleafbrush = uint16(),
        numleafbrushes = uint16(),
        leafWaterDataID = int16(),
        m_AmbientLighting = light_cube(),
        padding = int16(),
    }

end, 56 )

local leaf_array = lump_array( function()

    return {
        contents = int32(),
        cluster = int16(),
        areaflags = int16(),
        mins = Vector( int16(), int16(), int16() ),
        maxs = Vector( int16(), int16(), int16() ),
        firstleafface = uint16(),
        numleaffaces = uint16(),
        firstleafbrush = uint16(),
        numleafbrushes = uint16(),
        leafWaterDataID = int16(),
        padding = int16(),
    }

end, 32 )

lump_handlers[LUMP_LEAFS] = function( lump )

    local ver = lump.version
    if ver == 0 then return leaf_v0_array(lump) end
    return leaf_array(lump)

end

lump_handlers[LUMP_MODELS] = lump_array( function()

    return {
        mins = vector32(),
        maxs = vector32(),
        origin = vector32(),
        headnode = int32(),
        firstface = int32(),
        numfaces = int32(),
    }

end, 48 )

lump_handlers[LUMP_WORLDLIGHTS] = lump_array( function()

    return {
        origin = vector32(),
        intensity = vector32(),
        normal = vector32(),
        cluster = int32(),
        type = int32(),
        style = int32(),
        stopdot = float32(),
        stopdot2 = float32(),
        exponent = float32(),
        radius = float32(),
        constant_attn = float32(),
        linear_attn = float32(),
        quadratic_attn = float32(),
        flags = int32(),
        texinfo = int32(),
        owner = int32(),
    }

end, 88 )

lump_handlers[LUMP_WORLDLIGHTS_HDR] = lump_handlers[LUMP_WORLDLIGHTS]

lump_handlers[LUMP_BRUSHSIDES] = lump_array( function()

    return {
        planenum = uint16(),
        texinfo = int16(),
        dispinfo = int16(),
        bevel = int16(),
    }

end, 8 )

lump_handlers[LUMP_BRUSHES] = lump_array( function()

    return {
        firstside = int32(),
        numsides = int32(),
        contents = int32(),
    }

end, 12 )

lump_handlers[LUMP_DISPINFO] = lump_array( function()

    local function CDispSubNeighbor() --6 bytes
        return {
            neighbor = uint16(),
            neighborOrientation = uint8(),
            span = uint8(), --NeighborSpan
            neighborSpan = uint8(), --NeighborSpan
            padding = uint8(),
        }
    end

    local function CDispNeighbor() --12 bytes
        return {
            CDispSubNeighbor(),
            CDispSubNeighbor(),
        }
    end

    local function CDispCornerNeighbors() --10 bytes
        return {
            neighbors = array_of(uint16, 4),
            count = uint8(),
            padding = uint8(),
        }
    end

    return {
        start = vector32(),
        vertStart = int32(),
        triStart = int32(),
        power = int32(),
        minTess = int32(),
        smoothingAngle = float32(),
        contents = int32(),
        faceID = uint16(),
        unknown = uint16(),
        lmAlphaStart = int32(),
        lmSampleStart = int32(), -- 48
        edgeNeighbors = array_of(CDispNeighbor, 4),
        cornerNeighbors = array_of(CDispCornerNeighbors, 4),
        allowedVerts = array_of(uint32, 10),
    }

end, 176 )

-- Array of bytes, index into string if needed
lump_handlers[LUMP_DISP_LIGHTMAP_ALPHAS] = function() return m_data end
lump_handlers[LUMP_DISP_LIGHTMAP_SAMPLE_POSITIONS] = function() return m_data end
lump_handlers[LUMP_DISP_VERTS] = lump_array( function()

    return {
        vec = vector32(),
        dist = float32(),
        alpha = float32(),
    }

end, 20 )

lump_handlers[LUMP_DISP_TRIS] = lump_array( function()

    return uint16()

end, 2 )

local prop_lump_handlers = {}
prop_lump_handlers[4] = function()

    return {
        origin = vector32(),
        angles = angle32(),
        proptype = uint16(),
        firstleaf = uint16(),
        leafcount = uint16(),
        solid = uint8(),
        flags = uint8(),
        skin = int32(),
        fademindist = float32(),
        fademaxdist = float32(),
        lightingorigin = vector32(),
    }

end

prop_lump_handlers[5] = function()

    local t = prop_lump_handlers[4]()
    t.forcedfadescale = float32()
    return t

end

prop_lump_handlers[6] = function()

    local t = prop_lump_handlers[4]()
    t.forcedfadescale = float32()
    t.mindxlevel = uint16()
    t.maxdxlevel = uint16()
    return t

end

prop_lump_handlers[7] = function()

    local t = prop_lump_handlers[4]()
    t.forcedfadescale = float32()
    t.mindxlevel = uint16()
    t.maxdxlevel = uint16()
    t.color = int32()
    return t

end

prop_lump_handlers[8] = function()

    local t = prop_lump_handlers[4]()
    t.forcedfadescale = float32()
    t.mincpulevel = uint8()
    t.maxcpulevel = uint8()
    t.mingpulevel = uint8()
    t.maxgpulevel = uint8()
    t.color = int32()
    return t

end

prop_lump_handlers[9] = prop_lump_handlers[8]
prop_lump_handlers[10] = function()

    local t = prop_lump_handlers[4]()
    t.forcedfadescale = float32()
    t.mincpulevel = uint8()
    t.maxcpulevel = uint8()
    t.mingpulevel = uint8()
    t.maxgpulevel = uint8()
    t.color = int32()
    float32()
    return t

end

lump_handlers[LUMP_GAME_LUMP] = function(lump, params)

    local FLAG_COMPRESSED = 1

    local count = int32()
    local lumps = {}
    for i=1, count do
        local id = vcharstr(4)
        lumps[id] = {
            flags = uint16(),
            version = uint16(),
            fileofs = int32() - lump.offset,
            filelen = int32(),
        }
    end

    local ilump = 0
    for k,v in pairs(lumps) do
        if bit.band(v.flags, FLAG_COMPRESSED) ~= 0 then
            seek_data( v.fileofs )
            local sig = vcharstr(4)
            local actualSize = uint32()
            local lzmaSize = uint32()
            local props = array_of(uint8, 5)
            local str_data = charstr( v.filelen )
            local prop_bytes = str_char( unpack(props) )
            local size_bytes = str_int32( actualSize )

            -- Re-arrange the data a bit for util.Decompress
            str_data = prop_bytes .. size_bytes .. "\0\0\0\0" .. str_data
            str_data = util.Decompress(str_data)
            if str_data == nil then print("FAILED TO DECOMPRESS GAME LUMP: " .. actualSize) end
            v.data = str_data
            v.fileofs = 0
            v.filelen = size_bytes
        else
            v.data = m_data
        end
        ilump = ilump + 1
    end

    end_data()


    local props = {}
    local sprites = {}
    local detail_objects = {}
    local detail_models = {}

    local lmp = lumps["prps"]
    if lmp then
        local structure = prop_lump_handlers[lmp.version]
        if not structure then error("Unable to load static prop lump for version: " .. lmp.version) end
        begin_data( lmp.data )
        seek_data( lmp.fileofs )

        local num_entries = int32()
        local dict = {}
        for i=1, num_entries do dict[#dict+1] = vcharstr(128) end

        local num_entries = int32()
        local leaf_dict = {}
        for i=1, num_entries do leaf_dict[#leaf_dict+1] = uint16() end

        local count = int32()
        for i=1, count do
            local prop = structure()
            prop.model = dict[ prop.proptype + 1 ]
            prop.leafs = {}
            prop.id = i
            props[#props+1] = prop

            for j=1, prop.leafcount do
                local id = leaf_dict[ prop.firstleaf + j ]
                prop.leafs[#prop.leafs+1] = id
            end
        end

        end_data()
    end

    local lmp = lumps["prpd"]
    if lmp and params["load_detail_props"] then
        begin_data( lmp.data )
        seek_data( lmp.fileofs )

        local num_entries = int32()
        local dict = {}
        for i=1, num_entries do dict[#dict+1] = vcharstr(128) end

        detail_models = dict

        local sprites = {}
        local num_entries = int32()
        for i=1, num_entries do 
            sprites[#sprites+1] = {
                m_UL = { float32(), float32() },
                m_LR = { float32(), float32() },
                m_TexUL = { float32(), float32() },
                m_TexLR = { float32(), float32() },
            }
        end

        local detail_objects = {}
        local num_entries = int32()
        for i=1, num_entries do 
            detail_objects[#detail_objects+1] = {
                m_Origin = vector32(),
                m_Angles = angle32(),
                m_DetailModel = uint16(),
                m_Leaf = uint16(),
                m_Lighting = ColorRGBExp32(),
                m_LightStyles = uint32(),
                m_LightStyleCount = uint8(),
                m_SwayAmount = uint8(),
                m_ShapeAngle = uint8(),
                m_ShapeSize = uint8(),
                m_Orientation = uint8(),
                m_Padding2 = array_of(uint8, 3),
                m_Type = uint8(),
                m_Padding3 = array_of(uint8, 3),
                m_flScale = float32(),
            }
        end

        end_data()
    end

    return {
        props = props,
        sprites = sprites,
        detail_objects = detail_objects,
        detail_models = detail_models,
    }

end

lump_handlers[LUMP_LEAFWATERDATA] = lump_array( function()

    return {
        surfaceZ = float32(),
        minZ = float32(),
        surfaceTexInfoID = uint16(),
        padding = uint16(),
    }

end, 12 )

lump_handlers[LUMP_PRIMITIVES] = lump_array( function()

    return {
        type = uint8(),
        padding = uint8(),
        firstIndex = uint16(),
        indexCount = uint16(),
        firstVert = uint16(),
        vertCount = uint16(),
    }

end, 10 )

lump_handlers[LUMP_PRIMVERTS] = lump_array( vector32, 12 )
lump_handlers[LUMP_PRIMINDICES] = lump_array( uint16, 2 )
lump_handlers[LUMP_CLIPPORTALVERTS] = lump_array( vector32, 12 )
lump_handlers[LUMP_PAKFILE] = function(lump)

    local file_entries = {}
    local file_names = {}

    while true do

        local p,k = char(), char()
        local op = uint16()
        assert(p == "P" and k == "K")

        if op == 0x0403 then
            local ver = uint16()
            local flags = uint16()
            local method = uint16()
            local modified = uint32()
            local crc = uint32()
            local compressed = uint32()
            local uncompressed = uint32()
            local namelen = uint16()
            local extrafieldlen = uint16()
            assert(extrafieldlen == 0)
            --assert(compressed == uncompressed)

            local name = vcharstr( namelen )
            local data_ofs = tell_data()
            seek_data( data_ofs + compressed )

            file_names[#file_names+1] = name
            file_entries[name] = {
                offset = data_ofs,
                size = compressed,
                uncompressedSize = uncompressed,
                isCompressed = compressed ~= uncompressed,
            }

        else
            break
        end

    end

    return {
        file_names = file_names,
        file_entries = file_entries,
        data = m_data,
    }

end

lump_handlers[LUMP_VISIBILITY] = function()

    local num_clusters = int32()
    local num_cluster_bytes = rshift(num_clusters + 7, 3)
    local pvs, pas = {}, {}
    local vis = {pvs, pas}
    for i=1, num_clusters do
        pvs[i] = int32()
        pas[i] = int32()
    end

    local data = m_data
    local cluster_bytes = {}
    local function cluster_vis( cluster, visType )

        local num = 0
        local ofs = vis[visType][cluster+1]
        if ofs == nil then for i=1, num_cluster_bytes do cluster_bytes[i] = 0xFF end return cluster_bytes end
        begin_data( data )
        seek_data( ofs )

        local out = {}
        local d, c = uint8(), 0
        repeat
            if d ~= 0 then
                cluster_bytes[num+1] = d
                num = num + 1
                d = uint8()
            else
                c, d = uint8(), uint8()
                if num + c > num_cluster_bytes then
                    c = num_cluster_bytes - num
                    print("Vis decompression overrun")
                end
                while c > 0 do
                    cluster_bytes[num+1] = 0
                    num = num + 1
                    c = c - 1
                end
            end
        until num >= num_cluster_bytes
        end_data()

        return cluster_bytes

    end

    return cluster_vis

end

lump_handlers[LUMP_LEAF_AMBIENT_LIGHTING] = lump_array( LeafAmbientLighting, 28 )
lump_handlers[LUMP_LEAF_AMBIENT_LIGHTING_HDR] = lump_handlers[LUMP_LEAF_AMBIENT_LIGHTING]
lump_handlers[LUMP_LEAF_AMBIENT_INDEX] = lump_array( function()

    return {
        ambientSampleCount = uint16(),
        firstAmbientSample = uint16(),
    }
    
end, 4 )

lump_handlers[LUMP_LEAF_AMBIENT_INDEX_HDR] = lump_handlers[LUMP_LEAF_AMBIENT_INDEX]
lump_handlers[LUMP_MAP_FLAGS] = uint32
lump_handlers[LUMP_OVERLAY_FADES] = lump_array( function()

    return {
        flFadeDistMinSq = float32(),
        flFadeDistMaxSq = float32(),
    }

end, 8 )

local function loadBSPData( handle, requested, params )

    local header = { lumps = {}, }
    local lump_data = {}
    local data = handle:Read(header_size)
    begin_data(data)

    header.ident = int32()
    header.version = int32()

    params = params or {}

    for i=0, 63 do
        header.lumps[i] = {
            offset = int32(),
            length = int32(),
            version = int32(),
            uncompressedSize = int32(),
        }
    end

    end_data()

    for _, lump_id in ipairs(requested) do

        local lump = header.lumps[lump_id]
        print("LOAD: " .. lump_names[lump_id + 1] .. " : " .. lump.length .. " bytes")

        if lump.length > 0 then
            handle:Seek(lump.offset)
            lump_data[lump_id] = handle:Read(lump.length)
        end

        if lump.uncompressedSize ~= 0 then
            begin_data( lump_data[lump_id] )
            local sig = vcharstr(4)
            local actualSize = uint32()
            local lzmaSize = uint32()
            local props = array_of(uint8, 5)
            end_data()

            assert(sig == "LZMA", "Lump is compressed, but is not valid LZMA")
            assert(actualSize == lump.uncompressedSize, "Compressed size does not match")

            print("DECOMPRESS: " .. lump_names[lump_id + 1] .. " to " .. actualSize .. " bytes")

            local str = lump_data[lump_id]
            local prop_bytes = str_char( unpack(props) )
            local size_bytes = str_int32( actualSize )

            -- Re-arrange the data a bit for util.Decompress
            str = prop_bytes .. size_bytes .. "\0\0\0\0" .. str_sub(str, 18, -1)
            str = util.Decompress( str, actualSize )

            lump_data[lump_id] = str

            if lump_data[lump_id] == nil then
                print("FAILED TO DECOMPRESS")
                lump.length = 0
            else
                lump.length = lump.uncompressedSize
            end
        end

    end

    for _, lump_id in ipairs(requested) do

        local handler = lump_handlers[lump_id]
        local lump = header.lumps[lump_id]
        if lump.length == 0 then continue end
        print("PARSE: " .. lump_names[lump_id + 1])

        if handler then
            begin_data( lump_data[lump_id] )
            lump_data[lump_id] = handler(lump, params)
            end_data()
        else
            error("Unsupported lump: " .. lump_names[lump_id + 1])
        end

    end

    return lump_data

end

local function TriangleNormal( i0, i1, i2, positions )

    local p0,p1,p2 = positions[i0], positions[i1], positions[i2]
    local n = (p2 - p1):Cross(p2 - p0)
    n:Normalize()
    return n

end

local function LinkBSPData( data )

    for k, plane in ipairs( data[LUMP_PLANES] or {} ) do
        plane.back = data[LUMP_PLANES][ bit.bxor(k-1, 1) + 1 ]
    end

    local verts = data[LUMP_VERTEXES]
    for k, edge in pairs( ( verts and data[LUMP_EDGES] ) or {} ) do
        edge[1] = verts[edge[1]+1]
        edge[2] = verts[edge[2]+1]
    end

    local edges = data[LUMP_EDGES]
    for k, surfedge in ipairs( ( edges and data[LUMP_SURFEDGES] ) or {} ) do
        data[LUMP_SURFEDGES][k] = surfedge > 0 and edges[surfedge+1] or { edges[-surfedge+1][2], edges[-surfedge+1][1] }
    end

    for k, texdata in ipairs( data[LUMP_TEXDATA] or {} ) do
        texdata.material = data[LUMP_TEXDATA_STRING_DATA] and data[LUMP_TEXDATA_STRING_DATA][texdata.nameStringTableID+1] or ""
        texdata.nameStringTableID = nil
    end

    for k, texinfo in ipairs( data[LUMP_TEXINFO] or {} ) do
        texinfo.id = k
        texinfo.texdata = data[LUMP_TEXDATA] and data[LUMP_TEXDATA][texinfo.texdata+1]
    end

    local facelist = data[LUMP_FACES] or data[LUMP_ORIGINALFACES]

    local nodes = data[LUMP_NODES] or {}
    local leafs = data[LUMP_LEAFS] or {}
    local total = #(data[LUMP_NODES] or {})
    for k, node in ipairs( nodes ) do
        node.id = k
        node.plane = data[LUMP_PLANES] and data[LUMP_PLANES][node.planenum+1]
        node.planenum = nil

        for i = 1, 2 do
            node.children[i] = node.children[i] >= 0 and nodes[ node.children[i]+1 ] or leafs[ -(node.children[i]+1)+1 ]
        end

        node.faces = {}
        for i = node.firstface+1, node.firstface + node.numfaces do
            node.faces[#node.faces+1] = (facelist and facelist[i])
        end

        node.is_leaf = false
        node.is_node = true
    end

    for k, side in ipairs( data[LUMP_BRUSHSIDES] or {} ) do
        side.id = k
        side.plane = data[LUMP_PLANES] and data[LUMP_PLANES][side.planenum+1]
        side.planenum = nil

        side.texinfo = data[LUMP_TEXINFO] and data[LUMP_TEXINFO][side.texinfo+1]
        side.dispinfo = data[LUMP_DISPINFO] and data[LUMP_DISPINFO][side.dispinfo+1]
    end

    for k, brush in ipairs( ( data[LUMP_BRUSHSIDES] and data[LUMP_BRUSHES] ) or {} ) do
        brush.id = k
        brush.sides = {}
        for i = brush.firstside+1, brush.firstside + brush.numsides do
            brush.sides[#brush.sides+1] = data[LUMP_BRUSHSIDES][i]
        end
    end

    for k, leafface in ipairs( data[LUMP_LEAFFACES] or {} ) do
        data[LUMP_LEAFFACES][k] = facelist and facelist[leafface+1]
    end

    for k, leafbrush in ipairs( data[LUMP_LEAFBRUSHES] or {} ) do
        data[LUMP_LEAFBRUSHES][k] = data[LUMP_BRUSHES] and data[LUMP_BRUSHES][leafbrush+1]
    end

    local num_clusters = 0
    local cluster_leafs = {}
    local ambient_index = data[LUMP_LEAF_AMBIENT_INDEX_HDR] or data[LUMP_LEAF_AMBIENT_INDEX] or {}
    local ambient_samples = data[LUMP_LEAF_AMBIENT_LIGHTING_HDR] or data[LUMP_LEAF_AMBIENT_LIGHTING] or {}
    for k, leaf in ipairs( data[LUMP_LEAFS] or {} ) do
        leaf.id = k
        leaf.faces = {}
        for i = leaf.firstleafface+1, leaf.firstleafface + leaf.numleaffaces do
            leaf.faces[#leaf.faces+1] = ( data[LUMP_LEAFFACES] and data[LUMP_LEAFFACES][i] )
        end

        leaf.ambient = ambient_index[k]
        leaf.brushes = {}
        for i = leaf.firstleafbrush+1, leaf.firstleafbrush + leaf.numleafbrushes do
            leaf.brushes[#leaf.brushes+1] = ( data[LUMP_LEAFBRUSHES] and data[LUMP_LEAFBRUSHES][i] )
        end

        if leaf.ambient then
            for i = leaf.ambient.firstAmbientSample+1, leaf.ambient.firstAmbientSample + leaf.ambient.ambientSampleCount do
                local sample = ambient_samples[i]
                sample.pos = Vector(
                    leaf.mins.x * (1 - sample.x/255) + leaf.maxs.x * (sample.x/255),
                    leaf.mins.y * (1 - sample.y/255) + leaf.maxs.y * (sample.y/255),
                    leaf.mins.z * (1 - sample.z/255) + leaf.maxs.z * (sample.z/255)
                )
            end
        end

        leaf.has_detail_brushes = false
        for k,v in ipairs( leaf.brushes ) do
            if band( v.contents, CONTENTS_DETAIL ) ~= 0 then
                leaf.has_detail_brushes = true
            end
        end

        if leaf.cluster >= num_clusters then
            num_clusters = leaf.cluster + 1
        end

        cluster_leafs[leaf.cluster] = cluster_leafs[leaf.cluster] or {}
        local arr = cluster_leafs[leaf.cluster]
        arr[#arr+1] = leaf

        leaf.is_leaf = true
        leaf.is_node = false
    end

    local ltable = {}
    if data[LUMP_FACES] then ltable[#ltable+1] = data[LUMP_FACES] end
    if data[LUMP_ORIGINALFACES] then ltable[#ltable+1] = data[LUMP_ORIGINALFACES] end
    for _, lump in ipairs( ltable ) do
        for k, face in ipairs( lump ) do
            face.id = k
            face.plane = data[LUMP_PLANES] and data[LUMP_PLANES][face.planenum+1]
            face.planenum = nil
            face.edges = {}
            for i = face.firstedge+1, face.firstedge + face.numedges do
                face.edges[#face.edges+1] = ( data[LUMP_SURFEDGES] and data[LUMP_SURFEDGES][i] )
            end

            face.texinfo = data[LUMP_TEXINFO] and data[LUMP_TEXINFO][face.texinfo+1]
            face.dispinfo = data[LUMP_DISPINFO] and data[LUMP_DISPINFO][face.dispinfo+1]
            face.origFace = data[LUMP_ORIGINALFACES] and data[LUMP_ORIGINALFACES][face.origFace+1]
            face.primitives = {}
            for i = face.firstPrimID+1, face.firstPrimID + face.numPrims do
                face.prims = face.prims or {}
                face.prims[#face.prims+1] = ( data[LUMP_PRIMITIVES] and data[LUMP_PRIMITIVES][i] )
            end
        end
    end

    for k, model in ipairs( data[LUMP_MODELS] or {} ) do
        model.id = k
        model.headnode = data[LUMP_NODES] and data[LUMP_NODES][model.headnode+1]
        model.faces = {}
        for i = model.firstface+1, model.firstface + model.numfaces do
            model.faces[#model.faces+1] = ( facelist and facelist[i] )
        end
    end

    local iVertex, iTris = 0, 0
    local verts = data[LUMP_DISP_VERTS]
    for k, disp in ipairs( data[LUMP_DISPINFO] or {} ) do

        local col = ColorRand()
        disp.id = k
        disp.width = lshift(1, disp.power) + 1
        disp.numVerts = ( lshift(1, disp.power) + 1 ) * ( lshift(1, disp.power) + 1 )
        disp.numTris = lshift(1, disp.power) * lshift(1, disp.power) * 2
        disp.firstVert = iVertex
        disp.firstTri = iTris
        disp.positions = {}
        disp.normals = {}
        disp.alphas = {}
        disp.indices = {}

        if not data[LUMP_FACES] or not verts then continue end
        
        disp.face = data[LUMP_FACES][ disp.faceID+1 ]

        iVertex = iVertex + disp.numVerts
        iTris = iTris + disp.numTris

        local edges = disp.face.edges
        local p0,p1,p2,p3 = edges[1][1], edges[2][1], edges[3][1], edges[4][1]
        local mindist, startIdx = math.huge, 0
        for i=1, 4 do
            local len = (disp.start - edges[i][1]):LengthSqr()
            if len < mindist then mindist, startidx = len, i-1 end
        end
        for i=0, startidx-1 do p0,p1,p2,p3 = p1,p2,p3,p0 end

        local indices, width, positions, normals, alphas, firstVert = 
        disp.indices, disp.width, disp.positions, disp.normals, disp.alphas, disp.firstVert

        local min_x, min_y, min_z = math.huge, math.huge, math.huge
        local max_x, max_y, max_z = -math.huge, -math.huge, -math.huge
        local interval = 1 / (width - 1) 
        local e0 = (p1 - p0) * interval
        local e1 = (p2 - p3) * interval

        --[[debugoverlay.Line(p0, p1, 10, Color(255,100,255), true)
        debugoverlay.Line(p1, p2, 10, Color(255,100,255), true)
        debugoverlay.Line(p2, p3, 10, Color(255,100,255), true)
        debugoverlay.Line(p3, p0, 10, Color(255,100,255), true)]]

        for i=0, width-1 do

            local ep0 = p0 + e0 * i
            local ep1 = p3 + e1 * i
            local seg = (ep1 - ep0) * interval

            --debugoverlay.Line(ep0, ep1, 10, col, true)

            for j=0, width-1 do

                local pos = ep0 + seg * j
                local idx = i * width + j
                local vert = verts[firstVert + idx + 1]
                pos:Add(vert.vec * vert.dist)
                positions[#positions+1] = pos
                alphas[#alphas+1] = vert.alpha
                normals[#normals+1] = Vector(0,0,0)

                local x,y,z = pos:Unpack()
                min_x, max_x = math.min(min_x, x), math.max(max_x, x)
                min_y, max_y = math.min(min_y, y), math.max(max_y, y)
                min_z, max_z = math.min(min_z, z), math.max(max_z, z)

            end

        end

        disp.mins = Vector(min_x, min_y, min_z)
        disp.maxs = Vector(max_x, max_y, max_z)

        local num = 0
        for iv = 0, width - 2 do

            for iu = 0, width - 2 do

                local idx = iv * width + iu
                local a,b,c,d = idx+1, idx+2, idx+width+1, idx+width+2
                local w,x,y,z = d,a,d,b
                if idx % 2 == 1 then w,x,y,z = b,b,c,d end

                indices[num+1] = a
                indices[num+2] = c
                indices[num+3] = w
                indices[num+4] = x
                indices[num+5] = y
                indices[num+6] = z

                local n0 = TriangleNormal(a,c,w,positions)
                local n1 = TriangleNormal(x,y,z,positions)
                
                normals[a]:Add(n0)
                normals[c]:Add(n0)
                normals[w]:Add(n0)
                normals[x]:Add(n1)
                normals[y]:Add(n1)
                normals[z]:Add(n1)

                num = num + 6

            end

        end

        for _,v in ipairs(normals) do v:Normalize() end

        assert(#disp.indices/3 == disp.numTris)

    end

    data.entities = data[LUMP_ENTITIES]
    data.planes = data[LUMP_PLANES]
    data.verts = data[LUMP_VERTEXES]
    data.brushes = data[LUMP_BRUSHES]
    data.edges = data[LUMP_SURFEDGES]
    data.faces = facelist
    data.nodes = data[LUMP_NODES]
    data.leafs = data[LUMP_LEAFS]
    data.models = data[LUMP_MODELS]
    data.props = data[LUMP_GAME_LUMP] and data[LUMP_GAME_LUMP].props
    data.displacements = data[LUMP_DISPINFO]
    data.vis = data[LUMP_VISIBILITY]
    data.cluster_leafs = cluster_leafs
    data.num_clusters = num_clusters
    data.lighting = data[LUMP_LIGHTING_HDR] or data[LUMP_LIGHTING]
    data.pakfile = data[LUMP_PAKFILE]
    data.physcollide = data[LUMP_PHYSCOLLIDE]

end

function VisBitSet( unpackedVisData, cluster )

    local byte = unpackedVisData[1 + rshift(cluster, 3)]
    if byte == nil then return true end
    return band( byte, lshift(1, band(cluster,7) ) ) ~= 0

end

local empty_function = function() end
local meta = {}
meta.__index = meta

function GetMetaTable() return meta end

function meta:LeafAmbientSamples( leaf )

    local samples = self[LUMP_LEAF_AMBIENT_LIGHTING_HDR] or self[LUMP_LEAF_AMBIENT_LIGHTING]
    if not leaf.ambient or not samples then return empty_function end
    local i = leaf.ambient.firstAmbientSample
    local n = leaf.ambient.ambientSampleCount+1
    return function()
        n = n - 1
        i = i + 1
        if n ~= 0 then return samples[i] end
    end

end

function meta:GetLeafAtPos( pos, node )

    node = node or self.models[1].headnode
    if node.is_leaf then return node end

    local d = node.plane.normal:Dot( pos ) - node.plane.dist
    return self:GetLeafAtPos( pos, node.children[d > 0 and 1 or 2] )

end

function meta:GetNodeLeafs( node, out_leafs )

    if node.is_leaf then out_leafs[#out_leafs+1] = node return end

    self:GetNodeLeafs( node.children[1], out_leafs )
    self:GetNodeLeafs( node.children[2], out_leafs )

end

function meta:GetModelLeafs( model, out_leafs )

    self:GetNodeLeafs( model.headnode, out_leafs )

end

function meta:DebugDrawFace( face, write_z, col )

    for _, edge in ipairs(face.edges) do
        render.DrawLine(edge[1], edge[2], col or Color(0,255,100), write_z)
    end

end

function meta:DebugDrawLeaf( leaf, write_z, col )

    for _, f in ipairs(leaf.faces) do
        self:DebugDrawFace(f, write_z, col)
    end

end

-- Visibility
function meta:GetNumClusters()

    return self.num_clusters

end

function meta:GetClusterLeafs( cluster )

    return self.cluster_leafs[ cluster ]

end

function meta:UnpackClusterVis( cluster, mode )

    return self.vis( cluster, mode or VIS_PVS )

end

function meta:GetVisibleClusters( unpacked, out )

    out = out or {}
    for i=0, self:GetNumClusters() do
        if VisBitSet( unpacked, i ) then
            out[#out+1] = i
        end
    end
    return out

end

-- PakFile
function meta:GetPakFiles()

    if self.pakfile == nil then return {} end
    return self.pakfile.file_names

end

function meta:PakContains( name )

    if self.pakfile == nil then return false end
    return self.pakfile.file_entries[ name ] ~= nil

end

function meta:ReadPakFile( name )

    if self.pakfile == nil then return nil end
    local entry = self.pakfile.file_entries[ name ]
    if entry ~= nil then

        local data = self.pakfile.data
        local ptr = entry.offset + 1
        local str_data = str_sub(data, ptr, ptr + entry.size)

        if entry.isCompressed then
            begin_data( str_data )
            local version = uint16()
            local prop_size = uint16()
            local _,props = assert(prop_size == 5), array_of( uint8, prop_size )
            end_data()

            local prop_bytes = str_char( unpack(props) )
            local size_bytes = str_int32( entry.size )

            -- Re-arrange the data a bit for util.Decompress
            str_data = prop_bytes .. size_bytes .. "\0\0\0\0" .. str_sub(str_data, 10, -1)
            str_data = util.Decompress(str_data)
        end

        return str_data

    end

end

function meta:GetLightmapPixel( offset )

    if self.lighting == nil then return 0,0,0,0 end
    begin_data( self.lighting )
    seek_data( offset )
    local r,g,b,e = uint8(),uint8(),uint8(),int8()
    end_data()
    if r and g and b and e then
        r = 255 * TexLightToLinear(r, e)
        g = 255 * TexLightToLinear(g, e)
        b = 255 * TexLightToLinear(b, e)
        --r,g,b = CVT_ColorRGBExp32(r,g,b,e)
        return r,g,b
    else
        return nil
    end

end

function LoadBSP( filename, requested_lumps, path )

    local start = SysTime()
    local handle = file.Open(filename, "rb", path or "GAME")
    local result = nil
    if handle ~= nil then
        local b,e = xpcall(loadBSPData, function( err )
            print("Error loading bsp: " .. tostring(err))
            debug.Trace()

        end, handle, requested_lumps)
        if b then result = e end
        handle:Close()
    else
        error("Unable to find: " .. tostring(filename))
    end

    if result == nil then return end

    local finish = SysTime()
    print("LOAD BSP TOOK: " .. ((finish - start)*1000) .. "ms")

    start = SysTime()
    LinkBSPData(result)
    finish = SysTime()
    print("LINK BSP TOOK: " .. ((finish - start)*1000) .. "ms")

    setmetatable( result, meta )

    return result

end

-- Color correction
local linear_to_screen = {}
local tex_gamma_table = {}

function LinearToScreenGamma( f )
    local i = math.floor( 0.5 + math.min( math.max(f * 1023, 0), 1023 ) + 1 )
    return linear_to_screen[i]
end

function TexLightToLinear( c, e )
    return c * (2 ^ e) / 255
end

function BuildGammaTable( gamma, texGamma, brightness, overbright )

    local g = 1 / math.min(gamma, 3)
    local g1 = texGamma * g
    local g3 = 0

    if brightness <= 0 then 
        g3 = 0.125
    elseif brightness > 1.0 then
        g3 = 0.05
    else
        g3 = 0.125 - (brightness*brightness) * 0.075
    end

    for i=0, 255 do
        local inf = math.Clamp( 255 * (( i/255 ) ^ g1), 0, 255 )
        tex_gamma_table[i+1] = inf
    end

    for i=0, 1023 do
        local f = i/1023
        if brightness > 1.0 then f = f * brightness end
        if f <= g3 then
            f = (f / g3) * 0.125
        else
            f = 0.125 + ((f - g3) / (1.0 - g3)) * 0.875
        end

        local inf = math.Clamp( 255 * ( f ^ g ), 0, 255 )
        linear_to_screen[i+1] = inf
    end

end

function CVT_ColorRGBExp32(r,g,b,e)
    r = 255 * TexLightToLinear(r, e)
    g = 255 * TexLightToLinear(g, e)
    b = 255 * TexLightToLinear(b, e)
    r = LinearToScreenGamma(r)
    g = LinearToScreenGamma(g)
    b = LinearToScreenGamma(b)
    return r,g,b
end

BuildGammaTable(2.2, 2.2, 0, 2.0)