-- client/blips.lua

local eventBlip = nil

RegisterNetEvent("djonluc:client:startBlips", function(netId)
    if eventBlip then RemoveBlip(eventBlip) end

    if not netId or netId == 0 then return end
    
    local vehicle = nil
    local timeout = 0
    while not vehicle and timeout < 100 do
        if NetworkDoesEntityExistWithNetworkId(netId) then
            vehicle = NetworkGetEntityFromNetworkId(netId)
        end
        Wait(100)
        timeout = timeout + 1
    end

    if not vehicle then return end

    eventBlip = AddBlipForEntity(vehicle)
    SetBlipSprite(eventBlip, 67)
    SetBlipColour(eventBlip, 2) -- Green
    SetBlipScale(eventBlip, 1.2)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Evidence Convoy")
    EndTextCommandSetBlipName(eventBlip)

    CreateThread(function()
        while DoesEntityExist(vehicle) do
            Wait(1000)
            local health = GetEntityHealth(vehicle)
            local maxHealth = Config.Formation.Van.health
            
            local percent = (health / maxHealth) * 100

            if percent < 30 then
                SetBlipColour(eventBlip, 1) -- Red
            elseif percent < 70 then
                SetBlipColour(eventBlip, 5) -- Yellow
            else
                SetBlipColour(eventBlip, 2) -- Green
            end
        end
        if eventBlip then 
            RemoveBlip(eventBlip) 
            eventBlip = nil 
        end
    end)
end)

RegisterNetEvent("djonluc:client:removeBlips", function()
    if eventBlip then
        RemoveBlip(eventBlip)
        eventBlip = nil
    end
end)
