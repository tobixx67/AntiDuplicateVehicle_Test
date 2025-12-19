-- Anti Duplicate Vehicle server
local Config = require('config')

-- store last spawn per player source
local lastSpawn = {}

-- Helper for debug printing
local function dbg(...)
  if Config.debug then
    print('[antidup] ', ...) 
  end
end

RegisterNetEvent('antidup:vehicleSpawned')
AddEventHandler('antidup:vehicleSpawned', function(netId, model, plate, gameTimer)
  local src = source
  if not src then return end
  if not netId or not model then return end

  local now = gameTimer or os.time()*1000
  local prev = lastSpawn[src]

  if prev then
    local dt = now - prev.ts
    if dt <= (Config.duplicateWindowSeconds * 1000) then
      local sameModel = (prev.model == model)
      local samePlate = (prev.plate == plate)
      local plateCheck = (not Config.requireSamePlate) or samePlate

      if sameModel and plateCheck then
        dbg('Duplicate detected from source', src, 'model', model, 'netIds', prev.netId, netId)
        -- broadcast delete to all clients (ensures entity is removed everywhere)
        TriggerClientEvent('antidup:deleteVehicles', -1, {prev.netId, netId})
        if Config.notifyPlayers then
          TriggerClientEvent('chat:addMessage', src, { args = { '^1AntiDupe', 'Two identical vehicles spawned too quickly - vehicles removed.' } })
        end
        -- clear last spawn for this source
        lastSpawn[src] = nil
        return
      end
    end
  end

  -- store this spawn as the latest for the player
  lastSpawn[src] = {
    netId = netId,
    model = model,
    plate = plate,
    ts = now
  }

  -- ensure stale entries don't linger: clear after window expires
  Citizen.SetTimeout((Config.duplicateWindowSeconds * 1000) + 500, function()
    local cur = lastSpawn[src]
    if cur and cur.netId == netId then
      lastSpawn[src] = nil
    end
  end)
end)

AddEventHandler('playerDropped', function()
  local src = source
  if src and lastSpawn[src] then lastSpawn[src] = nil end
end)

dbg('Anti-duplicate server loaded')