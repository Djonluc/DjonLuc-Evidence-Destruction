-- client/main.lua
print("^2[CONVOY] client/main.lua loaded successfully.^7")

local GlobalConvoyData = nil

RegisterNetEvent("djonluc:client:startBlips", function(netId)
    ConvoyActive = true
    ConvoyActiveNetId = netId
end)

RegisterNetEvent("djonluc:client:removeBlips", function()
    ConvoyActive = false
    ConvoyActiveNetId = nil
    GlobalConvoyData = nil
end)

-- RESUME ROUTE HANDLER (PRODUCTION ALIGNMENT)
RegisterNetEvent("djonluc:client:resumeRoute", function()
    if GlobalConvoyData then
        print("^2[CONVOY]^7 Threat neutralized. Resuming route tasking...")
        TriggerEvent("djonluc:client:syncConvoyTasks", GlobalConvoyData)
    end
end)

RegisterNetEvent("djonluc:client:stabilizeVehicle", function(netId)
    if not NetworkDoesEntityExistWithNetworkId(netId) then return end
    local veh = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(veh) then
        FreezeEntityPosition(veh, true)
        SetVehicleOnGroundProperly(veh)
        SetVehicleEngineOn(veh, true, true, false)
        SetVehicleDoorsLocked(veh, 2)
        SetNetworkIdCanMigrate(netId, false)
        Wait(200)
        FreezeEntityPosition(veh, false)
    end
end)

RegisterNetEvent("djonluc:client:syncConvoyTasks", function(data)
    GlobalConvoyData = data -- Cache for resumption
    CreateThread(function()
        local van = nil
        while not van do
            if NetworkDoesEntityExistWithNetworkId(data.vanNetId) then
                van = NetworkGetEntityFromNetworkId(data.vanNetId)
            end
            Wait(50)
        end

        local leader = van
        local leaderDriver = GetPedInVehicleSeat(leader, -1)

        if not DoesEntityExist(leaderDriver) then
            print("^1[CONVOY ERROR]^7 No driver for convoy leader.")
            return
        end

        ConvoyActive = true
        ConvoyActiveNetId = data.vanNetId

        -- 1074528293 = Aggressive, ignore traffic, take shortest path
        TaskVehicleDriveToCoordLongrange(
            leaderDriver,
            leader,
            data.dest.x,
            data.dest.y,
            data.dest.z,
            data.speed,
            1074528293, -- SWAT Driving Style (Elite Alignment)
            5.0
        )
        
        SetDriverAbility(leaderDriver, 1.0)
        SetDriverAggressiveness(leaderDriver, 1.0)
        SetPedKeepTask(leaderDriver, true)
        SetVehicleSiren(leader, true)

        -- Everything else escorts the leader
        for _, netIdEscort in ipairs(data.escortNetIds) do
            if NetworkDoesEntityExistWithNetworkId(netIdEscort) then
                local escort = NetworkGetEntityFromNetworkId(netIdEscort)
                local escortDriver = GetPedInVehicleSeat(escort, -1)
                if DoesEntityExist(escortDriver) then
                    
                    TaskVehicleEscort(
                    escortDriver,
                    escort,
                    leader,
                    -1, -- Proper follow mode for spacing
                    data.speed - 5.0, -- Perfect lag for formation
                    1074528293, -- SWAT Driving Style
                    15.0, -- Precise production spacing
                    30, -- Min distance for speed adjustment
                    50.0 -- Max distance for tasking
                )
                    
                    SetDriverAbility(escortDriver, 1.0)
                    SetDriverAggressiveness(escortDriver, 1.0)
                    SetPedKeepTask(escortDriver, true)
                    SetVehicleSiren(escort, true)
                    SetVehicleHasMutedSirens(escort, false) -- Ensure they are audible
                end
            end
        end
    end)
end)
