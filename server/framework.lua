Framework = {}
Framework.Type = "standalone"

if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    Framework.Type = 'qb'

    Framework.AddItem = function(src, item, amount)
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            Player.Functions.AddItem(item, amount)
        end
    end

    Framework.Notify = function(src, msg, type)
        TriggerClientEvent('QBCore:Notify', src, msg, type)
    end

    Framework.GetPlayerJob = function(src)
        local Player = QBCore.Functions.GetPlayer(src)
        return Player and Player.PlayerData.job.name or "unemployed"
    end

elseif GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
    Framework.Type = 'esx'

    Framework.AddItem = function(src, item, amount)
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.addInventoryItem(item, amount)
        end
    end

    Framework.Notify = function(src, msg, type)
        TriggerClientEvent('esx:showNotification', src, msg)
    end

    Framework.GetPlayerJob = function(src)
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer and xPlayer.job.name or "unemployed"
    end
else
    -- Standalone Notify
    Framework.Notify = function(src, msg, type)
        TriggerClientEvent('djonluc:client:Notify', src, msg, type)
    end
end
