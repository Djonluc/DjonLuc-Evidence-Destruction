-- client/blips.lua

local eventBlip = nil

RegisterNetEvent("djonluc:client:startBlips", function(vanNetId)
    if eventBlip then RemoveBlip(eventBlip) end

    -- Wait for entity to exist for initial position
    local timeout = 0
    while not NetworkDoesEntityExistWithNetworkId(vanNetId) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    if not NetworkDoesEntityExistWithNetworkId(vanNetId) then return end
    local vehicle = NetworkGetEntityFromNetworkId(vanNetId)
    local coords = GetEntityCoords(vehicle)

    -- PRODUCTION FIX: Use AddBlipForCoord so blip never disappears when entity is culled
    eventBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    
    SetBlipSprite(eventBlip, 477) -- Armored Van
    SetBlipColour(eventBlip, 1)   -- Red
    SetBlipScale(eventBlip, 1.2)
    SetBlipAsShortRange(eventBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Security Convoy")
    EndTextCommandSetBlipName(eventBlip)
    
    SetBlipRoute(eventBlip, true)
    SetBlipRouteColour(eventBlip, 1)

    -- COORDINATE UPDATE THREAD (Non-culled Blip)
    CreateThread(function()
        while DoesEntityExist(vehicle) do
            Wait(2500) -- Update frequency
            local newCoords = GetEntityCoords(vehicle)
            SetBlipCoords(eventBlip, newCoords.x, newCoords.y, newCoords.z)
        end
        
        if eventBlip then 
            RemoveBlip(eventBlip) 
            eventBlip = nil
        end
    end)
end)

RegisterNetEvent("djonluc:client:vanDestroyed", function()
    if eventBlip then
        SetBlipSprite(eventBlip, 303) -- Wreckage
        SetBlipColour(eventBlip, 47)  -- Orange
        SetBlipRoute(eventBlip, false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Destroyed Convoy")
        EndTextCommandSetBlipName(eventBlip)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if eventBlip then RemoveBlip(eventBlip) end
    end
end)
