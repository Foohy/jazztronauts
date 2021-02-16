AddCSLuaFile()

module( "iocommon", package.seeall )

FGDClasses = {}

local function lines(str)
	local setinel = 0
	return function()
		local k = str:find("\r\n", setinel+1)
		if not k then return end
		local b = setinel
		setinel = k
		return str:sub(b+2, k-1)
	end
end

local classes = {}
local classMatch = "^@(%w+)(.*)=%s-([%w_]+)"
local classNameMatch = "=%s-([%w_]+)"
local outputMatch = "^%s+output%s(%w+)%((%w+)%)"
local inputMatch = "^%s+input%s(%w+)%((%w+)%)"
local argListMatch = "(%w+%([^%)]*%))"
local argKVMatch = "(%w+)%(([^%)]*)%)"
local argMultiMatch = "[^,%s]+"

local function parseFGD( fgd )

	local f = file.Open( fgd, "rb", "BASE_PATH" )
	if f then
		local targetClass = nil
		for x in lines( f:Read( f:Size() ) ) do

			local classtype, args, name = x:match(classMatch)
			if classtype and name then
				if targetClass then 
					classes[targetClass.classname] = targetClass 
				end
				targetClass = { 
					classname = name, 
					classtype = classtype,
					inputs = {},
					outputs = {},
					editorkeys = {},
					baseclasses = {},
				}

				if args then
					for arg in args:gmatch(argListMatch) do
						local k,v = arg:match(argKVMatch)
						if k == "base" then
							local bases = {}
							for base in v:gmatch(argMultiMatch) do
								bases[#bases+1] = base
							end
							targetClass.baseclasses = bases
						else
							targetClass.editorkeys[k] = v
						end
					end
				end
			end

			if targetClass then
				if x[1] == ']' then
					classes[targetClass.classname] = targetClass
					targetClass = nil
				else
					local output, param = x:match(outputMatch)
					if output then
						targetClass.outputs[output] = param
					end
					local input, param = x:match(inputMatch)
					if input then
						targetClass.inputs[input] = param
					end
				end
			end

		end
	end

end

local function walkAllBaseClasses(classes, class, bases)

	for _, base in ipairs(class.baseclasses) do

		local baseClass = classes[base]
		if not baseClass then 
			error("Failed to find class for: " .. base)
		end

		bases[#bases+1] = baseClass
		walkAllBaseClasses(classes, baseClass, bases)

	end

end

local function inheritBaseClasses(classes)

	for k, class in pairs(classes) do

		local bases = {}
		walkAllBaseClasses(classes, class, bases)

		for _, base in ipairs(bases) do

			for name, input in pairs(base.inputs) do
				if not class.inputs[name] then
					class.inputs[name] = input
				end
			end

			for name, output in pairs(base.outputs) do
				if not class.outputs[name] then
					class.outputs[name] = output
				end
			end

		end

	end

end

local start = SysTime()

parseFGD("bin/base.fgd")
parseFGD("bin/halflife2.fgd")
parseFGD("bin/garrysmod.fgd")

inheritBaseClasses(classes)

print("LOADING FGDs TOOK: " .. (SysTime() - start) .. " seconds")

for k,v in pairs(classes) do
	if k:find("func_button") then
		print(k)
		PrintTable(v,1)
	end
end

FGDClasses = classes