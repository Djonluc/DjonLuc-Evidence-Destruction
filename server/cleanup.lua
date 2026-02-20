-- server/cleanup.lua

function CleanupConvoy()
    if Convoy.van and DoesEntityExist(Convoy.van) then
        DeleteEntity(Convoy.van)
    end

    for _, v in pairs(Convoy.escorts) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    
    for _, p in pairs(Convoy.guards) do
        if DoesEntityExist(p) then
            DeleteEntity(p)
        end
    end

    Convoy.active = false
    Convoy.van = nil
    Convoy.escorts = {}
    Convoy.guards = {}
    Convoy.health = 0
    Convoy.destroyed = false
    Convoy.underAttack = false
    Convoy.startedAt = 0
    
    HostileList = {}
    TriggerClientEvent("djonluc:client:updateHostiles", -1, HostileList)
    
    TriggerClientEvent("djonluc:client:removeBlips", -1)
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    CleanupConvoy()
end)
