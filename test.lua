-- Comprehensive Test Script for Djonluc Evidence Event
-- Run this in the console to test the entire system

print("^3[Djonluc Evidence Event]^7 ========================================")
print("^3[Djonluc Evidence Event]^7 COMPREHENSIVE SYSTEM TEST")
print("^3[Djonluc Evidence Event]^7 ========================================")

-- Test 1: Check if Utils is available
if Utils then
    print("^2[Djonluc Evidence Event]^7 ✅ Utils is available")
    
    -- Test framework detection
    if Utils.Framework then
        print("^2[Djonluc Evidence Event]^7 ✅ Framework detected:", Utils.Framework.name)
        print("^2[Djonluc Evidence Event]^7 ✅ Framework version:", Utils.Framework.version)
        
        -- Test framework readiness
        if Utils.IsFrameworkReady then
            local isReady = Utils.IsFrameworkReady()
            print("^2[Djonluc Evidence Event]^7 ✅ Framework ready:", isReady and "YES" or "NO")
        else
            print("^1[Djonluc Evidence Event]^7 ❌ IsFrameworkReady function missing")
        end
    else
        print("^1[Djonluc Evidence Event]^7 ❌ Framework not detected")
    end
    
    -- Test utility functions
    local testFunctions = {
        "ValidatePlayer", "GetPlayerJob", "HasRequiredJob", "GetDistance", 
        "GetVehicleHash", "GetPedHash", "FormatNotification"
    }
    
    print("^3[Djonluc Evidence Event]^7 Testing utility functions...")
    for _, funcName in ipairs(testFunctions) do
        if Utils[funcName] then
            print("^2[Djonluc Evidence Event]^7 ✅ " .. funcName .. " function available")
        else
            print("^1[Djonluc Evidence Event]^7 ❌ " .. funcName .. " function missing")
        end
    end
else
    print("^1[Djonluc Evidence Event]^7 ❌ Utils not available")
end

-- Test 2: Check if Config is available
if Config then
    print("^2[Djonluc Evidence Event]^7 ✅ Config is available")
    
    -- Test required config sections
    local configSections = {
        "StartJobs", "Routes", "Vehicles", "Peds", "EventDuration"
    }
    
    print("^3[Djonluc Evidence Event]^7 Testing config sections...")
    for _, section in ipairs(configSections) do
        if Config[section] then
            print("^2[Djonluc Evidence Event]^7 ✅ " .. section .. " configured")
            
            -- Show some details for important sections
            if section == "StartJobs" then
                print("^3[Djonluc Evidence Event]^7   - Jobs:", table.concat(Config.StartJobs, ", "))
            elseif section == "Routes" then
                print("^3[Djonluc Evidence Event]^7   - Routes:", #Config.Routes)
                for name, route in pairs(Config.Routes) do
                    print("^3[Djonluc Evidence Event]^7     " .. name .. ": " .. route.start.x .. ", " .. route.start.y .. " → " .. route.destruction.x .. ", " .. route.destruction.y)
                end
            elseif section == "EventDuration" then
                print("^3[Djonluc Evidence Event]^7   - Duration:", Config.EventDuration .. "ms")
            end
        else
            print("^1[Djonluc Evidence Event]^7 ❌ " .. section .. " not configured")
        end
    end
else
    print("^1[Djonluc Evidence Event]^7 ❌ Config not available")
end

-- Test 3: Check if functions are available
print("^3[Djonluc Evidence Event]^7 Testing core functions...")

if Utils and Utils.ValidatePlayer then
    print("^2[Djonluc Evidence Event]^7 ✅ ValidatePlayer function available")
else
    print("^1[Djonluc Evidence Event]^7 ❌ ValidatePlayer function not available")
end

if Utils and Utils.GetPlayerJob then
    print("^2[Djonluc Evidence Event]^7 ✅ GetPlayerJob function available")
else
    print("^1[Djonluc Evidence Event]^7 ❌ GetPlayerJob function not available")
end

if Utils and Utils.HasRequiredJob then
    print("^2[Djonluc Evidence Event]^7 ✅ HasRequiredJob function available")
    -- Test with a sample job
    local testJob = "police"
    if Utils.HasRequiredJob(testJob) then
        print("^2[Djonluc Evidence Event]^7 ✅ Job validation works for:", testJob)
    else
        print("^1[Djonluc Evidence Event]^7 ❌ Job validation failed for:", testJob)
    end
else
    print("^1[Djonluc Evidence Event]^7 ❌ HasRequiredJob function not available")
end

-- Test 4: Check route configuration
if Config and Config.Routes then
    print("^3[Djonluc Evidence Event]^7 Testing route configuration...")
    for name, route in pairs(Config.Routes) do
        if route.start and route.destruction then
            print("^2[Djonluc Evidence Event]^7 ✅ Route " .. name .. " is valid")
            
            -- Check if coordinates are reasonable
            if route.start.x and route.start.y and route.start.z and
               route.destruction.x and route.destruction.y and route.destruction.z then
                print("^2[Djonluc Evidence Event]^7 ✅ Route " .. name .. " coordinates are valid")
                
                -- Display heading information
                local startHeading = route.start.w or 0.0
                local endHeading = route.destruction.w or 0.0
                print("^3[Djonluc Evidence Event]^7   - Start heading:", startHeading .. "°")
                print("^3[Djonluc Evidence Event]^7   - End heading:", endHeading .. "°")
                
                -- Calculate distance
                if Utils and Utils.GetDistance then
                    local distance = Utils.GetDistance(route.start, route.destruction)
                    print("^3[Djonluc Evidence Event]^7   - Distance:", string.format("%.1f", distance) .. "m")
                    
                    if distance < 100.0 then
                        print("^1[Djonluc Evidence Event]^7 ⚠️  Route " .. name .. " is very short (< 100m)")
                    elseif distance > 5000.0 then
                        print("^1[Djonluc Evidence Event]^7 ⚠️  Route " .. name .. " is very long (> 5km)")
                    else
                        print("^2[Djonluc Evidence Event]^7 ✅ Route " .. name .. " distance is reasonable")
                    end
                end
            else
                print("^1[Djonluc Evidence Event]^7 ❌ Route " .. name .. " has invalid coordinates")
            end
        else
            print("^1[Djonluc Evidence Event]^7 ❌ Route " .. name .. " is missing start or destruction point")
        end
    end
else
    print("^1[Djonluc Evidence Event]^7 ❌ No routes configured")
end

-- Test 5: Check vehicle and ped models
if Config and Config.Vehicles then
    print("^3[Djonluc Evidence Event]^7 Testing vehicle configuration...")
    for vehicleType, vehicleConfig in pairs(Config.Vehicles) do
        if vehicleConfig.model then
            print("^2[Djonluc Evidence Event]^7 ✅ " .. vehicleType .. " model:", vehicleConfig.model)
        else
            print("^1[Djonluc Evidence Event]^7 ❌ " .. vehicleType .. " missing model")
        end
    end
end

if Config and Config.Peds then
    print("^3[Djonluc Evidence Event]^7 Testing ped configuration...")
    for pedType, pedConfig in pairs(Config.Peds) do
        if pedConfig.model then
            print("^2[Djonluc Evidence Event]^7 ✅ " .. pedType .. " model:", pedConfig.model)
        else
            print("^1[Djonluc Evidence Event]^7 ❌ " .. pedType .. " missing model")
        end
    end
end

print("^3[Djonluc Evidence Event]^7 ========================================")
print("^3[Djonluc Evidence Event]^7 COMPREHENSIVE TEST COMPLETED!")
print("^3[Djonluc Evidence Event]^7 ========================================")
print("^3[Djonluc Evidence Event]^7 Next steps:")
print("^3[Djonluc Evidence Event]^7 1. Use /test_evidence to test the event system")
print("^3[Djonluc Evidence Event]^7 2. Use /checkjob to verify your job permissions")
print("^3[Djonluc Evidence Event]^7 3. Use /route to check current route status")
print("^3[Djonluc Evidence Event]^7 4. Use /setspawn and /setend to set convoy points")
print("^3[Djonluc Evidence Event]^7 5. Use /startevidence to start the event")
print("^3[Djonluc Evidence Event]^7 ========================================")
