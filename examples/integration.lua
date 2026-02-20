-- Example integration file for Evidence Destruction Event
-- This shows how other scripts can interact with the system

-- Example 1: Check if event is active
local function CheckEventStatus()
    local isActive = exports['djonluc_evidence_event']:IsEventActive()
    if isActive then
        print("Djonluc Evidence Event is currently active")
        local eventData = exports['djonluc_evidence_event']:GetEventData()
        print("Event started by: " .. eventData.startedBy)
    else
        print("No Djonluc Evidence Event currently active")
    end
end

-- Example 2: Start an event programmatically
local function StartEventFromScript(source)
    local success = exports['djonluc_evidence_event']:StartEvidenceEvent(source)
    if success then
        print("Event started successfully")
    else
        print("Failed to start event")
    end
end

-- Example 3: Register a custom route
local function RegisterCustomRoute()
    local customRoute = {
        start = vector3(100.0, 200.0, 30.0),
        destruction = vector3(500.0, 600.0, 40.0),
        waypoints = {
            vector3(150.0, 250.0, 32.0),
            vector3(200.0, 300.0, 35.0),
            vector3(300.0, 400.0, 38.0)
        }
    }
    
    local success = exports['djonluc_evidence_event']:RegisterCustomRoute("my_custom_route", customRoute)
    if success then
        print("Custom route registered successfully")
    end
end

-- Example 4: Monitor event progress
local function MonitorEvent()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5000) -- Check every 5 seconds
            
            local isActive = exports['djonluc_evidence_event']:IsEventActive()
            if isActive then
                local escortPedsAlive = exports['djonluc_evidence_event']:GetEscortPedsAlive()
                local convoyPos = exports['djonluc_evidence_event']:GetConvoyPosition()
                
                print(string.format("Event active - Escort peds alive: %d, Convoy position: %s", 
                    escortPedsAlive, 
                    convoyPos and string.format("%.1f, %.1f, %.1f", convoyPos.x, convoyPos.y, convoyPos.z) or "Unknown"
                ))
            end
        end
    end)
end

-- Example 5: Event status request (client-side)
RegisterNetEvent('djonluc_evidence_event:eventStatusResponse')
AddEventHandler('djonluc_evidence_event:eventStatusResponse', function(status)
    print("Event Status Response:")
    print("  Active: " .. tostring(status.active))
    print("  Escort Peds Alive: " .. status.escortPedsAlive)
    if status.data and status.data.route then
        print("  Route: " .. status.data.route.start.x .. ", " .. status.data.route.start.y)
    end
end)

-- Example 6: Request event status
local function RequestEventStatus()
    TriggerServerEvent('djonluc_evidence_event:requestEventStatus')
end

-- Example 7: Integration with job systems
local function CheckPlayerPermission(source)
    local playerJob = exports['djonluc_evidence_event']:GetPlayerJob(source)
    if playerJob == "doj" or playerJob == "leo" then
        return true
    end
    return false
end

-- Example 8: Custom notification integration
local function SendCustomNotification(source, message)
    -- Use the framework-agnostic notification system
    exports['djonluc_evidence_event']:ShowNotification(source, message, 'success')
end

-- Example 9: Event completion callback
local function OnEventCompleted(success)
    if success then
        print("Djonluc Evidence Event completed successfully - evidence destroyed")
        -- Handle successful completion
    else
        print("Djonluc Evidence Event failed - evidence intercepted")
        -- Handle failure
    end
end

-- Example 10: Resource dependency check
local function CheckDependencies()
    local evidenceEventState = GetResourceState('djonluc_evidence_event')
    if evidenceEventState == 'started' then
        print("Djonluc Evidence Event resource is running")
        return true
    else
        print("Djonluc Evidence Event resource is not running: " .. evidenceEventState)
        return false
    end
end

-- Usage examples:
-- CheckDependencies()
-- MonitorEvent()
-- RegisterCustomRoute()
-- CheckEventStatus()

print("Djonluc Evidence Event integration examples loaded")
print("Use these functions to integrate with the Evidence Destruction Event system")
