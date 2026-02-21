-- client/main.lua
print("^2[CONVOY] client/main.lua loaded successfully.^7")

ConvoyActive = false
ConvoyActiveNetId = nil

RegisterNetEvent("djonluc:client:startBlips", function(netId)
    ConvoyActive = true
    ConvoyActiveNetId = netId
end)

RegisterNetEvent("djonluc:client:removeBlips", function()
    ConvoyActive = false
    ConvoyActiveNetId = nil
end)

RegisterNetEvent("djonluc:client:stabilizeVehicle", function(netId)
    if not NetworkDoesEntityExistWithNetworkId(netId) then return end
    local veh = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(veh) then
        FreezeEntityPosition(veh, true)
        SetVehicleOnGroundProperly(veh)
        Wait(200)
        FreezeEntityPosition(veh, false)
    end
end)

RegisterNetEvent("djonluc:client:syncConvoyTasks", function(data)
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
            1074528293,
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
                        1,
                        data.speed - 2.0,
                        1074528293,
                        12.0,
                        20,
                        40.0
                    )
                    
                    SetDriverAbility(escortDriver, 1.0)
                    SetDriverAggressiveness(escortDriver, 1.0)
                    SetPedKeepTask(escortDriver, true)
                    SetVehicleSiren(escort, true)
                end
            end
        end
    end)
end)
