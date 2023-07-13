-- Just implementing the good ol hook for when a player's client is init'd and ready
AddCSLuaFile()

if SERVER then
	util.AddNetworkString("JazzPlayerClientStartup")

	net.Receive("jazzPlayerClientStartup", function(len, ply)
		if ply.JazzHasClientStarted then return end

		ply.JazzHasClientStarted = true
		hook.Run("OnClientInitialized", ply)
	end )
else
	hook.Add("Think", "JazzPlayerClientStartup", function()
		hook.Remove("Think", "JazzPlayerClientStartup")

		net.Start("JazzPlayerClientStartup")
		net.SendToServer()

		timer.Simple(0, function()
			hook.Run("OnClientInitialized", ply)
		end )
	end )
end
