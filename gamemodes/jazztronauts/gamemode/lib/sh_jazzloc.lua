AddCSLuaFile()

module( "jazzloc", package.seeall )

if CLIENT then

	Localize = function(...)
	
		local arg = {...}
		local strang = ""
		local strtable = arg
		if isstring(arg[1]) then
			strang = language.GetPhrase(tostring(table.remove(strtable,1)))
		elseif istable(arg[1]) then
			strtable = arg[1]
			strang = language.GetPhrase(tostring(table.remove(strtable,1)))
		else
			error("jazzloc.Localize needs strings or a table of strings, recieved " .. type(arg) )
		end
		
		for i,v in ipairs(strtable) do
			strang = string.Replace(strang,"%"..i.."%",language.GetPhrase(tostring(v)))
		end
		
		return strang
		
	end
	
else --no localization on server, so we'll just tack on the arguments to the localization token there

	Localize = function(...)
	
		local arg = {...}
		local strang = tostring(table.remove(arg,1))
		
		for i,v in ipairs(arg) do
			strang = strang..","..tostring(v)
		end
		
		return strang
		
	end

end

function AddSeperators(amount)

	local formatted = amount
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end

	return formatted

end
