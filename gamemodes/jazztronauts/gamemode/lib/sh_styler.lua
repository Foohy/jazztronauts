AddCSLuaFile()

if SERVER then return end

module( "styler", package.seeall )

local styler_meta = {}
styler_meta.__index = styler_meta

local element_meta = {}
element_meta.__index = element_meta

local function GetValue( data, key, ... )

	local is_function = type( data[key] ) == "function"
	local is_callable = getmetatable( data[key] ) and getmetatable( data[key] ).__call

	if is_function or is_callable then

		return tostring( data[key](...) )

	else

		return tostring( data[key] )

	end

end

local function MessageParts( message, data, style_table, style_remap )

	local key = nil
	local str = ""
	local parse = message .. " "
	for i=1, #parse do
		local ch = parse[i]
		if ch == '%' then
			key = ""
		elseif key == nil then
			str = str .. ch
		elseif key ~= nil then
			local b = string.byte(ch)
			if (b < 97 or b > 122) and ch ~= '_' then
				local val = GetValue( data, key ) --( type(data[key]) == "function" ) and data[key]() or tostring( data[key] )

				key = (style_remap and style_remap[key]) or key

				if style_table and style_table[key] ~= nil then
					local styledata = style_table[key]
					val = styledata[1] .. val .. styledata[2]
				end

				key = nil
				str = str .. val .. ch
			else
				key = key .. ch
			end
		end
	end

	return string.sub(str, 0, -2)

end


--STYLER META

function styler_meta:Element( message, data, style_remap )

	return setmetatable( {
		message = message,
		data = data or {},
		styler = self,
		style_remap = style_remap,
	}, element_meta ):Init()

end


--ELEMENT META
local empty_styling = {}

function element_meta:Init()

	self.shadow = {}

	for k,v in pairs( self.data ) do self.shadow[k] = GetValue( self.data, k ) end

	self:Parse()

	return self

end

function element_meta:Parse()

	local style_table = self.styler.style_table

	self.raw_string = MessageParts( self.message, self.data, empty_styling )
	self.string = MessageParts( self.message, self.data, style_table, self.style_remap )

	local whole_key = ( self.style_remap and self.style_remap.whole ) or "whole"
	local whole = style_table[whole_key]

	if whole then
		self.parsed = markup.Parse( whole[1] .. self.string .. whole[2], self.max_width )
	else
		self.parsed = markup.Parse( self.string, self.max_width )
	end

end

function element_meta:SetMaxWidth( w )

	self.max_width = w
	return self

end

function element_meta:Size()

	return self.parsed:Size()

end

function element_meta:Draw(...)

	self:Update()

	return self.parsed:Draw(...)

end

function element_meta:Update()

	local needs_reparse = false
	for k,v in pairs( self.data ) do

		local val = GetValue( self.data, k ) 
		if self.shadow[k] ~= val then
			needs_reparse = true
			self.shadow[k] = val
		end

	end

	if needs_reparse then
		self:Parse()
	end

end

function element_meta:SetStyleOverride( key, target )

	self.style_remap = self.style_remap or {}
	self.style_remap[key] = target
	self:Parse()
	return self

end

function New( style_table, parent )

	if parent and getmetatable(parent) == styler_meta then

		for k,v in pairs( parent.style_table ) do
			style_table[k] = style_table[k] or v
		end

	end

	return setmetatable( {
		style_table = style_table, 
	}, styler_meta )

end

local meta = {}
meta.__index = meta
meta.__add = function( a, b )

	return setmetatable( { a[1] .. b[1], b[2] .. a[2] }, meta )

end

local function MakeTag( tag, param )

	return setmetatable( {
		"<" .. tag .. "=" .. param .. ">",
		"</" .. tag .. ">"
	}, meta )

end

function Font( str ) return MakeTag( "font", str ) end
function Color( col ) return MakeTag( "colour", ("%i, %i, %i, %i>"):format( col.r, col.g, col.b, col.a ) ) end