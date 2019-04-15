if SERVER then AddCSLuaFile("sh_task.lua") end

TASK_PRIORITY_DEFAULT = 1

module( "task", package.seeall )

local TASK_TIME_SLICE = 0.008
local HITCH_THESHOLD = 0.05
local MAX_TASK_ITERATIONS = 100000
local TASK_HITCH_DETECTION = true
local TASK_PRIORITIZATION = true

tasks = tasks or {}
g_task = g_task or nil

local meta = {}
meta.__index = meta

local function CallTaskHook( task, hook, ... )

	hook = task.hooks[hook]
	if not hook then return end
	local res = { pcall( hook, task, ... ) }
	local b = res[1]
	table.remove( res, 1 )

	if not b then
		ErrorNoHalt( unpack( res ) )
	else
		task.queuedparams = res
	end

end

function New(...)

	return setmetatable({}, meta):Init(...)

end

-- Create a task that is finished once a callback is called
-- While waiting, it simply sleeps indefinitely
function NewCallback(func)
	local t = nil
	local results = {}
	local done = false
	local function doneFunc(...)
		if t then
			t.sleep = 0 -- Wake up the thread
		end

		results = { ... }
		done = true
	end

	t = task.New(function()
		func(doneFunc)

		-- Allow calls that exit immediately
		if not done then
			task.Sleep(999999)
		end

		return unpack(results)
	end, 1)

	return t
end


function YieldPer( x, ... )

	if g_task ~= nil then
		g_task.count = g_task.count + 1
		if (g_task.count-1) % x > g_task.count % x then
			local inf = debug.getinfo( 2 )
			g_task.currentline = inf.currentline
			return coroutine.yield( ... )
		end
	end

end

function Yield( ... )

	if g_task ~= nil then
		local inf = debug.getinfo( 2 )
		g_task.currentline = inf.currentline
		return coroutine.yield( ... )
	end

end

function Sleep( seconds, ... )

	if g_task ~= nil then
		local inf = debug.getinfo( 2 )
		g_task.currentline = inf.currentline
		g_task.sleep = SysTime() + seconds
		return coroutine.yield( ... )
	end

end

function Await( other, ... )

	if g_task ~= nil then
		assert( getmetatable(other) == meta )
		if not other.running then return other.result end
		for _, w in pairs(other.waiters) do
			if w == g_task then ErrorNoHalt("Already waiting on task") return end
		end
		local inf = debug.getinfo( 2 )
		g_task.currentline = inf.currentline
		g_task.sleep = SysTime() + 999999 --basically forever ok?
		g_task.waitcount = ( g_task.waitcount or 0 ) + 1
		table.insert( other.waiters, g_task )
		return coroutine.yield( ... )
	end

end

meta.__newindex = function( self, k, v )

	if type(v) == "function" and rawget(self, "work") ~= nil then
		rawset( self.hooks, k, v )
		return
	end
	rawset( self, k, v )

end

function meta:Init( work, priority, ... )

	priority = math.max( priority or TASK_PRIORITY_DEFAULT, 0 )
	if type(work) ~= "function" then return end

	self.work = work
	self.starting = true
	self.params = {...}
	self.start = SysTime()
	self.priority = priority
	self.lastCycle = 0
	self.sleep = 0
	self.info = debug.getinfo( self.work )
	self.co = coroutine.create( self.work )
	self.count = 0
	self.hooks = {}
	self.waiters = {}
	self.running = true

	table.insert( tasks, self )
	return self

end

function meta:GetStartTime() return self.start end
function meta:GetPriority() return self.priority end
function meta:IsFinished() return not self.running end
function meta:IsSleeping() return self.sleep > SysTime() end
function meta:IsWaiting() return self.waitcount and self.waitcount > 0 end

local function IsTaskAsleep( task )

	return task.sleep > SysTime()

end

local function GetPriorityValue( task )

	if task:IsSleeping() then return -1 end
	return ( SysTime() - task.lastCycle ) * task.priority

end

local function SortTasks()

	table.sort( tasks, function( a, b )

		return GetPriorityValue( a ) > GetPriorityValue( b )

	end )

end

local function WakeWaiters( task )

	for _, w in pairs( task.waiters ) do

		w.waitcount = math.max((w.waitcount or 0) - 1, 0)
		if w.waitcount == 0 then
			w.sleep = 0
			w.queuedparams = task.result
		end

	end
	task.waiters = nil

end

local function RemoveTask( task )

	task.running = false

	WakeWaiters( task )

	if #tasks > 0 and tasks[1] == task then
		table.remove( tasks, 1 )
	end

	for k,v in pairs( tasks ) do
		if v == task then table.remove( tasks, k ) return end
	end

end

local _noparams = {}
local function ResumeTask( task )

	local dead = false
	g_task = task

	local result = nil
	if task.starting then
		task.starting = false
		result = { coroutine.resume( task.co, unpack( task.params ) ) }
	else
		result = { coroutine.resume( task.co, unpack( task.queuedparams or _noparams ) ) }
		task.queuedparams = nil
	end

	if result then
		if result[1] == false then
			table.remove(result, 1)
			table.insert(result, "\n")
			ErrorNoHalt( unpack(result) )
			RemoveTask( task )
			g_task = nil
			return
		end
		table.remove(result, 1)
	end

	if coroutine.status( task.co ) == "dead" then
		local duration = SysTime() - task.start
		--print( ("Task Finished: %0.2fs"):format( duration ) )

		task.result = result
		RemoveTask( task )
		dead = true

		CallTaskHook( task, "OnFinished", duration, unpack( result ) )
	else
		if #result > 0 and type( result[1] ) == "string" then
			CallTaskHook( task, unpack( result) )
		end
	end

	g_task = nil
	return dead

end

local LastProcessTime = 0
local function ProcessTasks()
	-- HACK: To keep things playable for listen servers
	-- Only update once per frame (the server otherwise simulates multiple ticks per frame)
	if SERVER and not game.IsDedicated() then
		if RealTime() == LastProcessTime then return end
		LastProcessTime = RealTime()
	end

	if #tasks == 0 then return end

	local start = SysTime()

	local remaining_iterations = MAX_TASK_ITERATIONS
	local task_died = false
	local task_slept = false
	local task_yielded_timeslice = false

	if TASK_PRIORITIZATION then SortTasks() end

	local pre_num_tasks = #tasks
	while remaining_iterations > 0 and #tasks > 0 do

		local task_begin = SysTime()

		local run = tasks[1]
		if run:IsSleeping() then
			task_slept = true
		elseif ResumeTask( run ) then
			task_died = true
		end

		local task_end = SysTime()
		local task_duration = task_end - task_begin
		run.duration = math.max( run.duration or 0, task_duration )
		run.lastCycle = task_end

		if task_slept or task_died then
			break
		end

		if task_end - start > TASK_TIME_SLICE then
			task_yielded_timeslice = true
			break
		end

		remaining_iterations = remaining_iterations - 1

	end

	if not TASK_HITCH_DETECTION then return end

	if task_died then
		--print("TASK DIED")
	elseif task_slept then
		--print("TASK SLEPT")
	elseif #tasks == 0 then
		--print("TASKS EXHAUSTED")
	elseif remaining_iterations == 0 then
		--print("ITERATIONS EXHAUSTED")
	elseif task_yielded_timeslice then
		--print("TIMESLICE EXHAUSTED")
	else
		--print("SOMETHING")
	end

	local delta = SysTime() - start
	if delta > HITCH_THESHOLD then

		local ran_tasks = {}
		for k,v in pairs( tasks ) do
			if v.duration then
				table.insert( ran_tasks, v )
			end
		end

		table.sort( ran_tasks, function(a,b) return a.duration > b.duration end )

		local msg = ""
		msg = msg .. ("HITCHED: %0.3fs\n"):format( delta )

		for k,v in pairs(ran_tasks) do
			msg = msg .. (" %0.3fs %s : %i\n"):format( v.duration, v.info.source, v.currentline or 0 )
			if v.duration > HITCH_THESHOLD then
				msg = msg .. "  (Recommended: Call 'Yield' more often to release timeslice to engine)\n"
			end
		end

		print( msg )
	end

end
hook.Add("Think", "ProcessTasks", ProcessTasks)

if CLIENT then

	--[[local function BigTask()

		print("Starting the big task")
		for i=1, 30 do
			local x = 5
			for j=1, 10000000 do
				x = x + 5
				x = x - 5
				x = x * 2
				x = x / 2
				if j % 10000 == 1 then task.Yield() end
			end
			task.Yield()

			print(i, x)
		end

	end

	local t0 = task.New( BigTask, 1 )

	local function BigTask2()

		print("Starting the big task 2")
		for i=1, 40 do
			local x = 5
			for j=1, 10000000 do
				x = x + 5
				x = x - 5
				x = x * 2
				x = x / 2
				if j % 10000 == 1 then task.Yield() end
			end
			task.Yield()

			print(i, x)
		end

	end

	local t1 = task.New( BigTask2, 1 )

	local function SmallTask()
		print("Starting the small task, but let's wait for that big task")
		task.Await( t0 )
		task.Await( t1 )
		print("Hey, I'm the small task")
		print("I think we're done boys")
	end

	local t2 = task.New( SmallTask, 1 )]]

	--[[local function myTask( test )

		print( tostring(test) )
		for i=1, 30 do
			local x = 5
			for j=1, 10000000 do
				x = x + 5
				x = x - 5
				x = x * 2
				x = x / 2
				if j % 10000 == 1 then Yield() end
			end
			Yield()

			print(i, x)
		end

		return string.upper( tostring(test) )

	end

	New( myTask, 1, "hi there" )]]

	--[[local function smallTask()
		local x = 0
		for i=1, 1000 do
			x = x + 1
			if x == 100 then print( Sleep(1, "fuck", x) ) end
		end

		print(x)
	end

	local t = New( smallTask, 1 )
	function t:OnFinished( duration )
		print( "FINISHED THE TASK: " .. duration )
	end

	function t:fuck( x )
		print( "JUST TO PRINT: " .. x )
		return "HI FROM YIELD"
	end]]

end