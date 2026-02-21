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
    underAttack = false,
    lastEvent = 0
}

local function GetBehindPosition(base, distForward, distSide)
    local rad = math.rad(base.w)
    local fx = math.sin(rad)
    local fy = math.cos(rad)
    local x = base.x + (fx * distForward) + (fy * distSide)
    local y = base.y + (fy * distForward) - (fx * distSide)
    return vector4(x, y, base.z, base.w)
end

function SpawnPedInVehicle(vehicle, pedData, seat)
    local modelName = pedData.model
    local hash = joaat(modelName)
    local coords = GetEntityCoords(vehicle)
    
    -- Debugging spawn
    if Config.Debug.Enabled then
        print(string.format("^3[CONVOY DEBUG]^7 Spawning ped %s for seat %d", modelName, seat or -1))
    end

    -- Server-side CreatePed (Using model string directly)
    local ped = CreatePed(28, modelName, coords.x, coords.y, coords.z + 0.5, 0.0, true, true)
    
    -- Wait a frame
    Wait(50)

    if not DoesEntityExist(ped) then
        print("^1[CONVOY ERROR]^7 Failed to spawn ped:", modelName, "Hash:", hash)
        return nil
    end

    SetPedIntoVehicle(ped, vehicle, seat or -1)
    
    -- Server-Authoritative Basics
    GiveWeaponToPed(ped, joaat(pedData.weapon), 500, false, true)
    SetPedDropsWeaponsWhenDead(ped, false)
    SetEntityAsMissionEntity(ped, true, true)

    local pedNetId = NetworkGetNetworkIdFromEntity(ped)
    local vehNetId = NetworkGetNetworkIdFromEntity(vehicle)
    
    -- Delegate all tactical attributes to Client
    TriggerClientEvent("djonluc:client:setGuardGroup", -1, pedNetId, vehNetId, seat or -1, pedData.accuracy, pedData.armor, pedData.weapon)

    table.insert(Convoy.guards, ped)
    return ped
end

function SpawnConfiguredVehicle(config, coords)
    if not coords then
        print("^1[CONVOY ERROR]^7 Missing spawn coords.")
        return nil
    end

    local modelName = config.model
    local hash = joaat(modelName)
    
    -- Debugging spawn
    if Config.Debug.Enabled then
        print(string.format("^3[CONVOY DEBUG]^7 Spawning %s at %.2f, %.2f, %.2f (Heading: %.2f)", modelName, coords.x, coords.y, coords.z, coords.w))
    end

    -- Server-side CreateVehicle (Trying string model name for better compatibility)
    -- Adding +1.0 to Z to avoid floor clipping
    local vehicle = CreateVehicle(modelName, coords.x, coords.y, coords.z + 1.0, coords.w, true, false)
    
    -- Wait a frame for server entity ID to register
    Wait(100)

    if not DoesEntityExist(vehicle) then
        print("^1[CONVOY ERROR]^7 Failed to spawn vehicle:", modelName, "Hash:", hash)
        return nil
    end

    if config.locked ~= false then
        SetVehicleDoorsLocked(vehicle, 2)
    end

    SetEntityAsMissionEntity(vehicle, true, true)

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerClientEvent("djonluc:client:stabilizeVehicle", -1, netId)
    table.insert(Convoy.escorts, vehicle)

    return vehicle
end

function SpawnFullConvoy()
    local start = Config.Route.Start
    local form = Config.Formation

    --------------------------------------------------
    -- 1️⃣ FRONT: ARMORED RIOT VAN (LEADER)
    --------------------------------------------------
    Convoy.van = SpawnConfiguredVehicle(form.Van, start)
    if not Convoy.van then return false end

    SpawnPedInVehicle(Convoy.van, Config.Peds.Driver, -1)
    SpawnPedInVehicle(Convoy.van, Config.Peds.Guard, 0)

    --------------------------------------------------
    -- 2️⃣ BIKES (Behind Van, Side-by-Side)
    --------------------------------------------------
    for i, bikeData in ipairs(form.Bikes) do
        local side = (i == 1) and -2.5 or 2.5
        local pos = GetBehindPosition(start, -8.0, side)
        local bike = SpawnConfiguredVehicle(bikeData, pos)
        if bike then
            SpawnPedInVehicle(bike, Config.Peds.Driver, -1)
        end
    end

    --------------------------------------------------
    -- 3️⃣ PATROL CAR (16m behind)
    --------------------------------------------------
    local patrolPos = GetBehindPosition(start, -16.0, 0.0)
    local patrol = SpawnConfiguredVehicle(form.Patrol, patrolPos)
    if patrol then
        SpawnPedInVehicle(patrol, Config.Peds.Guard, 0)
        SpawnPedInVehicle(patrol, Config.Peds.Guard, 1)
    end

    --------------------------------------------------
    -- 4️⃣ SUV (24m behind)
    --------------------------------------------------
    local suvPos = GetBehindPosition(start, -24.0, 0.0)
    local suv = SpawnConfiguredVehicle(form.SUV, suvPos)
    if suv then
        -- Fill seats up to model capacity
        for s = 0, (form.SUV.seats or 4) - 2 do
            SpawnPedInVehicle(suv, Config.Peds.Guard, s)
        end
    end

    --------------------------------------------------
    -- 5️⃣ REAR ESCORT (32m behind)
    --------------------------------------------------
    local rearPos = GetBehindPosition(start, -32.0, 0.0)
    local rear = SpawnConfiguredVehicle(form.Rear, rearPos)
    if rear then
        for r = 0, (form.Rear.seats or 4) - 2 do
            SpawnPedInVehicle(rear, Config.Peds.Guard, r)
        end
    end

    return true
end
