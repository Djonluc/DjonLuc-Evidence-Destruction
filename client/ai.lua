-- client/ai.lua
print("^2[CONVOY] client/ai.lua loaded successfully.^7")

ConvoyGroupHash = nil

-- 1️⃣ RELATIONSHIP SETUP
CreateThread(function()
    AddRelationshipGroup("CONVOY_GUARDS")
    ConvoyGroupHash = GetHashKey("CONVOY_GUARDS")

    -- Start neutral to players
    SetRelationshipBetweenGroups(0, ConvoyGroupHash, joaat("PLAYER"))
    SetRelationshipBetweenGroups(0, joaat("PLAYER"), ConvoyGroupHash)
    
    -- Friendly to self
    SetRelationshipBetweenGroups(1, ConvoyGroupHash, ConvoyGroupHash)
end)

-- 2️⃣ TACTICAL INITIALIZATION HANDLER (Restoring attributes removed from server)
RegisterNetEvent("djonluc:client:setGuardGroup", function(pedNetId, vehNetId, seat, accuracy, armor, weapon)
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

            -- Restoration of tactical attributes (Moved to client for stability)
            SetPedAccuracy(ped, accuracy or 90)
            if armor then SetPedArmour(ped, armor) end
            if weapon then 
                SetCurrentPedWeapon(ped, joaat(weapon), true)
            end

            SetPedAsCop(ped, true)
            SetPedFleeAttributes(ped, 0, false)
            SetBlockingOfNonTemporaryEvents(ped, true)

            -- Global Combat attributes
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

-- 3️⃣ REACTIVE COMBAT THREAD (Deployment)
CreateThread(function()
    while true do
        Wait(500)

        if ConvoyActive then
            for _, guard in ipairs(GetGamePool("CPed")) do
                if GetPedRelationshipGroupHash(guard) == ConvoyGroupHash and not IsPedDeadOrDying(guard) then
                    
                    for _, player in ipairs(GetActivePlayers()) do
                        local playerPed = GetPlayerPed(player)
                        local serverId = GetPlayerServerId(player)

                        -- Respond to shooting players (excluding friendly law-enforcement)
                        if IsPedShooting(playerPed) and not LocalLawPlayers[serverId] then
                            local dist = #(GetEntityCoords(guard) - GetEntityCoords(playerPed))

                            if dist < 80.0 then
                                local veh = GetVehiclePedIsIn(guard, false)

                                -- Bail out passengers only (Keep drivers focused on route)
                                if veh ~= 0 and GetPedInVehicleSeat(veh, -1) ~= guard then
                                    TaskLeaveVehicle(guard, veh, 256)
                                    Wait(300)
                                end

                                -- Lock on and fight
                                TaskCombatPed(guard, playerPed, 0, 16)
                                SetPedKeepTask(guard, true)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- 4️⃣ RECOVERY & RE-ENTRY LOGIC
CreateThread(function()
    while true do
        Wait(5000)

        if ConvoyActive then
            local threat = false

            -- Check if anyone is still shooting
            for _, player in ipairs(GetActivePlayers()) do
                if IsPedShooting(GetPlayerPed(player)) then
                    threat = true
                    break
                end
            end

            -- If area is clear, return to vehicles
            if not threat then
                for _, guard in ipairs(GetGamePool("CPed")) do
                    if GetPedRelationshipGroupHash(guard) == ConvoyGroupHash and not IsPedDeadOrDying(guard) then
                        if not IsPedInAnyVehicle(guard, false) and not IsPedRagdoll(guard) then
                            local coords = GetEntityCoords(guard)
                            local veh = GetClosestVehicle(coords.x, coords.y, coords.z, 25.0, 0, 70)

                            if veh ~= 0 then
                                TaskEnterVehicle(guard, veh, -1, -1, 2.0, 1, 0)
                                SetPedKeepTask(guard, true)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- 5️⃣ BIKE REMOUNT SYSTEM (Standalone & Robust)
CreateThread(function()
    while true do
        Wait(2000)

        if ConvoyActive then
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
        end
    end
end)

-- 6️⃣ PRE-STREAMING HANDLER (Ensures models are ready for server-side spawn)
RegisterNetEvent("djonluc:client:preloadFormation", function(models)
    print("^3[CONVOY]^7 Preloading models for spawn...")
    for _, model in ipairs(models) do
        local hash = joaat(model)
        if IsModelInCdimage(hash) then
            RequestModel(hash)
            local timeout = 0
            while not HasModelLoaded(hash) and timeout < 100 do
                Wait(10)
                timeout = timeout + 1
            end
            if HasModelLoaded(hash) then
                print("^2[CONVOY]^7 Model pre-streamed: " .. model)
            else
                print("^1[CONVOY ERROR]^7 Model pre-streaming failed: " .. model)
            end
        end
    end
end)
