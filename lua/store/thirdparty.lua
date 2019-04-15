local weps = weapons.GetList()
local lookup = {}
for _, v in pairs(weps) do
	lookup[v.ClassName] = v
end
local function AddWeapon(name, price, options)
	if not lookup[name] then return end

	options = options or {}
	options.thirdparty = true
	return jstore.Register(lookup[name], price, options)
end

-- Wowozela
AddWeapon("wowozela", 50000, { type = "tool" })