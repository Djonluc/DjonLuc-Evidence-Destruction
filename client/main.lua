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
    if not DoesEntityExist(van) then return end

    local driver = GetPedInVehicleSeat(van, -1)
    if not driver or not DoesEntityExist(driver) then return end

    -- Apply Mission & Visual Attributes (Delegated from Server)
    SetEntityAsMissionEntity(van, true, true)
    SetVehicleEngineOn(van, true, true)
    SetVehicleTyresCanBurst(van, false)
    
    -- Sync Networking Flags
    local netId = data.vanNetId
    SetNetworkIdExistsOnAllMachines(netId, true)
    SetNetworkIdCanMigrate(netId, false)
    
    if Config.Vehicles.Van.health then
        SetEntityMaxHealth(van, Config.Vehicles.Van.health)
        SetEntityHealth(van, Config.Vehicles.Van.health)
    end

    SetEntityAsMissionEntity(driver, true, true)
    SetPedArmour(driver, Config.Peds.Driver.armor or 100)

    local style = 786603
    local speed = data.speed

    if data.state == "ALERT" then
        style = 1074528293
        speed = speed + 10.0
    elseif data.state == "DEFENSIVE" then
        style = 1074528293
        speed = speed + 20.0
    end

    -- Van Driver Task
    TaskVehicleDriveToCoordLongrange(driver, van, data.dest.x, data.dest.y, data.dest.z, speed, style, 10.0)

    -- Escort Tasks
    for _, escortNetId in ipairs(data.escortNetIds) do
        local escort = NetworkGetEntityFromNetworkId(escortNetId)
        if DoesEntityExist(escort) then
            local escortDriver = GetPedInVehicleSeat(escort, -1)
            if escortDriver and DoesEntityExist(escortDriver) then
                -- Apply Mission & Visual Attributes
                SetEntityAsMissionEntity(escort, true, true)
                SetVehicleEngineOn(escort, true, true)
                SetEntityAsMissionEntity(escortDriver, true, true)
                
                SetNetworkIdExistsOnAllMachines(escortNetId, true)
                SetNetworkIdCanMigrate(escortNetId, false)
                
                TaskVehicleEscort(escortDriver, escort, van, -1, speed + 5.0, style, 5.0, 0, 5.0)
            end
        end
    end
    
    print("^2[CONVOY]^7 Synchronized AI tasks on client (State: " .. data.state .. ")")
end)

-- Interaction / Looting Logic
RegisterNetEvent("djonluc:client:vanDestroyed", function()
    if Config.Event.UseTarget then
        -- Logic to add target to van
        local vanHash = joaat(Config.Vehicles.Van.model)
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
