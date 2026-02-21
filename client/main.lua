print("^2[CONVOY] client/main.lua loaded successfully.^7")

ConvoyActive = false
ConvoyActiveNetId = nil
ConvoyState = "CALM"
LocalLawPlayers = {}

RegisterNetEvent("djonluc:client:startBlips", function(netId)
    ConvoyActive = true
    ConvoyActiveNetId = netId
end)

RegisterNetEvent("djonluc:client:removeBlips", function()
    ConvoyActive = false
    ConvoyActiveNetId = nil
end)

RegisterNetEvent("djonluc:client:updateLawPlayers", function(data)
    LocalLawPlayers = data
end)

RegisterNetEvent("djonluc:client:stabilizeVehicle", function(netId)
    if not NetworkDoesEntityExistWithNetworkId(netId) then return end
    local vehicle = NetworkGetEntityFromNetworkId(netId)

    if DoesEntityExist(vehicle) then
        FreezeEntityPosition(vehicle, true)
        SetEntityInvincible(vehicle, true)

        SetVehicleOnGroundProperly(vehicle)

        Wait(200)

        FreezeEntityPosition(vehicle, false)
        SetEntityInvincible(vehicle, false)
    end
end)

RegisterNetEvent("djonluc:client:syncConvoyTasks", function(data)
    CreateThread(function()
        local van, leader, leaderDriver
        local timeout = 0
        
        -- Wait for entities to arrive on client
        while timeout < 100 do
            if data.vanNetId ~= 0 and data.leaderNetId ~= 0 then
                if NetworkDoesEntityExistWithNetworkId(data.vanNetId) and NetworkDoesEntityExistWithNetworkId(data.leaderNetId) then
                    van = NetworkGetEntityFromNetworkId(data.vanNetId)
                    leader = NetworkGetEntityFromNetworkId(data.leaderNetId)
                end
            end
            
            if DoesEntityExist(van) and DoesEntityExist(leader) then
                leaderDriver = GetPedInVehicleSeat(leader, -1)
                if DoesEntityExist(leaderDriver) then
                    break
                end
            end
            
            Wait(100)
            timeout = timeout + 1
        end

        if not DoesEntityExist(van) or not DoesEntityExist(leader) or not DoesEntityExist(leaderDriver) then
            print("^1[CONVOY ERROR]^7 Sync failed: Entities or Driver not networked in time.")
            return 
        end

        Wait(500) -- Allow a moment for net-sync to settle fully

        if not NetworkHasControlOfEntity(leader) then 
            return 
        end

        NetworkRequestControlOfEntity(leader)

        NetworkRequestControlOfEntity(leader)

        ConvoyActive = true
        ConvoyState = data.state -- Ensure state is synced
        
        -- Simple Clean Motorcade Logic
        local style = data.style or 786603
        local speed = data.speed or 35.0

        -- Leader (Riot Van)
        TaskVehicleDriveToCoordLongrange(
            leaderDriver,
            leader,
            data.dest.x,
            data.dest.y,
            data.dest.z,
            speed,
            1074528293,
            5.0
        )

        SetDriverAbility(leaderDriver, 1.0)
        SetDriverAggressiveness(leaderDriver, 1.0)
        SetPedKeepTask(leaderDriver, true)

        -- Fix 2: Speed Governor Thread
        CreateThread(function()
            while ConvoyActive do
                Wait(500)

                if NetworkDoesEntityExistWithNetworkId(data.vanNetId) then
                    local vanEntity = NetworkGetEntityFromNetworkId(data.vanNetId)

                    if DoesEntityExist(vanEntity) then
                        local maxSpeed = (data.speed or 35.0) / 2.237 -- mph to m/s

                        if GetEntitySpeed(vanEntity) > maxSpeed then
                            SetVehicleForwardSpeed(vanEntity, maxSpeed)
                        end
                    end
                end
            end
        end)

        SetVehicleSiren(leader, true)

        -- Everyone else escorts leader
        for _, escortNetId in ipairs(data.escortNetIds) do
            if NetworkDoesEntityExistWithNetworkId(escortNetId) then
                local escort = NetworkGetEntityFromNetworkId(escortNetId)
                if DoesEntityExist(escort) and escort ~= leader then
                    local escortDriver = GetPedInVehicleSeat(escort, -1)
                    if escortDriver and DoesEntityExist(escortDriver) then

                        NetworkRequestControlOfEntity(escort)
                        SetVehicleSiren(escort, true)
                        SetEntityAsMissionEntity(escort, true, true)

                        TaskVehicleEscort(
                            escortDriver,
                            escort,
                            leader,
                            1,
                            speed - 2.0,
                            1074528293,
                            10.0,
                            20,
                            40.0
                        )

                        SetDriverAbility(escortDriver, 1.0)
                        SetDriverAggressiveness(escortDriver, 1.0)
                        SetPedKeepTask(escortDriver, true)
                    end
                end
            end
        end

        print("^2[CONVOY]^7 Clean motorcade tasks applied (State: " .. data.state .. ")")
    end) -- End of CreateThread
end)

-- Interaction / Looting Logic
RegisterNetEvent("djonluc:client:vanDestroyed", function()
    if Config.Event.UseTarget then
        -- Logic to add target to van
        local vanHash = joaat(Config.Formation.Van.model)
        local vehicles = GetGamePool("CVehicle")
        
        for _, veh in ipairs(vehicles) do
            if GetEntityModel(veh) == vanHash and GetEntityHealth(veh) <= 0 then
                -- Target bridge is not in new manifest but we integrated logic elsewhere
                -- For the final refined version, we use the integrated target bridge or basic logic
                if exports['qb-target'] then
                    exports['qb-target']:AddTargetEntity(veh, {
                        options = {
                            {
                                type = "client",
                                event = "djonluc:client:startLooting",
                                icon = "fas fa-sack-dollar",
                                label = "Loot Evidence",
                                canInteract = function(entity)
                                    return GetEntityHealth(entity) <= 0
                                end
                            },
                        },
                        distance = 2.5,
                    })
                elseif exports['ox_target'] then
                    exports.ox_target:addLocalEntity(veh, {
                        {
                            name = 'loot_convoy',
                            event = 'djonluc:client:startLooting',
                            icon = 'fas fa-sack-dollar',
                            label = 'Loot Evidence',
                            canInteract = function(entity)
                                return GetEntityHealth(entity) <= 0
                            end
                        }
                    })
                end
            end
        end
    end
end)

RegisterNetEvent("djonluc:client:startLooting", function(data)
    local ped = PlayerPedId()
    local targetEntity = data.entity or data.netId and NetworkGetEntityFromNetworkId(data.netId)
    
    if targetEntity then
        local coords = GetEntityCoords(ped)
        local vanCoords = GetEntityCoords(targetEntity)
        if #(coords - vanCoords) > Config.Event.LootDistance then return end
    end

    -- Animation
    RequestAnimDict("anim@amb@business@weed@weed_inspecting_lo_med_hi@")
    while not HasAnimDictLoaded("anim@amb@business@weed@weed_inspecting_lo_med_hi@") do Wait(0) end
    
    TaskPlayAnim(ped, "anim@amb@business@weed@weed_inspecting_lo_med_hi@", "weed_stand_check_v2_inspector", 8.0, -8.0, -1, 49, 0, false, false, false)
    
    -- Progress Bar
    if GetResourceState('ox_lib') == 'started' then
        if exports.ox_lib:progressCircle({
            duration = 5000,
            label = 'Looting Evidence...',
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, mouse = false, combat = true },
        }) then
            ClearPedTasks(ped)
            TriggerServerEvent("djonluc:server:loot")
        else
            ClearPedTasks(ped)
        end
    else
        Wait(5000)
        ClearPedTasks(ped)
        TriggerServerEvent("djonluc:server:loot")
    end
end)
