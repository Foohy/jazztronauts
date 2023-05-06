-- detail props that gently bob in the water
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.ZOrig = 0.0
ENT.XOffset = 0.0
ENT.RotOrig = angle_zero
--ENT.Sorted = false

local rotVect = Vector(0,1,0)

function ENT:SetupDataTables()
	--gotta network this stuff so the client gets it from the server-only KeyValue
	self:NetworkVar( "String", 0, "NWModel")
	self:NetworkVar( "String", 1, "NWBodygroup")
	self:NetworkVar( "Int", 1, "NWSkin")
end

function ENT:Initialize() 
	self:SetModel( Model(self:GetNWModel()) )
	self:SetBodyGroups(self:GetNWBodygroup())
	self:SetSkin(self:GetNWSkin())
	self:DrawShadow( false )
	local pos = self:GetPos()
	self.ZOrig = pos.z
	self.XOffset = (pos.x % 512) / 512 * -2 * math.pi --512HU period, normalized (and flipped negative)
	self.RotOrig = self:GetAngles()
end

function ENT:KeyValue( key, value )

	--[[
    if table.HasValue(outputs, key) then
		self:StoreOutput(key, value)
	end
    --]]

	if key == "model" and value ~= "" then
		self:SetNWModel(value)
	end

    if key == "bodygroup" then
        if value ~= "" then
		    self:SetNWBodygroup(value)
        else
			self:SetNWBodygroup("0")
        end
	end

	number = tonumber(value)
	if key == "skin" and number ~= nil then
		self:SetNWSkin(number)
	end
end

--todo: more hassle than it's worth right now, not using it at the moment.
--[[function ENT:AcceptInput( name, activator, caller, data )
	if name == "SetModel" and data ~= "" then
        self:SetNWModel(data)
		--self:SetModel(Model(self.Model)) --network this
		return true
	end
	if name == "SetBodygroup" then
        if data ~= "" then
            self:SetNWBodygroup(data)
        else
            self:SetNWBodygroup("0")
        end
        --self:SetBodyGroups(self:GetNWBodygroup()) --network this
		return true
	end
    number = tonumber(data)
	if name == "Skin" and number ~= nil then
        self:SetNWSkin(number)
		--self:SetSkin(self:GetNWSkin()) --network this
		return true
	end

	return false
end]]

if SERVER then return end

function ENT:Think()

	--X offset makes these animate on a location-based delay to help simulate waves rippling through the water
	local sin = 2 * math.sin(CurTime() + self.XOffset)

	--bob up and down
	local pos = self:GetPos()
	pos.z = self.ZOrig + 0.5 + sin --Z moves -0.5 to +1.5
	self:SetPos(pos)

	--sway (bit expensive, so only do it when we're close enough to potentially appreciate it)
	local plr = LocalPlayer()
	if IsValid(plr) then
		local plrpos = plr:GetPos()
		if math.DistanceSqr(pos.x,pos.y,plrpos.x,plrpos.y) <= 1048576 then --1024^2
			--unfortunately if we don't do this as a new angle built off of the original it can desync when tabbed out
			local rotato = Angle(self.RotOrig)
			rotato:RotateAroundAxis(rotVect,sin) -- +/-2 degrees on X
			self:SetAngles(rotato)
		end
	end

	self:NextThink( CurTime() ) -- Set the next think to run as soon as possible, i.e. the next frame.
end