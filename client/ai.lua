-- client/ai.lua
print("^2[CONVOY] client/ai.lua loaded successfully.^7")
ConvoyGroupHash = nil

CreateThread(function()
    AddRelationshipGroup("CONVOY_GUARDS")
    ConvoyGroupHash = GetHashKey("CONVOY_GUARDS")

    -- Friendly to themselves
    SetRelationshipBetweenGroups(1, ConvoyGroupHash, ConvoyGroupHash)
end)

-- Reactive Engagement Thread (Forced Bail-out & Attack)
CreateThread(function()
    while true do
        Wait(500)

        if not ConvoyActive then goto skip_combat end

        for _, guard in ipairs(GetGamePool("CPed")) do
            -- Only manage guards belonging to our group
            if GetPedRelationshipGroupHash(guard) == ConvoyGroupHash and not IsPedDeadOrDying(guard) then
                
                for _, player in ipairs(GetActivePlayers()) do
                    local playerPed = GetPlayerPed(player)
                    local serverId = GetPlayerServerId(player)

                    -- Detect shooting players (excluding friendly law-enforcement)
                    if IsPedShooting(playerPed) and not LocalLawPlayers[serverId] then
                        local dist = #(GetEntityCoords(guard) - GetEntityCoords(playerPed))

                        if dist < 80.0 then
                            local vehicle = GetVehiclePedIsIn(guard, false)

                            -- Forced deployment
                            if vehicle ~= 0 then
                                -- Drivers STAY to keep the convoy mobile. Passengers bail.
                                if GetPedInVehicleSeat(vehicle, -1) ~= guard then
                                    TaskLeaveVehicle(guard, vehicle, 256)
                                    Wait(500)
                                end
                            end

                            -- Direct engine-level combat engagement
                            TaskCombatPed(guard, playerPed, 0, 16)
                            SetPedKeepTask(guard, true)
                        end
                    end
                end
            end
        end

        ::skip_combat::
    end
end)

-- Recovery & Route Resumption Logic
CreateThread(function()
    while true do
        Wait(5000)

        if not ConvoyActive then goto skip_recovery end

        local hostileNearby = false

        -- Scan for active threats
        for _, player in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(player)
            local serverId = GetPlayerServerId(player)

            if IsPedShooting(ped) and not LocalLawPlayers[serverId] then
                hostileNearby = true
                break
            end
        end

        -- Repatriation logic
        if not hostileNearby then
            for _, guard in ipairs(GetGamePool("CPed")) do
                if GetPedRelationshipGroupHash(guard) == ConvoyGroupHash and not IsPedDeadOrDying(guard) then
                    
                    -- If they are stranded on foot, put them back in a vehicle
                    if not IsPedInAnyVehicle(guard, false) and not IsPedRagdoll(guard) then
                        local coords = GetEntityCoords(guard)
                        local closestVehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 30.0, 0, 70)

                        if closestVehicle ~= 0 then
                            TaskEnterVehicle(guard, closestVehicle, -1, -1, 2.0, 1, 0)
                        end
                    end
                end
            end
        end

        ::skip_recovery::
    end
end)

-- BIKE REMOUNT SYSTEM (Standalone & Robust)
CreateThread(function()
    while true do
        Wait(2000)

        if not ConvoyActive then goto skip_bike end

        for _, ped in ipairs(GetGamePool("CPed")) do
            if GetPedRelationshipGroupHash(ped) == ConvoyGroupHash then
                if not IsPedInAnyVehicle(ped, false) and not IsPedRagdoll(ped) and not IsPedDeadOrDying(ped) then
                    local pedCoords = GetEntityCoords(ped)
                    local closestBike = nil
                    local closestDist = 999.0

                    for _, veh in ipairs(GetGamePool("CVehicle")) do
                        if GetVehicleClass(veh) == 8 then -- Bikes only
                            local dist = #(pedCoords - GetEntityCoords(veh))
                            if dist < closestDist and dist < 20.0 then
                                local driver = GetPedInVehicleSeat(veh, -1)
                                if not driver or driver == 0 then
                                    closestDist = dist
                                    closestBike = veh
                                end
                            end
                        end
                    end

                    if closestBike then
                        ClearPedTasks(ped)
                        TaskEnterVehicle(ped, closestBike, 8000, -1, 2.0, 1, 0)
                    end
                end
            end
        end

        ::skip_bike::
    end
end)

RegisterNetEvent("djonluc:client:setGuardGroup", function(pedNetId, vehNetId, seat, accuracy, armor, weapon)
    -- Ensure they are in the group for our threads to find them
    local timeout = 0
    while not NetworkDoesEntityExistWithNetworkId(pedNetId) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    if NetworkDoesEntityExistWithNetworkId(pedNetId) then
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        if DoesEntityExist(ped) then
            SetPedRelationshipGroupHash(ped, ConvoyGroupHash)
            SetEntityAsMissionEntity(ped, true, true)
            NetworkRequestControlOfEntity(ped)

            -- Tactical Initialization (Definitive pass)
            SetPedAccuracy(ped, accuracy or 90)
            if armor then SetPedArmour(ped, armor) end
            if weapon then 
                SetCurrentPedWeapon(ped, joaat(weapon), true)
            end

            SetPedAsCop(ped, true)
            SetPedFleeAttributes(ped, 0, false)
            SetBlockingOfNonTemporaryEvents(ped, true)

            -- Combat Attributes
            SetPedCombatAttributes(ped, 0, true)  -- Can use cover
            SetPedCombatAttributes(ped, 2, true)  -- Can do drive-bys
            SetPedCombatAttributes(ped, 4, true)  -- Can shoot from vehicle
            SetPedCombatAttributes(ped, 5, true)  -- Fight armed when unarmed
            SetPedCombatAttributes(ped, 17, true) -- Never flee
            SetPedCombatAttributes(ped, 46, true) -- Always fight
            SetPedCombatAttributes(ped, 52, true) -- Force attack vehicle occupants
            SetPedCombatAttributes(ped, 1, true)  -- BF_CanSwitchWeapon

            SetPedCombatAbility(ped, 2)   -- Professional
            SetPedCombatMovement(ped, 2)  -- Offensive
            SetPedCombatRange(ped, 2)     -- Medium

            SetPedConfigFlag(ped, 118, false) -- Disable Put Hands Up
        end
    end
end)
