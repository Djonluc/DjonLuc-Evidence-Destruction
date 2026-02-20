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

RegisterNetEvent("djonluc:client:syncConvoyTasks", function(data)
    ConvoyActive = true
    ConvoyState = data.state -- Ensure state is synced
    
    local van = NetworkGetEntityFromNetworkId(data.vanNetId)
    local leader = NetworkGetEntityFromNetworkId(data.leaderNetId)
    if not DoesEntityExist(van) or not DoesEntityExist(leader) then return end

    local leaderDriver = GetPedInVehicleSeat(leader, -1)
    if not leaderDriver or not DoesEntityExist(leaderDriver) then return end

    -- Elite Drive Style & Parameters
    local style = data.style or 786603
    local speed = data.speed or 30.0
    local escortSpeed = speed + 5.0

    if data.state == "ALERT" then
        speed = speed + 5.0
    elseif data.state == "DEFENSIVE" then
        speed = speed * 0.5 
        style = 1074528293
    end

    -- 1. Leader Logic
    SetVehicleSiren(leader, true)
    local maxSpeedMS = speed / 2.237
    SetVehicleMaxSpeed(leader, maxSpeedMS)
    
    if data.state == "DEFENSIVE" then
        TaskVehicleTempAction(leaderDriver, leader, 6, 10000) -- Stop!
    else
        TaskVehicleDriveToCoordLongrange(leaderDriver, leader, data.dest.x, data.dest.y, data.dest.z, speed, style, 10.0)
    end

    -- 2. Van Logic
    if van ~= leader then
        local vanDriver = GetPedInVehicleSeat(van, -1)
        if vanDriver and DoesEntityExist(vanDriver) then
            SetVehicleSiren(van, true)
            SetVehicleMaxSpeed(van, maxSpeedMS)
            if data.state == "DEFENSIVE" then
                TaskVehicleTempAction(vanDriver, van, 6, 10000)
            else
                TaskVehicleEscort(vanDriver, van, leader, -1, speed, style, 8.0, 10, 5.0)
            end
        end
    end

    -- 3. Escorts Logic
    for _, escortNetId in ipairs(data.escortNetIds) do
        local escort = NetworkGetEntityFromNetworkId(escortNetId)
        if DoesEntityExist(escort) and escort ~= leader and escort ~= van then
            local escortDriver = GetPedInVehicleSeat(escort, -1)
            if escortDriver and DoesEntityExist(escortDriver) then
                SetEntityAsMissionEntity(escort, true, true)
                SetVehicleSiren(escort, true)
                SetVehicleMaxSpeed(escort, maxSpeedMS)
                
                local escortMode = (GetVehicleClass(escort) == 8) and 12 or -1
                local escortDist = (GetVehicleClass(escort) == 8) and 4.0 or 7.0

                if data.state == "DEFENSIVE" then
                    TaskVehicleTempAction(escortDriver, escort, 6, 10000)
                else
                    TaskVehicleEscort(escortDriver, escort, leader, escortMode, speed, style, escortDist, 10, 4.0)
                end
            end
        end
    end

    -- 4. Speed Lock Thread
    CreateThread(function()
        while ConvoyActive and ConvoyState ~= "DEFENSIVE" do
            local leaderSpeed = GetEntitySpeed(leader)
            if leaderSpeed > 0.1 then
                for _, escortId in ipairs(data.escortNetIds) do
                    local v = NetworkGetEntityFromNetworkId(escortId)
                    if DoesEntityExist(v) and v ~= leader then
                        if GetEntitySpeed(v) > leaderSpeed + 1.2 then
                            SetVehicleForwardSpeed(v, leaderSpeed)
                        end
                    end
                end
            end
            Wait(200)
        end
    end)
    
    print("^2[CONVOY]^7 Synchronized Elite AI tasks (State: " .. data.state .. ")")
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
