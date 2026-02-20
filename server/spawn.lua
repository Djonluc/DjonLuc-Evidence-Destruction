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

    local timeout = 0
    while not DoesEntityExist(ped) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    if not ped or ped == 0 or not DoesEntityExist(ped) then
        print("^1[CONVOY ERROR]^7 Failed to spawn ped:", pedData.model)
        return nil
    end

    local pedNetId = NetworkGetNetworkIdFromEntity(ped)
    local vehNetId = NetworkGetNetworkIdFromEntity(vehicle)
    
    TriggerClientEvent("djonluc:client:setGuardGroup", -1, pedNetId, vehNetId, seat or -1, pedData.accuracy)

    SetPedArmour(ped, pedData.armor)
    GiveWeaponToPed(ped, joaat(pedData.weapon), 500, false, true)

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

    if config.locked ~= false then -- Default to locked
        SetVehicleDoorsLocked(vehicle, 2)
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    
    print("^2[CONVOY]^7 Spawned vehicle:", config.model)
    return vehicle
end

function SpawnFullConvoy()
    local start = Config.Route.Start
    local formation = Config.Formation

    -- 1. Lead Bikes (The very front of the convoy)
    -- Spawned side-by-side exactly at the 'Start' point
    for i, bikeData in ipairs(formation.Bikes) do
        local side = (i == 1) and -2.0 or 2.0
        local bikePos = GetBehindPosition(start, 0.0, side)
        local bike = SpawnConfiguredVehicle(bikeData, bikePos)
        if bike then
            table.insert(Convoy.escorts, bike)
            table.insert(Convoy.guards, SpawnPedInVehicle(bike, Config.Peds.Driver, -1))
        end
    end

    -- 2. Patrol Car (8m behind bikes)
    local patrolPos = GetBehindPosition(start, -8.0, 0.0)
    local patrol = SpawnConfiguredVehicle(formation.Patrol, patrolPos)
    if patrol then
        table.insert(Convoy.escorts, patrol)
        for s = -1, (formation.Patrol.seats or 2) - 2 do
            table.insert(Convoy.guards, SpawnPedInVehicle(patrol, Config.Peds.Guard, s))
        end
    end

    -- 3. Middle SUV (8m behind patrol car, 16m from start)
    local suvPos = GetBehindPosition(start, -16.0, 0.0)
    local suv = SpawnConfiguredVehicle(formation.SUV, suvPos)
    if suv then
        table.insert(Convoy.escorts, suv)
        for s = -1, (formation.SUV.seats or 4) - 2 do
            table.insert(Convoy.guards, SpawnPedInVehicle(suv, Config.Peds.Guard, s))
        end
    end

    -- 4. Van (10m behind SUV, 26m from start)
    local vanPos = GetBehindPosition(start, -26.0, 0.0)
    Convoy.van = SpawnConfiguredVehicle(formation.Van, vanPos)
    if Convoy.van then
        table.insert(Convoy.guards, SpawnPedInVehicle(Convoy.van, Config.Peds.Driver, -1))
        table.insert(Convoy.guards, SpawnPedInVehicle(Convoy.van, Config.Peds.Guard, 0))
    else
        return false
    end

    -- 5. Rear Escort (10m behind Van, 36m from start)
    local rearPos = GetBehindPosition(start, -36.0, 0.0)
    local rear = SpawnConfiguredVehicle(formation.Rear, rearPos)
    if rear then
        table.insert(Convoy.escorts, rear)
        for s = -1, (formation.Rear.seats or 4) - 2 do
            table.insert(Convoy.guards, SpawnPedInVehicle(rear, Config.Peds.Guard, s))
        end
    end
    
    return true
end
