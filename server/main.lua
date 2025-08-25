-- Server-side main logic for Evidence Destruction Event

local QBCore = nil
local ESX = nil
local eventActive = false
local eventData = {}
local convoyVehicles = {}
local escortPeds = {}


-- Dynamic route management
local currentDynamicRoute = {
    start = vector3(123.45, 678.90, 12.34),
    endPoint = vector3(-100.50, 200.75, 60.25),
    active = false
}

-- Initialize Framework (QBCore/ESX)
Citizen.CreateThread(function()
    print("^3[Djonluc Evidence Event]^7 Starting framework initialization...")
    
    -- Wait for Utils to be available
    local waitCount = 0
    while not Utils or not Utils.Framework do
        Citizen.Wait(100)
        waitCount = waitCount + 1
        if waitCount % 50 == 0 then -- Print every 5 seconds
            print("^3[Djonluc Evidence Event]^7 Waiting for Utils to be available... (attempt " .. waitCount .. ")")
        end
        if waitCount > 200 then -- Timeout after 20 seconds
            print("^1[Djonluc Evidence Event]^7 ERROR: Timeout waiting for Utils to be available!")
            return
        end
    end
    
    print("^3[Djonluc Evidence Event]^7 Utils available, checking framework...")
    print("^3[Djonluc Evidence Event]^7 Framework name:", Utils.Framework.name)
    print("^3[Djonluc Evidence Event]^7 Framework version:", Utils.Framework.version)
    
    -- Initialize based on detected framework
    if Utils.Framework.name == "qbcore" or Utils.Framework.name == "qbox" then
        print("^3[Djonluc Evidence Event]^7 Initializing QBCore...")
        QBCore = Utils.Framework.object
        if QBCore then
            print("^2[Djonluc Evidence Event]^7 QBCore initialized successfully")
        else
            print("^1[Djonluc Evidence Event]^7 Failed to get QBCore object")
        end
    elseif Utils.Framework.name == "esx" then
        print("^3[Djonluc Evidence Event]^7 Initializing ESX...")
        ESX = Utils.Framework.object
        if ESX then
            print("^2[Djonluc Evidence Event]^7 ESX initialized successfully")
        else
            print("^1[Djonluc Evidence Event]^7 Failed to get ESX object")
        end
    else
        print("^1[Djonluc Evidence Event]^7 Unknown framework:", Utils.Framework.name)
    end
    
    print("^3[Djonluc Evidence Event]^7 Framework initialization completed")
end)

-- Event management
function StartEvidenceEvent(source)
    print("^3[Djonluc Evidence Event]^7 StartEvidenceEvent called by player:", source)
    
    local player = Utils.ValidatePlayer(source)
    print("^3[Djonluc Evidence Event]^7 Player validation result:", player and "success" or "failed")
    
    if not player then
        print("^1[Djonluc Evidence Event]^7 ERROR: Player not found")
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Player not found')
        return false
    end
    
    local playerJob = Utils.GetPlayerJob(source)
    print("^3[Djonluc Evidence Event]^7 Player job:", playerJob)
    
    if not Utils.HasRequiredJob(playerJob) then
        print("^1[Djonluc Evidence Event]^7 ERROR: Player does not have required job. Required jobs:", table.concat(Config.StartJobs, ", "))
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'You do not have permission to start this event')
        return false
    end
    
    if eventActive then
        print("^3[Djonluc Evidence Event]^7 Event already active")
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Event already in progress')
        return false
    end
    
    -- Validate configuration
    if not Config.Routes or next(Config.Routes) == nil then
        print("^1[Djonluc Evidence Event]^7 ERROR: No routes configured")
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'No routes configured for events')
        return false
    end
    
    print("^3[Djonluc Evidence Event]^7 All validations passed, starting event...")
    
    -- Start the event
    eventActive = true
    local route = nil
    
    -- Check if dynamic route is active, otherwise use random route
    if currentDynamicRoute and currentDynamicRoute.active then
        print("^3[Djonluc Evidence Event]^7 Using dynamic route")
        route = {
            start = vector4(currentDynamicRoute.start.x, currentDynamicRoute.start.y, currentDynamicRoute.start.z, currentDynamicRoute.start.w or 0.0),
            destruction = vector4(currentDynamicRoute.endPoint.x, currentDynamicRoute.endPoint.y, currentDynamicRoute.endPoint.z, currentDynamicRoute.endPoint.w or 0.0)
        }
        if route then
            print("^2[Djonluc Evidence Event]^7 Using dynamic route from " .. 
                  currentDynamicRoute.start.x .. "," .. currentDynamicRoute.start.y .. 
                  " to " .. currentDynamicRoute.endPoint.x .. "," .. currentDynamicRoute.endPoint.y)
        end
    end
    
    -- Fallback to random route if dynamic route failed
    if not route then
        print("^3[Djonluc Evidence Event]^7 Using random route")
        local routeKeys = {}
        for k, _ in pairs(Config.Routes) do
            table.insert(routeKeys, k)
        end
        local randomRouteKey = routeKeys[math.random(#routeKeys)]
        local selectedRoute = Config.Routes[randomRouteKey]
        if selectedRoute then
            route = {
                start = vector4(selectedRoute.start.x, selectedRoute.start.y, selectedRoute.start.z, selectedRoute.start.w or 0.0),
                destruction = vector4(selectedRoute.destruction.x, selectedRoute.destruction.y, selectedRoute.destruction.z, selectedRoute.destruction.w or 0.0)
            }
            print("^2[Djonluc Evidence Event]^7 Using random route: " .. route.start.x .. "," .. route.start.y .. " (heading: " .. route.start.w .. ")")
        end
    end
    
    if not route then
        print("^1[Djonluc Evidence Event]^7 ERROR: No valid route available")
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'No valid route available')
        eventActive = false
        return false
    end
    
    print("^2[Djonluc Evidence Event]^7 Route selected successfully, spawning convoy...")
    
    eventData = {
        startTime = GetGameTimer(),
        route = route,
        startedBy = source,
        escortPedsAlive = 0
    }
    
    -- Create proper route structure for client (use the selected route)
    local clientRoute = {
        start = vector4(route.start.x, route.start.y, route.start.z, route.start.w or 0.0),
        destruction = vector4(route.destruction.x, route.destruction.y, route.destruction.z, route.destruction.w or 0.0)
    }
    
    -- Debug: Log the route being sent to client
    print("^3[Djonluc Evidence Event]^7 🗺️ Route being sent to client:")
    print("^3[Djonluc Evidence Event]^7   Start:", clientRoute.start.x, clientRoute.start.y, clientRoute.start.z, "Heading:", clientRoute.start.w)
    print("^3[Djonluc Evidence Event]^7   End:", clientRoute.destruction.x, clientRoute.destruction.y, clientRoute.destruction.z, "Heading:", clientRoute.destruction.w)
    
    -- Spawn convoy on all clients
    print("^3[Djonluc Evidence Event]^7 🚗 Spawning convoy on all clients...")
    TriggerClientEvent('djonluc_evidence_event:spawnConvoy', -1, clientRoute)
    
    -- Wait for convoy to spawn, then fill vehicle trunk with loot
    Citizen.SetTimeout(3000, function()
        -- Find the evidence vehicle and fill its trunk
        local evidenceVehicle = nil
        for _, vehicle in ipairs(convoyVehicles) do
            if DoesEntityExist(vehicle) then
                local model = GetEntityModel(vehicle)
                if model == GetHashKey(Config.Vehicles.evidence_van.model) then
                    evidenceVehicle = vehicle
                    break
                end
            end
        end
        
        if evidenceVehicle then
            local vehicleNetId = NetworkGetNetworkIdFromEntity(evidenceVehicle)
            FillVehicleTrunk(vehicleNetId)
        else
            print("^1[Djonluc Evidence Event]^7 ❌ Could not find evidence vehicle to fill trunk")
        end
    end)
    
    -- Start event timer
    SetTimeout(Config.EventDuration, function()
        EndEvent(true) -- Event completed successfully
    end)
    
    -- Notify all players
    local notification = Utils.FormatNotification(Config.Notifications.event_started, {
        location = string.format("%.1f, %.1f", route.start.x, route.start.y)
    })
    TriggerClientEvent('djonluc_evidence_event:showNotification', -1, notification)
    
    print("^2[Djonluc Evidence Event]^7 Event started successfully!")
    return true
end

function EndEvent(success)
    if not eventActive then return end
    
    eventActive = false
    
    if success then
        TriggerClientEvent('djonluc_evidence_event:showNotification', -1, Config.Notifications.event_ended)
    else
        TriggerClientEvent('djonluc_evidence_event:showNotification', -1, Config.Notifications.event_failed)
    end
    
    -- Clean up convoy
    TriggerClientEvent('djonluc_evidence_event:cleanupConvoy', -1)
    
    -- Clean up loot crate if exists

    
    -- Reset event data
    eventData = {}
    convoyVehicles = {}
    escortPeds = {}
end

-- Handle escort ped death
function OnEscortPedDeath(pedId)
    if not eventActive then return end
    
    eventData.escortPedsAlive = eventData.escortPedsAlive - 1
    
    -- Check if all escort peds are dead
    if eventData.escortPedsAlive <= 0 then
        -- Event ends when all escort peds are dead
        EndEvent(false)
    end
end





-- Commands
RegisterCommand('startevidence', function(source, args, rawCommand)
    if StartEvidenceEvent(source) then
        print(string.format("Djonluc Evidence Event started by player %s", source))
    end
end, false)

RegisterCommand('evidence_status', function(source, args, rawCommand)
    if source == 0 then -- Console only
        print("^2[Djonluc Evidence Event]^7 ========================================")
        print("^2[Djonluc Evidence Event]^7 Djonluc Evidence Event Status Report:")
        print("^2[Djonluc Evidence Event]^7 Event Active: " .. (eventActive and "✅ YES" or "❌ NO"))
        print("^2[Djonluc Evidence Event]^7 Convoy Vehicles: " .. #convoyVehicles)
        print("^2[Djonluc Evidence Event]^7 Escort Peds: " .. #escortPeds)

        
        -- Print framework status
        if Utils.PrintFrameworkStatus then
            Utils.PrintFrameworkStatus()
        end
        
        -- Print optional dependencies status
        if Utils.OptionalDeps then
            print("^3[Djonluc Evidence Event]^7 Optional Dependencies Status:")
            for dep, available in pairs(Utils.OptionalDeps) do
                print("^3[Djonluc Evidence Event]^7 " .. dep .. ": " .. (available and "✅" or "❌"))
            end
            
            -- Detailed ox_lib status
            if Utils.PrintOxLibStatus then
                Utils.PrintOxLibStatus()
            end
        end
        
        print("^2[Djonluc Evidence Event]^7 ========================================")
    else
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'This command is console-only')
    end
end, false)

RegisterCommand('evidence_redetect', function(source, args, rawCommand)
    if source == 0 then -- Console only
        if Utils.ReDetectFramework then
            Utils.ReDetectFramework()
        else
            print("^1[Djonluc Evidence Event]^7 ERROR: ReDetectFramework function not available")
        end
    else
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'This command is console-only')
    end
end, false)

RegisterCommand('endevent', function(source, args, rawCommand)
    local playerJob = Utils.GetPlayerJob(source)
    if Utils.HasRequiredJob(playerJob) then
        EndEvent(false)
        print(string.format("Djonluc Evidence Event ended by player %s", source))
    end
end, false)

-- Events
RegisterNetEvent('djonluc_evidence_event:escortPedDied')
AddEventHandler('djonluc_evidence_event:escortPedDied', function(pedId)
    OnEscortPedDeath(pedId)
end)

RegisterNetEvent('djonluc_evidence_event:updatePedCount')
AddEventHandler('djonluc_evidence_event:updatePedCount', function(count)
    if eventActive then
        eventData.escortPedsAlive = count
    end
end)



RegisterNetEvent('djonluc_evidence_event:convoyReachedDestination')
AddEventHandler('djonluc_evidence_event:convoyReachedDestination', function()
    if eventActive then
        EndEvent(true)
    end
end)

RegisterNetEvent('djonluc_evidence_event:convoyDestroyed')
AddEventHandler('djonluc_evidence_event:convoyDestroyed', function()
    if eventActive then
        EndEvent(false)
    end
end)

-- Export functions for other resources
exports('IsEventActive', function()
    return eventActive
end)

exports('GetEventData', function()
    return eventData
end)

exports('StartEvidenceEvent', function(source)
    return StartEvidenceEvent(source)
end)

exports('EndEvidenceEvent', function(success)
    return EndEvent(success)
end)

exports('GetConvoyPosition', function()
    if eventActive and eventData.route then
        return eventData.route.start
    end
    return nil
end)

exports('GetEscortPedsAlive', function()
    return eventData.escortPedsAlive or 0
end)

-- Allow other resources to register custom routes
local customRoutes = {}
exports('GetCustomRoutes', function()
    return customRoutes
end)

exports('GetPlayerJob', function(source)
    return Utils.GetPlayerJob(source)
end)

exports('RegisterCustomRoute', function(name, routeData)
    if routeData and routeData.start and routeData.destruction and routeData.waypoints then
        customRoutes[name] = routeData
        print("^2[Djonluc Evidence Event]^7 Custom route registered: " .. name)
        return true
    end
    return false
end)

exports('UnregisterCustomRoute', function(name)
    if customRoutes[name] then
        customRoutes[name] = nil
        print("^2[Djonluc Evidence Event]^7 Custom route unregistered: " .. name)
        return true
    end
    return false
end)

-- Dynamic route exports
exports('SetConvoyStartPoint', function(x, y, z)
    if not x or not y or not z then return false end
    currentDynamicRoute.start = vector3(x, y, z)
    currentDynamicRoute.active = true
    return true
end)

exports('SetConvoyEndPoint', function(x, y, z)
    if not x or not y or not z then return false end
    currentDynamicRoute.endPoint = vector3(x, y, z)
    currentDynamicRoute.active = true
    return true
end)

exports('GetCurrentDynamicRoute', function()
    return currentDynamicRoute
end)

-- Simple spawn point commands
RegisterCommand('setspawn', function(source, args, rawCommand)
    if source == 0 then -- Console only
        if #args < 4 then
            print("^1[Djonluc Evidence Event]^7 Usage: setspawn <x> <y> <z> <heading>")
            print("^3[Djonluc Evidence Event]^7 Example: setspawn 402.76 -1019.04 29.33 355.06")
            print("^3[Djonluc Evidence Event]^7 Heading: 0.0 = North, 90.0 = East, 180.0 = South, 270.0 = West")
            return
        end
        
        local x, y, z, heading = tonumber(args[1]), tonumber(args[2]), tonumber(args[3]), tonumber(args[4])
        if not x or not y or not z or not heading then
            print("^1[Djonluc Evidence Event]^7 ERROR: Invalid coordinates or heading")
            return
        end
        
        currentDynamicRoute.start = vector4(x, y, z, heading)
        currentDynamicRoute.active = true
        print("^2[Djonluc Evidence Event]^7 ✅ Convoy spawn point set to: " .. x .. ", " .. y .. ", " .. z .. " (heading: " .. heading .. "°)")
        print("^3[Djonluc Evidence Event]^7 Now use /setend to set the destination")
    else
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'This command is console-only')
    end
end, false)

RegisterCommand('setend', function(source, args, rawCommand)
    if source == 0 then -- Console only
        if #args < 4 then
            print("^1[Djonluc Evidence Event]^7 Usage: setend <x> <y> <z> <heading>")
            print("^3[Djonluc Evidence Event]^7 Example: setend -1594.21 2807.17 17.01 44.21")
            print("^3[Djonluc Evidence Event]^7 Heading: 0.0 = North, 90.0 = East, 180.0 = South, 270.0 = West")
            return
        end
        
        local x, y, z, heading = tonumber(args[1]), tonumber(args[2]), tonumber(args[3]), tonumber(args[4])
        if not x or not y or not z or not heading then
            print("^1[Djonluc Evidence Event]^7 ERROR: Invalid coordinates or heading")
            return
        end
        
        currentDynamicRoute.endPoint = vector4(x, y, z, heading)
        currentDynamicRoute.active = true
        print("^2[Djonluc Evidence Event]^7 ✅ Convoy destination set to: " .. x .. ", " .. y .. ", " .. z .. " (heading: " .. heading .. "°)")
        
        -- Check if both points are set
        if currentDynamicRoute.start and currentDynamicRoute.endPoint then
            local distance = #(vector3(currentDynamicRoute.start.x, currentDynamicRoute.start.y, currentDynamicRoute.start.z) - vector3(currentDynamicRoute.endPoint.x, currentDynamicRoute.endPoint.y, currentDynamicRoute.endPoint.z))
            print("^2[Djonluc Evidence Event]^7 ✅ Route ready! Distance: " .. string.format("%.1f", distance) .. "m")
            print("^3[Djonluc Evidence Event]^7 Use /startevidence to start the event")
        end
    else
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'This command is console-only')
    end
end, false)

-- Check current route status
RegisterCommand('route', function(source, args, rawCommand)
    if source == 0 then -- Console only
        print("^3[Djonluc Evidence Event]^7 ========================================")
        print("^3[Djonluc Evidence Event]^7 Current Route Status:")
        print("^3[Djonluc Evidence Event]^7 ========================================")
        
        -- Check dynamic route
        if currentDynamicRoute.active then
            print("^2[Djonluc Evidence Event]^7 ✅ Dynamic Route ACTIVE")
            print("^2[Djonluc Evidence Event]^7 Start: " .. currentDynamicRoute.start.x .. ", " .. currentDynamicRoute.start.y .. ", " .. currentDynamicRoute.start.z .. " (heading: " .. (currentDynamicRoute.start.w or 0.0) .. "°)")
            print("^2[Djonluc Evidence Event]^7 End: " .. currentDynamicRoute.endPoint.x .. ", " .. currentDynamicRoute.endPoint.y .. ", " .. currentDynamicRoute.endPoint.z .. " (heading: " .. (currentDynamicRoute.endPoint.w or 0.0) .. "°)")
            
            local distance = #(vector3(currentDynamicRoute.start.x, currentDynamicRoute.start.y, currentDynamicRoute.start.z) - vector3(currentDynamicRoute.endPoint.x, currentDynamicRoute.endPoint.y, currentDynamicRoute.endPoint.z))
            print("^2[Djonluc Evidence Event]^7 Distance: " .. string.format("%.1f", distance) .. "m")
        else
            print("^1[Djonluc Evidence Event]^7 ❌ Dynamic Route INACTIVE")
        end
        
        -- Check config routes
        if Config.Routes and next(Config.Routes) then
            print("^3[Djonluc Evidence Event]^7 Config Routes Available:")
            for name, route in pairs(Config.Routes) do
                local startHeading = route.start.w or 0.0
                local endHeading = route.destruction.w or 0.0
                print("^3[Djonluc Evidence Event]^7 - " .. name .. ": " .. route.start.x .. ", " .. route.start.y .. " (heading: " .. startHeading .. "°) → " .. route.destruction.x .. ", " .. route.destruction.y .. " (heading: " .. endHeading .. "°)")
            end
        else
            print("^1[Djonluc Evidence Event]^7 ❌ No config routes available")
        end
        
        -- Check event status
        print("^3[Djonluc Evidence Event]^7 Event Active: " .. (eventActive and "✅ YES" or "❌ NO"))
        
        print("^3[Djonluc Evidence Event]^7 ========================================")
    else
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'This command is console-only')
    end
end, false)

-- Reset convoy route to defaults
RegisterCommand('resetconvoyroute', function(source, args, rawCommand)
    if source == 0 then -- Console only
        currentDynamicRoute.start = Config.DynamicRoutes.default_start
        currentDynamicRoute.endPoint = Config.DynamicRoutes.default_end
        currentDynamicRoute.active = false
        print("^2[Djonluc Evidence Event]^7 Convoy route reset to defaults")
    else
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'This command is console-only')
    end
end, false)

-- Show current convoy route
RegisterCommand('convoyroute', function(source, args, rawCommand)
    if source == 0 then -- Console only
        if currentDynamicRoute.active then
            print("^2[Djonluc Evidence Event]^7 Current convoy route:")
            print("^2[Djonluc Evidence Event]^7 Start: " .. currentDynamicRoute.start.x .. ", " .. currentDynamicRoute.start.y .. ", " .. currentDynamicRoute.start.z .. " (heading: " .. (currentDynamicRoute.start.w or 0.0) .. "°)")
            print("^2[Djonluc Evidence Event]^7 End: " .. currentDynamicRoute.endPoint.x .. ", " .. currentDynamicRoute.endPoint.y .. ", " .. currentDynamicRoute.endPoint.z .. " (heading: " .. (currentDynamicRoute.endPoint.w or 0.0) .. "°)")
            
            local distance = #(vector3(currentDynamicRoute.start.x, currentDynamicRoute.start.y, currentDynamicRoute.start.z) - vector3(currentDynamicRoute.endPoint.x, currentDynamicRoute.endPoint.y, currentDynamicRoute.endPoint.z))
            print("^2[Djonluc Evidence Event]^7 Distance: " .. string.format("%.1f", distance) .. "m")
        else
            print("^3[Djonluc Evidence Event]^7 No dynamic route set. Use /setspawn and /setend to create one.")
        end
    else
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'This command is console-only')
    end
end, false)

-- Test ox_lib functionality
RegisterCommand('test_oxlib', function(source, args, rawCommand)
    if source == 0 then -- Console only
        if Utils.PrintOxLibStatus then
            Utils.PrintOxLibStatus()
        else
            print("^1[Djonluc Evidence Event]^7 ERROR: PrintOxLibStatus function not available")
        end
    else
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'This command is console-only')
    end
end, false)

-- Check if player has required job
RegisterCommand('checkjob', function(source, args, rawCommand)
    if source == 0 then -- Console only
        print("^1[Djonluc Evidence Event]^7 This command is for players only")
        return
    end
    
    local player = Utils.ValidatePlayer(source)
    if not player then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Player not found')
        return
    end
    
    local playerJob = Utils.GetPlayerJob(source)
    local hasRequiredJob = Utils.HasRequiredJob(playerJob)
    
    if hasRequiredJob then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, '✅ You have permission to start events! Job: ' .. playerJob)
        print("^2[Djonluc Evidence Event]^7 Player " .. source .. " has required job: " .. playerJob)
    else
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, '❌ You do not have permission. Your job: ' .. playerJob .. ' | Required: ' .. table.concat(Config.StartJobs, ', '))
        print("^1[Djonluc Evidence Event]^7 Player " .. source .. " does not have required job. Current: " .. playerJob .. " | Required: " .. table.concat(Config.StartJobs, ', '))
    end
end, false)

-- Test command to debug event starting
RegisterCommand('test_evidence', function(source, args, rawCommand)
    print("^3[Djonluc Evidence Event]^7 Testing event start process...")
    
    -- Check if player exists
    local player = Utils.ValidatePlayer(source)
    print("^3[Djonluc Evidence Event]^7 Player validation:", player and "SUCCESS" or "FAILED")
    
    if not player then
        print("^1[Djonluc Evidence Event]^7 ERROR: Player not found")
        return
    end
    
    -- Check player job
    local playerJob = Utils.GetPlayerJob(source)
    print("^3[Djonluc Evidence Event]^7 Player job:", playerJob)
    
    -- Check if job is required
    local hasRequiredJob = Utils.HasRequiredJob(playerJob)
    print("^3[Djonluc Evidence Event]^7 Has required job:", hasRequiredJob and "YES" or "NO")
    
    -- Check if event is already active
    print("^3[Djonluc Evidence Event]^7 Event already active:", eventActive and "YES" or "NO")
    
    -- Check route configuration
    print("^3[Djonluc Evidence Event]^7 Routes configured:", Config.Routes and "YES" or "NO")
    if Config.Routes then
        print("^3[Djonluc Evidence Event]^7 Number of routes:", #Config.Routes)
        for name, route in pairs(Config.Routes) do
            print("^3[Djonluc Evidence Event]^7 Route:", name, "Start:", route.start.x, route.start.y, route.start.z)
        end
    end
    
    -- Check dynamic route
    print("^3[Djonluc Evidence Event]^7 Dynamic route active:", currentDynamicRoute.active and "YES" or "NO")
    if currentDynamicRoute.active then
        print("^3[Djonluc Evidence Event]^7 Dynamic start:", currentDynamicRoute.start.x, currentDynamicRoute.start.y, currentDynamicRoute.start.z)
        print("^3[Djonluc Evidence Event]^7 Dynamic end:", currentDynamicRoute.endPoint.x, currentDynamicRoute.endPoint.y, currentDynamicRoute.endPoint.z)
    end
    
    -- Check ped configuration
    print("^3[Djonluc Evidence Event]^7 Ped Configuration:")
    if Config.Peds then
        for pedType, pedConfig in pairs(Config.Peds) do
            print("^3[Djonluc Evidence Event]^7   " .. pedType .. ": Model=" .. pedConfig.model .. ", Count=" .. pedConfig.count .. ", Weapon=" .. pedConfig.weapon)
        end
    else
        print("^1[Djonluc Evidence Event]^7   ❌ No ped configuration found")
    end
    
    -- Check vehicle configuration
    print("^3[Djonluc Evidence Event]^7 Vehicle Configuration:")
    if Config.Vehicles then
        for vehicleType, vehicleConfig in pairs(Config.Vehicles) do
            print("^3[Djonluc Evidence Event]^7   " .. vehicleType .. ": Model=" .. vehicleConfig.model .. ", Count=" .. vehicleConfig.count)
        end
    else
        print("^1[Djonluc Evidence Event]^7   ❌ No vehicle configuration found")
    end
    
    print("^3[Djonluc Evidence Event]^7 Test completed!")
end, false)

-- Command to check player's current job
RegisterCommand('checkjob', function(source, args, rawCommand)
    if source == 0 then
        print("^1[Djonluc Evidence Event]^7 This command can only be used by players")
        return
    end
    
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^3[Djonluc Evidence Event]^7 Checking job for player:", source)
    
    if Utils and Utils.GetPlayerJob then
        local playerJob = Utils.GetPlayerJob(source)
        print("^2[Djonluc Evidence Event]^7 Player job:", playerJob)
        
        if Utils.HasRequiredJob(playerJob) then
            print("^2[Djonluc Evidence Event]^7 ✅ Player has required job to start events")
        else
            print("^1[Djonluc Evidence Event]^7 ❌ Player does not have required job")
            print("^3[Djonluc Evidence Event]^7 Required jobs:", table.concat(Config.StartJobs, ", "))
        end
    else
        print("^1[Djonluc Evidence Event]^7 ❌ GetPlayerJob function not available")
    end
    
    print("^3[Djonluc Evidence Event]^7 ========================================")
end, false)

-- Easy Route Setup Commands
RegisterCommand('easyroute', function(source, args, rawCommand)
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^3[Djonluc Evidence Event]^7 🗺️  EASY ROUTE SETUP WIZARD")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^2[Djonluc Evidence Event]^7 Available Commands:")
    print("^3[Djonluc Evidence Event]^7 • /preset <name> - Use preset route")
    print("^3[Djonluc Evidence Event]^7 • /quickroute <start> <end> - Quick setup")
    print("^3[Djonluc Evidence Event]^7 • /nearby <location> - Find nearby spawn points")
    print("^3[Djonluc Evidence Event]^7 • /listpresets - Show all preset routes")
    print("^3[Djonluc Evidence Event]^7 • /saveroute <name> - Save current route")
    print("^3[Djonluc Evidence Event]^7 • /loadroute <name> - Load saved route")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^2[Djonluc Evidence Event]^7 Preset Routes Available:")
    print("^3[Djonluc Evidence Event]^7 • police - Police Station to Remote Location")
    print("^3[Djonluc Evidence Event]^7 • sandy - Sandy Shores to Mount Chiliad")
    print("^3[Djonluc Evidence Event]^7 • airport - Airport to Beach")
    print("^3[Djonluc Evidence Event]^7 • city - Downtown to Vinewood Hills")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    if source ~= 0 then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Check console for full route setup options')
    end
end, false)

-- Preset Routes
local presetRoutes = {
    police = {
        name = "Police Station Route",
        start = vector4(402.76, -1019.04, 29.33, 355.06),
        endPoint = vector4(-1594.21, 2807.17, 17.01, 44.21),
        description = "Police station to remote evidence destruction site"
    },
    sandy = {
        name = "Sandy Shores Route", 
        start = vector4(1853.45, 3689.67, 34.27, 210.0),
        endPoint = vector4(2340.12, 3126.89, 48.21, 45.0),
        description = "Sandy Shores to Mount Chiliad"
    },
    airport = {
        name = "Airport Route",
        start = vector4(-1037.89, -2738.56, 20.17, 327.0),
        endPoint = vector4(-1523.45, -851.23, 10.02, 180.0),
        description = "Airport to beach location"
    },
    city = {
        name = "City Route",
        start = vector4(441.23, -982.45, 30.69, 90.0),
        endPoint = vector4(1200.67, -600.34, 45.12, 270.0),
        description = "Downtown to Vinewood Hills"
    }
}

-- Use Preset Route
RegisterCommand('preset', function(source, args, rawCommand)
    if #args < 1 then
        if source == 0 then
            print("^1[Djonluc Evidence Event]^7 Usage: preset <route_name>")
            print("^3[Djonluc Evidence Event]^7 Available presets: police, sandy, airport, city")
            print("^3[Djonluc Evidence Event]^7 Use /listpresets to see all options")
        else
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Usage: /preset <route_name>')
        end
        return
    end
    
    local routeName = args[1]:lower()
    local preset = presetRoutes[routeName]
    
    if preset then
        currentDynamicRoute.start = preset.start
        currentDynamicRoute.endPoint = preset.endPoint
        currentDynamicRoute.active = true
        
        if source == 0 then
            print("^2[Djonluc Evidence Event]^7 ✅ Route set to: " .. preset.name)
            print("^3[Djonluc Evidence Event]^7 Start: " .. preset.start.x .. ", " .. preset.start.y .. " (heading: " .. preset.start.w .. "°)")
            print("^3[Djonluc Evidence Event]^7 End: " .. preset.endPoint.x .. ", " .. preset.endPoint.y .. " (heading: " .. preset.endPoint.w .. "°)")
            
            local distance = #(vector3(preset.start.x, preset.start.y, preset.start.z) - vector3(preset.endPoint.x, preset.endPoint.y, preset.endPoint.z))
            print("^2[Djonluc Evidence Event]^7 Distance: " .. string.format("%.1f", distance) .. "m")
            print("^3[Djonluc Evidence Event]^7 Description: " .. preset.description)
            print("^2[Djonluc Evidence Event]^7 Use /startevidence to start the event!")
        else
            local distance = #(vector3(preset.start.x, preset.start.y, preset.start.z) - vector3(preset.endPoint.x, preset.endPoint.y, preset.endPoint.z))
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '✅ Route set to: ' .. preset.name)
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '📍 Start: ' .. string.format("%.1f, %.1f", preset.start.x, preset.start.y))
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '📍 End: ' .. string.format("%.1f, %.1f", preset.endPoint.x, preset.endPoint.y))
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '📏 Distance: ' .. string.format("%.1f", distance) .. "m")
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '🎮 Use /startevidence to start the event!')
        end
    else
        if source == 0 then
            print("^1[Djonluc Evidence Event]^7 ❌ Unknown preset route: " .. routeName)
            print("^3[Djonluc Evidence Event]^7 Use /listpresets to see available routes")
        else
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '❌ Unknown preset route: ' .. routeName)
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '💡 Use /listpresets to see available routes')
        end
    end
end, false)

-- List All Preset Routes
RegisterCommand('listpresets', function(source, args, rawCommand)
    if source == 0 then
        print("^3[Djonluc Evidence Event]^7 ========================================")
        print("^3[Djonluc Evidence Event]^7 📋 AVAILABLE PRESET ROUTES")
        print("^3[Djonluc Evidence Event]^7 ========================================")
        
        for key, route in pairs(presetRoutes) do
            local distance = #(vector3(route.start.x, route.start.y, route.start.z) - vector3(route.endPoint.x, route.endPoint.y, route.endPoint.z))
            print("^2[Djonluc Evidence Event]^7 " .. key:upper() .. " - " .. route.name)
            print("^3[Djonluc Evidence Event]^7   Start: " .. route.start.x .. ", " .. route.start.y .. " (heading: " .. route.start.w .. "°)")
            print("^3[Djonluc Evidence Event]^7   End: " .. route.endPoint.x .. ", " .. route.endPoint.y .. " (heading: " .. route.endPoint.w .. "°)")
            print("^3[Djonluc Evidence Event]^7   Distance: " .. string.format("%.1f", distance) .. "m")
            print("^3[Djonluc Evidence Event]^7   Description: " .. route.description)
            print("^3[Djonluc Evidence Event]^7   Command: /preset " .. key)
            print("^3[Djonluc Evidence Event]^7   ----------------------------------------")
        end
        
        print("^2[Djonluc Evidence Event]^7 Use: /preset <route_name> to set a route")
        print("^3[Djonluc Evidence Event]^7 Example: /preset police")
    else
        local routeList = "📋 Available Preset Routes:\n\n"
        for key, route in pairs(presetRoutes) do
            local distance = #(vector3(route.start.x, route.start.y, route.start.z) - vector3(route.endPoint.x, route.endPoint.y, route.endPoint.z))
            routeList = routeList .. "📍 " .. key:upper() .. " - " .. route.name .. "\n"
            routeList = routeList .. "   Distance: " .. string.format("%.1f", distance) .. "m\n"
            routeList = routeList .. "   Use: /preset " .. key .. "\n\n"
        end
        routeList = routeList .. "💡 Example: /preset police"
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, routeList)
    end
end, false)

-- Quick Route Setup (just start and end locations)
RegisterCommand('quickroute', function(source, args, rawCommand)
    if #args < 2 then
        if source == 0 then
            print("^1[Djonluc Evidence Event]^7 Usage: quickroute <start_location> <end_location>")
            print("^3[Djonluc Evidence Event]^7 Available locations: police, sandy, airport, city, beach, mountain, downtown")
            print("^3[Djonluc Evidence Event]^7 Example: /quickroute police beach")
        else
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Usage: /quickroute <start_location> <end_location>')
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '💡 Example: /quickroute police beach')
        end
        return
    end
    
    local startLoc = args[1]:lower()
    local endLoc = args[2]:lower()
    
    local locations = {
        police = {pos = vector4(402.76, -1019.04, 29.33, 355.06), name = "Police Station"},
        sandy = {pos = vector4(1853.45, 3689.67, 34.27, 210.0), name = "Sandy Shores"},
        airport = {pos = vector4(-1037.89, -2738.56, 20.17, 327.0), name = "Airport"},
        city = {pos = vector4(441.23, -982.45, 30.69, 90.0), name = "Downtown"},
        beach = {pos = vector4(-1523.45, -851.23, 10.02, 180.0), name = "Beach"},
        mountain = {pos = vector4(2340.12, 3126.89, 48.21, 45.0), name = "Mount Chiliad"},
        downtown = {pos = vector4(1200.67, -600.34, 45.12, 270.0), name = "Vinewood Hills"}
    }
    
    local startPos = locations[startLoc]
    local endPos = locations[endLoc]
    
    if startPos and endPos then
        currentDynamicRoute.start = startPos.pos
        currentDynamicRoute.endPoint = endPos.pos
        currentDynamicRoute.active = true
        
        local distance = #(vector3(startPos.pos.x, startPos.pos.y, startPos.pos.z) - vector3(endPos.pos.x, endPos.pos.y, endPos.pos.z))
        
        if source == 0 then
            print("^2[Djonluc Evidence Event]^7 ✅ Quick route set!")
            print("^3[Djonluc Evidence Event]^7 Start: " .. startPos.name .. " (" .. startPos.pos.x .. ", " .. startPos.pos.y .. ")")
            print("^3[Djonluc Evidence Event]^7 End: " .. endPos.name .. " (" .. endPos.pos.x .. ", " .. endPos.pos.y .. ")")
            print("^2[Djonluc Evidence Event]^7 Distance: " .. string.format("%.1f", distance) .. "m")
            print("^2[Djonluc Evidence Event]^7 Use /startevidence to start the event!")
        else
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '✅ Quick route set!')
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '📍 Start: ' .. startPos.name)
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '📍 End: ' .. endPos.name)
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '📏 Distance: ' .. string.format("%.1f", distance) .. "m")
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '🎮 Use /startevidence to start the event!')
        end
    else
        if source == 0 then
            print("^1[Djonluc Evidence Event]^7 ❌ Unknown location(s)")
            print("^3[Djonluc Evidence Event]^7 Available: police, sandy, airport, city, beach, mountain, downtown")
        else
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '❌ Unknown location(s)')
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '💡 Available: police, sandy, airport, city, beach, mountain, downtown')
        end
    end
end, false)

-- Find Nearby Spawn Points
RegisterCommand('nearby', function(source, args, rawCommand)
    if #args < 1 then
        if source == 0 then
            print("^1[Djonluc Evidence Event]^7 Usage: nearby <location>")
            print("^3[Djonluc Evidence Event]^7 Example: /nearby police")
        else
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Usage: /nearby <location>')
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '💡 Example: /nearby police')
        end
        return
    end
    
    local searchLoc = args[1]:lower()
    
    local nearbyPoints = {
        police = {
            {name = "Police Station", pos = vector4(402.76, -1019.04, 29.33, 355.06)},
            {name = "Mission Row PD", pos = vector4(441.23, -982.45, 30.69, 90.0)},
            {name = "Vinewood PD", pos = vector4(1200.67, -600.34, 45.12, 270.0)}
        },
        sandy = {
            {name = "Sandy Shores", pos = vector4(1853.45, 3689.67, 34.27, 210.0)},
            {name = "Grapeseed", pos = vector4(2448.89, 4973.12, 46.81, 180.0)},
            {name = "Paleto Bay", pos = vector4(-275.45, 6635.23, 7.42, 45.0)}
        }
    }
    
    local points = nearbyPoints[searchLoc]
    if points then
        if source == 0 then
            print("^3[Djonluc Evidence Event]^7 ========================================")
            print("^3[Djonluc Evidence Event]^7 📍 Nearby " .. searchLoc:upper() .. " locations:")
            print("^3[Djonluc Evidence Event]^7 ========================================")
            
            for i, point in ipairs(points) do
                print("^2[Djonluc Evidence Event]^7 " .. i .. ". " .. point.name)
                print("^3[Djonluc Evidence Event]^7    Position: " .. point.pos.x .. ", " .. point.pos.y .. ", " .. point.pos.z .. " (heading: " .. point.pos.w .. "°)")
                print("^3[Djonluc Evidence Event]^7    Command: setspawn " .. point.pos.x .. " " .. point.pos.y .. " " .. point.pos.z .. " " .. point.pos.w)
                print("^3[Djonluc Evidence Event]^7    ----------------------------------------")
            end
        else
            local nearbyList = "📍 Nearby " .. searchLoc:upper() .. " locations:\n\n"
            for i, point in ipairs(points) do
                nearbyList = nearbyList .. i .. ". " .. point.name .. "\n"
                nearbyList = nearbyList .. "   Position: " .. string.format("%.1f, %.1f, %.1f", point.pos.x, point.pos.y, point.pos.z) .. "\n"
                nearbyList = nearbyList .. "   Heading: " .. string.format("%.1f°", point.pos.w) .. "\n\n"
            end
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, nearbyList)
        end
    else
        if source == 0 then
            print("^1[Djonluc Evidence Event]^7 ❌ No nearby points found for: " .. searchLoc)
        else
            TriggerClientEvent('djonluc_evidence_event:showNotification', source, '❌ No nearby points found for: ' .. searchLoc)
        end
    end
end, false)

-- In-Game Route Creation System
local playerRoutes = {} -- Store routes created by players
local routeCreationMode = {} -- Track which players are in route creation mode

-- Start route creation mode
RegisterCommand('createroute', function(source, args, rawCommand)
    if source == 0 then -- Console only
        print("^1[Djonluc Evidence Event]^7 This command is for players only")
        return
    end
    
    local player = Utils.ValidatePlayer(source)
    if not player then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Player not found')
        return
    end
    
    local playerJob = Utils.GetPlayerJob(source)
    if not Utils.HasRequiredJob(playerJob) then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, '❌ You need a law enforcement job to create routes')
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Usage: /createroute <route_name>')
        return
    end
    
    local routeName = args[1]:lower()
    
    -- Check if route name already exists
    if playerRoutes[routeName] then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, '❌ Route name already exists. Use /deleteroute <name> to remove it first')
        return
    end
    
    -- Initialize route creation mode for this player
    routeCreationMode[source] = {
        name = routeName,
        start = nil,
        endPoint = nil,
        step = 'start' -- 'start' or 'end'
    }
    
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '🗺️ Route creation started: ' .. routeName)
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '📍 Go to your desired START location and use /setstart')
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '💡 Use /routehelp for help or /cancelroute to cancel')
    
    print("^2[Djonluc Evidence Event]^7 Player " .. source .. " started creating route: " .. routeName)
end, false)

-- Set start point for route creation
RegisterCommand('setstart', function(source, args, rawCommand)
    if source == 0 then -- Console only
        print("^1[Djonluc Evidence Event]^7 This command is for players only")
        return
    end
    
    if not routeCreationMode[source] then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, '❌ You are not in route creation mode. Use /createroute <name> first')
        return
    end
    
    local player = Utils.ValidatePlayer(source)
    if not player then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Player not found')
        return
    end
    
    -- Get player's current position and heading
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local playerHeading = GetEntityHeading(GetPlayerPed(source))
    
    routeCreationMode[source].start = vector4(playerCoords.x, playerCoords.y, playerCoords.z, playerHeading)
    routeCreationMode[source].step = 'end'
    
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '✅ Start point set! Now go to your END location and use /setend')
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '📍 Start: ' .. string.format("%.2f, %.2f, %.2f (%.1f°)", playerCoords.x, playerCoords.y, playerCoords.z, playerHeading))
    
    print("^2[Djonluc Evidence Event]^7 Player " .. source .. " set start point for route: " .. routeCreationMode[source].name)
end, false)

-- Set end point for route creation
RegisterCommand('setend', function(source, args, rawCommand)
    if source == 0 then -- Console only
        print("^1[Djonluc Evidence Event]^7 This command is for players only")
        return
    end
    
    if not routeCreationMode[source] or routeCreationMode[source].step ~= 'end' then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, '❌ You need to set a start point first. Use /setstart')
        return
    end
    
    local player = Utils.ValidatePlayer(source)
    if not player then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Player not found')
        return
    end
    
    -- Get player's current position and heading
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local playerHeading = GetEntityHeading(GetPlayerPed(source))
    
    routeCreationMode[source].endPoint = vector4(playerCoords.x, playerCoords.y, playerCoords.z, playerHeading)
    
    -- Create the route
    local routeName = routeCreationMode[source].name
    local startPos = routeCreationMode[source].start
    local endPos = routeCreationMode[source].endPoint
    
    playerRoutes[routeName] = {
        name = routeName,
        start = startPos,
        endPoint = endPos,
        createdBy = source,
        createdTime = os.time(),
        description = "Player-created route"
    }
    
    -- Calculate distance
    local distance = #(vector3(startPos.x, startPos.y, startPos.z) - vector3(endPos.x, endPos.y, endPos.z))
    
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '✅ Route created successfully: ' .. routeName)
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '📍 End: ' .. string.format("%.2f, %.2f, %.2f (%.1f°)", playerCoords.x, playerCoords.y, playerCoords.z, playerHeading))
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '📏 Distance: ' .. string.format("%.1f", distance) .. "m")
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '🎮 Use /useroute " .. routeName .. " to activate this route')
    
    -- Exit route creation mode
    routeCreationMode[source] = nil
    
    print("^2[Djonluc Evidence Event]^7 Player " .. source .. " created route: " .. routeName .. " (Distance: " .. string.format("%.1f", distance) .. "m)")
end, false)

-- Use a player-created route
RegisterCommand('useroute', function(source, args, rawCommand)
    if source == 0 then -- Console only
        print("^1[Djonluc Evidence Event]^7 This command is for players only")
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Usage: /useroute <route_name>')
        return
    end
    
    local routeName = args[1]:lower()
    local route = playerRoutes[routeName]
    
    if not route then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, '❌ Route not found: ' .. routeName)
        return
    end
    
    -- Set as current dynamic route
    currentDynamicRoute.start = route.start
    currentDynamicRoute.endPoint = route.endPoint
    currentDynamicRoute.active = true
    
    local distance = #(vector3(route.start.x, route.start.y, route.start.z) - vector3(route.endPoint.x, route.endPoint.y, route.endPoint.z))
    
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '✅ Route activated: ' .. route.name)
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '📍 Start: ' .. string.format("%.2f, %.2f", route.start.x, route.start.y))
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '📍 End: ' .. string.format("%.2f, %.2f", route.endPoint.x, route.endPoint.y))
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '📏 Distance: ' .. string.format("%.1f", distance) .. "m")
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '🎮 Use /startevidence to start the event!')
    
    print("^2[Djonluc Evidence Event]^7 Player " .. source .. " activated route: " .. routeName)
end, false)

-- List player-created routes
RegisterCommand('myroutes', function(source, args, rawCommand)
    if source == 0 then -- Console only
        print("^1[Djonluc Evidence Event]^7 This command is for players only")
        return
    end
    
    local player = Utils.ValidatePlayer(source)
    if not player then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Player not found')
        return
    end
    
    local hasRoutes = false
    local routeList = "🗺️ Your Created Routes:\n"
    
    for name, route in pairs(playerRoutes) do
        if route.createdBy == source then
            hasRoutes = true
            local distance = #(vector3(route.start.x, route.start.y, route.start.z) - vector3(route.endPoint.x, route.endPoint.y, route.endPoint.z))
            routeList = routeList .. "📍 " .. name .. " (" .. string.format("%.1f", distance) .. "m)\n"
            routeList = routeList .. "   Start: " .. string.format("%.1f, %.1f", route.start.x, route.start.y) .. "\n"
            routeList = routeList .. "   End: " .. string.format("%.1f, %.1f", route.endPoint.x, route.endPoint.y) .. "\n"
            routeList = routeList .. "   Use: /useroute " .. name .. "\n\n"
        end
    end
    
    if not hasRoutes then
        routeList = "❌ You haven't created any routes yet.\n💡 Use /createroute <name> to create your first route!"
    end
    
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, routeList)
end, false)

-- List all available routes (preset + player-created)
RegisterCommand('allroutes', function(source, args, rawCommand)
    if source == 0 then -- Console only
        print("^1[Djonluc Evidence Event]^7 This command is for players only")
        return
    end
    
    local routeList = "🗺️ All Available Routes:\n\n"
    
    -- Preset routes
    routeList = routeList .. "🎯 Preset Routes:\n"
    for name, route in pairs(presetRoutes) do
        local distance = #(vector3(route.start.x, route.start.y, route.start.z) - vector3(route.endPoint.x, route.endPoint.y, route.endPoint.z))
        routeList = routeList .. "📍 " .. name .. " (" .. string.format("%.1f", distance) .. "m)\n"
        routeList = routeList .. "   Use: /preset " .. name .. "\n\n"
    end
    
    -- Player-created routes
    if next(playerRoutes) then
        routeList = routeList .. "👤 Player-Created Routes:\n"
        for name, route in pairs(playerRoutes) do
            local distance = #(vector3(route.start.x, route.start.y, route.start.z) - vector3(route.endPoint.x, route.endPoint.y, route.endPoint.z))
            routeList = routeList .. "📍 " .. name .. " (" .. string.format("%.1f", distance) .. "m)\n"
            routeList = routeList .. "   Use: /useroute " .. name .. "\n\n"
        end
    else
        routeList = routeList .. "👤 No player-created routes available.\n"
    end
    
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, routeList)
end, false)

-- Delete a player-created route
RegisterCommand('deleteroute', function(source, args, rawCommand)
    if source == 0 then -- Console only
        print("^1[Djonluc Evidence Event]^7 This command is for players only")
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Usage: /deleteroute <route_name>')
        return
    end
    
    local routeName = args[1]:lower()
    local route = playerRoutes[routeName]
    
    if not route then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, '❌ Route not found: ' .. routeName)
        return
    end
    
    if route.createdBy ~= source then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, '❌ You can only delete your own routes')
        return
    end
    
    playerRoutes[routeName] = nil
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '✅ Route deleted: ' .. routeName)
    
    print("^2[Djonluc Evidence Event]^7 Player " .. source .. " deleted route: " .. routeName)
end, false)

-- Cancel route creation
RegisterCommand('cancelroute', function(source, args, rawCommand)
    if source == 0 then -- Console only
        print("^1[Djonluc Evidence Event]^7 This command is for players only")
        return
    end
    
    if not routeCreationMode[source] then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, '❌ You are not in route creation mode')
        return
    end
    
    local routeName = routeCreationMode[source].name
    routeCreationMode[source] = nil
    
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, '❌ Route creation cancelled: ' .. routeName)
    
    print("^2[Djonluc Evidence Event]^7 Player " .. source .. " cancelled route creation: " .. routeName)
end, false)

-- Route creation help
RegisterCommand('routehelp', function(source, args, rawCommand)
    if source == 0 then -- Console only
        print("^1[Djonluc Evidence Event]^7 This command is for players only")
        return
    end
    
    local helpText = "🗺️ Route Creation Help:\n\n"
    helpText = helpText .. "1️⃣ /createroute <name> - Start creating a route\n"
    helpText = helpText .. "2️⃣ Go to START location and use /setstart\n"
    helpText = helpText .. "3️⃣ Go to END location and use /setend\n"
    helpText = helpText .. "4️⃣ Use /useroute <name> to activate your route\n\n"
    helpText = helpText .. "📋 Other Commands:\n"
    helpText = helpText .. "• /myroutes - Show your created routes\n"
    helpText = helpText .. "• /allroutes - Show all available routes\n"
    helpText = helpText .. "• /deleteroute <name> - Delete your route\n"
    helpText = helpText .. "• /cancelroute - Cancel current creation\n"
    helpText = helpText .. "• /preset <name> - Use preset routes\n\n"
    helpText = helpText .. "💡 Tip: Make sure you're facing the right direction when setting points!"
    
    TriggerClientEvent('djonluc_evidence_event:showNotification', source, helpText)
end, false)

-- Save player routes to file (persistent storage)
local function SavePlayerRoutes()
    -- Check if json library is available
    if not json then
        print("^1[Djonluc Evidence Event]^7 ERROR: JSON library not available, using simple text format")
        -- Fallback to simple text format
        local file = io.open(GetResourcePath(GetCurrentResourceName()) .. "/player_routes.txt", "w")
        if file then
            for routeName, route in pairs(playerRoutes) do
                local line = string.format("%s|%s|%.2f,%.2f,%.2f,%.2f|%.2f,%.2f,%.2f,%.2f|%d|%d\n",
                    routeName,
                    route.description or "Player route",
                    route.start.x, route.start.y, route.start.z, route.start.w,
                    route.endPoint.x, route.endPoint.y, route.endPoint.z, route.endPoint.w,
                    route.createdBy or 0,
                    route.createdTime or os.time()
                )
                file:write(line)
            end
            file:close()
            print("^2[Djonluc Evidence Event]^7 Player routes saved to text file")
        else
            print("^1[Djonluc Evidence Event]^7 ERROR: Could not save player routes to file")
        end
        return
    end
    
    -- Use JSON if available
    local file = io.open(GetResourcePath(GetCurrentResourceName()) .. "/player_routes.json", "w")
    if file then
        local success, jsonData = pcall(json.encode, playerRoutes)
        if success then
            file:write(jsonData)
            file:close()
            print("^2[Djonluc Evidence Event]^7 Player routes saved to JSON file")
        else
            file:close()
            print("^1[Djonluc Evidence Event]^7 ERROR: Could not encode routes to JSON")
        end
    else
        print("^1[Djonluc Evidence Event]^7 ERROR: Could not create player routes file")
    end
end

-- Load player routes from file
local function LoadPlayerRoutes()
    -- Try JSON first
    local file = io.open(GetResourcePath(GetCurrentResourceName()) .. "/player_routes.json", "r")
    if file then
        local content = file:read("*all")
        file:close()
        
        if json then
            local success, data = pcall(json.decode, content)
            if success and data then
                playerRoutes = data
                print("^2[Djonluc Evidence Event]^7 Loaded " .. (next(playerRoutes) and #playerRoutes or 0) .. " player routes from JSON file")
                return
            else
                print("^1[Djonluc Evidence Event]^7 ERROR: Could not decode JSON routes file")
            end
        else
            print("^1[Djonluc Evidence Event]^7 ERROR: JSON library not available for loading")
        end
    end
    
    -- Try text format as fallback
    local textFile = io.open(GetResourcePath(GetCurrentResourceName()) .. "/player_routes.txt", "r")
    if textFile then
        local content = textFile:read("*all")
        textFile:close()
        
        playerRoutes = {}
        for line in content:gmatch("[^\r\n]+") do
            local parts = {}
            for part in line:gmatch("[^|]+") do
                table.insert(parts, part)
            end
            
            if #parts >= 6 then
                local routeName = parts[1]
                local description = parts[2]
                
                -- Parse start coordinates
                local startCoords = {}
                for coord in parts[3]:gmatch("[^,]+") do
                    table.insert(startCoords, tonumber(coord))
                end
                
                -- Parse end coordinates
                local endCoords = {}
                for coord in parts[4]:gmatch("[^,]+") do
                    table.insert(endCoords, tonumber(coord))
                end
                
                if #startCoords == 4 and #endCoords == 4 then
                    playerRoutes[routeName] = {
                        name = routeName,
                        start = vector4(startCoords[1], startCoords[2], startCoords[3], startCoords[4]),
                        endPoint = vector4(endCoords[1], endCoords[2], endCoords[3], endCoords[4]),
                        createdBy = tonumber(parts[5]) or 0,
                        createdTime = tonumber(parts[6]) or os.time(),
                        description = description
                    }
                end
            end
        end
        
        if next(playerRoutes) then
            print("^2[Djonluc Evidence Event]^7 Loaded " .. #playerRoutes .. " player routes from text file")
        else
            print("^3[Djonluc Evidence Event]^7 No valid routes found in text file")
        end
    else
        print("^3[Djonluc Evidence Event]^7 No player routes file found, starting fresh")
    end
end

-- Auto-save routes every 5 minutes
Citizen.CreateThread(function()
    LoadPlayerRoutes() -- Load on startup
    
    while true do
        Citizen.Wait(300000) -- 5 minutes
        if next(playerRoutes) then
            SavePlayerRoutes()
        end
    end
end)

-- Save routes when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName and next(playerRoutes) then
        SavePlayerRoutes()
    end
end)

-- Resource cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName and eventActive then
        EndEvent(false)
    end
end)

-- Integration hooks for other scripts
RegisterNetEvent('djonluc_evidence_event:requestEventStatus')
AddEventHandler('djonluc_evidence_event:requestEventStatus', function()
    local source = source
    TriggerClientEvent('djonluc_evidence_event:eventStatusResponse', source, {
        active = eventActive,
        data = eventData,
        escortPedsAlive = eventData.escortPedsAlive or 0
    })
end)

-- Menu system integration
RegisterNetEvent('djonluc_evidence_event:requestStartEvent')
AddEventHandler('djonluc_evidence_event:requestStartEvent', function()
    local source = source
    if StartEvidenceEvent(source) then
        print(string.format("Djonluc Evidence Event started via menu by player %s", source))
    end
end)

-- Test ped spawning system
RegisterCommand('testpeds', function(source, args, rawCommand)
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^3[Djonluc Evidence Event]^7 🧪 TESTING PED SPAWNING SYSTEM")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    -- Check config
    print("^3[Djonluc Evidence Event]^7 Config.Peds exists:", Config.Peds and "✅ YES" or "❌ NO")
    if Config.Peds then
        for pedType, pedConfig in pairs(Config.Peds) do
            print("^3[Djonluc Evidence Event]^7 " .. pedType .. ":")
            print("^3[Djonluc Evidence Event]^7   Model: " .. (pedConfig.model or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Weapon: " .. (pedConfig.weapon or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Count: " .. (pedConfig.count or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Health: " .. (pedConfig.health or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Armor: " .. (pedConfig.armor or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Behavior: " .. (pedConfig.behavior or "❌ MISSING"))
        end
    end
    
    -- Check if event is active
    print("^3[Djonluc Evidence Event]^7 Event Active:", eventActive and "✅ YES" or "❌ NO")
    
    -- Check if route is set
    print("^3[Djonluc Evidence Event]^7 Dynamic Route Active:", currentDynamicRoute.active and "✅ YES" or "❌ NO")
    if currentDynamicRoute.active then
        print("^3[Djonluc Evidence Event]^7 Start: " .. currentDynamicRoute.start.x .. ", " .. currentDynamicRoute.start.y)
        print("^3[Djonluc Evidence Event]^7 End: " .. currentDynamicRoute.endPoint.x .. ", " .. currentDynamicRoute.endPoint.y)
    end
    
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    if source ~= 0 then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Check console for ped spawning test results')
    end
end, false)

-- Test route creation system
RegisterCommand('testroutes', function(source, args, rawCommand)
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^3[Djonluc Evidence Event]^7 🗺️ TESTING ROUTE CREATION SYSTEM")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    -- Check player routes
    print("^3[Djonluc Evidence Event]^7 Player Routes Count:", next(playerRoutes) and #playerRoutes or 0)
    if next(playerRoutes) then
        for name, route in pairs(playerRoutes) do
            print("^3[Djonluc Evidence Event]^7 Route: " .. name)
            print("^3[Djonluc Evidence Event]^7   Start: " .. route.start.x .. ", " .. route.start.y .. ", " .. route.start.z .. " (heading: " .. route.start.w .. "°)")
            print("^3[Djonluc Evidence Event]^7   End: " .. route.endPoint.x .. ", " .. route.endPoint.y .. ", " .. route.endPoint.z .. " (heading: " .. route.endPoint.w .. "°)")
            print("^3[Djonluc Evidence Event]^7   Created By: " .. route.createdBy)
            print("^3[Djonluc Evidence Event]^7   Created Time: " .. route.createdTime)
        end
    else
        print("^3[Djonluc Evidence Event]^7 No player routes found")
    end
    
    -- Check preset routes
    print("^3[Djonluc Evidence Event]^7 Preset Routes Count:", next(presetRoutes) and #presetRoutes or 0)
    if next(presetRoutes) then
        for name, route in pairs(presetRoutes) do
            print("^3[Djonluc Evidence Event]^7 Preset: " .. name .. " - " .. route.name)
        end
    end
    
    -- Check JSON library
    print("^3[Djonluc Evidence Event]^7 JSON Library Available:", json and "✅ YES" or "❌ NO")
    
    -- Check file paths
    local resourcePath = GetResourcePath(GetCurrentResourceName())
    print("^3[Djonluc Evidence Event]^7 Resource Path: " .. resourcePath)
    
    local jsonFile = io.open(resourcePath .. "/player_routes.json", "r")
    print("^3[Djonluc Evidence Event]^7 JSON File Exists:", jsonFile and "✅ YES" or "❌ NO")
    if jsonFile then jsonFile:close() end
    
    local txtFile = io.open(resourcePath .. "/player_routes.txt", "r")
    print("^3[Djonluc Evidence Event]^7 Text File Exists:", txtFile and "✅ YES" or "❌ NO")
    if txtFile then txtFile:close() end
    
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    if source ~= 0 then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Check console for route system test results')
    end
end, false)

-- Test convoy spawning system
RegisterCommand('testconvoy', function(source, args, rawCommand)
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^3[Djonluc Evidence Event]^7 🚗 TESTING CONVOY SPAWNING SYSTEM")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    -- Check vehicle config
    print("^3[Djonluc Evidence Event]^7 Vehicle Configuration:")
    if Config.Vehicles then
        for vehicleType, vehicleConfig in pairs(Config.Vehicles) do
            print("^3[Djonluc Evidence Event]^7 " .. vehicleType .. ":")
            print("^3[Djonluc Evidence Event]^7   Model: " .. (vehicleConfig.model or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Count: " .. (vehicleConfig.count or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Armor: " .. (vehicleConfig.armor or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Spawn Offset: " .. (vehicleConfig.spawn_offset or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Spawn Direction: " .. (vehicleConfig.spawn_direction or "❌ MISSING"))
        end
    else
        print("^1[Djonluc Evidence Event]^7 ❌ No vehicle configuration found")
    end
    
    -- Check ped config
    print("^3[Djonluc Evidence Event]^7 Ped Configuration:")
    if Config.Peds then
        for pedType, pedConfig in pairs(Config.Peds) do
            print("^3[Djonluc Evidence Event]^7 " .. pedType .. ":")
            print("^3[Djonluc Evidence Event]^7   Model: " .. (pedConfig.model or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Weapon: " .. (pedConfig.weapon or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Count: " .. (pedConfig.count or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Behavior: " .. (pedConfig.behavior or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Vehicle Assignment: " .. (pedConfig.vehicle_assignment or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Seat Preference: " .. (pedConfig.seat_preference or "❌ MISSING"))
            print("^3[Djonluc Evidence Event]^7   Driving Style: " .. (pedConfig.driving_style or "❌ MISSING"))
        end
    else
        print("^1[Djonluc Evidence Event]^7 ❌ No ped configuration found")
    end
    
    -- Check convoy formation config
    print("^3[Djonluc Evidence Event]^7 Convoy Formation Configuration:")
    if Config.ConvoyFormation then
        print("^3[Djonluc Evidence Event]^7   Formation Type: " .. (Config.ConvoyFormation.formation_type or "❌ MISSING"))
        print("^3[Djonluc Evidence Event]^7   Spacing: " .. (Config.ConvoyFormation.spacing or "❌ MISSING"))
        print("^3[Djonluc Evidence Event]^7   Max Width: " .. (Config.ConvoyFormation.max_convoy_width or "❌ MISSING"))
    else
        print("^1[Djonluc Evidence Event]^7 ❌ No convoy formation configuration found")
    end
    
    -- Check convoy movement config
    print("^3[Djonluc Evidence Event]^7 Convoy Movement Configuration:")
    if Config.ConvoyMovement then
        print("^3[Djonluc Evidence Event]^7   Speed: " .. (Config.ConvoyMovement.speed or "❌ MISSING") .. " m/s")
        print("^3[Djonluc Evidence Event]^7   Follow Distance: " .. (Config.ConvoyMovement.follow_distance or "❌ MISSING") .. "m")
        print("^3[Djonluc Evidence Event]^7   Formation Maintenance: " .. (Config.ConvoyMovement.formation_maintenance and "✅ YES" or "❌ NO"))
        print("^3[Djonluc Evidence Event]^7   Emergency Formation: " .. (Config.ConvoyMovement.emergency_formation and "✅ YES" or "❌ NO"))
        print("^3[Djonluc Evidence Event]^7   Max Deviation: " .. (Config.ConvoyMovement.max_deviation or "❌ MISSING") .. "m")
    else
        print("^1[Djonluc Evidence Event]^7 ❌ No convoy movement configuration found")
    end
    
    -- Check if event is active
    print("^3[Djonluc Evidence Event]^7 Event Active:", eventActive and "✅ YES" or "❌ NO")
    
    -- Check if route is set
    print("^3[Djonluc Evidence Event]^7 Dynamic Route Active:", currentDynamicRoute.active and "✅ YES" or "❌ NO")
    if currentDynamicRoute.active then
        print("^3[Djonluc Evidence Event]^7 Start: " .. currentDynamicRoute.start.x .. ", " .. currentDynamicRoute.start.y)
        print("^3[Djonluc Evidence Event]^7 End: " .. currentDynamicRoute.endPoint.x .. ", " .. currentDynamicRoute.endPoint.y)
    end
    
    -- Calculate expected convoy size
    local expectedVehicles = 0
    local expectedPeds = 0
    
    if Config.Vehicles then
        for _, vehicleConfig in pairs(Config.Vehicles) do
            expectedVehicles = expectedVehicles + (vehicleConfig.count or 0)
        end
    end
    
    if Config.Peds then
        for _, pedConfig in pairs(Config.Peds) do
            expectedPeds = expectedPeds + (pedConfig.count or 0)
        end
    end
    
    print("^3[Djonluc Evidence Event]^7 Expected Convoy Size:")
    print("^3[Djonluc Evidence Event]^7   Vehicles: " .. expectedVehicles)
    print("^3[Djonluc Evidence Event]^7   Peds: " .. expectedPeds)
    
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^2[Djonluc Evidence Event]^7 To test convoy spawning:")
    print("^3[Djonluc Evidence Event]^7 1. Set a route: /preset police")
    print("^3[Djonluc Evidence Event]^7 2. Start event: /startevidence")
    print("^3[Djonluc Evidence Event]^7 3. Check console for spawn messages")
    
    if source ~= 0 then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Check console for convoy spawning test results')
    end
end, false)

-- Vehicle Trunk Loot System Functions
local function FillVehicleTrunk(vehicleNetId)
    if not Config.VehicleTrunkLoot.enabled then return end
    
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    
    print("^3[Djonluc Evidence Event]^7 🎒 Filling evidence vehicle trunk with loot...")
    
    -- Get trunk items from config
    local trunkItems = Config.VehicleTrunkLoot.trunk_items
    local totalItems = 0
    
    for itemName, itemData in pairs(trunkItems) do
        local count = itemData.count
        totalItems = totalItems + count
        
        -- Add items to vehicle trunk (this would integrate with your inventory system)
        print("^3[Djonluc Evidence Event]^7   Adding " .. count .. "x " .. itemName .. " to trunk")
        
        -- Trigger client event to add items to vehicle trunk
        TriggerClientEvent('djonluc_evidence_event:addItemToVehicleTrunk', -1, vehicleNetId, itemName, count)
    end
    
    print("^3[Djonluc Evidence Event]^7 ✅ Vehicle trunk filled with " .. totalItems .. " items")
    
    -- Notify all players about the valuable cargo
    TriggerClientEvent('djonluc_evidence_event:showNotification', -1, '🚨 High-value evidence convoy spotted! Vehicle contains valuable contraband.', 'error')
end

local function HandlePedDeath(pedNetId)
    if not Config.VehicleTrunkLoot.enabled then return end
    
    local ped = NetworkGetEntityFromNetworkId(pedNetId)
    if not ped or not DoesEntityExist(ped) then return end
    
    local pedCoords = GetEntityCoords(ped)
    local pedDropItems = Config.VehicleTrunkLoot.ped_drop_items
    
    print("^3[Djonluc Evidence Event]^7 💀 Escort ped killed, checking for item drops...")
    
    for itemName, itemData in pairs(pedDropItems) do
        local chance = itemData.chance
        local countRange = itemData.count
        
        if math.random() <= chance then
            local count = math.random(countRange[1], countRange[2])
            
            print("^3[Djonluc Evidence Event]^7   Dropping " .. count .. "x " .. itemName .. " from killed ped")
            
            -- Trigger client event to spawn dropped items
            TriggerClientEvent('djonluc_evidence_event:spawnDroppedItem', -1, pedCoords, itemName, count)
        end
    end
end

local function HandleVehicleDestruction(vehicleNetId)
    if not Config.VehicleTrunkLoot.enabled then return end
    
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    
    local vehicleCoords = GetEntityCoords(vehicle)
    local destroyedItems = Config.VehicleTrunkLoot.vehicle_destroyed_items
    
    print("^3[Djonluc Evidence Event]^7 💥 Evidence vehicle destroyed, spawning scattered loot...")
    
    for itemName, itemData in pairs(destroyedItems) do
        local countRange = itemData.count
        local count = math.random(countRange[1], countRange[2])
        
        if count > 0 then
            print("^3[Djonluc Evidence Event]^7   Scattering " .. count .. "x " .. itemName .. " from destroyed vehicle")
            
            -- Spawn items in a radius around the destroyed vehicle
            for i = 1, count do
                local offsetX = math.random(-10, 10)
                local offsetY = math.random(-10, 10)
                local spawnPos = vector3(vehicleCoords.x + offsetX, vehicleCoords.y + offsetY, vehicleCoords.z)
                
                TriggerClientEvent('djonluc_evidence_event:spawnDroppedItem', -1, spawnPos, itemName, 1)
            end
        end
    end
    
    -- Notify all players about the scattered loot
    TriggerClientEvent('djonluc_evidence_event:showNotification', -1, '💎 Evidence vehicle destroyed! Valuable items scattered in the area.', 'inform')
end

-- Event handler for escort ped death
RegisterNetEvent('djonluc_evidence_event:escortPedDied')
AddEventHandler('djonluc_evidence_event:escortPedDied', function(pedNetId)
    HandlePedDeath(pedNetId)
end)

-- Event handler for convoy destruction
RegisterNetEvent('djonluc_evidence_event:convoyDestroyed')
AddEventHandler('djonluc_evidence_event:convoyDestroyed', function()
    print("^3[Djonluc Evidence Event]^7 🚨 Convoy destroyed, handling loot distribution...")
    
    -- Find the evidence vehicle and handle its destruction
    for _, vehicle in ipairs(convoyVehicles) do
        if DoesEntityExist(vehicle) then
            local model = GetEntityModel(vehicle)
            if model == GetHashKey(Config.Vehicles.evidence_van.model) then
                local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
                HandleVehicleDestruction(vehicleNetId)
                break
            end
        end
    end
end)

-- Test loot system
RegisterCommand('testloot', function(source, args, rawCommand)
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^3[Djonluc Evidence Event]^7 🎒 TESTING LOOT SYSTEM")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    -- Check if loot system is enabled
    print("^3[Djonluc Evidence Event]^7 Loot System Enabled:", Config.VehicleTrunkLoot.enabled and "✅ YES" or "❌ NO")
    
    if Config.VehicleTrunkLoot.enabled then
        -- Check trunk items
        print("^3[Djonluc Evidence Event]^7 Trunk Items:")
        local totalTrunkItems = 0
        for itemName, itemData in pairs(Config.VehicleTrunkLoot.trunk_items) do
            print("^3[Djonluc Evidence Event]^7   " .. itemName .. ": " .. itemData.count .. "x (Weight: " .. itemData.weight .. ")")
            totalTrunkItems = totalTrunkItems + itemData.count
        end
        print("^3[Djonluc Evidence Event]^7   Total Trunk Items: " .. totalTrunkItems)
        
        -- Check ped drop items
        print("^3[Djonluc Evidence Event]^7 Ped Drop Items:")
        for itemName, itemData in pairs(Config.VehicleTrunkLoot.ped_drop_items) do
            local chance = math.floor(itemData.chance * 100)
            local countRange = itemData.count[1] .. "-" .. itemData.count[2]
            print("^3[Djonluc Evidence Event]^7   " .. itemName .. ": " .. countRange .. "x (" .. chance .. "% chance)")
        end
        
        -- Check vehicle destroyed items
        print("^3[Djonluc Evidence Event]^7 Vehicle Destroyed Items:")
        for itemName, itemData in pairs(Config.VehicleTrunkLoot.vehicle_destroyed_items) do
            local countRange = itemData.count[1] .. "-" .. itemData.count[2]
            print("^3[Djonluc Evidence Event]^7   " .. itemName .. ": " .. countRange .. "x")
        end
    else
        print("^1[Djonluc Evidence Event]^7 ❌ Loot system is disabled in config")
    end
    
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^2[Djonluc Evidence Event]^7 Loot System Commands:")
    print("^3[Djonluc Evidence Event]^7   /access_trunk - Access vehicle trunk (client-side)")
    print("^3[Djonluc Evidence Event]^7   /testloot - Test loot system configuration")
    
    if source ~= 0 then
        TriggerClientEvent('djonluc_evidence_event:showNotification', source, 'Check console for loot system test results')
    end
end, false)

-- Test route data
RegisterCommand('testroute', function(source, args, rawCommand)
    if source == 0 then -- Console only
        print("^3[Djonluc Evidence Event]^7 ========================================")
        print("^3[Djonluc Evidence Event]^7 🗺️ TESTING ROUTE DATA")
        print("^3[Djonluc Evidence Event]^7 ========================================")
        
        print("^3[Djonluc Evidence Event]^7 Dynamic Route Status:")
        print("^3[Djonluc Evidence Event]^7   Active:", currentDynamicRoute.active and "✅ YES" or "❌ NO")
        
        if currentDynamicRoute.active then
            print("^3[Djonluc Evidence Event]^7   Start Point:", currentDynamicRoute.start.x, currentDynamicRoute.start.y, currentDynamicRoute.start.z, "Heading:", currentDynamicRoute.start.w or "None")
            print("^3[Djonluc Evidence Event]^7   End Point:", currentDynamicRoute.endPoint.x, currentDynamicRoute.endPoint.y, currentDynamicRoute.endPoint.z, "Heading:", currentDynamicRoute.endPoint.w or "None")
        end
        
        print("^3[Djonluc Evidence Event]^7 Config Routes:")
        if Config.Routes then
            for routeName, routeData in pairs(Config.Routes) do
                print("^3[Djonluc Evidence Event]^7   " .. routeName .. ":")
                print("^3[Djonluc Evidence Event]^7     Start:", routeData.start.x, routeData.start.y, routeData.start.z, "Heading:", routeData.start.w or "None")
                print("^3[Djonluc Evidence Event]^7     End:", routeData.destruction.x, routeData.destruction.y, routeData.destruction.z, "Heading:", routeData.destruction.w or "None")
            end
        else
            print("^1[Djonluc Evidence Event]^7 ❌ No config routes found")
        end
        
        print("^3[Djonluc Evidence Event]^7 ========================================")
    end
end, false)
