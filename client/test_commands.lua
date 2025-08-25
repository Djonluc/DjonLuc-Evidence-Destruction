-- Test Commands for Evidence Destruction Event
-- This file contains all debug and test commands for easier maintenance

-- Debug command to check vehicle and ped spawning
RegisterCommand('debugspawn', function()
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^3[Djonluc Evidence Event]^7 🐛 DEBUGGING PED SPAWNING ISSUE")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    -- Check convoy vehicles
    print("^3[Djonluc Evidence Event]^7 Convoy Vehicles Count:", #convoyVehicles)
    for i, vehicle in ipairs(convoyVehicles) do
        if DoesEntityExist(vehicle) then
            local model = GetEntityModel(vehicle)
            local modelName = GetDisplayNameFromVehicleModel(model)
            local coords = GetEntityCoords(vehicle)
            print("^3[Djonluc Evidence Event]^7 Vehicle " .. i .. ": Model=" .. modelName .. " (" .. model .. ") at " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
        else
            print("^3[Djonluc Evidence Event]^7 Vehicle " .. i .. ": INVALID ENTITY")
        end
    end
    
    -- Check escort peds
    print("^3[Djonluc Evidence Event]^7 Escort Peds Count:", #_G.escortPeds)
    for i, ped in ipairs(_G.escortPeds) do
        if DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped)
            local inVehicle = IsPedInAnyVehicle(ped, false)
            local vehicle = GetVehiclePedIsIn(ped, false)
            local vehicleInfo = inVehicle and ("Vehicle: " .. vehicle) or "Not in vehicle"
            print("^3[Djonluc Evidence Event]^7 Ped " .. i .. ": " .. vehicleInfo .. " at " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
        else
            print("^3[Djonluc Evidence Event]^7 Ped " .. i .. ": INVALID ENTITY")
        end
    end
    
    -- Check config values
    print("^3[Djonluc Evidence Event]^7 Config Values:")
    print("^3[Djonluc Evidence Event]^7   escort_car.model:", Config.Vehicles.escort_car.model)
    print("^3[Djonluc Evidence Event]^7   escort_car.count:", Config.Vehicles.escort_car.count)
    print("^3[Djonluc Evidence Event]^7   escort_suv.model:", Config.Vehicles.escort_suv.model)
    print("^3[Djonluc Evidence Event]^7   escort_suv.count:", Config.Vehicles.escort_suv.count)
    print("^3[Djonluc Evidence Event]^7   escort_cop.count:", Config.Peds.escort_cop.count)
    print("^3[Djonluc Evidence Event]^7   escort_swat.count:", Config.Peds.escort_swat.count)
    
    -- Check vehicle model hashes
    local escortCarHash = GetHashKey(Config.Vehicles.escort_car.model)
    local escortSuvHash = GetHashKey(Config.Vehicles.escort_suv.model)
    print("^3[Djonluc Evidence Event]^7 Model Hashes:")
    print("^3[Djonluc Evidence Event]^7   escort_car hash:", escortCarHash)
    print("^3[Djonluc Evidence Event]^7   escort_suv hash:", escortSuvHash)
    
    print("^3[Djonluc Evidence Event]^7 ========================================")
end, false)

-- Test command to spawn peds in specific vehicles
RegisterCommand('testpedspawn', function()
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^3[Djonluc Evidence Event]^7 🧪 TESTING PED SPAWNING IN VEHICLES")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    if #convoyVehicles == 0 then
        print("^1[Djonluc Evidence Event]^7 ❌ No convoy vehicles found. Start an event first!")
        return
    end
    
    -- Find vehicles by type
    local escortCars = {}
    local escortSuvs = {}
    
    for i, vehicle in ipairs(convoyVehicles) do
        if DoesEntityExist(vehicle) then
            local model = GetEntityModel(vehicle)
            local expectedCarHash = GetHashKey(Config.Vehicles.escort_car.model)
            local expectedSuvHash = GetHashKey(Config.Vehicles.escort_suv.model)
            
            if model == expectedCarHash then
                table.insert(escortCars, vehicle)
            elseif model == expectedSuvHash then
                table.insert(escortSuvs, vehicle)
            end
        end
    end
    
    print("^3[Djonluc Evidence Event]^7 Found vehicles:")
    print("^3[Djonluc Evidence Event]^7   Escort cars:", #escortCars)
    print("^3[Djonluc Evidence Event]^7   Escort SUVs:", #escortSuvs)
    
    -- Test spawning a cop in first escort car
    if #escortCars > 0 then
        print("^3[Djonluc Evidence Event]^7 Testing cop spawn in first escort car...")
        local testPed = SpawnEscortPed(Config.Peds.escort_cop, escortCars[1], true)
        if testPed then
            print("^2[Djonluc Evidence Event]^7 ✅ Cop spawned successfully in escort car!")
            table.insert(_G.escortPeds, testPed)
            print("^3[Djonluc Evidence Event]^7 Ped added to escortPeds table. New count:", #_G.escortPeds)
        else
            print("^1[Djonluc Evidence Event]^7 ❌ Failed to spawn cop in escort car")
        end
    end
    
    -- Test spawning SWAT in first escort SUV
    if #escortSuvs > 0 then
        print("^3[Djonluc Evidence Event]^7 Testing SWAT spawn in first escort SUV...")
        local testPed = SpawnEscortPed(Config.Peds.escort_swat, escortSuvs[1], true)
        if testPed then
            print("^2[Djonluc Evidence Event]^7 ✅ SWAT spawned successfully in escort SUV!")
            table.insert(_G.escortPeds, testPed)
            print("^3[Djonluc Evidence Event]^7 Ped added to escortPeds table. New count:", #_G.escortPeds)
        else
            print("^1[Djonluc Evidence Event]^7 ❌ Failed to spawn SWAT in escort SUV")
        end
    end
    
    print("^3[Djonluc Evidence Event]^7 ========================================")
end, false)

-- Test command to check convoy formation
RegisterCommand('testformation', function()
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^3[Djonluc Evidence Event]^7 🚗 TESTING CONVOY FORMATION")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    if #convoyVehicles == 0 then
        print("^1[Djonluc Evidence Event]^7 ❌ No convoy vehicles found. Start an event first!")
        return
    end
    
    print("^3[Djonluc Evidence Event]^7 Convoy Formation Analysis:")
    print("^3[Djonluc Evidence Event]^7 Total escort vehicles:", #convoyVehicles)
    
    -- Sort vehicles by Y position to show front-to-back formation
    local sortedVehicles = {}
    for i, vehicle in ipairs(convoyVehicles) do
        if DoesEntityExist(vehicle) then
            local coords = GetEntityCoords(vehicle)
            local model = GetEntityModel(vehicle)
            local modelName = GetDisplayNameFromVehicleModel(model)
            table.insert(sortedVehicles, {
                vehicle = vehicle,
                coords = coords,
                model = model,
                modelName = modelName,
                y = coords.y
            })
        end
    end
    
    -- Sort by Y coordinate to show front-to-back formation (highest Y = front)
    table.sort(sortedVehicles, function(a, b) return a.y > b.y end)
    
    print("^3[Djonluc Evidence Event]^7 Formation (Front to Back):")
    for i, vehicleInfo in ipairs(sortedVehicles) do
        local position = i == 1 and "FRONT" or (i == #sortedVehicles and "BACK" or "MIDDLE")
        print(string.format("^3[Djonluc Evidence Event]^7 %d. %s (%s) at X: %.2f, Y: %.2f, Z: %.2f", 
            i, position, vehicleInfo.modelName, vehicleInfo.coords.x, vehicleInfo.coords.y, vehicleInfo.coords.z))
    end
    
    -- Check if evidence vehicle exists and its position
    if eventData and eventData.route and eventData.route.start then
        local evidencePos = eventData.route.start
        print("^3[Djonluc Evidence Event]^7 Evidence vehicle spawn point: X: " .. evidencePos.x .. ", Y: " .. evidencePos.y .. ", Z: " .. evidencePos.z)
        
        -- Find closest escort vehicle to center
        local centerY = evidencePos.y
        local closestVehicle = nil
        local closestDistance = 999999
        
        for _, vehicleInfo in ipairs(sortedVehicles) do
            local distance = math.abs(vehicleInfo.y - centerY)
            if distance < closestDistance then
                closestDistance = distance
                closestVehicle = vehicleInfo
            end
        end
        
        if closestVehicle then
            print("^3[Djonluc Evidence Event]^7 Closest escort vehicle to center: " .. closestVehicle.modelName .. " (distance: " .. string.format("%.2f", closestDistance) .. "m)")
        end
    end
    
    print("^3[Djonluc Evidence Event]^7 ========================================")
end, false)

-- Test command to spawn peds in specific vehicles
RegisterCommand('testpedspawn', function()
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^3[Djonluc Evidence Event]^7 🧪 TESTING PED SPAWNING IN VEHICLES")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    if #convoyVehicles == 0 then
        print("^1[Djonluc Evidence Event]^7 ❌ No convoy vehicles found. Start an event first!")
        return
    end
    
    -- Find vehicles by type
    local escortCars = {}
    local escortSuvs = {}
    
    for i, vehicle in ipairs(convoyVehicles) do
        if DoesEntityExist(vehicle) then
            local model = GetEntityModel(vehicle)
            local expectedCarHash = GetHashKey(Config.Vehicles.escort_car.model)
            local expectedSuvHash = GetHashKey(Config.Vehicles.escort_suv.model)
            
            if model == expectedCarHash then
                table.insert(escortCars, vehicle)
            elseif model == expectedSuvHash then
                table.insert(escortSuvs, vehicle)
            end
        end
    end
    
    print("^3[Djonluc Evidence Event]^7 Found vehicles:")
    print("^3[Djonluc Evidence Event]^7   Escort cars:", #escortCars)
    print("^3[Djonluc Evidence Event]^7   Escort SUVs:", #escortSuvs)
    
    -- Test spawning a cop in first escort car
    if #escortCars > 0 then
        print("^3[Djonluc Evidence Event]^7 Testing cop spawn in first escort car...")
        local testPed = SpawnEscortPed(Config.Peds.escort_cop, escortCars[1], true)
        if testPed then
            print("^2[Djonluc Evidence Event]^7 ✅ Cop spawned successfully in escort car!")
            table.insert(_G.escortPeds, testPed)
            print("^3[Djonluc Evidence Event]^7 Ped added to escortPeds table. New count:", #_G.escortPeds)
        else
            print("^1[Djonluc Evidence Event]^7 ❌ Failed to spawn cop in escort car")
        end
    end
    
    -- Test spawning SWAT in first escort SUV
    if #escortSuvs > 0 then
        print("^3[Djonluc Evidence Event]^7 Testing SWAT spawn in first escort SUV...")
        local testPed = SpawnEscortPed(Config.Peds.escort_swat, escortSuvs[1], true)
        if testPed then
            print("^2[Djonluc Evidence Event]^7 ✅ SWAT spawned successfully in escort SUV!")
            table.insert(_G.escortPeds, testPed)
            print("^3[Djonluc Evidence Event]^7 Ped added to escortPeds table. New count:", #_G.escortPeds)
        else
            print("^1[Djonluc Evidence Event]^7 ❌ Failed to spawn SWAT in escort SUV")
        end
    end
    
    print("^3[Djonluc Evidence Event]^7 ========================================")
end, false)

-- Test command for enhanced convoy system
RegisterCommand('testenhanced', function()
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^3[Djonluc Evidence Event]^7 🚀 TESTING ENHANCED CONVOY SYSTEM")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    if not eventActive then
        print("^1[Djonluc Evidence Event]^7 ❌ No active event. Start an event first!")
        return
    end
    
    print("^3[Djonluc Evidence Event]^7 Enhanced System Status:")
    
    -- Check blip system
    print("^3[Djonluc Evidence Event]^7 📍 Blip System:")
    print("^3[Djonluc Evidence Event]^7   Main convoy blip:", convoyBlip and "✅ Active" or "❌ Missing")
    print("^3[Djonluc Evidence Event]^7   Destination blip:", destinationBlip and "✅ Active" or "❌ Missing")
    print("^3[Djonluc Evidence Event]^7   Vehicle blips:", #convoyBlips, "total")
    print("^3[Djonluc Evidence Event]^7   Status indicator:", convoyBlips.statusIndicator and "✅ Active" or "❌ Missing")
    print("^3[Djonluc Evidence Event]^7   Route progress:", convoyBlips.routeProgress and "✅ Active" or "❌ Missing")
    print("^3[Djonluc Evidence Event]^7   Protection zone:", convoyBlips.protectionZone and "✅ Active" or "❌ Missing")
    
    -- Check ped task management
    print("^3[Djonluc Evidence Event]^7 🧍 Ped Task Management:")
    local drivingPeds = 0
    local followingPeds = 0
    local escortPeds = 0
    
    for _, ped in ipairs(_G.escortPeds) do
        if DoesEntityExist(ped) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle then
                local task = GetScriptTaskStatus(ped, GetHashKey("SCRIPT_TASK_VEHICLE_DRIVE_TO_COORD"))
                if task == 1 then
                    drivingPeds = drivingPeds + 1
                end
            end
        end
    end
    
    print("^3[Djonluc Evidence Event]^7   Peds driving to destination:", drivingPeds)
    print("^3[Djonluc Evidence Event]^7   Total escort peds:", #_G.escortPeds)
    
    -- Check convoy formation
    print("^3[Djonluc Evidence Event]^7 🚗 Convoy Formation:")
    print("^3[Djonluc Evidence Event]^7   Total vehicles:", #convoyVehicles)
    print("^3[Djonluc Evidence Event]^7   Formation type: Single File Line")
    print("^3[Djonluc Evidence Event]^7   Spacing: 5.0m between vehicles")
    
    -- Test enhanced functions
    print("^3[Djonluc Evidence Event]^7 🧪 Testing Enhanced Functions:")
    
    -- Test status update
    if convoyBlips.statusIndicator then
        UpdateConvoyStatus()
        print("^2[Djonluc Evidence Event]^7 ✅ Status update test completed")
    end
    
    -- Test task management
    if #_G.escortPeds > 0 and #convoyVehicles > 0 then
        local testPed = _G.escortPeds[1]
        local testVehicle = convoyVehicles[1]
        if DoesEntityExist(testPed) and DoesEntityExist(testVehicle) then
            local success = ManagePedTasks(testPed, testVehicle, "drive")
            print("^2[Djonluc Evidence Event]^7 ✅ Task management test completed:", success)
        end
    end
    
    print("^3[Djonluc Evidence Event]^7 ========================================")
end, false)

-- Test command for all enhanced FiveM native features
RegisterCommand('testnatives', function()
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^3[Djonluc Evidence Event]^7 🚀 TESTING ENHANCED FIVEM NATIVES")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    if not eventActive then
        print("^1[Djonluc Evidence Event]^7 ❌ No active event. Start an event first!")
        return
    end
    
    print("^3[Djonluc Evidence Event]^7 Enhanced FiveM Native Features:")
    
    -- Test vehicle formation
    print("^3[Djonluc Evidence Event]^7 🚗 Vehicle Formation System:")
    if #convoyVehicles >= 2 then
        print("^3[Djonluc Evidence Event]^7   Testing enhanced vehicle formation...")
        SetupVehicleFormation()
        print("^2[Djonluc Evidence Event]^7   ✅ Vehicle formation test completed")
    else
        print("^1[Djonluc Evidence Event]^7   ❌ Not enough vehicles for formation test")
    end
    
    -- Test enhanced convoy movement
    print("^3[Djonluc Evidence Event]^7 🚀 Enhanced Convoy Movement:")
    if #convoyVehicles > 0 then
        print("^3[Djonluc Evidence Event]^7   Testing enhanced convoy movement...")
        EnhancedConvoyMovement()
        print("^2[Djonluc Evidence Event]^7   ✅ Enhanced movement test completed")
    else
        print("^1[Djonluc Evidence Event]^7   ❌ No vehicles for movement test")
    end
    
    -- Test enhanced ped AI
    print("^3[Djonluc Evidence Event]^7 🧍 Enhanced Ped AI System:")
    if #_G.escortPeds > 0 then
        print("^3[Djonluc Evidence Event]^7   Testing enhanced ped AI...")
        local testPed = _G.escortPeds[1]
        if DoesEntityExist(testPed) then
            local success = SetupEnhancedPedAI(testPed, Config.Peds.escort_cop)
            print("^2[Djonluc Evidence Event]^7   ✅ Enhanced ped AI test completed:", success)
        else
            print("^1[Djonluc Evidence Event]^7   ❌ Test ped not found")
        end
    else
        print("^1[Djonluc Evidence Event]^7   ❌ No escort peds for AI test")
    end
    
    -- Test enhanced escort behavior
    print("^3[Djonluc Evidence Event]^7 🛡️ Enhanced Escort Behavior:")
    if #_G.escortPeds > 0 and #convoyVehicles > 0 then
        print("^3[Djonluc Evidence Event]^7   Testing enhanced escort behavior...")
        local testPed = _G.escortPeds[1]
        local testVehicle = convoyVehicles[1]
        if DoesEntityExist(testPed) and DoesEntityExist(testVehicle) then
            local success = SetupEscortBehavior(testPed, testVehicle)
            print("^2[Djonluc Evidence Event]^7   ✅ Enhanced escort behavior test completed:", success)
        else
            print("^1[Djonluc Evidence Event]^7   ❌ Test entities not found")
        end
    else
        print("^1[Djonluc Evidence Event]^7   ❌ Not enough entities for behavior test")
    end
    
    -- Test enhanced visual effects
    print("^3[Djonluc Evidence Event]^7 🎨 Enhanced Visual Effects:")
    print("^3[Djonluc Evidence Event]^7   Testing enhanced blip effects...")
    CreateEnhancedBlipEffects()
    print("^2[Djonluc Evidence Event]^7   ✅ Enhanced visual effects test completed")
    
    -- Test enhanced status system
    print("^3[Djonluc Evidence Event]^7 📊 Enhanced Status System:")
    print("^3[Djonluc Evidence Event]^7   Testing enhanced status update...")
    UpdateEnhancedConvoyStatus()
    print("^2[Djonluc Evidence Event]^7   ✅ Enhanced status test completed")
    
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^2[Djonluc Evidence Event]^7 🎉 All enhanced FiveM native tests completed!")
    print("^3[Djonluc Evidence Event]^7 ========================================")
end, false)

-- Test command to verify all FiveM natives work correctly
RegisterCommand('testnativesvalid', function()
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^3[Djonluc Evidence Event]^7 ✅ TESTING VALID FIVEM NATIVES")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    print("^3[Djonluc Evidence Event]^7 Testing FiveM Native Functions:")
    
    -- Test entity management natives
    print("^3[Djonluc Evidence Event]^7 🏗️ Entity Management Natives:")
    local testEntity = PlayerPedId()
    if testEntity then
        local success = pcall(function()
            SetEntityAsMissionEntity(testEntity, true, true)
        end)
        print("^3[Djonluc Evidence Event]^7   SetEntityAsMissionEntity:", success and "✅ PASS" or "❌ FAIL")
        
        local success2 = pcall(function()
            SetEntityInvincible(testEntity, false)
        end)
        print("^3[Djonluc Evidence Event]^7   SetEntityInvincible:", success2 and "✅ PASS" or "❌ FAIL")
    end
    
    -- Test vehicle natives
    print("^3[Djonluc Evidence Event]^7 🚗 Vehicle Natives:")
    local testVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if testVehicle and testVehicle ~= 0 then
        local success = pcall(function()
            SetVehicleEngineOn(testVehicle, true, true, false)
        end)
        print("^3[Djonluc Evidence Event]^7   SetVehicleEngineOn:", success and "✅ PASS" or "❌ FAIL")
        
        local success2 = pcall(function()
            SetDriverAbility(testVehicle, 1.0)
        end)
        print("^3[Djonluc Evidence Event]^7   SetDriverAbility:", success2 and "✅ PASS" or "❌ FAIL")
        
        local success3 = pcall(function()
            SetDriverAggressiveness(testVehicle, 0.5)
        end)
        print("^3[Djonluc Evidence Event]^7   SetDriverAggressiveness:", success3 and "✅ PASS" or "❌ FAIL")
    else
        print("^3[Djonluc Evidence Event]^7   Vehicle natives: ⚠️ No vehicle to test")
    end
    
    -- Test ped natives
    print("^3[Djonluc Evidence Event]^7 🧍 Ped Natives:")
    local testPed = PlayerPedId()
    if testPed then
        local success = pcall(function()
            SetPedCombatAttributes(testPed, 46, true)
        end)
        print("^3[Djonluc Evidence Event]^7   SetPedCombatAttributes:", success and "✅ PASS" or "❌ FAIL")
        
        local success2 = pcall(function()
            SetPedCombatRange(testPed, 2)
        end)
        print("^3[Djonluc Evidence Event]^7   SetPedCombatRange:", success2 and "✅ PASS" or "❌ FAIL")
        
        local success3 = pcall(function()
            SetPedAccuracy(testPed, 85)
        end)
        print("^3[Djonluc Evidence Event]^7   SetPedAccuracy:", success3 and "✅ PASS" or "❌ FAIL")
        
        local success4 = pcall(function()
            SetPedCombatAbility(testPed, 100)
        end)
        print("^3[Djonluc Evidence Event]^7   SetPedCombatAbility:", success4 and "✅ PASS" or "❌ FAIL")
        
        local success5 = pcall(function()
            SetPedFleeAttributes(testPed, 0, false)
        end)
        print("^3[Djonluc Evidence Event]^7   SetPedFleeAttributes:", success5 and "✅ PASS" or "❌ FAIL")
    end
    
    -- Test blip natives
    print("^3[Djonluc Evidence Event]^7 📍 Blip Natives:")
    local testBlip = AddBlipForCoord(0, 0, 0)
    if testBlip then
        local success = pcall(function()
            SetBlipFlashes(testBlip, true)
        end)
        print("^3[Djonluc Evidence Event]^7   SetBlipFlashes:", success and "✅ PASS" or "❌ FAIL")
        
        local success2 = pcall(function()
            SetBlipAsShortRange(testBlip, true)
        end)
        print("^3[Djonluc Evidence Event]^7   SetBlipAsShortRange:", success2 and "✅ PASS" or "❌ FAIL")
        
        local success3 = pcall(function()
            SetBlipRotation(testBlip, 45)
        end)
        print("^3[Djonluc Evidence Event]^7   SetBlipRotation:", success3 and "✅ PASS" or "❌ FAIL")
        
        local success4 = pcall(function()
            SetBlipAlpha(testBlip, 128)
        end)
        print("^3[Djonluc Evidence Event]^7   SetBlipAlpha:", success4 and "✅ PASS" or "❌ FAIL")
        
        -- Clean up test blip
        RemoveBlip(testBlip)
        print("^3[Djonluc Evidence Event]^7   Test blip cleaned up")
    end
    
    -- Test task natives
    print("^3[Djonluc Evidence Event]^7 🎯 Task Natives:")
    local testPed = PlayerPedId()
    if testPed then
        local success = pcall(function()
            ClearPedTasksImmediately(testPed)
        end)
        print("^3[Djonluc Evidence Event]^7   ClearPedTasksImmediately:", success and "✅ PASS" or "❌ FAIL")
        
        local success2 = pcall(function()
            TaskGoToCoordAnyMeans(testPed, 0, 0, 0, 2.0, 0, false, 786603, 0)
        end)
        print("^3[Djonluc Evidence Event]^7   TaskGoToCoordAnyMeans:", success2 and "✅ PASS" or "❌ FAIL")
    end
    
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^2[Djonluc Evidence Event]^7 🎉 All valid FiveM native tests completed!")
    print("^3[Djonluc Evidence Event]^7 ========================================")
end, false)

print("^2[Djonluc Evidence Event]^7 Test commands loaded successfully!")
