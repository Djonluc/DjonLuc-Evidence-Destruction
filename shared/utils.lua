-- Shared utility functions for Evidence Destruction Event

Utils = {}

-- Framework detection and compatibility
Utils.Framework = {
    name = "unknown",
    version = "unknown",
    object = nil
}

-- Optional dependency detection
Utils.OptionalDeps = {
    ox_inventory = false,
    qb_inventory = false,
    ox_target = false,
    qb_target = false,
    ox_lib = false,
    qb_menu = false,
    ox_weapons = false
}

-- Enhanced framework detection with retry mechanism
Citizen.CreateThread(function()
    local maxRetries = 10
    local retryCount = 0
    
    local function detectFramework()
        -- Try QBCore first (primary framework - most common)
        if GetResourceState('qb-core') == 'started' then
            local success, QBCore = pcall(function()
                -- Official QBCore method: GetCoreObject()
                local core = exports['qb-core']:GetCoreObject()
                -- Validate QBCore object has required methods (FiveM best practice)
                if core and core.Functions and core.Functions.GetPlayer then
                    return core
                end
                return nil
            end)
            if success and QBCore then
                Utils.Framework.name = "qbcore"
                Utils.Framework.version = "latest"
                Utils.Framework.object = QBCore
                print("^2[Djonluc Evidence Event]^7 QBCore Framework detected via official method")
                return true
            else
                print("^3[Djonluc Evidence Event]^7 QBCore detected but GetCoreObject() failed or invalid")
            end
        end
        
        -- Try QBox (QBCore-based framework)
        if GetResourceState('qbox-core') == 'started' then
            local success, QBox = pcall(function()
                local core = exports['qbox-core']:GetCoreObject()
                -- Validate QBox object has required methods (FiveM best practice)
                if core and core.Functions and core.Functions.GetPlayer then
                    return core
                end
                return nil
            end)
            if success and QBox then
                Utils.Framework.name = "qbox"
                Utils.Framework.version = "latest"
                Utils.Framework.object = QBox
                print("^2[Djonluc Evidence Event]^7 QBox Framework detected")
                return true
            end
        end
        
        -- Try ESX (fallback)
        if GetResourceState('es_extended') == 'started' then
            -- Try ESX Legacy export method first (more reliable)
            local success, ESX = pcall(function()
                return exports['es_extended']:getSharedObject()
            end)
            if success and ESX then
                Utils.Framework.name = "esx"
                Utils.Framework.version = "legacy"
                Utils.Framework.object = ESX
                print("^2[Djonluc Evidence Event]^7 ESX Framework detected via export")
                return true
            end
            
            -- Fallback to event method
            TriggerEvent('esx:getSharedObject', function(obj)
                if obj then
                    Utils.Framework.name = "esx"
                    Utils.Framework.version = "legacy"
                    Utils.Framework.object = obj
                    print("^2[Djonluc Evidence Event]^7 ESX Framework detected via event")
                end
            end)
            
            -- Wait a bit for event to complete
            Citizen.Wait(1000)
            if Utils.Framework.name == "esx" then
                return true
            end
        end
        
        -- Try QBox (QBCore-based framework)
        if GetResourceState('qbox-core') == 'started' then
            local success, QBox = pcall(function()
                return exports['qbox-core']:GetCoreObject()
            end)
            if success and QBox then
                Utils.Framework.name = "qbox"
                Utils.Framework.version = "latest"
                Utils.Framework.object = QBox
                print("^2[Djonluc Evidence Event]^7 QBox Framework detected")
                return true
            end
        end
        
        -- Try vRP
        if GetResourceState('vrp') == 'started' then
            Utils.Framework.name = "vrp"
            Utils.Framework.version = "legacy"
            print("^2[Djonluc Evidence Event]^7 vRP Framework detected")
            return true
        end
        
        return false
    end
    
    -- Try to detect framework with retries
    while retryCount < maxRetries and not detectFramework() do
        retryCount = retryCount + 1
        print("^3[Djonluc Evidence Event]^7 Framework detection attempt " .. retryCount .. "/" .. maxRetries)
        Citizen.Wait(2000) -- Wait 2 seconds between attempts
    end
    
    if Utils.Framework.name == "unknown" then
        print("^1[Djonluc Evidence Event]^7 WARNING: No framework detected! Script may not work properly.")
        print("^1[Djonluc Evidence Event]^7 Supported frameworks: ESX, QBCore, QBox, vRP")
    else
        print("^2[Djonluc Evidence Event]^7 Framework detection completed: " .. Utils.Framework.name .. " (" .. Utils.Framework.version .. ")")
    end
    
    -- Enhanced optional dependency detection with validation
    print("^3[Djonluc Evidence Event]^7 Scanning for optional dependencies...")
    
    -- Inventory systems
    Utils.OptionalDeps.ox_inventory = GetResourceState('ox_inventory') == 'started'
    Utils.OptionalDeps.qb_inventory = GetResourceState('qb-inventory') == 'started'
    
    -- Target systems
    Utils.OptionalDeps.ox_target = GetResourceState('ox_target') == 'started'
    Utils.OptionalDeps.qb_target = GetResourceState('qb-target') == 'started'
    
         -- Menu systems
     Utils.OptionalDeps.ox_lib = GetResourceState('ox_lib') == 'started'
     Utils.OptionalDeps.qb_menu = GetResourceState('qb-menu') == 'started'
     
     -- Enhanced ox_lib validation
     if Utils.OptionalDeps.ox_lib then
         local success = pcall(function()
             return exports.ox_lib ~= nil
         end)
         Utils.OptionalDeps.ox_lib = success
         if success then
             print("^2[Djonluc Evidence Event]^7 ✅ ox_lib detected and validated")
         else
             print("^3[Djonluc Evidence Event]^7 ⚠️ ox_lib resource found but exports not accessible")
         end
     end
    
    -- Weapon systems
    Utils.OptionalDeps.ox_weapons = GetResourceState('ox_weapons') == 'started'
    
    -- Print detected optional dependencies with status
    local detectedDeps = {}
    local missingDeps = {}
    
    for dep, available in pairs(Utils.OptionalDeps) do
        if available then
            table.insert(detectedDeps, dep)
        else
            table.insert(missingDeps, dep)
        end
    end
    
    if #detectedDeps > 0 then
        print("^2[Djonluc Evidence Event]^7 ✅ Optional dependencies detected: " .. table.concat(detectedDeps, ", "))
    end
    
    if #missingDeps > 0 then
        print("^3[Djonluc Evidence Event]^7 ⚠️  Missing optional dependencies: " .. table.concat(missingDeps, ", "))
        print("^3[Djonluc Evidence Event]^7 Using fallback systems for missing dependencies")
    end
    
    -- Final status report
    print("^2[Djonluc Evidence Event]^7 ========================================")
    print("^2[Djonluc Evidence Event]^7 Framework: " .. Utils.Framework.name .. " (" .. Utils.Framework.version .. ")")
    print("^2[Djonluc Evidence Event]^7 Optional Dependencies: " .. #detectedDeps .. "/" .. (#detectedDeps + #missingDeps))
    print("^2[Djonluc Evidence Event]^7 ========================================")
    
    -- Schedule a re-check after 30 seconds to catch late-loading frameworks
    SetTimeout(30000, function()
        if Utils.Framework.name == "unknown" then
            print("^3[Djonluc Evidence Event]^7 Re-checking for frameworks after 30 seconds...")
            detectFramework()
            if Utils.Framework.name ~= "unknown" then
                print("^2[Djonluc Evidence Event]^7 Framework detected on re-check: " .. Utils.Framework.name)
            end
        end
    end)
end)

-- Function to manually re-detect framework (useful for troubleshooting)
function Utils.ReDetectFramework()
    print("^3[Djonluc Evidence Event]^7 Manually re-detecting framework...")
    Utils.Framework.name = "unknown"
    Utils.Framework.version = "unknown"
    Utils.Framework.object = nil
    
    local function detectFramework()
        -- Try ESX first (most common)
        if GetResourceState('es_extended') == 'started' then
            local success, ESX = pcall(function()
                return exports['es_extended']:getSharedObject()
            end)
            if success and ESX then
                Utils.Framework.name = "esx"
                Utils.Framework.version = "legacy"
                Utils.Framework.object = ESX
                return true
            end
        end
        
        -- Try QBCore
        if GetResourceState('qb-core') == 'started' then
            local success, QBCore = pcall(function()
                return exports['qb-core']:GetCoreObject()
            end)
            if success and QBCore then
                Utils.Framework.name = "qbcore"
                Utils.Framework.version = "latest"
                Utils.Framework.object = QBCore
                return true
            end
        end
        
        -- Try QBox
        if GetResourceState('qbox-core') == 'started' then
            local success, QBox = pcall(function()
                return exports['qbox-core']:GetCoreObject()
            end)
            if success and QBox then
                Utils.Framework.name = "qbox"
                Utils.Framework.version = "latest"
                Utils.Framework.object = QBox
                return true
            end
        end
        
        -- Try vRP
        if GetResourceState('vrp') == 'started' then
            Utils.Framework.name = "vrp"
            Utils.Framework.version = "legacy"
            return true
        end
        
        return false
    end
    
    if detectFramework() then
        print("^2[Djonluc Evidence Event]^7 Framework re-detection successful: " .. Utils.Framework.name)
        Utils.PrintFrameworkStatus()
    else
        print("^1[Djonluc Evidence Event]^7 Framework re-detection failed")
    end
end

-- Framework validation and status functions
function Utils.IsFrameworkReady()
    return Utils.Framework.name ~= "unknown" and Utils.Framework.object ~= nil
end

function Utils.GetFrameworkStatus()
    local status = {
        name = Utils.Framework.name,
        version = Utils.Framework.version,
        ready = Utils.IsFrameworkReady(),
        object = Utils.Framework.object ~= nil
    }
    
    if Utils.Framework.name == "esx" then
        status.ready = status.ready and Utils.Framework.object.GetPlayerFromId ~= nil
    elseif Utils.Framework.name == "qbcore" or Utils.Framework.name == "qbox" then
        status.ready = status.ready and Utils.Framework.object.Functions ~= nil
    elseif Utils.Framework.name == "vrp" then
        status.ready = status.ready and vRP ~= nil
    end
    
    return status
end

function Utils.PrintFrameworkStatus()
    local status = Utils.GetFrameworkStatus()
    print("^2[Djonluc Evidence Event]^7 ========================================")
    print("^2[Djonluc Evidence Event]^7 Framework Status Report:")
    print("^2[Djonluc Evidence Event]^7 Name: " .. status.name)
    print("^2[Djonluc Evidence Event]^7 Version: " .. status.version)
    print("^2[Djonluc Evidence Event]^7 Ready: " .. (status.ready and "✅ YES" or "❌ NO"))
    print("^2[Djonluc Evidence Event]^7 Object: " .. (status.object and "✅ YES" or "❌ NO"))
    print("^2[Djonluc Evidence Event]^7 ========================================")
    
    if not status.ready then
        print("^1[Djonluc Evidence Event]^7 WARNING: Framework not ready! Some features may not work.")
        print("^1[Djonluc Evidence Event]^7 Please ensure your framework is properly loaded.")
    end
end

-- Check if player has required job
function Utils.HasRequiredJob(playerJob)
    for _, job in ipairs(Config.StartJobs) do
        if playerJob == job then
            return true
        end
    end
    return false
end

-- Check if player should be ignored by guards
function Utils.ShouldIgnorePlayer(playerJob)
    for _, job in ipairs(Config.GuardIgnoreJobs) do
        if playerJob == job then
            return true
        end
    end
    return false
end

-- Framework-specific job checking with error handling
function Utils.GetPlayerJob(source)
    if not Utils.IsFrameworkReady() then
        print("^1[Djonluc Evidence Event]^7 ERROR: Framework not ready in GetPlayerJob")
        return "unemployed"
    end
    
    local success, result = pcall(function()
        if Utils.Framework.name == "esx" then
            if Utils.Framework.object and Utils.Framework.object.GetPlayerFromId then
                local xPlayer = Utils.Framework.object.GetPlayerFromId(source)
                return xPlayer and xPlayer.job and xPlayer.job.name or "unemployed"
            end
        elseif Utils.Framework.name == "qbcore" or Utils.Framework.name == "qbox" then
            if Utils.Framework.object and Utils.Framework.object.Functions and Utils.Framework.object.Functions.GetPlayer then
                local Player = Utils.Framework.object.Functions.GetPlayer(source)
                -- Official QBCore job checking method
                if Player and Player.PlayerData and Player.PlayerData.job then
                    return Player.PlayerData.job.name
                end
            end
        elseif Utils.Framework.name == "vrp" then
            if vRP and vRP.getUserId and vRP.getUserGroupByType then
                local user_id = vRP.getUserId({source})
                if user_id then
                    local job = vRP.getUserGroupByType({user_id, "job"})
                    return job or "unemployed"
                end
            end
        end
        return "unemployed"
    end)
    
    if success then
        return result
    else
        print("^1[Djonluc Evidence Event]^7 ERROR in GetPlayerJob: " .. tostring(result))
        return "unemployed"
    end
end

-- Framework-specific player validation
function Utils.ValidatePlayer(source)
    if Utils.Framework.name == "esx" then
        return Utils.Framework.object.GetPlayerFromId(source)
    elseif Utils.Framework.name == "qbcore" or Utils.Framework.name == "qbox" then
        return Utils.Framework.object.Functions.GetPlayer(source)
    elseif Utils.Framework.name == "vrp" then
        local user_id = vRP.getUserId({source})
        return user_id and {id = user_id} or nil
    end
    return nil
end

-- Get random route
function Utils.GetRandomRoute()
    local routes = {}
    
    -- Add configured routes
    for _, route in pairs(Config.Routes) do
        table.insert(routes, route)
    end
    
    -- Add custom routes from other resources
    local success, customRoutes = pcall(function()
        return exports.djonluc_evidence_event:GetCustomRoutes()
    end)
    if success and customRoutes then
        for _, route in pairs(customRoutes) do
            table.insert(routes, route)
        end
    end
    
    if #routes == 0 then
        return nil
    end
    
    return routes[math.random(1, #routes)]
end

-- Generate dynamic route between two points
function Utils.GenerateDynamicRoute(startPoint, endPoint)
    if not startPoint or not endPoint then
        print("^1[Djonluc Evidence Event]^7 ERROR: Start and end points required for dynamic route")
        return nil
    end
    
    local route = {
        start = startPoint,
        destruction = endPoint,
        waypoints = {}
    }
    
    -- Generate waypoints between start and end
    local waypointCount = Config.DynamicRoutes.waypoint_count
    local minDist = Config.DynamicRoutes.min_distance
    local maxDist = Config.DynamicRoutes.max_distance
    
    for i = 1, waypointCount do
        local progress = i / (waypointCount + 1)
        local basePos = startPoint + (endPoint - startPoint) * progress
        
        -- Add some randomness to make routes more interesting
        local randomOffset = vector3(
            math.random(-maxDist/2, maxDist/2),
            math.random(-maxDist/2, maxDist/2),
            0
        )
        
        local waypoint = basePos + randomOffset
        waypoint.z = startPoint.z + (endPoint.z - startPoint.z) * progress
        
        -- Ensure waypoint is at least min_distance from previous waypoint
        if i > 1 then
            local prevWaypoint = route.waypoints[i-1]
            local distance = Utils.GetDistance(waypoint, prevWaypoint)
            if distance < minDist then
                local direction = (waypoint - prevWaypoint):Normalize()
                waypoint = prevWaypoint + direction * minDist
            end
        end
        
        table.insert(route.waypoints, waypoint)
    end
    
    return route
end

-- Validate route points
function Utils.ValidateRoutePoints(startPoint, endPoint)
    if not startPoint or not endPoint then
        return false, "Start and end points are required"
    end
    
    if not Utils.IsValidPosition(startPoint) or not Utils.IsValidPosition(endPoint) then
        return false, "Invalid position format (must be vector3)"
    end
    
    local distance = Utils.GetDistance(startPoint, endPoint)
    if distance < 100.0 then
        return false, "Start and end points must be at least 100 units apart"
    end
    
    if distance > 5000.0 then
        return false, "Start and end points cannot be more than 5000 units apart"
    end
    
    return true, "Valid route points"
end



-- Format notification message
function Utils.FormatNotification(message, data)
    if data and data.location then
        return string.gsub(message, "{location}", data.location)
    end
    return message
end

-- Calculate distance between two points
function Utils.GetDistance(pos1, pos2)
    return #(pos1 - pos2)
end

-- Check if position is valid
function Utils.IsValidPosition(pos)
    return pos and pos.x and pos.y and pos.z
end

-- Get vehicle model hash
function Utils.GetVehicleHash(model)
    return GetHashKey(model)
end

-- Get ped model hash
function Utils.GetPedHash(model)
    return GetHashKey(model)
end

-- Enhanced notification detection and system
function Utils.ShowNotification(source, message, type)
    -- Try ox_lib notifications first if available (most modern)
    if Utils.OptionalDeps and Utils.OptionalDeps.ox_lib then
        local success = pcall(function()
            TriggerClientEvent('ox_lib:notify', source, {
                type = type or 'inform',
                description = message,
                duration = 5000
            })
        end)
        if success then return end
    end
    
    -- Try framework-specific notifications
    if Utils.Framework.name == "esx" then
        TriggerClientEvent('esx:showNotification', source, message)
    elseif Utils.Framework.name == "qbcore" or Utils.Framework.name == "qbox" then
        -- Latest QBCore notification method (FiveM best practice)
        TriggerClientEvent('QBCore:Notify', source, message, type or 'primary', 5000)
    elseif Utils.Framework.name == "vrp" then
        TriggerClientEvent('chatMessage', source, '^2[Djonluc Evidence Event]^7', {255, 255, 255}, message)
    else
        -- Fallback to basic notification
        TriggerClientEvent('chatMessage', source, '^2[Djonluc Evidence Event]^7', {255, 255, 255}, message)
    end
end

-- Enhanced notification with title and description
function Utils.ShowAdvancedNotification(source, title, message, type, duration)
    duration = duration or 5000
    
    -- Try ox_lib advanced notifications first
    if Utils.OptionalDeps and Utils.OptionalDeps.ox_lib then
        local success = pcall(function()
            TriggerClientEvent('ox_lib:notify', source, {
                type = type or 'inform',
                title = title,
                description = message,
                duration = duration
            })
        end)
        if success then return end
    end
    
    -- Fallback to basic notification
    Utils.ShowNotification(source, title .. ': ' .. message, type)
end

-- Check if ox_lib is properly available and working
function Utils.IsOxLibAvailable()
    if not Utils.OptionalDeps or not Utils.OptionalDeps.ox_lib then
        return false
    end
    
    -- Test if ox_lib exports are working
    local success = pcall(function()
        return exports.ox_lib ~= nil
    end)
    
    return success
end

-- QBCore-specific utility functions (FiveM best practice)
function Utils.GetQBCorePlayer(source)
    if not Utils.IsFrameworkReady() or (Utils.Framework.name ~= "qbcore" and Utils.Framework.name ~= "qbox") then
        return nil
    end
    
    local success, Player = pcall(function()
        return Utils.Framework.object.Functions.GetPlayer(source)
    end)
    
    if success and Player then
        return Player
    end
    
    return nil
end

-- Get player job using latest QBCore method
function Utils.GetQBCorePlayerJob(source)
    local Player = Utils.GetQBCorePlayer(source)
    if Player and Player.PlayerData and Player.PlayerData.job then
        return Player.PlayerData.job.name, Player.PlayerData.job.grade
    end
    return "unemployed", 0
end

-- Get player money using latest QBCore method
function Utils.GetQBCorePlayerMoney(source, moneyType)
    local Player = Utils.GetQBCorePlayer(source)
    if Player and Player.Functions.GetMoney then
        local success, money = pcall(function()
            return Player.Functions.GetMoney(moneyType or "cash")
        end)
        if success then
            return money
        end
    end
    return 0
end

-- Add money to player using latest QBCore method
function Utils.AddQBCorePlayerMoney(source, moneyType, amount, reason)
    local Player = Utils.GetQBCorePlayer(source)
    if Player and Player.Functions.AddMoney then
        local success = pcall(function()
            Player.Functions.AddMoney(moneyType or "cash", amount, reason or "Evidence Event")
        end)
        return success
    end
    return false
end

-- Remove money from player using latest QBCore method
function Utils.RemoveQBCorePlayerMoney(source, moneyType, amount, reason)
    local Player = Utils.GetQBCorePlayer(source)
    if Player and Player.Functions.RemoveMoney then
        local success = pcall(function()
            Player.Functions.RemoveMoney(moneyType or "cash", amount, reason or "Evidence Event")
        end)
        return success
    end
    return false
end

-- Give item to player using latest QBCore method
function Utils.GiveQBCorePlayerItem(source, item, amount, slot, info)
    local Player = Utils.GetQBCorePlayer(source)
    if Player and Player.Functions.AddItem then
        local success = pcall(function()
            Player.Functions.AddItem(item, amount, slot, info)
        end)
        return success
    end
    return false
end

-- Remove item from player using latest QBCore method
function Utils.RemoveQBCorePlayerItem(source, item, amount, slot)
    local Player = Utils.GetQBCorePlayer(source)
    if Player and Player.Functions.RemoveItem then
        local success = pcall(function()
            Player.Functions.RemoveItem(item, amount, slot)
        end)
        return success
    end
    return false
end

-- Check if player has item using latest QBCore method
function Utils.QBCorePlayerHasItem(source, item, amount)
    local Player = Utils.GetQBCorePlayer(source)
    if Player and Player.Functions.GetItemByName then
        local success, itemData = pcall(function()
            return Player.Functions.GetItemByName(item)
        end)
        if success and itemData then
            return itemData.amount >= (amount or 1)
        end
    end
    return false
end

-- Get player inventory using latest QBCore method
function Utils.GetQBCorePlayerInventory(source)
    local Player = Utils.GetQBCorePlayer(source)
    if Player and Player.Functions.GetItemsByName then
        local success, items = pcall(function()
            return Player.Functions.GetItemsByName()
        end)
        if success then
            return items
        end
    end
    return {}
end

-- QBCore notification wrapper (latest standard)
function Utils.QBCoreNotify(source, message, type, duration)
    if Utils.Framework.name == "qbcore" or Utils.Framework.name == "qbox" then
        -- Latest QBCore notification method with proper parameters
        TriggerClientEvent('QBCore:Notify', source, message, type or 'primary', duration or 5000)
        return true
    end
    return false
end

-- QBCore progress bar wrapper (if available)
function Utils.QBCoreProgressBar(source, duration, label, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if Utils.Framework.name == "qbcore" or Utils.Framework.name == "qbox" then
        -- Check if QBCore progress bar is available
        local success = pcall(function()
            TriggerClientEvent('QBCore:Progressbar', source, duration, label, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
        end)
        return success
    end
    return false
end

-- QBCore target system wrapper (if available)
function Utils.QBCoreAddTargetEntity(entity, options)
    if Utils.Framework.name == "qbcore" or Utils.Framework.name == "qbox" then
        -- Check if qb-target is available
        if Utils.OptionalDeps.qb_target then
            local success = pcall(function()
                exports['qb-target']:AddTargetEntity(entity, options)
            end)
            return success
        end
    end
    return false
end

-- QBCore menu system wrapper (if available)
function Utils.QBCoreShowMenu(source, menuData)
    if Utils.Framework.name == "qbcore" or Utils.Framework.name == "qbox" then
        -- Check if qb-menu is available
        if Utils.OptionalDeps.qb_menu then
            local success = pcall(function()
                TriggerClientEvent('qb-menu:client:openMenu', source, menuData)
            end)
            return success
        end
    end
    return false
end

-- Test ox_lib functionality
function Utils.TestOxLibFunctionality()
    if not Utils.IsOxLibAvailable() then
        return false, "ox_lib not available"
    end
    
    local tests = {
        notify = false,
        showContext = false,
        inputDialog = false
    }
    
    -- Test notify function
    local notifySuccess = pcall(function()
        return exports.ox_lib.notify ~= nil
    end)
    tests.notify = notifySuccess
    
    -- Test showContext function
    local contextSuccess = pcall(function()
        return exports.ox_lib.showContext ~= nil
    end)
    tests.showContext = contextSuccess
    
    -- Test inputDialog function
    local inputSuccess = pcall(function()
        return exports.ox_lib.inputDialog ~= nil
    end)
    tests.inputDialog = inputSuccess
    
    return true, tests
end

-- Print detailed ox_lib status
function Utils.PrintOxLibStatus()
    if not Utils.OptionalDeps.ox_lib then
        print("^3[Djonluc Evidence Event]^7 ox_lib: ❌ Not detected")
        return
    end
    
    local isAvailable = Utils.IsOxLibAvailable()
    if not isAvailable then
        print("^3[Djonluc Evidence Event]^7 ox_lib: ⚠️ Resource found but exports not accessible")
        return
    end
    
    local success, tests = Utils.TestOxLibFunctionality()
    if success then
        print("^2[Djonluc Evidence Event]^7 ox_lib: ✅ Available")
        print("^3[Djonluc Evidence Event]^7   - notify: " .. (tests.notify and "✅" or "❌"))
        print("^3[Djonluc Evidence Event]^7   - showContext: " .. (tests.showContext and "✅" or "❌"))
        print("^3[Djonluc Evidence Event]^7   - inputDialog: " .. (tests.inputDialog and "✅" or "❌"))
    else
        print("^1[Djonluc Evidence Event]^7 ox_lib: ❌ Functionality test failed")
    end
end
