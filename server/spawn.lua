-- server/spawn.lua

Convoy = {
    active = false,
    state = "CALM",
    van = nil,
    escorts = {},
    guards = {},
    health = 0,
    destroyed = false,
    startedAt = 0,
    underAttack = false
}

-- Comprehensive Diagnostic Spawn (Multi-Pass + Fallback)
function SafeSpawnVehicle(modelNames, coords)
    -- Normalize to table for fallback support
    local models = type(modelNames) == "table" and modelNames or {modelNames}
    local spawnedVeh = nil

    for _, model in ipairs(models) do
        local modelHash = joaat(model)
        
        -- Debugging hash
        print("^3[CONVOY DEBUG]^7 Attempting to spawn: " .. tostring(model) .. " | Hash: " .. tostring(modelHash))

        -- Multi-pass retry loop
        for pass = 1, 3 do
            -- Server-safe: true (isNetwork), false (isDynamic)
            local veh = CreateVehicle(modelHash, coords.x, coords.y, coords.z + 1.2, coords.w, true, false)
            
            -- MUST wait a tick for server handle registration
            Wait(0)

            if veh and veh ~= 0 then
                spawnedVeh = veh
                print("^2[CONVOY]^7 Vehicle spawned successfully: " .. tostring(model) .. " (Pass " .. pass .. ")")
                break
            else
                print("^3[CONVOY DEBUG]^7 Pass " .. pass .. " failed for " .. tostring(model))
            end
        end

        if spawnedVeh then break end
        print("^1[CONVOY WARNING]^7 All passes failed for model: " .. tostring(model) .. ". Trying fallback if available...")
    end

    if not spawnedVeh then
        print("^1[CONVOY ERROR]^7 CRITICAL: All models and passes failed to spawn at " .. tostring(coords))
        return nil
    end

    SetVehicleOnGroundProperly(spawnedVeh)
    SetEntityAsMissionEntity(spawnedVeh, true, true)

    local netId = NetworkGetNetworkIdFromEntity(spawnedVeh)
    TriggerClientEvent("djonluc:client:stabilizeVehicle", -1, netId)

    return spawnedVeh
end

function SpawnPedInVehicle(vehicle, pedData, seat)
    local modelHash = joaat(pedData.model)

    -- Multi-pass ped spawn with server-side nuances
    local ped = nil
    for pass = 1, 3 do
        ped = CreatePed(28, modelHash, 0.0, 0.0, 0.0, 0.0, true, false)
        Wait(0)
        if ped and ped ~= 0 then break end
    end

    if not ped or ped == 0 then
        print("^1[CONVOY ERROR]^7 Failed to create ped: " .. tostring(pedData.model))
        return nil
    end

    SetPedIntoVehicle(ped, vehicle, seat or -1)

    -- Server-Safe Persistence & Equipment
    SetBlockingOfNonTemporaryEvents(ped, true)
    GiveWeaponToPed(ped, joaat(pedData.weapon), 500, false, true)
    SetEntityAsMissionEntity(ped, true, true)

    local pedNetId = NetworkGetNetworkIdFromEntity(ped)
    local vehNetId = NetworkGetNetworkIdFromEntity(vehicle)
    
    -- Delegate tactical attributes to Client
    TriggerClientEvent("djonluc:client:setGuardGroup", -1, pedNetId, vehNetId, seat or -1, pedData.accuracy, pedData.armor, pedData.weapon)

    return ped
end

function SpawnFullConvoy()
    print("^3[CONVOY]^7 Starting full diagnostic convoy spawn sequence...")
    local start = Config.Route.Start
    local formation = Config.Formation

    -- 1️⃣ FRONT: ARMORED VAN (LEADER)
    -- Primary: Riot, Fallbacks: Stockade, Police4 (Unmarked)
    local vanModels = { formation.Van.model, "stockade", "police4" }
    Convoy.van = SafeSpawnVehicle(vanModels, start)
    
    if not Convoy.van then
        print("^1[CONVOY ERROR]^7 Convoy canceled: Could not spawn any viable lead vehicle.")
        return false
    end

    table.insert(Convoy.guards, SpawnPedInVehicle(Convoy.van, Config.Peds.Driver, -1))
    table.insert(Convoy.guards, SpawnPedInVehicle(Convoy.van, Config.Peds.Guard, 0))

    -- 2️⃣ ESCORTS
    
    -- Bikes (Behind Van)
    for i, bikeData in ipairs(formation.Bikes) do
        local side = (i == 1 and -2.2 or 2.2)
        local bikePos = vector4(
            start.x + math.sin(math.rad(start.w)) * -8.0 + math.cos(math.rad(start.w)) * side,
            start.y + math.cos(math.rad(start.w)) * -8.0 - math.sin(math.rad(start.w)) * side,
            start.z,
            start.w
        )

        local bike = SafeSpawnVehicle({bikeData.model, "policeb2", "faggio"}, bikePos)
        if bike then
            table.insert(Convoy.escorts, bike)
            table.insert(Convoy.guards, SpawnPedInVehicle(bike, Config.Peds.Driver, -1))
        end
    end

    -- Patrol (16m behind)
    local patrolPos = vector4(
        start.x + math.sin(math.rad(start.w)) * -16.0,
        start.y + math.cos(math.rad(start.w)) * -16.0,
        start.z,
        start.w
    )

    local patrol = SafeSpawnVehicle({formation.Patrol.model, "police2", "police"}, patrolPos)
    if patrol then
        table.insert(Convoy.escorts, patrol)
        table.insert(Convoy.guards, SpawnPedInVehicle(patrol, Config.Peds.Guard, 0))
        table.insert(Convoy.guards, SpawnPedInVehicle(patrol, Config.Peds.Guard, 1))
    end

    -- SUV (24m behind)
    local suvPos = vector4(
        start.x + math.sin(math.rad(start.w)) * -24.0,
        start.y + math.cos(math.rad(start.w)) * -24.0,
        start.z,
        start.w
    )

    local suv = SafeSpawnVehicle({formation.SUV.model, "fbi2", "granger"}, suvPos)
    if suv then
        table.insert(Convoy.escorts, suv)
        for s = 0, (formation.SUV.seats or 4) - 2 do
            table.insert(Convoy.guards, SpawnPedInVehicle(suv, Config.Peds.Guard, s))
        end
    end

    -- Rear Escort (32m behind)
    local rearPos = vector4(
        start.x + math.sin(math.rad(start.w)) * -32.0,
        start.y + math.cos(math.rad(start.w)) * -32.0,
        start.z,
        start.w
    )

    local rear = SafeSpawnVehicle({formation.Rear.model, "fbi", "sheriff2"}, rearPos)
    if rear then
        table.insert(Convoy.escorts, rear)
        for r = 0, (formation.Rear.seats or 4) - 2 do
            table.insert(Convoy.guards, SpawnPedInVehicle(rear, Config.Peds.Guard, r))
        end
    end

    print("^2[CONVOY]^7 Full diagnostic convoy initialization complete.")
    return true
end
