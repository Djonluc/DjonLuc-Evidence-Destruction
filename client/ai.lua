-- client/ai.lua

ConvoyActive = false
ConvoyActiveNetId = nil
local ConvoyGroupHash = joaat("DJONLUC_CONVOY_GUARD")
local LawGroupHash = joaat("LawEnforcement")
local LocalLawPlayers = {}

-- SHARED COMBAT STATE
local GlobalConvoyInCombat = false
local LastCombatTime = 0

-- Initialize Relationship Groups
CreateThread(function()
    AddRelationshipGroup("DJONLUC_CONVOY_GUARD")
    ConvoyGroupHash = joaat("DJONLUC_CONVOY_GUARD")
    
    -- Professional hostility: Convoy hates everyone EXCEPT law enforcement
    SetRelationshipBetweenGroups(5, ConvoyGroupHash, joaat("PLAYER"))
    SetRelationshipBetweenGroups(0, ConvoyGroupHash, joaat("LawEnforcement"))
    SetRelationshipBetweenGroups(0, joaat("LawEnforcement"), ConvoyGroupHash)
end)

RegisterNetEvent("djonluc:client:updateLawPlayers", function(lawList)
    LocalLawPlayers = lawList or {}
end)

-- 1️⃣ TACTICAL INITIALIZATION (Elite Attributes)
RegisterNetEvent("djonluc:client:setGuardGroup", function(pedNetId, vehNetId, seat, accuracy, armor, weapon)
    -- CLIENT-SIDE HARDENING: Wait for entities to register on client
    local ped = 0
    local vehicle = 0
    local timeout = 0
    
    while (ped == 0 or vehicle == 0) and timeout < 40 do
        if ped == 0 and NetworkDoesEntityExistWithNetworkId(pedNetId) then
            ped = NetworkGetEntityFromNetworkId(pedNetId)
        end
        if vehicle == 0 and NetworkDoesEntityExistWithNetworkId(vehNetId) then
            vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        end
        
        if ped ~= 0 and vehicle ~= 0 then break end
        
        Wait(50)
        timeout = timeout + 1
    end
    
    if ped ~= 0 and DoesEntityExist(ped) then
        ConvoyActive = true
        ConvoyActiveNetId = vehNetId

        -- REDUNDANT SEATING: Guarantee position on client
        if vehicle ~= 0 and DoesEntityExist(vehicle) then
            SetPedIntoVehicle(ped, vehicle, seat or -1)
        end
        
        -- Server -> Client Hand-off of Elite Attributes
        SetPedRelationshipGroupHash(ped, ConvoyGroupHash)
        SetPedAsCop(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatAttributes(ped, 46, true) -- Always fight (Elite)
        SetPedCombatAttributes(ped, 0, true)  -- Professional/Standard tactics
        SetPedCombatAttributes(ped, 2, true)  -- Can use cover / Tactical Reload
        SetPedCombatAttributes(ped, 5, true)  -- Defensive positioning
        SetPedCombatAttributes(ped, 3, true)  -- Avoid fire (Prevents running into bullets)
        
        SetPedAccuracy(ped, accuracy or 90)
        SetPedCombatAbility(ped, 2) -- Professional
        SetEntityMaxHealth(ped, 200)
        SetEntityHealth(ped, 200)
        SetPedArmour(ped, armor or 100)

        SetPedCombatRange(ped, 2) -- Medium-Long Range (Better engagement)
        SetPedCombatMovement(ped, 2) -- Offensive/Tactical Flanking

        -- Persistence
        SetEntityAsMissionEntity(ped, true, true)
        if vehicle and DoesEntityExist(vehicle) then
            SetEntityAsMissionEntity(vehicle, true, true)
        end
        SetPedKeepTask(ped, true)
        
        -- Weapons
        GiveWeaponToPed(ped, joaat(weapon), 500, false, true)
    end
end)

-- 2️⃣ MILITARY-GRADE REACTIVE COMBAT THREAD (PRODUCTION ALIGNED)
CreateThread(function()
    while true do
        Wait(300) -- Production frequency

        if not ConvoyActive then goto continue end

        local convoyPeds = {}
        local threatDetected = false
        local nearestTarget = nil

        -- A) SCAN FOR LOCAL THREATS
        for _, guard in ipairs(GetGamePool("CPed")) do
            if GetPedRelationshipGroupHash(guard) == ConvoyGroupHash and not IsPedDeadOrDying(guard) then
                table.insert(convoyPeds, guard)
                local guardCoords = GetEntityCoords(guard)
                
                for _, player in ipairs(GetActivePlayers()) do
                    local playerPed = GetPlayerPed(player)
                    local serverId = GetPlayerServerId(player)

                    if not LocalLawPlayers[serverId] then
                        local dist = #(guardCoords - GetEntityCoords(playerPed))

                        if dist < 80.0 then
                            if IsPedShooting(playerPed)
                            or IsPlayerFreeAiming(player)
                            or HasEntityBeenDamagedByEntity(guard, playerPed, true) then
                                threatDetected = true
                                nearestTarget = playerPed
                                GlobalConvoyInCombat = true
                                LastCombatTime = GetGameTimer()
                            end
                        end
                    end
                end
            end
        end

        -- B) SHARED RESPONSE: If one is in combat, everyone engages
        if GlobalConvoyInCombat or threatDetected then
            for _, guard in ipairs(convoyPeds) do
                local veh = GetVehiclePedIsIn(guard, false)
                
                -- Everyone (including drivers) bail if engagement is sustained
                if veh ~= 0 then
                    TaskLeaveVehicle(guard, veh, 256)
                    Wait(100)
                end

                if nearestTarget then
                    TaskCombatPed(guard, nearestTarget, 0, 16)
                    SetPedKeepTask(guard, true)
                end
            end
        end

        ::continue::
    end
end)

-- 3️⃣ RECOVERY, BIKE REMOUNT, AND ROUTE RESUMPTION
CreateThread(function()
    while true do
        Wait(3000)

        if not ConvoyActive then goto continue_recovery end

        -- A) NEUTRALIZATION CHECK: Has combat stopped for 10 seconds?
        if GlobalConvoyInCombat and (GetGameTimer() - LastCombatTime > 10000) then
            print("^2[CONVOY]^7 No active threats detected for 10s. Verifying neutralization...")
            local stillThreat = false
            
            for _, player in ipairs(GetActivePlayers()) do
                local playerPed = GetPlayerPed(player)
                for _, guard in ipairs(GetGamePool("CPed")) do
                    if GetPedRelationshipGroupHash(guard) == ConvoyGroupHash and not IsPedDeadOrDying(guard) then
                        if #(GetEntityCoords(guard) - GetEntityCoords(playerPed)) < 100.0 then
                            if IsPedShooting(playerPed) or IsPlayerFreeAiming(player) then
                                stillThreat = true
                                break
                            end
                        end
                    end
                end
                if stillThreat then break end
            end

            if not stillThreat then
                print("^2[CONVOY]^7 Area secure. Triggering route resumption sequence.")
                GlobalConvoyInCombat = false
                TriggerEvent("djonluc:client:resumeRoute")
            end
        end

        -- B) RECOVERY & REMOUNT
        for _, guard in ipairs(GetGamePool("CPed")) do
            if GetPedRelationshipGroupHash(guard) == ConvoyGroupHash and not IsPedDeadOrDying(guard) then
                if not IsPedInAnyVehicle(guard, false) and not IsPedRagdoll(guard) and not GlobalConvoyInCombat then
                    local pedCoords = GetEntityCoords(guard)
                    
                    local closestVeh = 0
                    local minDist = 40.0
                    
                    for _, veh in ipairs(GetGamePool("CVehicle")) do
                        local dist = #(pedCoords - GetEntityCoords(veh))
                        if dist < minDist then
                            if GetVehicleClass(veh) == 18 or GetVehicleClass(veh) == 8 or GetEntityModel(veh) == joaat("riot") then
                                local driver = GetPedInVehicleSeat(veh, -1)
                                if GetVehicleClass(veh) == 8 then
                                    if not driver or driver == 0 then
                                        minDist = dist
                                        closestVeh = veh
                                    end
                                else
                                    minDist = dist
                                    closestVeh = veh
                                end
                            end
                        end
                    end

                    if closestVeh ~= 0 then
                        TaskEnterVehicle(guard, closestVeh, 15000, -1, 2.0, 1, 0)
                    end
                end
            end
        end

        ::continue_recovery::
    end
end)

-- 4️⃣ PRE-STREAMING HANDLER
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
        end
    end
end)
