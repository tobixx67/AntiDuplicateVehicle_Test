-- Anti Duplicate Vehicle Config
Config = {}

-- Time window (in seconds) within which two spawns of the same model are considered duplicates
Config.duplicateWindowSeconds = 2

-- If true, also require identical license plates to count as duplicates
Config.requireSamePlate = false

-- If true, the server will print debug information to the console
Config.debug = true

-- Notify players when their spawned vehicles are removed (toggle)
Config.notifyPlayers = true

return Config
