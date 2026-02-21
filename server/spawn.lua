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

-- EXTREME SANITIZED SPAWN (Server-Side Only Natives)
function SafeSpawnVehicle(modelNames, coords)
    local models = type(modelNames) == "table" and modelNames or {modelNames}
    local spawnedVeh = nil

    for _, model in ipairs(models) do
        local modelHash = joaat(model)
        print("^3[CONVOY DEBUG]^7 Attempting to spawn: " .. tostring(model) .. " | Hash: " .. tostring(modelHash))

        for pass = 1, 3 do
            -- Server-safe: isNetwork=true, isDynamic=false
            local veh = CreateVehicle(modelHash, coords.x, coords.y, coords.z + 1.2, coords.w, true, false)
            
            -- Wait a tick for handle registration
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
    end

    if not spawnedVeh or not DoesEntityExist(spawnedVeh) then
        print("^1[CONVOY ERROR]^7 CRITICAL: All models and passes failed to spawn or entity was lost.")
        return nil
    end

    -- Robust NetID wait
    local netId = 0
    for i = 1, 10 do
        netId = NetworkGetNetworkIdFromEntity(spawnedVeh)
        if netId and netId ~= 0 then break end
        Wait(50)
    end

    if not netId or netId == 0 then
        print("^1[CONVOY WARNING]^7 Failed to get netId for " .. tostring(spawnedVeh) .. " - Sync issues ممکن!")
    end

    -- Delegate stabilization to client (Engine, Doors, Migration, Mission Status)
    TriggerClientEvent("djonluc:client:stabilizeVehicle", -1, netId)

    return spawnedVeh
end

function SpawnPedInVehicle(vehicle, pedData, seat)
    if not vehicle or not DoesEntityExist(vehicle) then
        print("^1[CONVOY ERROR]^7 Cannot spawn ped: Vehicle is invalid.")
        return nil
    end

    local modelHash = joaat(pedData.model)
    local vCoords = GetEntityCoords(vehicle)

    -- LOCALIZED CREATION: Spawn at vehicle pos to ensure handle validity
    local ped = nil
    for pass = 1, 3 do
        -- Type 4: human/security (Universal)
        ped = CreatePed(4, modelHash, vCoords.x, vCoords.y, vCoords.z, 0.0, true, false)
        Wait(0)
        
        if ped and ped ~= 0 and DoesEntityExist(ped) then 
            print("^2[CONVOY]^7 Ped spawned successfully: " .. tostring(pedData.model) .. " (Pass " .. pass .. ") | Handle: " .. tostring(ped))
            break 
        else
            print("^3[CONVOY DEBUG]^7 Ped spawn pass " .. pass .. " failed for " .. tostring(pedData.model))
        end
    end

    if not ped or ped == 0 or not DoesEntityExist(ped) then
        print("^1[CONVOY ERROR]^7 Failed to create ped after all passes: " .. tostring(pedData.model))
        return nil
    end

    -- STABILITY: Warp into seat
    SetPedIntoVehicle(ped, vehicle, seat or -1)
    Wait(50) -- Wait for OneSync to sync seat occupancy

    -- Robust Ped NetID wait loop
    local pedNetId = 0
    for i = 1, 15 do
        pedNetId = NetworkGetNetworkIdFromEntity(ped)
        if pedNetId and pedNetId ~= 0 then break end
        Wait(50)
    end

    -- Robust Vehicle NetID wait loop
    local vehNetId = 0
    for i = 1, 15 do
        vehNetId = NetworkGetNetworkIdFromEntity(vehicle)
        if vehNetId and vehNetId ~= 0 then break end
        Wait(50)
    end

    if not pedNetId or pedNetId == 0 or not vehNetId or vehNetId == 0 then
        print("^1[CONVOY WARNING]^7 Failed to sync NetIDs for ped/vehicle - Tactical setup may fail.")
    end
    
    -- ALL tactical setup (Weapons, Accuracy, Armour, BlockingEvents, Mission Status) done client-side
    TriggerClientEvent("djonluc:client:setGuardGroup", -1, pedNetId, vehNetId, seat or -1, pedData.accuracy, pedData.armor, pedData.weapon)

    return ped
end

function SpawnFullConvoy()
    print("^3[CONVOY]^7 Starting EXTREME ORDER spawn sequence (Vehicles -> Peds)...")
    local start = Config.Route.Start
    local formation = Config.Formation

    -- STAGE 1: Spawn all Vehicles
    local vehicleTable = {}

    -- 1) Lead Van
    local vanModels = { formation.Van.model, "stockade", "police4" }
    Convoy.van = SafeSpawnVehicle(vanModels, start)
    if not Convoy.van then return false end
    print("^2[CONVOY]^7 Van spawned.")

    -- 2) Escorts (Pure Vector Math Offsets)
    for i, bikeData in ipairs(formation.Bikes) do
        local side = (i == 1 and -2.2 or 2.2)
        local bikePos = vector4(
            start.x + math.sin(math.rad(start.w)) * -8.0 + math.cos(math.rad(start.w)) * side,
            start.y + math.cos(math.rad(start.w)) * -8.0 - math.sin(math.rad(start.w)) * side,
            start.z,
            start.w
        )
        local bike = SafeSpawnVehicle({bikeData.model, "policeb2"}, bikePos)
        if bike then
            table.insert(Convoy.escorts, bike)
            table.insert(vehicleTable, {veh = bike, type = "bike"})
        end
    end

    -- 3) Patrol (16m)
    local patrolPos = vector4(
        start.x + math.sin(math.rad(start.w)) * -16.0,
        start.y + math.cos(math.rad(start.w)) * -16.0,
        start.z,
        start.w
    )
    local patrol = SafeSpawnVehicle({formation.Patrol.model, "police2"}, patrolPos)
    if patrol then
        table.insert(Convoy.escorts, patrol)
        table.insert(vehicleTable, {veh = patrol, type = "patrol"})
    end

    -- 4) SUV (24m)
    local suvPos = vector4(
        start.x + math.sin(math.rad(start.w)) * -24.0,
        start.y + math.cos(math.rad(start.w)) * -24.0,
        start.z,
        start.w
    )
    local suv = SafeSpawnVehicle({formation.SUV.model, "fbi2"}, suvPos)
    if suv then
        table.insert(Convoy.escorts, suv)
        table.insert(vehicleTable, {veh = suv, type = "suv"})
    end

    -- 5) Rear (32m)
    local rearPos = vector4(
        start.x + math.sin(math.rad(start.w)) * -32.0,
        start.y + math.cos(math.rad(start.w)) * -32.0,
        start.z,
        start.w
    )
    local rear = SafeSpawnVehicle({formation.Rear.model, "fbi"}, rearPos)
    if rear then
        table.insert(Convoy.escorts, rear)
        table.insert(vehicleTable, {veh = rear, type = "rear"})
    end

    print("^3[CONVOY]^7 Vehicles spawned. Waiting for entity settlement...")
    Wait(1000) -- Increased wait for network stability

    -- STAGE 2: Spawn all Peds
    print("^3[CONVOY]^7 Initializing Peds (Staggered Spawning)...")

    -- Van Peds
    table.insert(Convoy.guards, SpawnPedInVehicle(Convoy.van, Config.Peds.Driver, -1))
    Wait(100)
    table.insert(Convoy.guards, SpawnPedInVehicle(Convoy.van, Config.Peds.Guard, 0))
    Wait(100)

    -- Escort Peds
    for _, data in ipairs(vehicleTable) do
        if DoesEntityExist(data.veh) then
            -- ALL VEHICLES GET A DRIVER
            print("^3[CONVOY DEBUG]^7 Spawning driver for vehicle type: " .. tostring(data.type))
            table.insert(Convoy.guards, SpawnPedInVehicle(data.veh, Config.Peds.Driver, -1))
            Wait(100)

            -- Add extra guards based on type
            if data.type == "patrol" then
                table.insert(Convoy.guards, SpawnPedInVehicle(data.veh, Config.Peds.Guard, 0))
                Wait(100)
            elseif data.type == "suv" or data.type == "rear" then
                -- SUVs and Rear vehicles always get 3 extra guards (Seats 0, 1, 2)
                print("^3[CONVOY DEBUG]^7 Spawning 3 guards for SUV/Rear vehicle.")
                for s = 0, 2 do
                    table.insert(Convoy.guards, SpawnPedInVehicle(data.veh, Config.Peds.Guard, s))
                    Wait(100)
                end
            end
        end
    end

    print("^2[CONVOY]^7 Full convoy order-spawn complete.")
    return true
end
