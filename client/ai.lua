-- client/ai.lua
print("^2[CONVOY] client/ai.lua loaded successfully.^7")
ConvoyGroupHash = nil
local HostilePlayers = {}
-- ConvoyState is global from main.lua

CreateThread(function()
    AddRelationshipGroup("CONVOY_GUARDS")
    ConvoyGroupHash = GetHashKey("CONVOY_GUARDS")

    -- Passive/Friendly to everyone by default
    SetRelationshipBetweenGroups(0, ConvoyGroupHash, joaat("PLAYER"))
    SetRelationshipBetweenGroups(0, ConvoyGroupHash, ConvoyGroupHash)
end)

RegisterNetEvent("djonluc:client:updateHostiles", function(data)
    HostilePlayers = data
end)

-- State is synced globally in main.lua handler

RegisterNetEvent("djonluc:client:setGuardGroup", function(pedNetId, vehNetId, seat, accuracy)
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
            SetNetworkIdCanMigrate(pedNetId, false)
            
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

        local convoyEntities = { ConvoyActiveNetId } -- Start with Van
        -- Add guards and escorts to check list if needed, 
        -- but usually van/escort collision is enough.

        -- Check Van & Escorts for damage/impacts
        local entitiesToCheck = { NetworkGetEntityFromNetworkId(ConvoyActiveNetId) }
        -- Add guards later in the loop or separate

        for _, entity in ipairs(GetGamePool("CVehicle")) do
            local isConvoyVeh = (entity == NetworkGetEntityFromNetworkId(ConvoyActiveNetId))
            if not isConvoyVeh then
                for _, escort in ipairs(GetGamePool("CVehicle")) do
                    -- We can't easily identify escorts here without more netId syncing, 
                    -- so let's stick to the Van and visible guards for now.
                end
            end

            if isConvoyVeh then
                -- 1. Damage check
                if HasEntityBeenDamagedByAnyPed(entity) then
                    local attacker = GetEntityLastDamageEntity(entity)
                    if IsPedAPlayer(attacker) then
                        TriggerServerEvent("djonluc:server:markHostile", GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker)))
                    end
                    ClearEntityLastDamageEntity(entity)
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

        -- Check Guards for damage
        for _, ped in ipairs(GetGamePool("CPed")) do
            if GetPedRelationshipGroupHash(ped) == ConvoyGroupHash then
                if HasEntityBeenDamagedByAnyPed(ped) then
                    local attacker = GetEntityLastDamageEntity(ped)
                    if IsPedAPlayer(attacker) then
                        TriggerServerEvent("djonluc:server:markHostile", GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker)))
                    end
                    ClearEntityLastDamageEntity(ped)
                end
            end
        end

        ::skip_dmg::
    end
end)


-- Helper: Count hostiles nearby
local function CountHostilesNearby(coords, radius)
    local count = 0
    for id, _ in pairs(HostilePlayers) do
        local player = GetPlayerFromServerId(id)
        if player then
            local ped = GetPlayerPed(player)
            if #(GetEntityCoords(ped) - coords) < radius then
                count = count + 1
            end
        end
    end
    return count
end

-- Reactive Combat Targeting + Escalation
CreateThread(function()
    while true do
        Wait(1000)
        if not ConvoyActive then goto skip_combat end

        local escalationTriggered = (ConvoyState == "DEFENSIVE")

        for _, guard in ipairs(GetGamePool("CPed")) do
            if GetPedRelationshipGroupHash(guard) == ConvoyGroupHash then
                local guardCoords = GetEntityCoords(guard)
                
                -- Draw weapon if in ALERT or higher
                if (ConvoyState == "ALERT" or ConvoyState == "DEFENSIVE") then
                    if not IsPedArmed(guard, 7) then
                        local weapon = GetSelectedPedWeapon(guard)
                        if weapon ~= joaat("WEAPON_UNARMED") then
                            SetCurrentPedWeapon(guard, weapon, true)
                        end
                    end
                else
                    if IsPedArmed(guard, 7) then
                        SetCurrentPedWeapon(guard, joaat("WEAPON_UNARMED"), true)
                        ClearPedTasks(guard)
                    end
                end

                -- Precision Targeting: ONLY target hostiles
                local hasTarget = false
                if ConvoyState ~= "CALM" then
                    for _, player in ipairs(GetActivePlayers()) do
                        local serverId = GetPlayerServerId(player)
                        if HostilePlayers[serverId] then
                            local targetPed = GetPlayerPed(player)
                            local dist = #(guardCoords - GetEntityCoords(targetPed))
                            
                            if dist < 120.0 then
                                hasTarget = true
                                if IsPedInAnyVehicle(guard, false) then
                                    -- Logic: Exit if attacked or hostile is close
                                    if escalationTriggered or dist < 60.0 then
                                        TaskLeaveVehicle(guard, GetVehiclePedIsIn(guard, false), 256)
                                    end
                                else
                                    TaskCombatPed(guard, targetPed, 0, 16)
                                end
                            end
                        end
                    end
                end

                if not hasTarget and not IsPedInAnyVehicle(guard, false) and ConvoyState == "CALM" then
                    ClearPedTasks(guard)
                end
            end
        end

        ::skip_combat::
    end
end)



-- Remove legacy relationship group force logic (It competes with the reactive system)
