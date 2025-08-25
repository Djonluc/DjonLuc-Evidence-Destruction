-- AI behavior system for escort peds

local escortAI = {}

-- Make escortAI globally accessible for other client files
_G.escortAI = escortAI

function escortAI.InitializePed(ped, config)
    -- Set combat attributes
    SetPedCombatAttributes(ped, 46, true) -- Can use cover
    SetPedCombatAttributes(ped, 5, true)  -- Can fight armed peds
    SetPedCombatAttributes(ped, 2, true)  -- Can use vehicles
    SetPedCombatAttributes(ped, 1, true)  -- Can fight armed peds when not armed
    
    -- Set combat ability
    SetPedCombatAbility(ped, 100)
    SetPedCombatRange(ped, 2)
    SetPedAccuracy(ped, 80)
    
    -- Set behavior
    if config.behavior == "aggressive" then
        SetPedCombatAttributes(ped, 46, true)
        SetPedCombatAttributes(ped, 5, true)
        SetPedCombatAttributes(ped, 17, true) -- Can use group tactics
    end
    
    -- Start AI behavior thread
    Citizen.CreateThread(function()
        escortAI.BehaviorLoop(ped, config)
    end)
end

function escortAI.BehaviorLoop(ped, config)
    while DoesEntityExist(ped) and not IsEntityDead(ped) do
        Citizen.Wait(1000)
        
        local playerPed = PlayerPedId()
        local playerJob = escortAI.GetPlayerJob()
        
        -- Check if player should be ignored
        if Utils.ShouldIgnorePlayer(playerJob) then
            goto continue
        end
        
        local pedPos = GetEntityCoords(ped)
        local playerPos = GetEntityCoords(playerPed)
        local distance = Utils.GetDistance(pedPos, playerPos)
        
        -- Check if player is in alert radius
        if distance <= Config.EscortAIBehavior.alert_radius then
            -- Check if player is attacking
            if escortAI.IsPlayerAttacking() then
                escortAI.EngagePlayer(ped, playerPed)
            elseif distance <= Config.EscortAIBehavior.support_radius then
                escortAI.AlertNearbyGuards(ped, playerPos)
            end
        end
        
        ::continue::
    end
end

function escortAI.EngagePlayer(ped, playerPed)
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
    
    -- Set ped to combat mode
    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAttributes(ped, 5, true)
    
    -- Attack player
    TaskCombatPed(ped, playerPed, 0, 16)
    
    -- Alert other guards
    escortAI.AlertNearbyGuards(ped, GetEntityCoords(playerPed))
end

function escortAI.AlertNearbyGuards(alertingPed, targetPos)
    -- Get escort peds from the main client file
    local escortPeds = _G.convoyEscortPeds or {}
    for _, ped in ipairs(escortPeds) do
        if DoesEntityExist(ped) and not IsEntityDead(ped) and ped ~= alertingPed then
            local pedPos = GetEntityCoords(ped)
            local distance = Utils.GetDistance(pedPos, targetPos)
            
            if distance <= Config.EscortAIBehavior.support_radius then
                -- Move to support position
                local supportPos = GetOffsetFromEntityInWorldCoords(alertingPed, math.random(-5, 5), math.random(-5, 5), 0)
                TaskGoToCoordAnyMeans(ped, supportPos.x, supportPos.y, supportPos.z, 2.0, 0, false, 786603, 0xbf800000)
            end
        end
    end
end

function escortAI.IsPlayerAttacking()
    local playerPed = PlayerPedId()
    
    -- Check if player has weapon drawn
    if IsPedArmed(playerPed, 4) then
        return true
    end
    
    -- Check if player is in combat
    if IsPedInCombat(playerPed, GetPlayerPed(-1)) then
        return true
    end
    
    return false
end

function escortAI.GetPlayerJob()
    if ESX and ESX.GetPlayerData() then
        return ESX.GetPlayerData().job.name
    elseif Utils.Framework.name == "qbcore" or Utils.Framework.name == "qbox" then
        if Utils.Framework.object and Utils.Framework.object.Functions then
            local Player = Utils.Framework.object.Functions.GetPlayerData()
            return Player and Player.job and Player.job.name or "unemployed"
        end
    end
    return "unemployed"
end

-- Export functions
exports('InitializeEscortAI', escortAI.InitializePed)

-- Enhanced AI behavior for realistic escort response
function escortAI.EnhancedCombatBehavior(ped, config)
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
    
    -- Set advanced combat attributes
    SetPedCombatAttributes(ped, 46, true) -- Can use cover
    SetPedCombatAttributes(ped, 5, true)  -- Can fight armed peds
    SetPedCombatAttributes(ped, 2, true)  -- Can use vehicles
    SetPedCombatAttributes(ped, 1, true)  -- Can fight armed peds when not armed
    SetPedCombatAttributes(ped, 17, true) -- Can use group tactics
    SetPedCombatAttributes(ped, 1424, true) -- Can use advanced tactics
    
    -- Set combat ability
    SetPedCombatAbility(ped, 100)
    SetPedCombatRange(ped, 2)
    SetPedAccuracy(ped, 85)
    SetPedFiringPattern(ped, 0x7D60D5ED) -- Burst fire pattern
    
    -- Set behavior based on config
    if config.behavior == "aggressive" then
        SetPedCombatAttributes(ped, 46, true)
        SetPedCombatAttributes(ped, 5, true)
        SetPedCombatAttributes(ped, 17, true)
        SetPedCombatAttributes(ped, 1424, true)
    elseif config.behavior == "defensive" then
        SetPedCombatAttributes(ped, 46, true)
        SetPedCombatAttributes(ped, 2, true)
        SetPedCombatAttributes(ped, 17, true)
    end
    
    -- Start enhanced AI behavior thread
    Citizen.CreateThread(function()
        escortAI.EnhancedBehaviorLoop(ped, config)
    end)
end

function escortAI.EnhancedBehaviorLoop(ped, config)
    while DoesEntityExist(ped) and not IsEntityDead(ped) do
        Citizen.Wait(500) -- More responsive AI
        
        local playerPed = PlayerPedId()
        local playerJob = escortAI.GetPlayerJob()
        
        -- Check if player should be ignored
        if Utils.ShouldIgnorePlayer(playerJob) then
            goto continue
        end
        
        local pedPos = GetEntityCoords(ped)
        local playerPos = GetEntityCoords(playerPed)
        local distance = Utils.GetDistance(pedPos, playerPos)
        
        -- Enhanced threat assessment
        if distance <= Config.EscortAIBehavior.alert_radius then
            local threatLevel = escortAI.AssessThreatLevel(playerPed, distance)
            
            if threatLevel == "high" then
                escortAI.EngagePlayer(ped, playerPed)
                escortAI.CallForBackup(ped, playerPos)
            elseif threatLevel == "medium" then
                escortAI.AlertNearbyGuards(ped, playerPos)
                escortAI.TakeCover(ped, playerPos)
            elseif threatLevel == "low" and distance <= Config.EscortAIBehavior.support_radius then
                escortAI.MonitorPlayer(ped, playerPos)
            end
        end
        
        ::continue::
    end
end

function escortAI.AssessThreatLevel(playerPed, distance)
    -- Check if player has weapon drawn
    if IsPedArmed(playerPed, 4) then
        return "high"
    end
    
    -- Check if player is in combat
    if IsPedInCombat(playerPed, GetPlayerPed(-1)) then
        return "high"
    end
    
    -- Check if player is moving aggressively
    local playerSpeed = GetEntitySpeed(playerPed)
    if playerSpeed > 3.0 and distance < 20.0 then
        return "medium"
    end
    
    return "low"
end

function escortAI.CallForBackup(ped, targetPos)
    -- Enhanced backup calling system
    local backupPeds = _G.convoyEscortPeds or {}
    for _, backupPed in ipairs(backupPeds) do
        if DoesEntityExist(backupPed) and not IsEntityDead(backupPed) and backupPed ~= ped then
            local backupPos = GetEntityCoords(backupPed)
            local distance = Utils.GetDistance(backupPos, targetPos)
            
            if distance <= Config.EscortAIBehavior.support_radius * 1.5 then
                -- Move to tactical position
                local tacticalPos = GetOffsetFromEntityInWorldCoords(ped, math.random(-8, 8), math.random(-8, 8), 0)
                TaskGoToCoordAnyMeans(backupPed, tacticalPos.x, tacticalPos.y, tacticalPos.z, 3.0, 0, false, 786603, 0xbf800000)
                
                -- Set to combat mode
                TaskCombatPed(backupPed, GetPlayerPed(-1), 0, 16)
            end
        end
    end
end

function escortAI.TakeCover(ped, targetPos)
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
    
    -- Find cover position
    local pedPos = GetEntityCoords(ped)
    local coverPos = GetOffsetFromEntityInWorldCoords(ped, math.random(-5, 5), math.random(-5, 5), 0)
    
    -- Move to cover
    TaskGoToCoordAnyMeans(ped, coverPos.x, coverPos.y, coverPos.z, 2.0, 0, false, 786603, 0xbf800000)
    
    -- Set defensive stance
    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAttributes(ped, 2, true)
end

function escortAI.MonitorPlayer(ped, playerPos)
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
    
    -- Turn to face player
    local pedPos = GetEntityCoords(ped)
    local heading = GetHeadingFromVector_2d(playerPos.x - pedPos.x, playerPos.y - pedPos.y)
    SetEntityHeading(ped, heading)
    
    -- Set to alert state
    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAttributes(ped, 2, true)
end

-- Export enhanced AI functions
exports('InitializeEnhancedEscortAI', escortAI.EnhancedCombatBehavior)
