AddCSLuaFile()

if SERVER then
	local function validSpawnEntity(ent)
		return IsValid(ent) and (ent.Alive and ent:Alive() or true)
	end

	local function getSpawnEntity(ply)
		local obstarget = ply:GetObserverTarget()

		if validSpawnEntity(obstarget) then
			return obstarget
		end
	end

	function GM:GetDefaultSpawn(ply)
		return self.BaseClass.PlayerSelectSpawn(self, ply)
	end

	-- Allow spawning on players if they're hovered over someone that's alive
	function GM:PlayerSelectSpawn(ply)
		local target = getSpawnEntity(ply)

		if not IsValid(target) or target == ply then
			target = self:GetDefaultSpawn(ply)
		end

		ply.JazzSpawnEntity = target

		return target
	end

	hook.Add("PlayerSpawn", "JazzPlayerSpawnLogic", function(ply)
		-- If they spawn on the trolley specifically, automatically just put them in a seat
		local ent = ply.JazzSpawnEntity
		if not IsValid(ent) then return end

		-- If they spawned on the bus, or spawned on a player sitting in a bus, spawn on the bus
		local bus = ent:GetClass() == "jazz_bus_explore" and ent or nil
		if not IsValid(bus) then
			local parent = ent:IsPlayer() and IsValid(ent:GetVehicle()) and ent:GetVehicle():GetParent()
			bus = IsValid(parent) and parent:GetClass() == "jazz_bus_explore" and parent or nil
		end

		-- Sit em' down
		if IsValid(bus) then
			bus:SitPlayer(ply)
		end
	end )

	-- Get a list of all non-player spawn points (including the trolley/default map)
	local function getNonPlayerSpawns(ply)
		local spawns = {
			ply -- Signifies default map spawn
		}
		table.Add(spawns, ents.FindByClass("jazz_bus_explore"))

		return spawns
	end

	-- Get a list of all available spawnpoints
	local function getAvailableSpawns(ply)
		local spawns = getNonPlayerSpawns(ply)

		local players = player.GetAll()
		for _, v in pairs(players) do
			if IsValid(v) and v:Alive() then table.insert(spawns, v) end
		end

		return spawns
	end

	-- Given the current target, retrieve the next spectate target
	local function getNextSpawn(ply, curtarget)
		local spawns = getAvailableSpawns(ply)
		if #spawns == 0 then return nil end

		local i = table.KeyFromValue(spawns, curtarget) or 1
		i = (i % #spawns) + 1

		return spawns[i]
	end

	function GM:PlayerDeathThink(ply)

		local wantsSpawn = ply:KeyPressed( IN_ATTACK ) || ply:KeyPressed( IN_JUMP )
		local inSpectate = ply:GetObserverMode() != OBS_MODE_NONE

		-- Switch observing player if they click the button or they're not spectating yet
		if ply:KeyPressed(IN_ATTACK2) or (wantsSpawn and not inSpectate) then
			local curtarget = getSpawnEntity(ply)
			local nexttarget = getNextSpawn(ply, curtarget)

			-- If the next target is invalid or there's only one spawnpoint, then just immediately spawn on that
			-- no need to preview it
			if IsValid(nexttarget) and (inSpectate or #getAvailableSpawns(ply) > 1) then

				-- Setup spectate on the next target
				if IsValid(nexttarget) then
					ply:Spectate(OBS_MODE_CHASE)
					ply:SpectateEntity(nexttarget)

					-- If the next target is _ourselves_, we treat it as a default map spawn
					if nexttarget == ply then
						local spawnpoint = self:GetDefaultSpawn(ply)
						if IsValid(spawnpoint) then
							ply:SetPos(spawnpoint:GetPos())
						end
					end
				end

				return
			end

		end

		if ply.NextSpawnTime && ply.NextSpawnTime > CurTime() then return end

		-- Respawn on time's up
		if ply:IsBot() or wantsSpawn then
			ply:Spawn()
		end

	end

	function GM:SetupPlayerVisibility(ply, viewEntity)
		if ply:GetObserverMode() == OBS_MODE_NONE then return end

		local curtarget = getSpawnEntity(ply)
		if IsValid(curtarget) then
			AddOriginToPVS(curtarget:GetPos())
		end
	end

end

-- Draw spectate stuff
if CLIENT then
	local function GetSpectateName(ent)
		if ent == LocalPlayer() then return jazzloc.Localize("jazz.respawn.playerstart") end
		if ent:IsPlayer() then return ent:GetName() end

		local class = ent:GetClass()
		if class == "jazz_bus_explore" then return jazzloc.Localize("jazz_bus_explore") end
		return class
	end

	hook.Add("HUDPaint", "JazzDrawSpectate", function()
		if LocalPlayer():GetObserverMode() == OBS_MODE_NONE then return end
		local obstarget = LocalPlayer():GetObserverTarget()
		if not IsValid(obstarget) then return end
		local name = GetSpectateName(obstarget)
		local hintText = jazzloc.Localize("jazz.respawn.switch",jazzloc.Localize(input.LookupBinding("+attack2")))

		surface.SetFont("DermaDefault")
		local wn, hn = surface.GetTextSize(name)
		local wh, hh = surface.GetTextSize(hintText)
		local w, h = math.max(wn, wh) * 1.3, math.max(hn, hh) * 1.3

		local x, y = ScrW()/2, ScrH()/2 + ScreenScale(55)
		surface.SetTextColor(255, 255, 255, 255)
		draw.RoundedBox(5, x - w/2, y - h/2, w, h * 2, Color(0, 0, 0, 150))

		surface.SetTextPos(x - wn/2, y - hn / 2)
		surface.DrawText(name)

		surface.SetTextPos(x - wh / 2, y + h - hh / 2)
		surface.DrawText(hintText)
	end)
end