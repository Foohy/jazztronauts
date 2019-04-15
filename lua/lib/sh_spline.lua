if SERVER then AddCSLuaFile("sh_spline.lua") end

module( "spline", package.seeall )

local _staticVecA = Vector()
local _staticVecB = Vector()
local _staticVecC = Vector()
local _staticVecD = Vector()
local _staticVecOut = Vector()
local _staticVecOut2 = Vector()
local _staticVecOut3 = Vector()

local function VectorScale(v, s, out)
	out.x = v.x * s
	out.y = v.y * s
	out.z = v.z * s
end

local function VectorAdd(a, b, out)
	out.x = a.x + b.x
	out.y = a.y + b.y
	out.z = a.z + b.z
end

function CatmullRomSpline(p1, p2, p3, p4, t, output)
	local tSqr = t*t*0.5;
	local tSqrSqr = t*tSqr;
	t = t * 0.5;

	output = output or _staticVecOut

	output.x = 0
	output.y = 0
	output.z = 0

	local a = _staticVecA
	local b = _staticVecB
	local c = _staticVecC
	local d = _staticVecD

	// matrix row 1
	VectorScale( p1, -tSqrSqr, a );		// 0.5 t^3 * [ (-1*p1) + ( 3*p2) + (-3*p3) + p4 ]
	VectorScale( p2, tSqrSqr*3, b );
	VectorScale( p3, tSqrSqr*-3, c );
	VectorScale( p4, tSqrSqr, d );

	VectorAdd( a, output, output );
	VectorAdd( b, output, output );
	VectorAdd( c, output, output );
	VectorAdd( d, output, output );

	// matrix row 2
	VectorScale( p1, tSqr*2,  a );		// 0.5 t^2 * [ ( 2*p1) + (-5*p2) + ( 4*p3) - p4 ]
	VectorScale( p2, tSqr*-5, b );
	VectorScale( p3, tSqr*4,  c );
	VectorScale( p4, -tSqr,	d );

	VectorAdd( a, output, output );
	VectorAdd( b, output, output );
	VectorAdd( c, output, output );
	VectorAdd( d, output, output );

	// matrix row 3
	VectorScale( p1, -t, a );			// 0.5 t * [ (-1*p1) + p3 ]
	VectorScale( p3, t,  b );

	VectorAdd( a, output, output );
	VectorAdd( b, output, output );

	// matrix row 4
	VectorAdd( p2, output, output );	// p2

	return output
end

function CatmullRomSplineTangent(p1, p2, p3, p4, t, output)
	local tOne = 3*t*t*0.5;
	local tTwo = 2*t*0.5;
	local tThree = 0.5;

	output = output or _staticVecOut2

	output.x = 0
	output.y = 0
	output.z = 0

	local a = _staticVecA
	local b = _staticVecB
	local c = _staticVecC
	local d = _staticVecD

	// matrix row 1
	VectorScale( p1, -tOne, a );		// 0.5 t^3 * [ (-1*p1) + ( 3*p2) + (-3*p3) + p4 ]
	VectorScale( p2, tOne*3, b );
	VectorScale( p3, tOne*-3, c );
	VectorScale( p4, tOne, d );

	VectorAdd( a, output, output );
	VectorAdd( b, output, output );
	VectorAdd( c, output, output );
	VectorAdd( d, output, output );

	// matrix row 2
	VectorScale( p1, tTwo*2,  a );		// 0.5 t^2 * [ ( 2*p1) + (-5*p2) + ( 4*p3) - p4 ]
	VectorScale( p2, tTwo*-5, b );
	VectorScale( p3, tTwo*4,  c );
	VectorScale( p4, -tTwo,	d );

	VectorAdd( a, output, output );
	VectorAdd( b, output, output );
	VectorAdd( c, output, output );
	VectorAdd( d, output, output );

	// matrix row 3
	VectorScale( p1, -tThree, a );			// 0.5 t * [ (-1*p1) + p3 ]
	VectorScale( p3, tThree,  b );

	VectorAdd( a, output, output );
	VectorAdd( b, output, output );

	return output
end

function DrawCatmullRomSpline(p1, p2, p3, p4, steps, color)
	steps = steps or 10

	local interval = 1/steps
	local t = 0
	for i=1, steps do
		local a = CatmullRomSpline(p1, p2, p3, p4, t, _staticVecOut)
		--local tangent = CatmullRomSplineTangent(p1, p2, p3, p4, t, _staticVecOut3)

		t = t + interval
		local b = CatmullRomSpline(p1, p2, p3, p4, t, _staticVecOut2)

		render.DrawLine( a, b, color or Color(0,255,0,255), true )
	end
end