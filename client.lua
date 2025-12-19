-- Anti-duplicate vehicle client
local sentSpawns = {}

AddEventHandler('entityCreated', function(entity)
	if not DoesEntityExist(entity) then return end
	if not IsEntityAVehicle(entity) then return end

	-- small wait so vehicle properties are available
	Citizen.Wait(100)

	if not DoesEntityExist(entity) or not IsEntityAVehicle(entity) then return end

	local netId = NetworkGetNetworkIdFromEntity(entity)
	local model = GetEntityModel(entity)
	local plate = GetVehicleNumberPlateText(entity)

	-- Ensure we don't spam the server for the same entity
	if sentSpawns[netId] then return end

	-- Check network ownership — if the local player is owner, report spawn
	local owner = NetworkGetEntityOwner(entity)
	if owner == PlayerId() then
		sentSpawns[netId] = true
		TriggerServerEvent('antidup:vehicleSpawned', netId, model, plate, GetGameTimer())
	end
end)

RegisterNetEvent('antidup:deleteVehicle', function(netId)
	if not netId then return end
	local ent = NetworkGetEntityFromNetworkId(netId)
	if DoesEntityExist(ent) then
		SetEntityAsMissionEntity(ent, true, true)
		DeleteVehicle(ent)
	end
	sentSpawns[netId] = nil
end)

-- Optional: request deletion of multiple IDs
RegisterNetEvent('antidup:deleteVehicles', function(netIds)
	if type(netIds) ~= 'table' then return end
	for _, id in ipairs(netIds) do
		local ent = NetworkGetEntityFromNetworkId(id)
		if DoesEntityExist(ent) then
			SetEntityAsMissionEntity(ent, true, true)
			DeleteVehicle(ent)
		end
		sentSpawns[id] = nil
	end
end)

-- Debug helper
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60000)
		-- cleanup sentSpawns table occasionally
		for k,v in pairs(sentSpawns) do
			if not NetworkDoesNetworkIdExist(k) then sentSpawns[k] = nil end
		end
	end
end)