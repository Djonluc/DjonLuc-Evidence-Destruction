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

-- Utility to safely spawn a vehicle (Failsafe Version)
function SafeSpawnVehicle(modelName, coords)
    local modelHash = joaat(modelName)

    -- Server-side CreateVehicle
    -- Using the model hash and trusting the engine to handle it
    local veh = CreateVehicle(modelHash, coords.x, coords.y, coords.z + 1.0, coords.w, true, true)

    if not veh or veh == 0 or not DoesEntityExist(veh) then
        print("^1[CONVOY ERROR]^7 Vehicle spawn failed for model: " .. tostring(modelName))
        return nil
    end

    SetVehicleOnGroundProperly(veh)
    SetEntityAsMissionEntity(veh, true, true)

    local netId = NetworkGetNetworkIdFromEntity(veh)
    TriggerClientEvent("djonluc:client:stabilizeVehicle", -1, netId)

    print("^2[CONVOY]^7 Vehicle spawned: " .. tostring(modelName))
    return veh
end

function SpawnPedInVehicle(vehicle, pedData, seat)
    local modelHash = joaat(pedData.model)

    -- Server-side CreatePed
    local ped = CreatePed(28, modelHash, 0.0, 0.0, 0.0, 0.0, true, false)
    if not DoesEntityExist(ped) then
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
    
    -- Delegate client-only tactical attributes (SetPedAsCop, Accuracy, Armor, etc.) to Client
    TriggerClientEvent("djonluc:client:setGuardGroup", -1, pedNetId, vehNetId, seat or -1, pedData.accuracy, pedData.armor, pedData.weapon)

    print("^2[CONVOY]^7 Guard spawned: " .. tostring(pedData.model))
    return ped
end

function SpawnFullConvoy()
    print("^3[CONVOY]^7 Starting full failsafe convoy spawn...")
    local start = Config.Route.Start
    local formation = Config.Formation

    -- 1️⃣ FRONT: ARMORED RIOT VAN (LEADER)
    Convoy.van = SafeSpawnVehicle(formation.Van.model, start)
    if not Convoy.van then
        print("^1[CONVOY ERROR]^7 Van spawn failed. Aborting convoy.")
        return false
    end

    table.insert(Convoy.guards, SpawnPedInVehicle(Convoy.van, Config.Peds.Driver, -1))
    table.insert(Convoy.guards, SpawnPedInVehicle(Convoy.van, Config.Peds.Guard, 0))

    -- 2️⃣ ESCORTS
    
    -- Bikes (Behind Van)
    for i, bikeData in ipairs(formation.Bikes) do
        local side = (i == 1 and -2.0 or 2.0)
        local bikePos = vector4(start.x, start.y, start.z, start.w)
        -- Pure vector math for offset compatibility
        bikePos = vector4(
            bikePos.x + math.sin(math.rad(bikePos.w)) * -8.0 + math.cos(math.rad(bikePos.w)) * side,
            bikePos.y + math.cos(math.rad(bikePos.w)) * -8.0 - math.sin(math.rad(bikePos.w)) * side,
            bikePos.z,
            bikePos.w
        )

        local bike = SafeSpawnVehicle(bikeData.model, bikePos)
        if bike then
            table.insert(Convoy.escorts, bike)
            table.insert(Convoy.guards, SpawnPedInVehicle(bike, Config.Peds.Driver, -1))
        end
    end

    -- Patrol (16m behind)
    local patrolPos = vector4(start.x, start.y, start.z, start.w)
    patrolPos = vector4(
        patrolPos.x + math.sin(math.rad(patrolPos.w)) * -16.0,
        patrolPos.y + math.cos(math.rad(patrolPos.w)) * -16.0,
        patrolPos.z,
        patrolPos.w
    )

    local patrol = SafeSpawnVehicle(formation.Patrol.model, patrolPos)
    if patrol then
        table.insert(Convoy.escorts, patrol)
        table.insert(Convoy.guards, SpawnPedInVehicle(patrol, Config.Peds.Guard, 0))
        table.insert(Convoy.guards, SpawnPedInVehicle(patrol, Config.Peds.Guard, 1))
    end

    -- SUV (24m behind)
    local suvPos = vector4(start.x, start.y, start.z, start.w)
    suvPos = vector4(
        suvPos.x + math.sin(math.rad(suvPos.w)) * -24.0,
        suvPos.y + math.cos(math.rad(suvPos.w)) * -24.0,
        suvPos.z,
        suvPos.w
    )

    local suv = SafeSpawnVehicle(formation.SUV.model, suvPos)
    if suv then
        table.insert(Convoy.escorts, suv)
        for s = 0, (formation.SUV.seats - 2) do
            table.insert(Convoy.guards, SpawnPedInVehicle(suv, Config.Peds.Guard, s))
        end
    end

    -- Rear Escort (32m behind)
    local rearPos = vector4(start.x, start.y, start.z, start.w)
    rearPos = vector4(
        rearPos.x + math.sin(math.rad(rearPos.w)) * -32.0,
        rearPos.y + math.cos(math.rad(rearPos.w)) * -32.0,
        rearPos.z,
        rearPos.w
    )

    local rear = SafeSpawnVehicle(formation.Rear.model, rearPos)
    if rear then
        table.insert(Convoy.escorts, rear)
        for r = 0, (formation.Rear.seats - 2) do
            table.insert(Convoy.guards, SpawnPedInVehicle(rear, Config.Peds.Guard, r))
        end
    end

    print("^2[CONVOY]^7 Full failsafe convoy spawned successfully.")
    return true
end
