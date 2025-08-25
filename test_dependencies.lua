-- Test script for Evidence Destruction Event dependencies
-- Run this in the server console to verify everything is working

print("^2[Djonluc Evidence Event]^7 ========================================")
print("^2[Djonluc Evidence Event]^7 Dependency Test Script")
print("^2[Djonluc Evidence Event]^7 ========================================")

-- Test 1: Check if Utils is loaded
if Utils then
    print("^2✅ Utils loaded successfully")
    
    -- Test framework detection
    if Utils.Framework then
        print("^2✅ Framework detection system loaded")
        print("^3   - Current framework: " .. Utils.Framework.name)
        print("^3   - Version: " .. Utils.Framework.version)
    else
        print("^1❌ Framework detection system missing")
    end
    
    -- Test optional dependencies
    if Utils.OptionalDeps then
        print("^2✅ Optional dependency detection loaded")
        for dep, available in pairs(Utils.OptionalDeps) do
            print("^3   - " .. dep .. ": " .. (available and "✅" or "❌"))
        end
    else
        print("^1❌ Optional dependency detection missing")
    end
    
    -- Test key functions
    local testFunctions = {
        "IsFrameworkReady",
        "GetPlayerJob", 
        "ShowNotification",
        "GenerateDynamicRoute",
        "ValidateRoutePoints"
    }
    
    for _, funcName in ipairs(testFunctions) do
        if Utils[funcName] then
            print("^2✅ Function " .. funcName .. " available")
        else
            print("^1❌ Function " .. funcName .. " missing")
        end
    end
    
else
    print("^1❌ Utils not loaded")
end

-- Test 2: Check if Config is loaded
if Config then
    print("^2✅ Config loaded successfully")
    
    -- Test key config sections
    local configSections = {
        "StartJobs",
        "GuardIgnoreJobs", 
        "Vehicles",
        "Peds",
        "Routes",
        "DynamicRoutes",
        "LootCrate"
    }
    
    for _, section in ipairs(configSections) do
        if Config[section] then
            print("^2✅ Config section " .. section .. " available")
        else
            print("^1❌ Config section " .. section .. " missing")
        end
    end
    
else
    print("^1❌ Config not loaded")
end

-- Test 3: Check exports
local exports = {
    'IsEventActive',
    'GetEventData', 
    'StartEvidenceEvent',
    'EndEvidenceEvent',
    'GetConvoyPosition',
    'GetEscortPedsAlive',
    'GetCustomRoutes',
    'RegisterCustomRoute',
    'UnregisterCustomRoute',
    'GetPlayerJob',
    'InitializeEscortAI',
    'InitializeEnhancedEscortAI',
    'SetConvoyStartPoint',
    'SetConvoyEndPoint',
    'GetCurrentDynamicRoute',
    'ResetConvoyRoute'
}

print("^3[Djonluc Evidence Event]^7 Testing exports...")
for _, exportName in ipairs(exports) do
    local success = pcall(function()
        return exports['djonluc_evidence_event'][exportName]
    end)
    
    if success then
        print("^2✅ Export " .. exportName .. " available")
    else
        print("^1❌ Export " .. exportName .. " missing")
    end
end

-- Test 4: Check framework compatibility
print("^3[Djonluc Evidence Event]^7 Testing framework compatibility...")

-- Test QBCore (Primary Framework)
if GetResourceState('qb-core') == 'started' then
    print("^2✅ QBCore resource detected (Primary Framework)")
    
    -- Test QBCore exports
    local success = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)
    if success then
        print("^2✅ QBCore exports working")
    else
        print("^1❌ QBCore exports not working")
    end
else
    print("^1❌ QBCore resource not detected (REQUIRED)")
end

-- Test ESX (Fallback)
if GetResourceState('es_extended') == 'started' then
    print("^3⚠️ ESX resource detected (Fallback)")
else
    print("^3⚠️ ESX resource not detected")
end

-- Test QBox
if GetResourceState('qbox-core') == 'started' then
    print("^2✅ QBox resource detected")
else
    print("^3⚠️ QBox resource not detected")
end

-- Test vRP
if GetResourceState('vrp') == 'started' then
    print("^2✅ vRP resource detected")
else
    print("^3⚠️ vRP resource not detected")
end

-- Test optional dependencies
print("^3[Djonluc Evidence Event]^7 Testing optional dependencies...")

-- QBCore-specific resources (Primary)
local qbDeps = {
    'qb-inventory',
    'qb-target',
    'qb-menu'
}

print("^3[Djonluc Evidence Event]^7 Testing QBCore dependencies (Primary)...")
for _, dep in ipairs(qbDeps) do
    if GetResourceState(dep) == 'started' then
        print("^2✅ " .. dep .. " detected (QBCore)")
    else
        print("^3⚠️ " .. dep .. " not detected")
    end
end

-- Modern resources (QBCore compatible)
local modernDeps = {
    'ox_inventory',
    'ox_target', 
    'ox_lib',
    --'ox_weapons'
}

print("^3[Djonluc Evidence Event]^7 Testing modern dependencies (QBCore compatible)...")
for _, dep in ipairs(modernDeps) do
    if GetResourceState(dep) == 'started' then
        print("^2✅ " .. dep .. " detected (Modern)")
    else
        print("^3⚠️ " .. dep .. " not detected")
    end
end

for _, dep in ipairs(optionalDeps) do
    if GetResourceState(dep) == 'started' then
        print("^2✅ " .. dep .. " detected")
    else
        print("^3⚠️ " .. dep .. " not detected")
    end
end

print("^2[Djonluc Evidence Event]^7 ========================================")
print("^2[Djonluc Evidence Event]^7 Dependency test completed")
print("^2[Djonluc Evidence Event]^7 ========================================")

-- Test 5: Run framework status if available
if Utils and Utils.PrintFrameworkStatus then
    print("^3[Djonluc Evidence Event]^7 Running framework status report...")
    Utils.PrintFrameworkStatus()
end

-- Test 6: Test ox_lib if available
if Utils and Utils.PrintOxLibStatus then
    print("^3[Djonluc Evidence Event]^7 Running ox_lib status report...")
    Utils.PrintOxLibStatus()
end
