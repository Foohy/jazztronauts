module( "converse", package.seeall )
ResetConvos()

AddMission(0, "mission0.accept", MISSION_AVAILABLE)
AddMission(0, "mission0.idle", MISSION_ACCEPTED)
AddMission(0, "mission0.turnin", MISSION_COMPLETED)

AddMission(1, "mission1.accept", MISSION_AVAILABLE)
AddMission(1, "mission1.idle", MISSION_ACCEPTED)
AddMission(1, "mission1.turnin", MISSION_COMPLETED)