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

    if config.locked then
        SetVehicleDoorsLocked(vehicle, 2)
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    
    print("^2[CONVOY]^7 Spawned vehicle:", config.model)
    return vehicle
end

function SpawnPedInVehicle(vehicle, pedData, seat)
    local hash = joaat(pedData.model)
    local coords = GetEntityCoords(vehicle)
    
    -- CREATE_PED(pedType, modelHash, x, y, z, heading, isNetwork, bScriptHostPed)
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
    
    -- Accuracy and Seating MUST be handled on client
    TriggerClientEvent("djonluc:client:setGuardGroup", -1, pedNetId, vehNetId, seat or -1, pedData.accuracy)

    SetPedArmour(ped, pedData.armor)
    GiveWeaponToPed(ped, joaat(pedData.weapon), 500, false, true)

    print("^2[CONVOY]^7 Spawned ped:", pedData.model)
    return ped
end


local function GetOffsetCoords(coords, heading, offset)
    local angle = math.rad(heading)
    -- Calculate position behind the initial coords based on heading
    -- In GTA, heading 0 is North (+Y), 90 is West (-X), 180 is South (-Y), 270 is East (+X)
    local x = coords.x + (math.sin(angle) * offset)
    local y = coords.y - (math.cos(angle) * offset)
    return vector4(x, y, coords.z, heading)
end

function SpawnFullConvoy()
    local start = Config.Route.Start
    local spacing = 8.0 -- Meters between vehicles

    -- Spawn Van
    Convoy.van = SpawnConfiguredVehicle(Config.Vehicles.Van, start)
    if not Convoy.van then return false end

    -- Spawn Driver and Guard for Van
    local vanDriver = SpawnPedInVehicle(Convoy.van, Config.Peds.Driver, -1)
    local vanGuard = SpawnPedInVehicle(Convoy.van, Config.Peds.Guard, 0)
    
    if vanDriver then table.insert(Convoy.guards, vanDriver) end
    if vanGuard then table.insert(Convoy.guards, vanGuard) end

    -- Spawn Escorts
    for i, escortConfig in ipairs(Config.Vehicles.Escorts) do
        -- Each escort spawns 'spacing' meters behind the previous one
        local spawnPos = GetOffsetCoords(start, start.w, i * spacing)
        local escort = SpawnConfiguredVehicle(escortConfig, spawnPos)

        if escort then
            table.insert(Convoy.escorts, escort)

            -- Spawn AI per seat based on config
            local seats = escortConfig.seats or 2
            for s = -1, seats - 2 do -- -1 is driver, 0 is passenger, etc.
                local guard = SpawnPedInVehicle(escort, Config.Peds.Guard, s)
                if guard then table.insert(Convoy.guards, guard) end
            end
        end
    end
    
    return true
end
