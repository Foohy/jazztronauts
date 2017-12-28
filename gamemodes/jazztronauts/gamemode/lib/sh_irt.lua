if SERVER then AddCSLuaFile("sh_irt.lua") end
if SERVER then return end

include("sh_rect.lua")
include("sh_scene.lua")

IRT = nil

print("SHIRT")

module( "irt", package.seeall )

local TEXTUREFLAGS_POINTSAMPLE			= 0x1
local TEXTUREFLAGS_TRILINEAR			= 0x2
local TEXTUREFLAGS_CLAMPS				= 0x4
local TEXTUREFLAGS_CLAMPT				= 0x8
local TEXTUREFLAGS_ANISOTROPIC			= 0x10
local TEXTUREFLAGS_HINT_DXT5			= 0x20
local TEXTUREFLAGS_PWL_CORRECTED		= 0x40
local TEXTUREFLAGS_NORMAL				= 0x80
local TEXTUREFLAGS_NOMIP				= 0x100
local TEXTUREFLAGS_NOLOD				= 0x200
local TEXTUREFLAGS_ALL_MIPS				= 0x400
local TEXTUREFLAGS_PROCEDURAL			= 0x800
local TEXTUREFLAGS_ONEBITALPHA			= 0x1000
local TEXTUREFLAGS_EIGHTBITALPHA		= 0x2000
local TEXTUREFLAGS_ENVMAP				= 0x4000
local TEXTUREFLAGS_RENDERTARGET 		= 0x8000
local TEXTUREFLAGS_DEPTHRENDERTARGET	= 0x10000
local TEXTUREFLAGS_NODEBUGOVERRIDE 		= 0x20000
local TEXTUREFLAGS_SINGLECOPY 			= 0x40000
local TEXTUREFLAGS_IMMEDIATE_CLEANUP 	= 0x100000
local TEXTUREFLAGS_NODEPTHBUFFER		= 0x800000
local TEXTUREFLAGS_CLAMPU				= 0x2000000
local TEXTUREFLAGS_VERTEXTEXTURE		= 0x4000000
local TEXTUREFLAGS_SSBUMP				= 0x8000000
local TEXTUREFLAGS_BORDER				= 0x20000000

local g_cachemap = {}
local meta = {}
meta.__index = meta

function meta:Init(...)

	self.enable_color = true
	self.enable_depth = false
	self.enable_fullscreen = false
	self.enable_hdr = false
	self.enable_mip = false
	self.enable_separate_depth = false
	self.enable_anisotropy = false
	self.enable_point_sample = false
	self.alpha_bits = 0

	self.clamp_s = false
	self.clamp_t = false

	return self

end

function meta:SetAlphaBits(bits)

	self.alpha_bits = bits
	return self

end

function meta:SetClamp(bClampS, bClampT)

	self.clamp_s = bClampS
	self.clamp_t = bClampT
	return self

end

function meta:EnablePointSample(bPointSample)

	self.enable_point_sample = bPointSample == true
	return self

end

function meta:EnableAnisotropy(bAnisotropy)

	self.enable_anisotropy = bAnisotropy == true
	return self

end

function meta:EnableDepth(bDepth, bSeparate)

	self.enable_depth = bDepth == true
	self.enable_separate_depth = bSeparate == true
	return self

end

function meta:EnableFullscreen(bFullscreen)

	self.enable_fullscreen = bFullscreen == true
	return self

end

function meta:EnableHDR(bHDR)

	self.enable_hdr = bHDR == true
	return self

end

function meta:EnableMipmap(bMipmap)

	self.enable_mip = bMipmap == true
	return self

end

function meta:GetSizeMode()

	if self.enable_fullscreen then
		return RT_SIZE_FULL_FRAME_BUFFER_ROUNDED_UP
	end
	if self.enable_hdr then
		return RT_SIZE_HDR
	end
	if self.enable_mip then
		return RT_SIZE_PICMIP
	end
	if not self.enable_depth then
		return RT_SIZE_NO_CHANGE
	end
	return RT_SIZE_DEFAULT

end

function meta:GetDepthMode()

	if not self.enable_depth then
		return MATERIAL_RT_DEPTH_NONE
	end
	if not self.enable_color then
		return MATERIAL_RT_DEPTH_ONLY
	end
	if self.enable_separate_depth then
		return MATERIAL_RT_DEPTH_SEPARATE
	end
	return MATERIAL_RT_DEPTH_SHARED

end

function meta:GetTextureFlags()

	local flags = TEXTUREFLAGS_RENDERTARGET
	if not self.enable_color and self.enable_depth then
		flags = bit.bor(flags, TEXTUREFLAGS_DEPTHRENDERTARGET)
	elseif self.enable_color and not self.enable_depth then
		flags = bit.bor(flags, TEXTUREFLAGS_NODEPTHBUFFER)
	end

	if not self.enable_mip then
		flags = bit.bor(flags, TEXTUREFLAGS_NOMIP)
	end

	if self.clamp_s then
		flags = bit.bor( flags, TEXTUREFLAGS_CLAMPS )
	end

	if self.clamp_t then
		flags = bit.bor( flags, TEXTUREFLAGS_CLAMPT )
	end

	if self.enable_anisotropy then
		flags = bit.bor( flags, TEXTUREFLAGS_ANISOTROPIC )
	end

	if self.enable_point_sample then
		flags = bit.bor( flags, TEXTUREFLAGS_POINTSAMPLE )
	end

	if self.alpha_bits == 1 then
		flags = bit.bor( flags, TEXTUREFLAGS_ONEBITALPHA )
	end

	if self.alpha_bits == 8 then
		flags = bit.bor( flags, TEXTUREFLAGS_EIGHTBITALPHA )
	end

	return flags

end

function meta:GetCreateFlags()

	local flags = 0
	if self.enable_hdr then
		flags = bit.bor( flags, CREATERENDERTARGETFLAGS_HDR )
	end

	if self.enable_mip then
		flags = bit.bor( flags, CREATERENDERTARGETFLAGS_AUTOMIPMAP )
	end

	return flags

end

function meta:GetImageFormat()

	if self.enable_hdr then
		return IMAGE_FORMAT_RGBA16161616F
	end

	if self.alpha_bits > 0 then
		return IMAGE_FORMAT_ARGB8888
	end

	return IMAGE_FORMAT_RGB888

end

function meta:GetSize()

	if self.enable_fullscreen then
		return 1,1
	end

	if self.enable_hdr then
		--width = width * 4
	end

	return self.width, self.height

end

function meta:GetIDString()

	local id = self.id
	local width, height = self:GetSize()
	local sizemode = self:GetSizeMode()
	local depthmode = self:GetDepthMode()
	local textureflags = self:GetTextureFlags()
	local createflags = self:GetCreateFlags()
	local imageformat = self:GetImageFormat()

	return tostring(id) .. "_" .. width .. "x" .. height .. "_" .. sizemode .. "_" .. depthmode .. "_" .. textureflags .. "_" .. createflags .. "_" .. imageformat

end

function meta:GetTarget()

	local idstr = self:GetIDString()
	local cached = g_cachemap[idstr]
	if cached ~= nil then return cached end

	local id = self.id
	local width, height = self:GetSize()
	local sizemode = self:GetSizeMode()
	local depthmode = self:GetDepthMode()
	local textureflags = self:GetTextureFlags()
	local createflags = self:GetCreateFlags()
	local imageformat = self:GetImageFormat()

	local target = GetRenderTargetEx( idstr, width, height, sizemode, depthmode, textureflags, createflags, imageformat )

	print(target)
	g_cachemap[idstr] = target

	return target

end

function meta:BuildMaterialParams(bNoCull, bModel, bVertexColor, bVertexAlpha)

	local params = {}
	params["$nocull"] = bNoCull and 1 or 0
	params["$model"] = bModel and 1 or 0
	params["$vertexcolor"] = bVertexColor and 1 or 0
	params["$vertexalpha"] = bVertexAlpha and 1 or 0
	params["$alphatest"] = self.alpha_bits == 1 and 1 or 0
	params["$translucent"] = self.alpha_bits == 8 and 1 or 0

	if params["$translucent"] == 1 then
		params["$alphatest"] = 0
	else
		params["$alphatestreference"] = 0.5
	end


	local pflags = 0
	pflags = pflags + params["$nocull"]
	pflags = pflags + params["$model"] * 0x2
	pflags = pflags + params["$vertexcolor"] * 0x4
	pflags = pflags + params["$vertexalpha"] * 0x8
	pflags = pflags + params["$alphatest"] * 0x10
	pflags = pflags + params["$translucent"] * 0x20

	return params, pflags

end

function meta:GetUnlitMaterial(...)

	local params, pflags = self:BuildMaterialParams(...)

	local idstr = "m_unlit_" .. self:GetIDString() .. "_" .. pflags
	local cached = g_cachemap[idstr]
	if cached ~= nil then return cached end

	params["$basetexture"] = self:GetIDString()

	local material = CreateMaterial( idstr, "UnlitGeneric", params )
	print(material)

	g_cachemap[idstr] = material
	return material

end

function meta:RenderViewOrtho( origin, angles, scale, bViewModel )

	scale = scale or 1
    render.PushRenderTarget(self:GetTarget())

    	local b, e = pcall( function()

        render.RenderView( {
            origin = origin,
            angles = angles,
            drawviewmodel = bViewModel or false,
            x = 0,
            y = 0,
            w = self.width,
            h = self.height,
            ortholeft = -self.width * scale,
            orthoright = self.width * scale,
            orthotop = -self.height * scale,
            orthobottom = self.height * scale,
            ortho = true,
        } )

        LocalPlayer():DrawModel()

        end)

    render.PopRenderTarget()

    if not b then error( tostring( e ) ) end

end

function meta:Render( fCallback, ... )

	if not fCallback then return end

	render.PushRenderTarget(self:GetTarget())

		local b, e = pcall(fCallback, ...)

	render.PopRenderTarget()

	if not b then error( tostring( e ) ) end

end

function meta:RenderScene( scene )

	render.PushRenderTarget(self:GetTarget())
	render.OverrideAlphaWriteEnable( true, true )
	render.SetWriteDepthToDestAlpha( false )

		local b, e = pcall( function()
			scene:Render( Rect( 0, 0, self.width, self.height ) )
		end )

	render.OverrideAlphaWriteEnable( false )
	render.PopRenderTarget()

	if not b then error( tostring( e ) ) end

end

function meta:Clear( r, g, b, a, bDepth, bStencil )

	render.PushRenderTarget(self:GetTarget())
	render.OverrideAlphaWriteEnable( true, true )
	render.Clear( r, g, b, a, bDepth, bStencil )
	render.OverrideAlphaWriteEnable( false )
	render.PopRenderTarget()


end

function New(id, width, height)

	return setmetatable({id=id, width=width, height=height}, meta):Init()

end

IRT = New


local camera = Camera( Vector(-90,0,0), Angle(0,0,0), 8 )
local scene = Scene( camera )

scene:SetBoxLight( 1, 255,255,255 )
scene:SetBoxLight( 2, 0,0,255 )

local myRT = New("testRT4",64,64)
myRT:EnableDepth( true, true )

local material = myRT:GetUnlitMaterial(true,false,false,true)
local removetime = 10

local function test()
	--myRT:RenderViewOrtho( Vector(0,0,64), Angle(0,0,0), 1 )

--local mins, maxs = LocalPlayer():GetHitBoxBounds( 0, 0 )
--print( mins, maxs )

	local size_test = 32

	if scene ~= nil then

		scene:Clear()

		local inst = scene:AddModel("player", LocalPlayer():GetModel())

		inst:Get():SetupBones()
		local head = inst:Get():LookupBone("ValveBiped.Bip01_Head1")
		if not head then head = inst:Get():LookupBone("ValveBiped.Bip01_Spine2") end
		if not head then head = inst:Get():LookupBone("ValveBiped.Bip01_Spine1") end

		local mtx = inst:Get():GetBoneMatrix(head)
		local bonelen = inst:Get():BoneLength(head)
		inst:Identity()
		inst:Rotate( Angle(0,CurTime() * 120,0) )

		camera.pos = mtx:GetTranslation() + Vector(-90,0,bonelen/2)

		--[[for i=1, inst:Get():GetFlexNum() do
			local min,max = inst:Get():GetFlexBounds( i )
			inst:Get():SetFlexWeight(i, math.Rand(min, max) )
		end]]

		--[[myRT:Clear( 0,0,0,0,true )
		myRT:RenderScene( scene )

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( material )
		surface.DrawTexturedRect( Rect(0,0,size_test,size_test):Unpack() )]]


		scene:Render( Rect(0,0,size_test,size_test):ScreenScale() )

	end

	--[[removetime = removetime - FrameTime()
	if removetime <= 0 and scene ~= nil then
		print("DEREF SCENE")
		scene = nil
	end]]

end
hook.Add("HUDPaint", "irttest", test)