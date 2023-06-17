AddCSLuaFile()

module( "jazzloc", package.seeall )

if CLIENT then
	MaterialLocMap = MaterialLocMap or {}
	MaterialSystemReady = MaterialSystemReady or false
	DummyTestMaterial = CreateMaterial("jazz_dummy_localization_material", "UnlitGeneric", {
		["$basetexture"] = "color/white"
	})

	Localize = function(...)
	
		local arg = {...}
		local strang = ""
		local strtable = arg
		if isstring(arg[1]) then
			strang = tostring(table.remove(strtable,1))
		elseif istable(arg[1]) then
			strtable = arg[1]
			strang = tostring(table.remove(strtable,1))
		else
			error("jazzloc.Localize needs strings or a table of strings, recieved " .. type(arg) )
		end

		--see if we have a Jazztronauts specific override for a default localization string
		--(also technically lets us leave the "jazz." off of our strings in the code if we wanted to)
		local jazzitup = "jazz."..strang
		if not (jazzitup == language.GetPhrase(jazzitup)) then
			strang = jazzitup
		end
		strang = language.GetPhrase(strang)
		
		for i,v in ipairs(strtable) do
			strang = string.Replace(strang,"%"..i.."%",language.GetPhrase(tostring(v)))
		end
		
		return strang
		
	end

	local function loadTexture(texturepath)
		DummyTestMaterial:SetTexture("$basetexture", texturepath)
		local texture = DummyTestMaterial:GetTexture("$basetexture")

		return texture and not texture:IsError() and not texture:IsErrorTexture() and texture or nil
	end

	local function doLocalizeMaterial(matpath)
		assert(MaterialLocMap[matpath])
		local matinfo = MaterialLocMap[matpath]

		-- Lua starts before the material system is ready and can cause a crash
		if not MaterialSystemReady then
			return
		end

		-- Fill out metadata if this material isn't in the system yet
		if not matinfo.orig_name then
			local mat = Material(matpath)
			local basetexture = mat:GetTexture("$basetexture")
					
			--print("LocalizeMaterial(" .. matpath .. ") = " .. tostring(mat))
			matinfo.material  = mat
			matinfo.texture   = basetexture
			matinfo.orig_name = basetexture and basetexture:GetName() or nil
		end


		if matinfo.orig_name then

			-- Build the translated name of the base texture based on our current language
			local lang = string.lower(GetConVar("gmod_language"):GetString())
			local translated = matinfo.orig_name .. "_" .. string.lower(lang)
			local currentName = matinfo.texture and string.lower(matinfo.texture:GetName()) or nil
			local mat = matinfo.material

			-- Check if we even need to translate anything
			if currentName == translated or (lang == "en" and currentName == matinfo.orig_name) then
				--print("Texture is already the correct translation")
				return
			end

			-- Try loading the translated texture, and only if it succeeds do we override the base material
			local new_texture = loadTexture(translated)
			if new_texture then
				print("Localizing " .. mat:GetName() .. ": " .. matinfo.orig_name .. " -> " .. translated)

			-- Check if we need to revert
			elseif currentName != matinfo.orig_name then
				new_texture = loadTexture(matinfo.orig_name)
				print("Reverting to original texture for " .. mat:GetName() .. ": " .. tostring(currentName) .. " -> " .. tostring(matinfo.orig_name))
			else
				--print("No translation found for " .. mat:GetName() .. ": " .. matinfo.orig_name .. " -> " .. translated)
			end

			-- Apply the new texture
			if new_texture then
				matinfo.material:SetTexture("$basetexture", new_texture)
				matinfo.texture = new_texture
			end
		end
	end

	LocalizeMaterial = function(matpath)
		-- print("LocalizeMaterial(" .. matpath .. ")")
	
		-- Add to system, but don't fill out metadata until material system initialized
		if not MaterialLocMap[matpath] then
			MaterialLocMap[matpath] = {}
		end

		doLocalizeMaterial(matpath)

	end

	RefreshMaterials = function()
		for matpath, _ in pairs(MaterialLocMap) do
			doLocalizeMaterial(matpath)
		end
	end

	-- Refresh after material system initialized
	timer.Simple(0, function()
		MaterialSystemReady = true
		print("Initialized material system, refreshing localized materials")
		RefreshMaterials()
	end )

	-- Refresh on language change
	cvars.AddChangeCallback("gmod_language", RefreshMaterials, "jazz_localization_listener")

	-- Refresh on concommand
	concommand.Add("jazz_loc_refreshmats", function()
		RefreshMaterials()
	end )

	
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
