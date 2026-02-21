-- server/spawn.lua

Convoy = {
    active = false,
    state = "CALM", -- CALM, ALERT, DEFENSIVE
    van = nil,
    escorts = {},
    guards = {},
    health = 0,
    destroyed = false,
    startedAt = 0,
    underAttack = false,
    lastEvent = 0
}

LawPlayers = {}

local function GetBehindPosition(base, distForward, distSide)
    local rad = math.rad(base.w)
    local fx = math.sin(rad)
    local fy = math.cos(rad)
    
    local x = base.x + (fx * distForward) + (fy * distSide)
    local y = base.y + (fy * distForward) - (fx * distSide)
    return vector4(x, y, base.z, base.w)
end

function SpawnPedInVehicle(vehicle, pedData, seat)
    local hash = joaat(pedData.model)

    local coords = GetEntityCoords(vehicle)
    local ped = CreatePed(28, hash, coords.x, coords.y, coords.z, 0.0, true, true)

    if not DoesEntityExist(ped) then
        print("^1[CONVOY ERROR]^7 Ped failed to spawn:", pedData.model)
        return nil
    end

    SetPedIntoVehicle(ped, vehicle, seat or -1)

    -- Server Authoritative Basics
    GiveWeaponToPed(ped, joaat(pedData.weapon), 500, false, true)
    SetPedDropsWeaponsWhenDead(ped, false)
    SetEntityAsMissionEntity(ped, true, true)

    local pedNetId = NetworkGetNetworkIdFromEntity(ped)
    local vehNetId = NetworkGetNetworkIdFromEntity(vehicle)
    
    TriggerClientEvent("djonluc:client:setGuardGroup", -1, pedNetId, vehNetId, seat or -1, pedData.accuracy, pedData.armor, pedData.weapon)

    print("^2[CONVOY]^7 Spawned ped:", pedData.model)
    return ped
end

function SpawnConfiguredVehicle(config, coords)
    if not coords then
        print("^1[CONVOY ERROR]^7 Missing spawn coordinates.")
        return nil
    end

    local hash = joaat(config.model)
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, coords.w, true, true)

    local timeout = 0
    while not DoesEntityExist(vehicle) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    if not DoesEntityExist(vehicle) then
        print("^1[CONVOY ERROR]^7 Failed to create vehicle:", config.model)
        return nil
    end

    if config.locked ~= false then
        SetVehicleDoorsLocked(vehicle, 2)
    end

    local netId = 0
    timeout = 0
    while netId == 0 and timeout < 100 do
        netId = NetworkGetNetworkIdFromEntity(vehicle)
        Wait(10)
        timeout = timeout + 1
    end

    if netId == 0 then
        print("^1[CONVOY ERROR]^7 Failed to get netId for vehicle:", config.model)
        return nil
    end

    -- NOW stabilize AFTER netId is valid
    TriggerClientEvent("djonluc:client:stabilizeVehicle", -1, netId)

    print("^2[CONVOY]^7 Spawned vehicle:", config.model)
    return vehicle
end

function SpawnFullConvoy()
    local start = Config.Route.Start
    local formation = Config.Formation

    --------------------------------------------------
    -- 1️⃣ FRONT: ARMORED RIOT VAN (LEADER)
    --------------------------------------------------
    Convoy.van = SpawnConfiguredVehicle(formation.Van, start)
    if not Convoy.van then return false end

    table.insert(Convoy.guards, SpawnPedInVehicle(Convoy.van, Config.Peds.Driver, -1))
    table.insert(Convoy.guards, SpawnPedInVehicle(Convoy.van, Config.Peds.Guard, 0))

    --------------------------------------------------
    -- 2️⃣ BIKES (Behind Van, Side-by-Side)
    --------------------------------------------------
    for i, bikeData in ipairs(formation.Bikes) do
        local side = (i == 1) and -2.5 or 2.5
        local bikePos = GetBehindPosition(start, -8.0, side)
        local bike = SpawnConfiguredVehicle(bikeData, bikePos)

        if bike then
            table.insert(Convoy.escorts, bike)
            table.insert(Convoy.guards, SpawnPedInVehicle(bike, Config.Peds.Driver, -1))
        end
    end

    --------------------------------------------------
    -- 3️⃣ PATROL CAR (16m behind)
    --------------------------------------------------
    local patrolPos = GetBehindPosition(start, -16.0, 0.0)
    local patrol = SpawnConfiguredVehicle(formation.Patrol, patrolPos)

    if patrol then
        table.insert(Convoy.escorts, patrol)
        for s = -1, (formation.Patrol.seats or 2) - 2 do
            table.insert(Convoy.guards, SpawnPedInVehicle(patrol, Config.Peds.Guard, s))
        end
    end

    --------------------------------------------------
    -- 4️⃣ SUV (24m behind)
    --------------------------------------------------
    local suvPos = GetBehindPosition(start, -24.0, 0.0)
    local suv = SpawnConfiguredVehicle(formation.SUV, suvPos)

    if suv then
        table.insert(Convoy.escorts, suv)
        for s = -1, (formation.SUV.seats or 4) - 2 do
            table.insert(Convoy.guards, SpawnPedInVehicle(suv, Config.Peds.Guard, s))
        end
    end

    --------------------------------------------------
    -- 5️⃣ REAR ESCORT (32m behind)
    --------------------------------------------------
    local rearPos = GetBehindPosition(start, -32.0, 0.0)
    local rear = SpawnConfiguredVehicle(formation.Rear, rearPos)

    if rear then
        table.insert(Convoy.escorts, rear)
        for s = -1, (formation.Rear.seats or 4) - 2 do
            table.insert(Convoy.guards, SpawnPedInVehicle(rear, Config.Peds.Guard, s))
        end
    end

    return true
end
