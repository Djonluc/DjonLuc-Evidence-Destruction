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

-- Server-safe model validation (Native checks only)
function PreloadModel(model)
    local hash = type(model) == "string" and joaat(model) or model

    -- IsModelInCdimage and IsModelAVehicle are server-safe in most modern FiveM builds
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        print("^1[CONVOY ERROR]^7 Invalid or missing vehicle model: " .. tostring(model))
        return false
    end

    -- NOTE: RequestModel/HasModelLoaded are client-only. 
    -- We skip them here but the checks above ensure the model exists in the game files.
    return true
end

function SpawnPedInVehicle(vehicle, pedData, seat)
    local modelName = pedData.model
    local hash = joaat(modelName)
    local coords = GetEntityCoords(vehicle)
    
    -- RequestModel is client-only, so we just use CreatePed directly on server
    local ped = CreatePed(28, modelName, coords.x, coords.y, coords.z + 0.5, 0.0, true, true)
    
    -- Wait a frame
    Wait(50)

    if not DoesEntityExist(ped) then
        print("^1[CONVOY ERROR]^7 Failed to spawn ped: " .. tostring(modelName))
        return nil
    end

    SetPedIntoVehicle(ped, vehicle, seat or -1)
    
    -- Server-Authoritative Basics
    GiveWeaponToPed(ped, joaat(pedData.weapon), 500, false, true)
    SetPedDropsWeaponsWhenDead(ped, false)
    SetEntityAsMissionEntity(ped, true, true)

    local pedNetId = NetworkGetNetworkIdFromEntity(ped)
    local vehNetId = NetworkGetNetworkIdFromEntity(vehicle)
    
    -- Delegate tactical attributes to Client side
    TriggerClientEvent("djonluc:client:setGuardGroup", -1, pedNetId, vehNetId, seat or -1, pedData.accuracy, pedData.armor, pedData.weapon)

    table.insert(Convoy.guards, ped)
    return ped
end

function SpawnConfiguredVehicle(config, coords)
    if not coords then
        print("^1[CONVOY ERROR]^7 Missing spawn coords.")
        return nil
    end

    if not PreloadModel(config.model) then
        return nil
    end

    local modelName = config.model
    local hash = joaat(modelName)
    
    -- Adding +1.0 to Z to avoid floor clipping
    local vehicle = CreateVehicle(modelName, coords.x, coords.y, coords.z + 1.0, coords.w, true, false)
    
    -- Wait for server entity registration
    Wait(100)

    if not DoesEntityExist(vehicle) then
        print("^1[CONVOY ERROR]^7 CreateVehicle returned nil for: " .. tostring(modelName))
        return nil
    end

    SetVehicleOnGroundProperly(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)

    if config.locked ~= false then
        SetVehicleDoorsLocked(vehicle, 2)
    else
        SetVehicleDoorsLocked(vehicle, 1)
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerClientEvent("djonluc:client:stabilizeVehicle", -1, netId)
    table.insert(Convoy.escorts, vehicle)

    print("^2[CONVOY]^7 Spawned vehicle: " .. tostring(modelName))
    return vehicle
end

function SpawnFullConvoy()
    print("^3[CONVOY]^7 Starting full convoy spawn sequence...")
    local start = Config.Route.Start
    local form = Config.Formation

    --------------------------------------------------
    -- 1️⃣ FRONT: ARMORED RIOT VAN (LEADER)
    --------------------------------------------------
    print("^3[CONVOY]^7 Spawning Riot Van (Leader)...")
    Convoy.van = SpawnConfiguredVehicle(form.Van, start)
    if not Convoy.van then 
        print("^1[CONVOY ERROR]^7 !!! VAN SPAWN FAILED !!!")
        return false 
    end

    SpawnPedInVehicle(Convoy.van, Config.Peds.Driver, -1)
    SpawnPedInVehicle(Convoy.van, Config.Peds.Guard, 0)

    --------------------------------------------------
    -- 2️⃣ BIKES (Behind Van)
    --------------------------------------------------
    print("^3[CONVOY]^7 Spawning Escort Bikes...")
    for i, bikeData in ipairs(form.Bikes) do
        local pos = GetBehindPosition(start, -8.0, (i == 1 and -2.5 or 2.5))
        local bike = SpawnConfiguredVehicle(bikeData, pos)
        if bike then
            SpawnPedInVehicle(bike, Config.Peds.Driver, -1)
        else
            print("^1[CONVOY ERROR]^7 Bike spawn failed: " .. tostring(bikeData.model))
        end
    end

    --------------------------------------------------
    -- 3️⃣ PATROL CAR (16m behind)
    --------------------------------------------------
    print("^3[CONVOY]^7 Spawning Patrol Escort...")
    local patrolPos = GetBehindPosition(start, -16.0, 0.0)
    local patrol = SpawnConfiguredVehicle(form.Patrol, patrolPos)
    if patrol then
        SpawnPedInVehicle(patrol, Config.Peds.Guard, 0)
        SpawnPedInVehicle(patrol, Config.Peds.Guard, 1)
    else
        print("^1[CONVOY ERROR]^7 Patrol car spawn failed.")
    end

    --------------------------------------------------
    -- 4️⃣ SUV (24m behind)
    --------------------------------------------------
    print("^3[CONVOY]^7 Spawning SUV Escort...")
    local suvPos = GetBehindPosition(start, -24.0, 0.0)
    local suv = SpawnConfiguredVehicle(form.SUV, suvPos)
    if suv then
        for s = 0, (form.SUV.seats or 4) - 2 do
            SpawnPedInVehicle(suv, Config.Peds.Guard, s)
        end
    else
        print("^1[CONVOY ERROR]^7 SUV spawn failed.")
    end

    --------------------------------------------------
    -- 5️⃣ REAR ESCORT (32m behind)
    --------------------------------------------------
    print("^3[CONVOY]^7 Spawning Rear Escort SUV...")
    local rearPos = GetBehindPosition(start, -32.0, 0.0)
    local rear = SpawnConfiguredVehicle(form.Rear, rearPos)
    if rear then
        for r = 0, (form.Rear.seats or 4) - 2 do
            SpawnPedInVehicle(rear, Config.Peds.Guard, r)
        end
    else
        print("^1[CONVOY ERROR]^7 Rear escort spawn failed.")
    end

    print("^2[CONVOY]^7 Full convoy successfully initialized.")
    return true
end
