-- Proxy for point_viewcontrol to make them work on multiple players simultaneously

ENT.Type = "point"

local LOCK_CREATE_VIEWCONTROL = false

function ENT:Initialize()

	MsgC( Color(100,255,255), "****INITIALIZE jazz_view_control*****\n" )

	-- List of controllers this proxy manages
	self.controllers = {}

end

function ENT:KeyValue( key, value )

	--MsgC( Color(100,255,255), "****KEYVALUE[" .. tostring(self) .. "]: " .. tostring(key) .. " = " .. tostring(value) .. " *****\n" )

	-- Accept targetname as our own, does not propegate to instanced point_viewcontrols
	if key == "targetname" then self:SetName( value ) return end

	-- Intercept all keyvalues and store them locally to be copied onto new point_viewcontrols
	self.proxy_keyvalues = self.proxy_keyvalues or {}
	self.proxy_keyvalues[key] = value

end

function ENT:CreateViewController()

	-- This lock stops the 'OnEntityCreated' and 'EntityKeyValue' hooks from intercepting this new point_viewcontrol
	LOCK_CREATE_VIEWCONTROL = true

	-- New point_viewcontrol entity
	local controller = ents.Create("point_viewcontrol")

	-- Copy stored keyvalues on this proxy to the new point_viewcontrol
	for k,v in pairs( self.proxy_keyvalues ) do
		controller:SetKeyValue( k, v )
	end

	-- Spawn the new point_viewcontrol
	controller:Spawn()

	-- Release lock
	LOCK_CREATE_VIEWCONTROL = false

	return controller

end

function ENT:EnsureControllers()

	-- Ensure this proxy has one point_viewcontrol for each player
	for _, ply in pairs( player.GetAll() ) do

		-- Ensure the player is valid
		if not IsValid( ply ) or not ply:IsPlayer() then continue end

		-- Create a controller if there isn't one for this player
		if not self.controllers[ply] then self.controllers[ply] = self:CreateViewController() end

	end

end

function ENT:FireControllers( name, activator, caller, data )

	-- Iterate over every controller this proxy manages ( one for each player )
	for ply, controller in pairs( self.controllers ) do

		-- We use the controller's player as the activator / caller
		controller:Input( name, ply, ply, data )

	end

end

function ENT:DropControllers()

	-- Call disable on all controllers
	self:FireControllers( "disable", nil, nil, nil )

	-- Remove each controller
	for _, controller in pairs( self.controllers ) do
		controller:Remove()
	end

	-- Ensure players are restored
	for _, ply in pairs( player.GetAll() ) do

		ply:SetViewEntity( ply )
		ply:SetObserverMode( OBS_MODE_NONE )
		ply:UnLock()
		ply:Freeze( false )

		-- Clear proxy concurrency for this proxy
		if ply.current_viewcontrol_proxy == self then
			ply.current_viewcontrol_proxy = nil
		end

	end

	-- Clear controller list
	self.controllers = {}

end

function ENT:MakeCurrent()

	for _, ply in pairs( player.GetAll() ) do

		-- Check if player is watching through another viewcontrol proxy
		if IsValid( ply.current_viewcontrol_proxy ) and ply.current_viewcontrol_proxy ~= self then

			-- If they are, override the running proxy
			MsgC( Color(255,100,100), "****CONCURRENT PROXIES: Disabling other vc_proxy for " .. tostring(ply) .. "\n" )
			ply.current_viewcontrol_proxy:Disable( ply )

		end

		-- Make this the active proxy
		ply.current_viewcontrol_proxy = self

	end

end

function ENT:Enable( activator )

	-- Ensure each player has their own point_viewcontrol entity
	self:EnsureControllers()

	-- Make this proxy current, disables other proxies in use
	self:MakeCurrent()

	-- Fire 'enable' input on each controller
	self:FireControllers( "enable", activator, activator, nil )

end

function ENT:Disable( activator )

	-- We're done with all point_viewcontrol's at this point, clean up and remove them
	self:FireControllers( "disable", activator, activator, nil )

end

function ENT:OnRemove()

	MsgC( Color(100,255,255), "****REMOVE jazz_view_control*****\n" )

	-- Clean up and remove all managed point_viewcontrols under this proxy
	self:DropControllers()

end

function ENT:AcceptInput( name, activator, caller, data )

	-- Sanity check
	name = name:lower()

	-- Make sure all players have point_viewcontrols
	self:EnsureControllers()

	MsgC( Color(100,255,100), "****Accepting output: " .. tostring(name) .. " : " .. tostring(activator) .. " : " .. tostring(caller) .. " : " .. tostring(data) .. "\n" )

	-- Forward enable / disable to internals
	if name == "enable" then self:Enable( activator ) return end
	if name == "disable" then self:Disable( activator ) return end

	-- Otherwise, forward inputs directly to point_viewcontrol instances
	self:FireControllers( name, activator, caller, data )

end

local function CreateViewControlProxy()

	-- Proxy entity which will receive inputs
	local proxy = ents.Create("jazz_view_control")

	-- Spawn proxy entity
	proxy:Spawn()

	return proxy

end

local INITED_POST_ENTITY = false

hook.Add("EntityKeyValue", "view_control_proxy", function( ent, key, value )

	if ent:GetClass() != "point_viewcontrol" then return end

	-- Do not convert if this point_viewcontrol is being created by a jazz_view_control
	if LOCK_CREATE_VIEWCONTROL then return end

	-- Store all original string-based keyvalues for point_viewcontrol entities
	ent.stored_keyvalues = ent.stored_keyvalues or {}
	ent.stored_keyvalues[key] = value

	-- Do not do in-line creation unless the map has spawned fully
	if not INITED_POST_ENTITY then return end

	-- Create a proxy for this point_viewcontrol to copy keyvalues to
	ent.proxy = ent.proxy or CreateViewControlProxy()

	-- Copy all keyvalues except classname
	if key ~= "classname" then
		ent.proxy:SetKeyValue( key, value )
	end

	-- Original point_viewcontrol is no longer named, all inputs target proxy
	if key == "targetname" then return "" end

end)

hook.Add("OnEntityCreated", "view_control_proxy", function( ent )

	-- Only operate on point_viewcontrols
	if ent:GetClass() != "point_viewcontrol" then return end

	-- Do not convert if this point_viewcontrol is being created by a jazz_view_control
	if LOCK_CREATE_VIEWCONTROL then return end

	if INITED_POST_ENTITY then

		-- Remove old point_viercontrol after it has been converted to jazz_view_control
		timer.Simple(1, function() print("REMOVE POINT_VIEWCONTROL") ent:Remove() end)

	end

end )

hook.Add("InitPostEntity", "view_control_proxy", function()

	-- Remove any existing proxies in the off case we have any
	for _, ent in pairs( ents.FindByClass("jazz_view_control") ) do
		ent:Remove()
	end

	-- Find all point_viewcontrols and create proxies, remove original
	for _, ent in pairs( ents.FindByClass("point_viewcontrol") ) do

		-- Proxy entity which will receive inputs
		local proxy = ents.Create("jazz_view_control")

		-- Copy keyvalues to proxy entity
		for k,v in pairs( ent.stored_keyvalues ) do
			proxy:SetKeyValue(k, v)
		end

		-- Spawn proxy and remove original entity
		proxy:Spawn()
		ent:Remove()

	end

	-- Map has spawned, do in-line creation for any new point_viewcontrols
	INITED_POST_ENTITY = true

end)