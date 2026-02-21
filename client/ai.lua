-- client/ai.lua
print("^2[CONVOY] client/ai.lua loaded successfully.^7")
ConvoyGroupHash = nil
local HostilePlayers = {}

CreateThread(function()
    AddRelationshipGroup("CONVOY_GUARDS")
    ConvoyGroupHash = GetHashKey("CONVOY_GUARDS")

    -- Default neutral
    SetRelationshipBetweenGroups(0, ConvoyGroupHash, joaat("PLAYER"))
    SetRelationshipBetweenGroups(0, joaat("PLAYER"), ConvoyGroupHash)

    -- Friendly to themselves
    SetRelationshipBetweenGroups(1, ConvoyGroupHash, ConvoyGroupHash)
end)

RegisterNetEvent("djonluc:client:updateHostiles", function(data)
    HostilePlayers = data

    for id, _ in pairs(HostilePlayers) do
        local player = GetPlayerFromServerId(id)
        if player then
            local ped = GetPlayerPed(player)
            if DoesEntityExist(ped) then
                SetRelationshipBetweenGroups(
                    5,
                    ConvoyGroupHash,
                    GetPedRelationshipGroupHash(ped)
                )
                SetRelationshipBetweenGroups(
                    5,
                    GetPedRelationshipGroupHash(ped),
                    ConvoyGroupHash
                )
            end
        end
    end
end)

-- State is synced globally in main.lua handler

RegisterNetEvent("djonluc:client:setGuardGroup", function(pedNetId, vehNetId, seat, accuracy, armor, weapon)
    if not pedNetId or pedNetId == 0 then return end
    
    local timeout = 0
    while not NetworkDoesEntityExistWithNetworkId(pedNetId) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    if NetworkDoesEntityExistWithNetworkId(pedNetId) then
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        if DoesEntityExist(ped) then
            SetPedRelationshipGroupHash(ped, ConvoyGroupHash)
            SetPedAccuracy(ped, accuracy or 60)
            if armor then SetPedArmour(ped, armor) end
            if weapon then GiveWeaponToPed(ped, joaat(weapon), 500, false, true) end
            
            -- Hard Aggression: Never surrender, Never flee
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedFleeAttributes(ped, 0, false)
            SetPedConfigFlag(ped, 100, true)  -- CPED_CONFIG_FLAG_BlocksPedsDuringVehicleJack
            SetPedConfigFlag(ped, 118, false) -- CPED_CONFIG_FLAG_CanPutHandsUp (Disable)
            SetPedConfigFlag(ped, 208, true)  -- CPED_CONFIG_FLAG_DisablePanicInVehicle
            
            SetPedCombatAttributes(ped, 46, Config.AI.AlwaysFight)
            SetPedCombatAttributes(ped, 5, true)   -- CanFightArmedPedsWhenNotArmed
            SetPedCombatAttributes(ped, 0, true)   -- CanUseCover
            SetPedCombatAttributes(ped, 52, true)  -- ForceTargetPedsInVehicles
            SetPedCombatAttributes(ped, 17, false) -- Never Flee
            SetPedCombatAttributes(ped, 4, true)   -- BF_CanDriveBy
            SetPedCombatAttributes(ped, 2, true)   -- BF_CanDoDrivebys
            
            SetPedCombatMovement(ped, Config.AI.CombatMovement or 1)
            SetPedCombatRange(ped, Config.AI.CombatRange or 2)
            SetPedAsCop(ped, true)
            SetEntityAsMissionEntity(ped, true, true)
            SetPedCanBeTargetted(ped, true) -- Correct native for targeting
            
            SetNetworkIdExistsOnAllMachines(pedNetId, true)
            SetNetworkIdCanMigrate(pedNetId, true)
            
            -- Handle seating on client
            if vehNetId then
                local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
                if DoesEntityExist(vehicle) then
                    SetPedIntoVehicle(ped, vehicle, seat or -1)
                end
            end
            
            -- Ensure they are neutral to players specifically
            SetPedRelationshipGroupHash(ped, ConvoyGroupHash)
        end
    end
end)

-- Attacker Detection (Damage & Ram Monitoring)
local ImpactCounts = {}

CreateThread(function()
    while true do
        Wait(500)
        if not ConvoyActive then goto skip_dmg end

        -- Proximity Threat Scan
        for _, player in ipairs(GetActivePlayers()) do
            local targetPed = GetPlayerPed(player)
            local serverId = GetPlayerServerId(player)

            if not LocalLawPlayers[serverId] then
                if IsPedShooting(targetPed) then
                    -- Get any guard to check distance from
                    local localPed = PlayerPedId() 
                    local dist = #(GetEntityCoords(localPed) - GetEntityCoords(targetPed))
                    if dist < 80.0 then
                        TriggerServerEvent("djonluc:server:markHostile", serverId)
                    end
                end
            end
        end

        local van = nil
        if ConvoyActiveNetId and NetworkDoesEntityExistWithNetworkId(ConvoyActiveNetId) then
            van = NetworkGetEntityFromNetworkId(ConvoyActiveNetId)
        end

        local entitiesToCheck = {}
        if van then table.insert(entitiesToCheck, van) end

        for _, entity in ipairs(GetGamePool("CVehicle")) do
            local isConvoyVeh = (entity == van)
            if not isConvoyVeh then
                for _, escort in ipairs(GetGamePool("CVehicle")) do
                    -- We can't easily identify escorts here without more netId syncing, 
                    -- so let's stick to the Van and visible guards for now.
                end
            end

            if isConvoyVeh then
                -- 1. Damage check: Trigger ALERT based on damage, but identification is harder for vehicles
                if HasEntityBeenDamagedByAnyPed(entity) then
                    -- If we can't reliably get the attacker for a vehicle, 
                    -- the server-side health monitoring will still trigger ALERT.
                    -- We just clear the flag to keep monitoring.
                    if ClearEntityLastDamageEntity then
                        ClearEntityLastDamageEntity(entity)
                    end
                end

                -- 2. Ram Detection (Collision check)
                if HasEntityCollidedWithAnything(entity) then
                    local _, other = GetEntityPlayerIsFreeAimingAt(PlayerId()) -- This is not right
                    -- Better way: GetLastEntityHitByEntity
                    -- However, FiveM collision natives are tricky. 
                    -- Let's use a simpler "HitBy" check or wait for damage.
                    -- GTA's 'HasEntityBeenDamagedByAnyPed' often triggers on hard rams too.
                end
            end
        end

        -- Check Guards for damage (Identify attackers)
        for _, ped in ipairs(GetGamePool("CPed")) do
            if GetPedRelationshipGroupHash(ped) == ConvoyGroupHash then
                if HasEntityBeenDamagedByAnyPed(ped) then
                    local attacker = GetPedSourceOfDamage(ped)
                    if IsPedAPlayer(attacker) then
                        local playerId = NetworkGetPlayerIndexFromPed(attacker)
                        if playerId and playerId ~= -1 then
                            TriggerServerEvent("djonluc:server:markHostile", GetPlayerServerId(playerId))
                        end
                    end
                    if ClearEntityLastDamageEntity then
                        ClearEntityLastDamageEntity(ped)
                    end
                end
            end
        end

        ::skip_dmg::
    end
end)

-- Reactive AI Logic (Using native relationship hostility now)

-- BIKE REMOUNT SYSTEM (Robust Version)
CreateThread(function()
    while true do
        Wait(1500)

        if not ConvoyActive then goto skip end

        for _, ped in ipairs(GetGamePool("CPed")) do
            if GetPedRelationshipGroupHash(ped) == ConvoyGroupHash then

                -- Only care about bike riders
                if not IsPedInAnyVehicle(ped, false) and not IsPedRagdoll(ped) and not IsPedDeadOrDying(ped) then

                    local pedCoords = GetEntityCoords(ped)
                    local closestBike = nil
                    local closestDist = 999.0

                    for _, veh in ipairs(GetGamePool("CVehicle")) do
                        if GetVehicleClass(veh) == 8 then -- Bikes only
                            local driver = GetPedInVehicleSeat(veh, -1)

                            -- Ensure bike belongs to convoy (driver is convoy guard or empty)
                            if not driver or GetPedRelationshipGroupHash(driver) == ConvoyGroupHash then
                                local dist = #(pedCoords - GetEntityCoords(veh))
                                if dist < closestDist then
                                    closestDist = dist
                                    closestBike = veh
                                end
                            end
                        end
                    end

                    if closestBike and closestDist < 20.0 then
                        -- Clear combat temporarily so GTA allows entering
                        ClearPedTasks(ped)

                        -- Force them to enter driver seat
                        TaskEnterVehicle(ped, closestBike, 8000, -1, 2.0, 1, 0)
                    end
                end
            end
        end

        ::skip::
    end
end)
