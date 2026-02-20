Framework = {}
Framework.Type = nil
Framework.Object = nil

if GetResourceState('qb-core') == 'started' then
    Framework.Type = "qb"
    Framework.Object = exports['qb-core']:GetCoreObject()

elseif GetResourceState('qbx_core') == 'started' then
    Framework.Type = "qbox"
    Framework.Object = exports['qbx_core']:GetCoreObject()

elseif GetResourceState('es_extended') == 'started' then
    Framework.Type = "esx"
    Framework.Object = exports['es_extended']:getSharedObject()

elseif GetResourceState('ox_core') == 'started' then
    Framework.Type = "ox"
    -- Ox handles primarily through exports
end

function Framework.GetJob(src)
    if not Framework.Type then return nil end
    
    if Framework.Type == "qb" or Framework.Type == "qbox" then
        local Player = Framework.Object.Functions.GetPlayer(src)
        return Player and Player.PlayerData.job.name
    elseif Framework.Type == "esx" then
        local xPlayer = Framework.Object.GetPlayerFromId(src)
        return xPlayer and xPlayer.job.name
    elseif Framework.Type == "ox" then
        -- Optional: Logic for ox_core job fetch if needed
        local char = exports.ox_core:GetCharacter(src)
        return char and char.getGroup('job')
    end
    return nil
end

function Framework.Notify(src, msg, type)
    if Framework.Type == "qb" or Framework.Type == "qbox" then
        TriggerClientEvent('QBCore:Notify', src, msg, type)
    elseif Framework.Type == "esx" then
        TriggerClientEvent('esx:showNotification', src, msg)
    else
        TriggerClientEvent('chat:addMessage', src, { args = { '^1[Convoy]^7', msg } })
    end
end
