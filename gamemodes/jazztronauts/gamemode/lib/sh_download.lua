if SERVER then
	util.AddNetworkString( "download_msg" )
	AddCSLuaFile("sh_download.lua")
end

DL_STARTED = 1
DL_PROGRESS = 2
DL_FINISHED = 3
DL_ERROR = 4

module( "download", package.seeall )

local registry = {}
local names = {}
local download_queue = {}
local threads = {}

local InitThread = nil

local dlmeta = {}
dlmeta.__index = dlmeta
dlmeta.__tostring = function(self)
	return ("%s: %i / %i (%0.2f%%) [ %i x %ib chunks ]"):format(
		self:GetName(),
		self:GetBytesDownloaded(),
		self:GetSize(),
		self:GetProgress() * 100,
		self:GetNumChunks(),
		self:GetChunkSize()
	)
end

function dlmeta:GetName() return self.name end
function dlmeta:GetBytesDownloaded() return self.downloaded end
function dlmeta:GetSize() return self.size end
function dlmeta:GetData() return self.data end
function dlmeta:GetDataCRC() return self.data_crc end
function dlmeta:GetCRC() return self.crc end
function dlmeta:GetProgress() return self.progress end
function dlmeta:GetNumChunks() return self.num_chunks end
function dlmeta:GetCurrentChunk() return self.current end
function dlmeta:GetChunkSize() return self.chunk_size end
function dlmeta:GetPlayer() return self.ply end
function dlmeta:GetError() return self.error end

local function CompressChunks( blob, chunk_size )

	local chunks = {}
	local compressed = util.Compress( blob )
	local crc = util.CRC( compressed )

	local i = 1
	repeat
		local nxt = math.min( #compressed, i + chunk_size )
		table.insert( chunks, compressed:sub( i, nxt == #compressed and nxt or nxt-1 ) )
		i = nxt
	until i == #compressed

	return chunks, #compressed, tonumber( crc )

end

local function ExpandChunks( chunks )

	local blob = ""
	local buf = ""
	local strings = {}
	for k,v in pairs( chunks ) do blob = blob .. v end

	local crc = util.CRC( blob )

	blob = util.Decompress( blob )

	return blob, tonumber( crc )

end

function Register( name, callback )

	local code = tonumber( util.CRC( name ) )
	registry[code] = callback
	names[code] = name

	print("REGISTER-DL: " .. tostring( code ) .. " = " .. name )

end

function Start( name, data, ply, chunk_size )

	if not SERVER then return end

	local code = tonumber( util.CRC( name ) )
	local reg = registry[ code ]
	if reg == nil then return false end
	if not IsValid( ply ) or not ply:IsPlayer() then return false end
	if not threads[ply] then
		Msg("No thread for player: " .. tostring(ply) .. " creating new thread")
		if not InitThread( ply ) then error("Unable to create thread") end
	end

	chunk_size = chunk_size or 512
	local chunks, size, crc = CompressChunks( data, chunk_size )
	local download = setmetatable({
		data = data,
		data_crc = crc,
		error = "",
		name = name,
		code = code,
		crc = crc,
		reg = reg,
		chunks = chunks,
		chunk_size = chunk_size,
		num_chunks = #chunks,
		size = size,
		ply = ply,
		current = 0,
		downloaded = 0,
	}, dlmeta)

	local thread = threads[ply]
	if thread.active ~= nil or thread.waiting_for_init then

		--If a download is currently active, or the player hasn't connected yet, table the download for later
		print("QUEUED DOWNLOAD: " .. tostring(ply) .. " " .. name)
		table.insert( download_queue[ply], download )
		--print( coroutine.status( thread.co ) )

	else

		--No active downloads, immediately start this download
		print("SEND DOWNLOAD: " .. tostring(ply) .. " " .. name)
		coroutine.resume( thread.co, download )
		--print( coroutine.status( thread.co ) )

	end

	return download

end

local function GetDownloadsForPlayer( ply )

	local queue = {}
	for k,v in pairs( download_queue ) do
		if v.ply == ply then table.insert( queue, v ) end
	end

	table.sort( queue, function(a,b) return a.when < b.when end )
	return queue

end

local function PlayerThread( ply, thread )

	download_queue[ply] = download_queue[ply] or {}

	print("WAITING ON CLIENT: " .. tostring(ply))

	coroutine.yield("init-wait")

	print("INIT PLAYER THREAD: " .. tostring(ply))

	while true do

		if not IsValid(ply) or not ply:IsPlayer() then
			print("Player not valid, probably disconnected")
			break
		end

		if download_queue[ply] == nil then
			print("OOPS, Yeah lost the download_queue for player: " .. tostring(ply))
			break
		end

		print("THREAD READY: " .. tostring(ply))

		local queued = #download_queue[ply] > 0 and download_queue[ply][1] or nil
		local download = queued or coroutine.yield("download-wait")
		thread.active = download

		if queued then table.remove( download_queue[ply], 1 ) end

		print("STARTING DOWNLOAD: " .. tostring( download.name ))

		download.reg( DL_STARTED, download )

		net.Start( "download_msg" )
		net.WriteBit( 1 )
		net.WriteUInt( download.code, 32 )
		net.WriteUInt( download.crc, 32 )
		net.WriteUInt( download.num_chunks, 32 )
		net.WriteUInt( download.size, 32 )
		net.WriteUInt( download.chunk_size, 16 )

		while download.current ~= download.num_chunks do

			if download.current ~= 0 then
				net.Start( "download_msg" )
				net.WriteBit( 0 )
			end

			download.current = download.current + 1
			download.downloaded = math.min( download.downloaded + download.chunk_size, download.size )
			download.progress = (download.downloaded / download.size)

			local chunk = download.chunks[ download.current ]

			net.WriteUInt( download.current, 32 )
			net.WriteData( chunk, #chunk )
			net.Send( ply )

			thread.awaiting_response = true
			thread.ttl = CurTime() + 15
			local response = coroutine.yield()
			if response ~= "ok" then
				ErrorNoHalt( "Download failed for " .. tostring(ply) .. " : " .. tostring( response ) .. "\n")
				thread.awaiting_response = false
				download.error = response
				download.reg( DL_ERROR, download, response )
				break
			elseif download.current == download.num_chunks then
				download.reg( DL_PROGRESS, download )
				download.reg( DL_FINISHED, download )
			else
				download.reg( DL_PROGRESS, download )
			end

			thread.awaiting_response = false

		end

		thread.ttl = -1
		thread.active = nil

	end

	download_queue[ply] = nil

end

if SERVER then

	InitThread = function( ply )

		if threads[ply] then return false end
		local co = coroutine.create( PlayerThread )
		threads[ply] = {
			co = co,
			active = nil,
			awaiting_response = false,
			waiting_for_init = true,
			ttl = -1,
		}

		local thread = threads[ply]
		print(coroutine.resume( co, ply, thread ))
		return true

	end

	for _, ply in pairs( player.GetAll() ) do

		InitThread( ply )

	end

	hook.Add( "Think", "download_thread_ttl", function()

		for _, thread in pairs( threads ) do
			if thread.ttl ~= -1 and thread.ttl - CurTime() <= 0 then
				coroutine.resume( thread.co, "timed-out" )
			end
		end

	end )

	hook.Add( "PlayerInitialSpawn", "download_thread", function(ply)

		InitThread( ply )

	end )

	net.Receive( "download_msg", function( len, ply )

		local thread = threads[ply]
		if thread == nil then
			return
		end

		local chunkid = net.ReadUInt( 32 )
		if chunkid == 0 then
			net.Start( "download_msg" )
			net.WriteBit( 0 )
			net.WriteUInt( 0, 32 )
			net.Send( ply )
		end

		if thread.waiting_for_init then
			thread.waiting_for_init = false
			coroutine.resume( thread.co, "ok" )
			return
		end

		if not thread.awaiting_response then return end

		if thread.active.current == chunkid or chunkid == 0 then
			coroutine.resume( thread.co, "ok" )
		elseif thread.active.current > chunkid then
			-- Received duplicate chunk, but safe to ignore
			print("DL-WARNING: Received duplicate chunkID " .. chunkid .. " (expected " .. thread.active.current .. ") from " .. tostring(ply))
		else
			coroutine.resume( thread.co, "out-of-order chunk " .. chunkid .. " expected " .. thread.active.current)
		end

	end )

else

	local download = nil
	local server_acked = false

	net.Receive( "download_msg", function( len, ply )

		local ok = false
		local init = net.ReadBit() == 1
		if init then
			download = setmetatable({
				data = "",
				data_crc = 0,
				error = "",
				code = net.ReadUInt( 32 ),
				crc = net.ReadUInt( 32 ),
				num_chunks = net.ReadUInt( 32 ),
				size = net.ReadUInt( 32 ),
				chunk_size = net.ReadUInt( 16 ),
				downloaded = 0,
				progress = 0,
				ply = LocalPlayer(),
				current = 1,
				chunks = {}
			}, dlmeta)

			local reg = registry[download.code]
			if not reg then error("No callback for download on client") end
			download.reg = reg
			download.name = names[ download.code ] or "<unnamed>"
			download.reg( DL_STARTED, download )
		end

		local chunkid = net.ReadUInt( 32 )

		if chunkid == 0 then
			server_acked = true
			return
		end

		if not download then error("No download active") end

		if chunkid ~= download.current then error("out-of-order chunk") end
		if chunkid ~= download.num_chunks then

			table.insert( download.chunks, net.ReadData( download.chunk_size ) )
			download.current = download.current + 1
			download.downloaded = download.downloaded + download.chunk_size
			download.progress = download.downloaded / download.size
			download.reg( DL_PROGRESS, download )
			ok = true

		else

			local remain = download.size - download.downloaded
			table.insert( download.chunks, net.ReadData( remain ) )
			download.current = download.current + 1
			download.downloaded = download.size
			download.progress = 1

			local data, crc = ExpandChunks( download.chunks )

			download.data = data
			download.data_crc = crc

			if crc ~= download.crc then
				download.error = "BAD CHECKSUM: " .. tostring( crc ) .. " != " .. tostring( download.crc )
				download.reg( DL_ERROR, download )
				ok = false
			else
				download.reg( DL_PROGRESS, download )
				download.reg( DL_FINISHED, download )
				download = nil
				ok = true
			end

		end

		if ok then
			net.Start( "download_msg" )
			net.WriteUInt( chunkid, 32 )
			net.SendToServer()
		end

	end )

	local next_ping = 0
	hook.Add( "Think", "init_dl_client", function()
		if server_acked or next_ping > CurTime() then return end

		net.Start( "download_msg" )
		net.WriteUInt( 0, 32 )
		net.SendToServer()

		next_ping = CurTime() + 2
	end)

end


Register("mydownload", function(cb, dl)

if CLIENT then

	if cb == DL_STARTED then
		print("DL-Start: " .. tostring(dl))
	end

	if cb == DL_PROGRESS then
		print("DL-Progress: " .. tostring(dl))
	end

	if cb == DL_FINISHED then
		print("DL-Finished: " .. tostring(dl))

		local data = string.Explode( "\n", dl:GetData() )
		task.New( function()

			print("\n\n********************************")
			print("********************************")
			print("***** I HOPE YOU LIKE JAZZ *****")
			print("********************************")
			print("********************************\n\n")

			task.Sleep( 2 )

			--[[local k = 1
			while k ~= #data do
				local f = k / #data
				local c = f * (1-f) * 4
				local s = 1 + c * 100
				print( data[k] )
				k = k + 1
				task.Sleep( 1 / s )
			end]]

		end )

	end

	if cb == DL_ERROR then
		print("ERROR: " .. tostring(dl.error) )
	end

else

	if cb == DL_PROGRESS then
		print("DL-Progress: " .. tostring(dl:GetPlayer()) .. " : " .. tostring(dl))
	end

end

end)
