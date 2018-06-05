if SERVER then AddCSLuaFile("sh_matrix.lua") end

local meta = FindMetaTable("VMatrix")

local __kmap = {}
for k=1,16 do __kmap[k] = { math.ceil(k/4), ((k-1) % 4)+1 } end


local cvmeta = {}
cvmeta.__index = function( self, k )
	local m = rawget(self, "mtx")
	local r,c = unpack(__kmap[k])
	if type(m) ~= "table" then return rawget(self, "mtx"):GetField( r, c ) end
	return rawget(self, "mtx")[ r ][ c ]
end

cvmeta.__newindex = function( self, k, v )
	if type(k) == "string" then return rawset(self, k, v) end
	local m = rawget(self, "mtx")
	local r,c = unpack(__kmap[k])
	if type(m) ~= "table" then rawget(self, "mtx"):SetField( r, c, v ) return end
	rawget(self, "mtx")[ r ][ c ] = v
end

function MAccess(mtx)
	return setmetatable({mtx = mtx}, cvmeta)
end

local _A = MAccess()
local _B = MAccess()
local _C = MAccess()

function meta:Transpose()
/*
	_A.mtx = self:ToTable()
	_C.mtx = self

	_C[2 ] = _A[5 ]
	_C[3 ] = _A[9 ]
	_C[4 ] = _A[13]
	_C[7 ] = _A[10]
	_C[8 ] = _A[14]
	_C[12] = _A[15]

	_C[5 ] = _A[2 ]
	_C[9 ] = _A[3 ]
	_C[13] = _A[4 ]
	_C[10] = _A[7 ]
	_C[14] = _A[8 ]
	_C[15] = _A[12]
*/

	local m = self
	local mv = m:ToTable()

	m:SetField(1,2, mv[2][1])
	m:SetField(1,3, mv[3][1])
	m:SetField(1,4, mv[4][1])

	m:SetField(2,1, mv[1][2])
	m:SetField(2,3, mv[3][2])
	m:SetField(2,4, mv[4][2])

	m:SetField(3,1, mv[1][3])
	m:SetField(3,2, mv[2][3])
	m:SetField(3,4, mv[4][3])

	m:SetField(4,1, mv[1][4])
	m:SetField(4,2, mv[2][4])
	m:SetField(4,3, mv[3][4])

	return self

end

function meta:Concat( other )

	_A.mtx = self:ToTable()
	_B.mtx = other
	_C.mtx = self

	_C[1 ] = _A[1 ] * _B[1 ] + _A[2 ] * _B[5 ] + _A[3 ] * _B[9 ] + _A[4 ] * _B[13]
	_C[2 ] = _A[1 ] * _B[2 ] + _A[2 ] * _B[6 ] + _A[3 ] * _B[10] + _A[4 ] * _B[14]
	_C[3 ] = _A[1 ] * _B[3 ] + _A[2 ] * _B[7 ] + _A[3 ] * _B[11] + _A[4 ] * _B[15]
	_C[4 ] = _A[1 ] * _B[4 ] + _A[2 ] * _B[8 ] + _A[3 ] * _B[12] + _A[4 ] * _B[16]

	_C[5 ] = _A[5 ] * _B[1 ] + _A[6 ] * _B[5 ] + _A[7 ] * _B[9 ] + _A[8 ] * _B[13]
	_C[6 ] = _A[5 ] * _B[2 ] + _A[6 ] * _B[6 ] + _A[7 ] * _B[10] + _A[8 ] * _B[14]
	_C[7 ] = _A[5 ] * _B[3 ] + _A[6 ] * _B[7 ] + _A[7 ] * _B[11] + _A[8 ] * _B[15]
	_C[8 ] = _A[5 ] * _B[4 ] + _A[6 ] * _B[8 ] + _A[7 ] * _B[12] + _A[8 ] * _B[16]

	_C[9 ] = _A[9 ] * _B[1 ] + _A[10] * _B[5 ] + _A[11] * _B[9 ] + _A[12] * _B[13]
	_C[10] = _A[9 ] * _B[2 ] + _A[10] * _B[6 ] + _A[11] * _B[10] + _A[12] * _B[14]
	_C[11] = _A[9 ] * _B[3 ] + _A[10] * _B[7 ] + _A[11] * _B[11] + _A[12] * _B[15]
	_C[12] = _A[9 ] * _B[4 ] + _A[10] * _B[8 ] + _A[11] * _B[12] + _A[12] * _B[16]

	_C[13] = _A[13] * _B[1 ] + _A[14] * _B[5 ] + _A[15] * _B[9 ] + _A[16] * _B[13]
	_C[14] = _A[13] * _B[2 ] + _A[14] * _B[6 ] + _A[15] * _B[10] + _A[16] * _B[14]
	_C[15] = _A[13] * _B[3 ] + _A[14] * _B[7 ] + _A[15] * _B[11] + _A[16] * _B[15]
	_C[16] = _A[13] * _B[4 ] + _A[14] * _B[8 ] + _A[15] * _B[12] + _A[16] * _B[16]

	return self

end

function meta:Copy()

	return Matrix( self:ToTable() )

end

local _T = MAccess()

function meta:Transform3( vector, w, out )

	out = out or Vector()

	local x = vector.x
	local y = vector.y
	local z = vector.z
	w = w or 1

	_T.mtx = self
	local nx = x * _T[1 ] + y * _T[2 ] + z * _T[3 ] + w * _T[4 ]
	local ny = x * _T[5 ] + y * _T[6 ] + z * _T[7 ] + w * _T[8 ]
	local nz = x * _T[9 ] + y * _T[10] + z * _T[11] + w * _T[12]

	out.x = nx
	out.y = ny
	out.z = nz

	return out

end

function meta:Transform4( vector, w, out )

	out = out or Vector()

	local x = vector.x
	local y = vector.y
	local z = vector.z
	w = w or 1

	_T.mtx = self
	local nx = x * _T[1 ] + y * _T[2 ] + z * _T[3 ] + w * _T[4 ]
	local ny = x * _T[5 ] + y * _T[6 ] + z * _T[7 ] + w * _T[8 ]
	local nz = x * _T[9 ] + y * _T[10] + z * _T[11] + w * _T[12]
	local nw = x * _T[13] + y * _T[14] + z * _T[15] + w * _T[16]

	out.x = nx
	out.y = ny
	out.z = nz

	return out, nw

end

function meta:DrawAxis( scale )

	if SERVER then return end

	gfx.renderAxis( self:GetTranslation(), self:GetForward(), self:GetRight(), self:GetUp(), scale )

end