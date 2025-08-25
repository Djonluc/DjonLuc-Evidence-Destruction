-- Client-side main logic for Evidence Destruction Event

local convoyVehicles = {}
-- Make escortPeds globally accessible for AI system
_G.escortPeds = {}
local escortPeds = _G.escortPeds -- Local reference to global table
local eventActive = false
local eventData = {} -- Event data from server
local convoyBlip = nil -- Blip for convoy tracking

-- Debug function
local function DebugPrint(message, ...)
    local args = {...}
    local formattedMessage = string.format("[DEBUG] %s", message)
    if #args > 0 then
        formattedMessage = formattedMessage .. " | Args: " .. table.concat(args, ", ")
    end
    print(formattedMessage)
end

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

-- Make escort peds globally accessible for AI system
_G.convoyEscortPeds = _G.escortPeds

-- Enhanced blip management with individual vehicle tracking
local convoyBlips = {} -- Table to store individual vehicle blips
local convoyBlip = nil -- Main convoy blip
local destinationBlip = nil -- Destination blip

-- Create individual blips for each convoy vehicle
local function CreateVehicleBlips()
    -- Clear existing vehicle blips
    for _, blip in pairs(convoyBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    convoyBlips = {}
    
    -- Create blip for evidence vehicle
    if #convoyVehicles > 0 then
        local evidenceVehicle = convoyVehicles[1] -- Evidence vehicle should be first
        if DoesEntityExist(evidenceVehicle) then
            local evidenceBlip = AddBlipForEntity(evidenceVehicle)
            SetBlipSprite(evidenceBlip, 67) -- Police car sprite
            SetBlipDisplay(evidenceBlip, 4)
            SetBlipScale(evidenceBlip, 1.2)
            SetBlipColour(evidenceBlip, 1) -- Red color for evidence vehicle
            SetBlipAsShortRange(evidenceBlip, false)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Evidence Vehicle")
            EndTextCommandSetBlipName(evidenceBlip)
            
            convoyBlips.evidence = evidenceBlip
            DebugPrint("Evidence vehicle blip created:", evidenceBlip)
        end
    end
    
    -- Create blips for escort vehicles
    for i, vehicle in ipairs(convoyVehicles) do
        if DoesEntityExist(vehicle) and vehicle ~= convoyVehicles[1] then
            local vehicleBlip = AddBlipForEntity(vehicle)
            local model = GetEntityModel(vehicle)
            local expectedCarHash = GetHashKey(Config.Vehicles.escort_car.model)
            local expectedSuvHash = GetHashKey(Config.Vehicles.escort_suv.model)
            
            -- Set blip properties based on vehicle type
            if model == expectedCarHash then
                SetBlipSprite(vehicleBlip, 56) -- Police car sprite
                SetBlipColour(vehicleBlip, 3) -- Blue color for escort cars
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Escort Car " .. i)
                EndTextCommandSetBlipName(vehicleBlip)
            elseif model == expectedSuvHash then
                SetBlipSprite(vehicleBlip, 56) -- Police car sprite
                SetBlipColour(vehicleBlip, 5) -- Yellow color for escort SUVs
                BeginTextCommandSetBlipName(vehicleBlip, 5)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Escort SUV " .. i)
                EndTextCommandSetBlipName(vehicleBlip)
            end
            
            SetBlipDisplay(vehicleBlip, 4)
            SetBlipScale(vehicleBlip, 0.8)
            SetBlipAsShortRange(vehicleBlip, false)
            
            convoyBlips[i] = vehicleBlip
            DebugPrint("Escort vehicle blip created:", vehicleBlip, "for vehicle:", i)
        end
    end
    
    DebugPrint("Total vehicle blips created:", #convoyBlips)
end

-- Create main convoy blip and destination
local function CreateConvoyBlip()
    if convoyBlip then
        RemoveBlip(convoyBlip)
    end
    
    -- Create main convoy blip
    convoyBlip = AddBlipForCoord(0, 0, 0)
    SetBlipSprite(convoyBlip, 67) -- Police car sprite
    SetBlipDisplay(convoyBlip, 4)
    SetBlipScale(convoyBlip, 1.0)
    SetBlipColour(convoyBlip, 3) -- Blue color
    SetBlipAsShortRange(convoyBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Evidence Convoy")
    EndTextCommandSetBlipName(convoyBlip)
    
    -- Add destination blip
    if eventData and eventData.route and eventData.route.destruction then
        destinationBlip = AddBlipForCoord(eventData.route.destruction.x, eventData.route.destruction.y, eventData.route.destruction.z)
        SetBlipSprite(destinationBlip, 1) -- Destination sprite
        SetBlipDisplay(destinationBlip, 4)
        SetBlipScale(destinationBlip, 0.8)
        SetBlipColour(destinationBlip, 2) -- Green color
        SetBlipAsShortRange(destinationBlip, false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Evidence Destruction Point")
        EndTextCommandSetBlipName(destinationBlip)
        
        DebugPrint("Destination blip created")
    end
    
    -- Create individual vehicle blips
    CreateVehicleBlips()
    
    DebugPrint("Enhanced convoy blip system created")
end

-- Update convoy blip positions and create protection zone
local function UpdateConvoyBlip()
    if not convoyBlip or not eventActive or #convoyVehicles == 0 then
        return
    end
    
    -- Find the evidence vehicle (main convoy vehicle)
    local evidenceVehicle = nil
    for _, vehicle in ipairs(convoyVehicles) do
        if DoesEntityExist(vehicle) then
            -- Check if this is the evidence vehicle (stockade)
            local model = GetEntityModel(vehicle)
            if model == GetHashKey("stockade") then
                evidenceVehicle = vehicle
                break
            end
        end
    end
    
    -- If no evidence vehicle found, use the first available vehicle
    if not evidenceVehicle and #convoyVehicles > 0 then
        for _, vehicle in ipairs(convoyVehicles) do
            if DoesEntityExist(vehicle) then
                evidenceVehicle = vehicle
                break
            end
        end
    end
    
    if evidenceVehicle then
        local coords = GetEntityCoords(evidenceVehicle)
        
        -- Update main convoy blip position
        SetBlipCoords(convoyBlip, coords.x, coords.y, coords.z)
        
        -- Create convoy protection zone (radius blip)
        if not convoyBlips.protectionZone then
            convoyBlips.protectionZone = AddBlipForRadius(coords.x, coords.y, coords.z, 50.0)
            SetBlipRotation(convoyBlips.protectionZone, 0)
            SetBlipColour(convoyBlips.protectionZone, 1) -- Red color for danger zone
            SetBlipAlpha(convoyBlips.protectionZone, 128) -- Semi-transparent
            SetBlipAsShortRange(convoyBlips.protectionZone, false)
            
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Convoy Protection Zone")
            EndTextCommandSetBlipName(convoyBlips.protectionZone)
            
            DebugPrint("Convoy protection zone created")
        else
            -- Update protection zone position
            SetBlipCoords(convoyBlips.protectionZone, coords.x, coords.y, coords.z)
        end
        
        -- Update individual vehicle blips (they automatically follow entities)
        for _, blip in pairs(convoyBlips) do
            if DoesBlipExist(blip) and blip ~= convoyBlips.protectionZone then
                -- Entity blips update automatically, just ensure they're visible
                SetBlipDisplay(blip, 4)
            end
        end
    end
end

local function RemoveConvoyBlip()
    if convoyBlip then
        RemoveBlip(convoyBlip)
        convoyBlip = nil
        DebugPrint("Convoy blip removed")
    end
    
    -- Remove destination blip
    if _G.destinationBlip then
        RemoveBlip(_G.destinationBlip)
        _G.destinationBlip = nil
        DebugPrint("Destination blip removed")
    end
end

-- Initialize Framework (QBCore/ESX)
Citizen.CreateThread(function()
    DebugPrint("Starting framework initialization...")
    
    -- Wait for Utils to be available (FiveM best practice)
    while not Utils or not Utils.Framework do
        Citizen.Wait(100)
    end
    
    DebugPrint("Framework initialization completed via Utils")
end)

-- Register ox_lib context menu if available
Citizen.CreateThread(function()
    DebugPrint("Checking for ox_lib dependency...")
    if Utils.OptionalDeps and Utils.OptionalDeps.ox_lib then
        DebugPrint("ox_lib detected, registering context menu...")
        local success = pcall(function()
            exports.ox_lib:registerContext({
                id = 'evidence_event_menu',
                title = 'Evidence Destruction Event',
                options = {
                    {
                        title = 'Start Event',
                        description = 'Start a high-security convoy escort mission',
                        icon = 'fas fa-shield-alt',
                        onSelect = function()
                            DebugPrint("Start Event option selected")
                            TriggerServerEvent('djonluc_evidence_event:requestStartEvent')
                        end
                    },
                    {
                        title = 'Event Status',
                        description = 'Check current event status',
                        icon = 'fas fa-info-circle',
                        onSelect = function()
                            DebugPrint("Event Status option selected")
                            TriggerServerEvent('djonluc_evidence_event:requestEventStatus')
                        end
                    }
                }
            })
        end)
        if success then
            DebugPrint("Context menu registered successfully")
        else
            DebugPrint("Failed to register context menu")
        end
    else
        DebugPrint("ox_lib not available")
    end
end)

-- Event start menu system
local function ShowEventStartMenu()
    DebugPrint("ShowEventStartMenu called")
    
    if Utils.OptionalDeps and Utils.OptionalDeps.ox_lib then
        DebugPrint("Using ox_lib context menu")
        -- ox_lib context menu
        local success = pcall(function()
            exports.ox_lib:showContext('evidence_event_menu')
        end)
        
        if success then
            DebugPrint("Context menu shown successfully")
        else
            DebugPrint("Context menu failed, trying input dialog...")
        end
        
        -- If context menu fails, try input dialog
        if not success then
            local inputSuccess = pcall(function()
                exports.ox_lib:inputDialog('Evidence Event', {
                    {
                        type = 'select',
                        label = 'Choose Action',
                        options = {
                            { value = 'start', label = 'Start Event' },
                            { value = 'status', label = 'Check Status' }
                        }
                    }
                }, function(data)
                    if data and data[1] then
                        DebugPrint("Input dialog result:", data[1])
                        if data[1] == 'start' then
                            TriggerServerEvent('djonluc_evidence_event:requestStartEvent')
                        elseif data[1] == 'status' then
                            TriggerServerEvent('djonluc_evidence_event:requestEventStatus')
                        end
                    end
                end)
            end)
            
            if inputSuccess then
                DebugPrint("Input dialog shown successfully")
            else
                DebugPrint("Input dialog failed, using fallback")
            end
            
            -- If both fail, fall back to basic menu
            if not inputSuccess then
                DebugPrint("Using fallback chat message")
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"Djonluc Evidence Event", "Use /startevidence to start the event"}
                })
            end
        end
    elseif Utils.OptionalDeps and Utils.OptionalDeps.qb_menu then
        DebugPrint("Using qb-menu with latest QBCore standards")
        -- Use the new QBCore menu wrapper function
        local success = Utils.QBCoreShowMenuClient({
            {
                header = "Evidence Destruction Event",
                isMenuHeader = true
            },
            {
                header = "Start Event",
                txt = "Start a high-security convoy escort mission",
                params = {
                    event = "djonluc_evidence_event:requestStartEvent"
                }
            },
            {
                header = "Event Status",
                txt = "Check current event status",
                params = {
                    event = "djonluc_evidence_event:requestEventStatus"
                }
            }
        })
        
        if success then
            DebugPrint("qb-menu opened successfully using QBCore wrapper")
        else
            DebugPrint("qb-menu failed, trying direct export")
            -- Fallback to direct export
            local directSuccess = pcall(function()
                exports['qb-menu']:openMenu({
                    {
                        header = "Evidence Destruction Event",
                        isMenuHeader = true
                    },
                    {
                        header = "Start Event",
                        txt = "Start a high-security convoy escort mission",
                        params = {
                            event = "djonluc_evidence_event:requestStartEvent"
                        }
                    },
                    {
                        header = "Event Status",
                        txt = "Check current event status",
                        params = {
                            event = "djonluc_evidence_event:requestEventStatus"
                        }
                    }
                })
            end)
            
            if directSuccess then
                DebugPrint("Direct qb-menu export successful")
            else
                DebugPrint("Direct qb-menu export failed")
            end
        end
    else
        DebugPrint("No menu system available, using fallback")
        -- Fallback to command
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Djonluc Evidence Event", "Use /startevidence to start the event"}
        })
    end
end

-- Register keybind for menu (F6 by default)
RegisterCommand('evidence_menu', function()
    DebugPrint("evidence_menu command executed")
    ShowEventStartMenu()
end, false)

RegisterKeyMapping('evidence_menu', 'Open Djonluc Evidence Event Menu', 'keyboard', 'F6')

-- Toggle convoy blip visibility
RegisterCommand('toggleblip', function()
    if convoyBlip then
        if IsBlipVisible(convoyBlip) then
            SetBlipDisplay(convoyBlip, 0) -- Hide blip
            DebugPrint("Convoy blip hidden")
            TriggerEvent('chat:addMessage', {
                color = {255, 255, 0},
                multiline = true,
                args = {"Djonluc Evidence Event", "Convoy blip hidden"}
            })
        else
            SetBlipDisplay(convoyBlip, 4) -- Show blip
            DebugPrint("Convoy blip shown")
            TriggerEvent('chat:addMessage', {
                color = {0, 255, 0},
                multiline = true,
                args = {"Djonluc Evidence Event", "Convoy blip shown"}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Djonluc Evidence Event", "No convoy blip available"}
        })
    end
end, false)



-- Framework status check command
RegisterCommand('evidence_check', function()
    DebugPrint("evidence_check command executed")
    if Utils and Utils.PrintFrameworkStatus then
        Utils.PrintFrameworkStatus()
        
        -- Also show client-side status
        print("^3[Djonluc Evidence Event]^7 Client Status:")
        print("^3[Djonluc Evidence Event]^7 Event Active: " .. (eventActive and "✅ YES" or "❌ NO"))
        print("^3[Djonluc Evidence Event]^7 Convoy Vehicles: " .. #convoyVehicles)
        print("^3[Djonluc Evidence Event]^7 Escort Peds: " .. #escortPeds)
        print("^3[Djonluc Evidence Event]^7 Loot Crate: " .. (lootCrate and "✅ YES" or "❌ NO"))
        
                 -- Show optional dependencies status
         if Utils.OptionalDeps then
             print("^3[Djonluc Evidence Event]^7 Optional Dependencies:")
             for dep, available in pairs(Utils.OptionalDeps) do
                 print("^3[Djonluc Evidence Event]^7 " .. dep .. ": " .. (available and "✅" or "❌"))
             end
             
             -- Detailed ox_lib status
             if Utils.PrintOxLibStatus then
                 Utils.PrintOxLibStatus()
             end
         end
    else
        print("^1[Djonluc Evidence Event]^7 ERROR: Utils not available")
    end
end, false)





-- Test escort peds and vehicles
RegisterCommand('testpeds', function()
    print("^3[Djonluc Evidence Event]^7 ========================================")
    print("^3[Djonluc Evidence Event]^7 👥 TESTING ESCORT PEDS AND VEHICLES")
    print("^3[Djonluc Evidence Event]^7 ========================================")
    
    print("^3[Djonluc Evidence Event]^7 Event Status:")
    print("^3[Djonluc Evidence Event]^7   Event Active: " .. (eventActive and "✅ YES" or "❌ NO"))
    
    print("^3[Djonluc Evidence Event]^7 Convoy Vehicles:")
    print("^3[Djonluc Evidence Event]^7   Total Count: " .. #convoyVehicles)
    for i, vehicle in ipairs(convoyVehicles) do
        if DoesEntityExist(vehicle) then
            local coords = GetEntityCoords(vehicle)
            local model = GetEntityModel(vehicle)
            local health = GetVehicleEngineHealth(vehicle)
            print("^3[Djonluc Evidence Event]^7   Vehicle " .. i .. ": Model=" .. model .. ", Health=" .. math.floor(health) .. ", Position=" .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
        else
            print("^1[Djonluc Evidence Event]^7   Vehicle " .. i .. ": ❌ DOES NOT EXIST")
        end
    end
    
    print("^3[Djonluc Evidence Event]^7 Escort Peds:")
    print("^3[Djonluc Evidence Event]^7   Total Count: " .. #_G.escortPeds)
    for i, ped in ipairs(_G.escortPeds) do
        if DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped)
            local health = GetEntityHealth(ped)
            local armor = GetPedArmour(ped)
            local inVehicle = IsPedInAnyVehicle(ped, false)
            local vehicle = GetVehiclePedIsIn(ped, false)
            print("^3[Djonluc Evidence Event]^7   Ped " .. i .. ": Health=" .. health .. ", Armor=" .. armor .. ", In Vehicle=" .. (inVehicle and "✅ YES" or "❌ NO") .. ", Position=" .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
            if inVehicle and vehicle ~= 0 then
                local vehicleCoords = GetEntityCoords(vehicle)
                print("^3[Djonluc Evidence Event]^7     Vehicle Position: " .. vehicleCoords.x .. ", " .. vehicleCoords.y .. ", " .. vehicleCoords.z)
            end
        else
            print("^1[Djonluc Evidence Event]^7   Ped " .. i .. ": ❌ DOES NOT EXIST")
        end
    end
    
    print("^3[Djonluc Evidence Event]^7 Configuration:")
    print("^3[Djonluc Evidence Event]^7   Escort Cop Count: " .. (Config.Peds.escort_cop.count or "❌ MISSING"))
    print("^3[Djonluc Evidence Event]^7   Escort SWAT Count: " .. (Config.Peds.escort_swat.count or "❌ MISSING"))
    print("^3[Djonluc Evidence Event]^7   Escort Car Count: " .. (Config.Vehicles.escort_car.count or "❌ MISSING"))
    print("^3[Djonluc Evidence Event]^7   Escort SUV Count: " .. (Config.Vehicles.escort_suv.count or "❌ MISSING"))
    
    print("^3[Djonluc Evidence Event]^7 ========================================")
end, false)









-- Enhanced notification handler with ox_lib support
RegisterNetEvent('djonluc_evidence_event:showNotification')
AddEventHandler('djonluc_evidence_event:showNotification', function(message, type)
    DebugPrint("Notification received:", message, "Type:", type or "default")
    
    -- Try ox_lib notifications first if available
    if Utils.OptionalDeps and Utils.OptionalDeps.ox_lib then
        DebugPrint("Attempting ox_lib notification...")
        local success = pcall(function()
            exports.ox_lib:notify({
                type = type or 'inform',
                description = message,
                duration = 5000
            })
        end)
        if success then 
            DebugPrint("ox_lib notification sent successfully")
            return 
        else
            DebugPrint("ox_lib notification failed")
        end
    end
    
    -- Fallback to basic notification
    DebugPrint("Using basic fallback notification")
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, false)
end)

-- Advanced notification handler for title + message
RegisterNetEvent('djonluc_evidence_event:showAdvancedNotification')
AddEventHandler('djonluc_evidence_event:showAdvancedNotification', function(title, message, type, duration)
    -- Try ox_lib advanced notifications first
    if Utils.OptionalDeps and Utils.OptionalDeps.ox_lib then
        local success = pcall(function()
            exports.ox_lib:notify({
                type = type or 'inform',
                title = title,
                description = message,
                duration = duration or 5000
            })
        end)
        if success then return end
    end
    
    -- Fallback to basic notification
    local fullMessage = title and (title .. ': ' .. message) or message
    TriggerEvent('djonluc_evidence_event:showNotification', fullMessage, type)
end)

-- Spawn convoy
RegisterNetEvent('djonluc_evidence_event:spawnConvoy')
AddEventHandler('djonluc_evidence_event:spawnConvoy', function(route)
    DebugPrint("spawnConvoy event received, route:", route and "valid" or "invalid")
    
    if eventActive then 
        DebugPrint("Event already active, ignoring spawn request")
        return 
    end
    
    -- Validate route data before storing (FiveM best practice)
    if not route or not route.start or not route.destruction then
        DebugPrint("Error: Invalid route data received")
        print("^1[Djonluc Evidence Event]^7 ERROR: Invalid route data received")
        return
    end
    
    -- Store route data for blip system
    eventData.route = route
    DebugPrint("Route data stored:", route.start.x, route.start.y, route.start.z, "→", route.destruction.x, route.destruction.y, route.destruction.z)
    
    eventActive = true
    DebugPrint("Event marked as active, spawning convoy...")
    
    -- Create convoy blip
    CreateConvoyBlip()
    
    -- Use proper thread creation (FiveM best practice)
    Citizen.CreateThread(function()
        DebugPrint("Starting convoy spawn thread...")
        SpawnConvoy(route)
    end)
end)

-- Vehicle modification event (called from server)
RegisterNetEvent('djonluc_evidence_event:modifyVehicles')
AddEventHandler('djonluc_evidence_event:modifyVehicles', function()
    DebugPrint("Vehicle modification event received")
    
    -- Wait a bit for vehicles to be fully spawned
    Citizen.Wait(1000)
    
    -- Modify evidence vehicle
    for _, vehicle in ipairs(convoyVehicles) do
        if DoesEntityExist(vehicle) then
            local model = GetEntityModel(vehicle)
            
            if model == GetHashKey("stockade") then
                -- Evidence vehicle modifications
                SetVehicleDoorsLocked(vehicle, 2)
                SetVehicleEngineHealth(vehicle, 1000.0)
                SetVehicleBodyHealth(vehicle, 1000.0)
                DebugPrint("Evidence vehicle modified - Doors locked, Health set")
            elseif model == GetHashKey("police") then
                -- Escort car modifications
                SetVehicleDoorsLocked(vehicle, 2)
                SetVehicleEngineHealth(vehicle, 1000.0)
                SetVehicleBodyHealth(vehicle, 1000.0)
                DebugPrint("Escort car modified - Doors locked, Health set")
            elseif model == GetHashKey("fbi2") then
                -- Escort SUV modifications
                SetVehicleDoorsLocked(vehicle, 2)
                SetVehicleEngineHealth(vehicle, 1000.0)
                SetVehicleBodyHealth(vehicle, 1000.0)
                DebugPrint("Escort SUV modified - Doors locked, Health set")
            end
        end
    end
end)

function SpawnConvoy(route)
    DebugPrint("SpawnConvoy function called")
    if not route or not route.start or not route.destruction then
        DebugPrint("Error: Invalid route configuration")
        print("Error: Invalid route configuration")
        return
    end
    
    DebugPrint("Route validation passed, spawning vehicles...")
    local startPos = route.start
    local heading = startPos.w or 0.0 -- Use the heading from vector4, fallback to 0.0
    DebugPrint("Using heading from route:", heading)
    
    -- Spawn evidence vehicle (main target)
    DebugPrint("Spawning evidence vehicle...")
    local evidenceVehicle = SpawnVehicle(Config.Vehicles.evidence_van.model, startPos, heading)
    if evidenceVehicle then
        DebugPrint("Evidence vehicle spawned successfully:", evidenceVehicle)
        table.insert(convoyVehicles, evidenceVehicle)
        
        -- Set vehicle properties (client-side only)
        SetVehicleEngineOn(evidenceVehicle, true, true, false)
        DebugPrint("Evidence vehicle properties set")
        
        -- Spawn escort vehicles
        DebugPrint("Spawning escort vehicles...")
        SpawnEscortVehicles(startPos, heading)
        
        -- Spawn escort peds
        DebugPrint("Spawning escort peds...")
        SpawnEscortPeds(evidenceVehicle)
        
        -- Start convoy movement
        DebugPrint("Starting convoy movement...")
        StartConvoyMovement(evidenceVehicle, route)
        
        -- Initialize AI for all escort peds
        DebugPrint("Initializing AI for escort peds...")
        for _, ped in ipairs(_G.escortPeds) do
            if DoesEntityExist(ped) then
                local success = pcall(function()
                    -- Call the local AI function directly
                    if escortAI and escortAI.InitializePed then
                        escortAI.InitializePed(ped, Config.Peds.escort_cop)
                    else
                        DebugPrint("Warning: escortAI.InitializePed not available")
                    end
                end)
                if not success then
                    DebugPrint("Warning: Failed to initialize AI for ped:", ped)
                    print("Warning: Failed to initialize AI for ped")
                else
                    DebugPrint("AI initialized successfully for ped:", ped)
                end
            end
        end
        
        -- Create enhanced convoy status system
        CreateConvoyStatusSystem()
        
        -- Set up enhanced ped task management
        DebugPrint("Setting up enhanced ped task management...")
        for i, ped in ipairs(_G.escortPeds) do
            if DoesEntityExist(ped) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                if vehicle and DoesEntityExist(vehicle) then
                    -- Set peds to drive their vehicles in convoy formation
                    ManagePedTasks(ped, vehicle, "drive")
                    DebugPrint("Ped", i, "set to drive mode")
                end
            end
        end
    else
        DebugPrint("Failed to spawn evidence vehicle")
    end
end

function SpawnEscortVehicles(startPos, heading)
    DebugPrint("SpawnEscortVehicles called, startPos:", startPos.x, startPos.y, startPos.z, "heading:", heading)
    
    -- Validate start position
    if not startPos or startPos.x == 0 and startPos.y == 0 and startPos.z == 0 then
        DebugPrint("ERROR: Invalid start position for escort vehicles")
        return
    end
    
    -- Calculate convoy formation - vehicles in a single file line behind the evidence vehicle
    local totalEscortVehicles = Config.Vehicles.escort_car.count + Config.Vehicles.escort_suv.count
    local spacing = Config.Vehicles.escort_car.spawn_offset -- Distance between vehicles
    
    DebugPrint("Convoy formation: Single file line, Total vehicles:", totalEscortVehicles, "Spacing:", spacing)
    
    -- Spawn escort cars in a line behind the evidence vehicle
    DebugPrint("Spawning escort cars in line...")
    for i = 1, Config.Vehicles.escort_car.count do
        -- Calculate position behind the evidence vehicle
        local offset = i * spacing
        local pos = vector3(startPos.x, startPos.y - offset, startPos.z)
        
        DebugPrint("Spawning escort car", i, "at position:", pos.x, pos.y, pos.z, "offset behind center:", offset)
        local vehicle = SpawnVehicle(Config.Vehicles.escort_car.model, pos, heading)
        if vehicle then
            DebugPrint("Escort car", i, "spawned successfully:", vehicle)
            table.insert(convoyVehicles, vehicle)
        else
            DebugPrint("Failed to spawn escort car", i)
        end
        
        -- Wait between vehicle spawns to prevent interference
        Citizen.Wait(100)
    end
    
    -- Spawn escort SUVs in line behind the escort cars
    DebugPrint("Spawning escort SUVs in line...")
    for i = 1, Config.Vehicles.escort_suv.count do
        -- Calculate position behind the escort cars
        local offset = (Config.Vehicles.escort_car.count + i) * spacing
        local pos = vector3(startPos.x, startPos.y - offset, startPos.z)
        
        DebugPrint("Spawning escort SUV", i, "at position:", pos.x, pos.y, pos.z, "offset behind center:", offset)
        local vehicle = SpawnVehicle(Config.Vehicles.escort_suv.model, pos, heading)
        if vehicle then
            DebugPrint("Escort SUV", i, "spawned successfully:", vehicle)
            table.insert(convoyVehicles, vehicle)
        else
            DebugPrint("Failed to spawn escort SUV", i)
        end
        
        -- Wait between vehicle spawns to prevent interference
        Citizen.Wait(100)
    end
    
    DebugPrint("Total escort vehicles spawned:", #convoyVehicles)
    DebugPrint("Total convoy vehicles (including evidence):", #convoyVehicles + 1) -- +1 for evidence vehicle
end

function SpawnEscortPeds(evidenceVehicle)
    DebugPrint("SpawnEscortPeds called, evidenceVehicle:", evidenceVehicle)
    DebugPrint("Current escortPeds count before spawning:", #_G.escortPeds)
    local pedCount = 0
    
    -- Clear existing escort peds table
    _G.escortPeds = {}
    
    -- Get all escort vehicles organized by type
    local escortVehiclesByType = {
        escort_car = {},
        escort_suv = {},
        evidence_van = {evidenceVehicle}
    }
    
    -- Debug: Show all vehicles and their models
    DebugPrint("Analyzing convoy vehicles for ped assignment...")
    for i, vehicle in ipairs(convoyVehicles) do
        if DoesEntityExist(vehicle) and vehicle ~= evidenceVehicle then
            local model = GetEntityModel(vehicle)
            local modelName = GetDisplayNameFromVehicleModel(model)
            local expectedCarHash = GetHashKey(Config.Vehicles.escort_car.model)
            local expectedSuvHash = GetHashKey(Config.Vehicles.escort_suv.model)
            
            DebugPrint("Vehicle " .. i .. ": Model=" .. modelName .. " (" .. model .. ")")
            DebugPrint("  Expected escort_car hash: " .. expectedCarHash)
            DebugPrint("  Expected escort_suv hash: " .. expectedSuvHash)
            DebugPrint("  Is escort_car: " .. tostring(model == expectedCarHash))
            DebugPrint("  Is escort_suv: " .. tostring(model == expectedSuvHash))
            
            if model == expectedCarHash then
                table.insert(escortVehiclesByType.escort_car, vehicle)
                DebugPrint("  -> Assigned to escort_car")
            elseif model == expectedSuvHash then
                table.insert(escortVehiclesByType.escort_suv, vehicle)
                DebugPrint("  -> Assigned to escort_suv")
            else
                DebugPrint("  -> UNKNOWN TYPE - not assigned to any category")
            end
        end
    end
    
    DebugPrint("Found vehicles by type:")
    DebugPrint("  Escort cars:", #escortVehiclesByType.escort_car)
    DebugPrint("  Escort SUVs:", #escortVehiclesByType.escort_suv)
    DebugPrint("  Evidence van:", #escortVehiclesByType.evidence_van)
    
    -- Spawn escort cops and assign to escort cars
    DebugPrint("Spawning escort cops...")
    DebugPrint("Available escort_car vehicles:", #escortVehiclesByType.escort_car)
    DebugPrint("Config escort_cop count:", Config.Peds.escort_cop.count)
    
    for i = 1, Config.Peds.escort_cop.count do
        local targetVehicle = escortVehiclesByType.escort_car[i]
        local isDriver = Config.Peds.escort_cop.seat_preference == "driver"
        
        DebugPrint("Attempting to spawn escort cop", i, "in vehicle:", targetVehicle, "isDriver:", isDriver)
        if targetVehicle and DoesEntityExist(targetVehicle) then
            local ped = SpawnEscortPed(Config.Peds.escort_cop, targetVehicle, isDriver)
            if ped then
                DebugPrint("Escort cop", i, "spawned successfully:", ped, "in vehicle:", targetVehicle)
                table.insert(_G.escortPeds, ped)
                pedCount = pedCount + 1
                DebugPrint("Ped added to global escortPeds table. New count:", #_G.escortPeds)
            else
                DebugPrint("Failed to spawn escort cop", i)
            end
        else
            DebugPrint("ERROR: Target vehicle for escort cop", i, "is invalid or doesn't exist")
        end
        
        -- Wait between spawning peds to prevent interference
        Citizen.Wait(200)
    end
    
    -- Spawn escort SWAT and assign to escort SUVs
    DebugPrint("Spawning escort SWAT...")
    DebugPrint("Available escort_suv vehicles:", #escortVehiclesByType.escort_suv)
    DebugPrint("Config escort_swat count:", Config.Peds.escort_swat.count)
    
    for i = 1, Config.Peds.escort_swat.count do
        local targetVehicle = escortVehiclesByType.escort_suv[i]
        local isDriver = Config.Peds.escort_swat.seat_preference == "driver"
        
        DebugPrint("Attempting to spawn escort SWAT", i, "in vehicle:", targetVehicle, "isDriver:", isDriver)
        if targetVehicle and DoesEntityExist(targetVehicle) then
            local ped = SpawnEscortPed(Config.Peds.escort_swat, targetVehicle, isDriver)
            if ped then
                DebugPrint("Escort SWAT", i, "spawned successfully:", ped, "in vehicle:", targetVehicle)
                table.insert(_G.escortPeds, ped)
                pedCount = pedCount + 1
                DebugPrint("Ped added to global escortPeds table. New count:", #_G.escortPeds)
            else
                DebugPrint("Failed to spawn escort SWAT", i)
            end
        else
            DebugPrint("ERROR: Target vehicle for escort SWAT", i, "is invalid or doesn't exist")
        end
        
        -- Wait between spawning peds to prevent interference
        Citizen.Wait(200)
    end
    
    -- Update server with ped count
    TriggerServerEvent('djonluc_evidence_event:updatePedCount', pedCount)
    
    DebugPrint("Total peds spawned:", pedCount)
    DebugPrint("Final escortPeds count:", #_G.escortPeds)
end

function SpawnEscortPed(pedConfig, vehicle, isDriver)
    DebugPrint("SpawnEscortPed called with config:", pedConfig.model, "vehicle:", vehicle, "isDriver:", isDriver)
    
    if not pedConfig or not pedConfig.model then
        DebugPrint("ERROR: Invalid ped config - missing model")
        return nil
    end
    
    if not vehicle or not DoesEntityExist(vehicle) then
        DebugPrint("ERROR: Invalid vehicle - does not exist")
        return nil
    end
    
    -- Get ped model hash
    local pedHash = GetHashKey(pedConfig.model)
    DebugPrint("Ped hash:", pedHash, "for model:", pedConfig.model)
    
    -- Request and load ped model with proper timeout (FiveM best practice)
    DebugPrint("Requesting ped model:", pedConfig.model)
    RequestModel(pedHash)
    
    local modelLoadStart = GetGameTimer()
    local modelLoaded = false
    
    while not HasModelLoaded(pedHash) and (GetGameTimer() - modelLoadStart) < 10000 do
        Citizen.Wait(0)  -- Use Wait(0) for proper model loading
    end
    
    modelLoaded = HasModelLoaded(pedHash)
    
    if not modelLoaded then
        DebugPrint("Failed to load ped model:", pedConfig.model)
        SetModelAsNoLongerNeeded(pedHash)
        return nil
    end
    
    DebugPrint("Ped model loaded successfully:", pedConfig.model)
    
    -- Get vehicle position for spawn
    local vehiclePos = GetEntityCoords(vehicle)
    local vehicleHeading = GetEntityHeading(vehicle)
    
    -- Use simpler spawn position - directly at vehicle with slight offset
    local spawnPos = vector3(
        vehiclePos.x,
        vehiclePos.y,
        vehiclePos.z + 2.0  -- 2 meters above vehicle
    )
    
    DebugPrint("Vehicle position:", vehiclePos.x, vehiclePos.y, vehiclePos.z, "Heading:", vehicleHeading)
    DebugPrint("Spawn position:", spawnPos.x, spawnPos.y, spawnPos.z)
    
    -- Create ped with proper parameters (FiveM best practice)
    -- pedType 4 = human, 26 = animal, 27 = unknown
    -- For police/security peds, use pedType 4 (human)
    local ped = CreatePed(4, pedHash, spawnPos.x, spawnPos.y, spawnPos.z, vehicleHeading, true, true)
    
    if not DoesEntityExist(ped) then
        DebugPrint("Failed to create ped entity")
        SetModelAsNoLongerNeeded(pedHash)
        return nil
    end
    
    DebugPrint("Ped created successfully:", ped)
    
    -- Essential ped setup (FiveM best practice)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedCanRagdoll(ped, false)
    SetPedCanBeTargetted(ped, true)
    SetPedCanBeDraggedOut(ped, false)
    SetPedCanRagdollFromPlayerWeapon(ped, false)
    
    -- Set ped properties
    SetPedMaxHealth(ped, pedConfig.health)
    SetEntityHealth(ped, pedConfig.health)
    SetPedArmour(ped, pedConfig.armor)
    
    -- Set ped invincible temporarily during setup
    SetEntityInvincible(ped, true)
    
    -- Give weapon to ped
    if pedConfig.weapon then
        local weaponHash = GetHashKey(pedConfig.weapon)
        DebugPrint("Weapon hash:", weaponHash, "for weapon:", pedConfig.weapon)
        
        GiveWeaponToPed(ped, weaponHash, 1000, false, true)
        SetPedCombatAbility(ped, 100)
        SetPedCombatRange(ped, 2)
        SetPedAccuracy(ped, 80)
    end
    
    -- Set behavior attributes
    if pedConfig.behavior == "aggressive" then
        SetPedCombatAttributes(ped, 46, true) -- Can use cover
        SetPedCombatAttributes(ped, 5, true)  -- Can fight armed peds
        SetPedCombatAttributes(ped, 17, true) -- Can use group tactics
        SetPedCombatAttributes(ped, 2, true)  -- Can use vehicles
    end
    
    -- Set ped to not flee
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 17, true)
    
    -- Wait for ped to fully spawn (FiveM best practice)
    Citizen.Wait(100)
    
    -- Place ped in vehicle
    local seatIndex = isDriver and -1 or 0  -- -1 = driver, 0 = front passenger
    
    DebugPrint("Placing ped in vehicle seat:", seatIndex, "isDriver:", isDriver)
    
    -- Try to place ped in vehicle (FiveM best practice)
    local success = false
    
    -- Method 1: TaskWarpPedIntoVehicle (preferred)
    TaskWarpPedIntoVehicle(ped, vehicle, seatIndex)
    Citizen.Wait(100)
    
    -- Check if ped is in vehicle
    if IsPedInVehicle(ped, vehicle, false) then
        success = true
        DebugPrint("Ped successfully placed in vehicle using TaskWarpPedIntoVehicle")
    else
        DebugPrint("TaskWarpPedIntoVehicle failed, trying SetPedIntoVehicle")
        
        -- Method 2: SetPedIntoVehicle (fallback)
        SetPedIntoVehicle(ped, vehicle, seatIndex)
        Citizen.Wait(100)
        
        if IsPedInVehicle(ped, vehicle, false) then
            success = true
            DebugPrint("Ped successfully placed in vehicle using SetPedIntoVehicle")
        else
            DebugPrint("Both methods failed to place ped in vehicle")
        end
    end
    
    if success then
        DebugPrint("Ped successfully placed in vehicle seat:", seatIndex)
        
        -- Wait for ped to settle in vehicle (FiveM best practice)
        Citizen.Wait(500)
        
        -- If this is a driver, make them drive to destination
        if isDriver and eventData and eventData.route then
            local destination = eventData.route.destruction
            DebugPrint("Setting driving task to destination:", destination.x, destination.y, destination.z)
            
            -- Set ped to drive to destination (FiveM best practice)
            local speed = Config.ConvoyMovement.speed or 20.0
            TaskVehicleDriveToCoord(ped, vehicle, destination.x, destination.y, destination.z, speed, 0, GetEntityModel(vehicle), 786603, 5.0, 1.0)
            
            -- Set driving attributes (FiveM best practice)
            SetDriverAbility(ped, 1.0)
            SetDriverAggressiveness(ped, 0.5)
            
            DebugPrint("Driver ped configured to drive to destination with speed:", speed)
        end
    else
        DebugPrint("Warning: Failed to place ped in vehicle")
    end
    
    -- Remove invincibility after setup
    SetEntityInvincible(ped, false)
    
    -- Initialize AI for the ped
    if escortAI and escortAI.InitializePed then
        local aiSuccess = pcall(function()
            escortAI.InitializePed(ped, pedConfig)
        end)
        if aiSuccess then
            DebugPrint("AI initialized successfully for ped:", ped)
        else
            DebugPrint("Warning: Failed to initialize AI for ped:", ped)
        end
    else
        DebugPrint("Warning: escortAI.InitializePed not available")
    end
    
    -- Monitor ped health
    Citizen.CreateThread(function()
        MonitorPedHealth(ped)
    end)
    
    -- Monitor vehicle movement for stuck vehicles
    if isDriver then
        Citizen.CreateThread(function()
            MonitorVehicleMovement(ped, vehicle, eventData.route.destruction)
        end)
    end
    
    -- Clean up model (FiveM best practice)
    SetModelAsNoLongerNeeded(pedHash)
    
    return ped
end

-- Monitor vehicle movement to prevent stuck vehicles
function MonitorVehicleMovement(ped, vehicle, destination)
    local lastPosition = GetEntityCoords(vehicle)
    local stuckCounter = 0
    
    while DoesEntityExist(ped) and DoesEntityExist(vehicle) and eventActive do
        Citizen.Wait(5000) -- Check every 5 seconds
        
        local currentPosition = GetEntityCoords(vehicle)
        local distanceMoved = #(currentPosition - lastPosition)
        
        -- If vehicle hasn't moved much, it might be stuck
        if distanceMoved < 2.0 then
            stuckCounter = stuckCounter + 1
            DebugPrint("Vehicle potentially stuck, counter:", stuckCounter)
            
            if stuckCounter >= 3 then -- Stuck for 15 seconds
                DebugPrint("Vehicle confirmed stuck, attempting to unstuck")
                
                -- Try to unstuck by giving new driving task
                local speed = Config.ConvoyMovement.speed or 20.0
                TaskVehicleDriveToCoordLongrange(vehicle, destination.x, destination.y, destination.z, speed, 786603, 5.0)
                
                -- Reset stuck counter
                stuckCounter = 0
            end
        else
            -- Vehicle is moving, reset stuck counter
            stuckCounter = 0
        end
        
        lastPosition = currentPosition
    end
end

function MonitorPedHealth(ped)
    while DoesEntityExist(ped) and eventActive do
        Citizen.Wait(1000)
        
        if IsEntityDead(ped) then
            TriggerServerEvent('djonluc_evidence_event:escortPedDied', ped)
            break
        end
    end
end

function StartConvoyMovement(evidenceVehicle, route)
    Citizen.CreateThread(function()
        local destination = route.destruction
        DebugPrint("Starting convoy movement to destination:", destination.x, destination.y, destination.z)
        
        while DoesEntityExist(evidenceVehicle) and eventActive do
            local currentPos = GetEntityCoords(evidenceVehicle)
            local targetPos = destination
            
            -- Check if reached destination (more lenient check)
            local distanceToDestination = Utils.GetDistance(currentPos, targetPos)
            if distanceToDestination < 15.0 then
                -- Reached destination
                DebugPrint("Convoy reached destination! Distance:", distanceToDestination)
                TriggerServerEvent('djonluc_evidence_event:convoyReachedDestination')
                break
            end
            
            DebugPrint("Convoy moving to destination. Distance remaining:", distanceToDestination)
            
            -- Move evidence vehicle directly to destination with configurable speed
            local speed = Config.ConvoyMovement.speed or 20.0
            TaskVehicleDriveToCoordLongrange(evidenceVehicle, targetPos.x, targetPos.y, targetPos.z, speed, 786603, 5.0)
            
            -- Move escort vehicles to follow the evidence vehicle to destination
            if Config.ConvoyMovement.formation_maintenance then
                local followDistance = Config.ConvoyMovement.follow_distance or 8.0
                local maxDeviation = Config.ConvoyMovement.max_deviation or 15.0
                
                for _, vehicle in ipairs(convoyVehicles) do
                    if vehicle ~= evidenceVehicle and DoesEntityExist(vehicle) then
                        -- Calculate formation position relative to evidence vehicle
                        local offset = GetOffsetFromEntityInWorldCoords(evidenceVehicle, 
                            math.random(-followDistance, followDistance), 
                            math.random(-followDistance, followDistance), 0)
                        
                        -- Ensure escort vehicles don't deviate too far from evidence vehicle
                        local vehiclePos = GetEntityCoords(vehicle)
                        local distanceFromEvidence = #(vehiclePos - currentPos)
                        
                        if distanceFromEvidence > maxDeviation then
                            -- Bring vehicle back to formation near evidence vehicle
                            local formationPos = GetOffsetFromEntityInWorldCoords(evidenceVehicle, 
                                math.random(-followDistance, followDistance), 
                                math.random(-followDistance, followDistance), 0)
                            TaskVehicleDriveToCoordLongrange(vehicle, formationPos.x, formationPos.y, formationPos.z, speed + 5.0, 786603, 5.0)
                            DebugPrint("Escort vehicle returning to formation")
                        else
                            -- Normal formation following - escort vehicles follow evidence vehicle
                            TaskVehicleDriveToCoordLongrange(vehicle, offset.x, offset.y, offset.z, speed, 786603, 5.0)
                        end
                    end
                end
            else
                -- Simple following - all vehicles move toward destination
                for _, vehicle in ipairs(convoyVehicles) do
                    if vehicle ~= evidenceVehicle and DoesEntityExist(vehicle) then
                        -- Escort vehicles follow evidence vehicle but also move toward destination
                        local offset = GetOffsetFromEntityInWorldCoords(evidenceVehicle, math.random(-8, 8), math.random(-8, 8), 0)
                        TaskVehicleDriveToCoordLongrange(vehicle, offset.x, offset.y, offset.z, speed + 5.0, 786603, 5.0)
                    end
                end
            end
            
            Citizen.Wait(3000) -- Update every 3 seconds for more responsive movement
        end
    end)
    
    -- Start a separate thread to ensure all vehicles keep moving toward destination
    Citizen.CreateThread(function()
        while DoesEntityExist(evidenceVehicle) and eventActive do
            Citizen.Wait(10000) -- Check every 10 seconds
            
            -- Ensure evidence vehicle is still moving to destination
            if DoesEntityExist(evidenceVehicle) then
                local currentPos = GetEntityCoords(evidenceVehicle)
                local distanceToDestination = Utils.GetDistance(currentPos, destination)
                
                if distanceToDestination > 20.0 then -- If still far from destination
                    local speed = Config.ConvoyMovement.speed or 20.0
                    TaskVehicleDriveToCoordLongrange(evidenceVehicle, destination.x, destination.y, destination.z, speed, 786603, 5.0)
                    DebugPrint("Reinforcing evidence vehicle movement to destination")
                end
            end
            
            -- Ensure escort vehicles are following
            for _, vehicle in ipairs(convoyVehicles) do
                if vehicle ~= evidenceVehicle and DoesEntityExist(vehicle) then
                    local vehiclePos = GetEntityCoords(vehicle)
                    local evidencePos = GetEntityCoords(evidenceVehicle)
                    local distanceFromEvidence = #(vehiclePos - evidencePos)
                    
                    if distanceFromEvidence > 25.0 then -- If escort vehicle is too far
                        local speed = Config.ConvoyMovement.speed or 20.0
                        local offset = GetOffsetFromEntityInWorldCoords(evidenceVehicle, math.random(-8, 8), math.random(-8, 8), 0)
                        TaskVehicleDriveToCoordLongrange(vehicle, offset.x, offset.y, offset.z, speed, 786603, 5.0)
                        DebugPrint("Reinforcing escort vehicle movement to follow evidence vehicle")
                    end
                end
            end
        end
    end)
end

-- Vehicle Trunk Loot System (replaces loot crate)
local vehicleTrunkItems = {} -- Track items in vehicle trunk
local droppedItems = {} -- Track dropped items in the world

-- Add items to vehicle trunk
RegisterNetEvent('djonluc_evidence_event:addItemToVehicleTrunk')
AddEventHandler('djonluc_evidence_event:addItemToVehicleTrunk', function(vehicleNetId, itemName, count)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    
    -- Store items in vehicle trunk
    if not vehicleTrunkItems[vehicleNetId] then
        vehicleTrunkItems[vehicleNetId] = {}
    end
    
    vehicleTrunkItems[vehicleNetId][itemName] = (vehicleTrunkItems[vehicleNetId][itemName] or 0) + count
    
    DebugPrint("Added " .. count .. "x " .. itemName .. " to vehicle trunk:", vehicleNetId)
    
    -- Show notification to nearby players
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicleCoords = GetEntityCoords(vehicle)
    local distance = #(playerCoords - vehicleCoords)
    
    if distance < 50.0 then
        TriggerEvent('djonluc_evidence_event:showNotification', '🎒 Evidence vehicle trunk loaded with ' .. count .. 'x ' .. itemName, 'inform')
    end
end)

-- Spawn dropped items in the world
RegisterNetEvent('djonluc_evidence_event:spawnDroppedItem')
AddEventHandler('djonluc_evidence_event:spawnDroppedItem', function(position, itemName, count)
    DebugPrint("Spawning dropped item:", itemName, "x", count, "at", position.x, position.y, position.z)
    
    -- Create a simple object to represent the dropped item
    local itemHash = GetHashKey("prop_money_bag_01") -- Use money bag as default
    
    -- Use different props for different item types
    if itemName:find("weapon") then
        itemHash = GetHashKey("prop_box_wood02a")
    elseif itemName:find("cash") then
        itemHash = GetHashKey("prop_money_bag_01")
    elseif itemName:find("cocaine") or itemName:find("meth") or itemName:find("weed") then
        itemHash = GetHashKey("prop_drug_package")
    elseif itemName:find("gold") then
        itemHash = GetHashKey("prop_gold_bar")
    end
    
    -- Request and load the model
    RequestModel(itemHash)
    while not HasModelLoaded(itemHash) do
        Citizen.Wait(1)
    end
    
    -- Create the item object
    local itemObject = CreateObject(itemHash, position.x, position.y, position.z, true, true, true)
    
    if DoesEntityExist(itemObject) then
        SetEntityAsMissionEntity(itemObject, true, true)
        PlaceObjectOnGroundProperly(itemObject)
        
        -- Store dropped item info
        local itemId = #droppedItems + 1
        droppedItems[itemId] = {
            object = itemObject,
            name = itemName,
            count = count,
            position = position,
            spawnTime = GetGameTimer()
        }
        
        DebugPrint("Dropped item spawned successfully:", itemId, itemName, count)
        
        -- Add interaction zone for the dropped item
        Citizen.CreateThread(function()
            while DoesEntityExist(itemObject) and droppedItems[itemId] do
                Citizen.Wait(0)
                
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local itemCoords = GetEntityCoords(itemObject)
                local distance = #(playerCoords - itemCoords)
                
                if distance < 2.0 then
                    -- Show 3D text
                    local textPos = itemCoords + vector3(0.0, 0.0, 1.0)
                    DrawText3D(textPos.x, textPos.y, textPos.z, "Press ~y~E~w~ to loot " .. itemName .. " (x" .. count .. ")")
                    
                    -- Check for interaction
                    if IsControlJustPressed(0, 38) then -- E key
                        LootDroppedItem(itemId)
                        break
                    end
                end
                
                -- Remove item after 5 minutes if not looted
                if GetGameTimer() - droppedItems[itemId].spawnTime > 300000 then -- 5 minutes
                    if DoesEntityExist(itemObject) then
                        DeleteEntity(itemObject)
                    end
                    droppedItems[itemId] = nil
                    break
                end
            end
        end)
    end
end)

-- Function to loot dropped items
function LootDroppedItem(itemId)
    local item = droppedItems[itemId]
    if not item then return end
    
    DebugPrint("Looting dropped item:", item.name, "x", item.count)
    
    -- Show notification
    TriggerEvent('djonluc_evidence_event:showNotification', '💎 Looted ' .. item.count .. 'x ' .. item.name .. '!', 'success')
    
    -- Remove the item object
    if DoesEntityExist(item.object) then
        DeleteEntity(item.object)
    end
    
    -- Remove from dropped items list
    droppedItems[itemId] = nil
    
    -- Here you would integrate with your inventory system
    -- For example: TriggerServerEvent('inventory:addItem', item.name, item.count)
    print("^3[Djonluc Evidence Event]^7 💎 Player looted " .. item.count .. "x " .. item.name)
end

-- Function to access vehicle trunk
function AccessVehicleTrunk(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    
    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
    local trunkItems = vehicleTrunkItems[vehicleNetId]
    
    if not trunkItems or next(trunkItems) == nil then
        TriggerEvent('djonluc_evidence_event:showNotification', '🚗 Vehicle trunk is empty', 'inform')
        return
    end
    
    DebugPrint("Accessing vehicle trunk, items found:", #trunkItems)
    
    -- Show trunk contents
    local itemList = "Vehicle Trunk Contents:\n"
    for itemName, count in pairs(trunkItems) do
        itemList = itemList .. "• " .. itemName .. " x" .. count .. "\n"
    end
    
    -- Here you would show a proper inventory interface
    -- For now, just show a notification
    TriggerEvent('djonluc_evidence_event:showNotification', '🚗 Vehicle trunk accessed - ' .. itemList, 'inform')
    
    -- Here you would integrate with your inventory system to transfer items
    -- For example: TriggerServerEvent('inventory:transferFromVehicle', vehicleNetId, itemName, count)
end

-- Command to access vehicle trunk
RegisterCommand('access_trunk', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Find nearby evidence vehicle
    for _, vehicle in ipairs(convoyVehicles) do
        if DoesEntityExist(vehicle) then
            local model = GetEntityModel(vehicle)
            if model == GetHashKey(Config.Vehicles.evidence_van.model) then
                local vehicleCoords = GetEntityCoords(vehicle)
                local distance = #(playerCoords - vehicleCoords)
                
                if distance < 3.0 then
                    AccessVehicleTrunk(vehicle)
                    return
                end
            end
        end
    end
    
    TriggerEvent('djonluc_evidence_event:showNotification', '🚗 No evidence vehicle nearby', 'error')
end, false)

-- Cleanup convoy
RegisterNetEvent('djonluc_evidence_event:cleanupConvoy')
AddEventHandler('djonluc_evidence_event:cleanupConvoy', function()
    DebugPrint("cleanupConvoy event received")
    eventActive = false
    DebugPrint("Event marked as inactive")
    
    -- Remove vehicles
    DebugPrint("Cleaning up", #convoyVehicles, "convoy vehicles")
    for i, vehicle in ipairs(convoyVehicles) do
        if DoesEntityExist(vehicle) then
            DebugPrint("Deleting convoy vehicle", i, ":", vehicle)
            DeleteEntity(vehicle)
        else
            DebugPrint("Vehicle", i, "does not exist, skipping deletion")
        end
    end
    convoyVehicles = {}
    DebugPrint("All convoy vehicles cleaned up")
    
    -- Remove peds
    DebugPrint("Cleaning up", #escortPeds, "escort peds")
    for i, ped in ipairs(escortPeds) do
        if DoesEntityExist(ped) then
            DebugPrint("Deleting escort ped", i, ":", ped)
            DeleteEntity(ped)
        else
            DebugPrint("Ped", i, "does not exist, skipping deletion")
        end
    end
    -- Clear the global escortPeds table properly
    for i = #_G.escortPeds, 1, -1 do
        _G.escortPeds[i] = nil
    end
    DebugPrint("All escort peds cleaned up")
    
    -- Clean up dropped items
    DebugPrint("Cleaning up", #droppedItems, "dropped items")
    for itemId, item in pairs(droppedItems) do
        if DoesEntityExist(item.object) then
            DebugPrint("Deleting dropped item", itemId, ":", item.name)
            DeleteEntity(item.object)
        end
    end
    droppedItems = {}
    DebugPrint("All dropped items cleaned up")
    
    -- Clear vehicle trunk items
    vehicleTrunkItems = {}
    DebugPrint("Vehicle trunk items cleared")
    
    -- Remove convoy blip using enhanced cleanup
    CleanupConvoyBlips()
end)

-- Handle convoy destruction
Citizen.CreateThread(function()
    DebugPrint("Starting convoy destruction monitoring thread")
    while true do
        Citizen.Wait(5000) -- Check every 5 seconds
        
        if eventActive and #convoyVehicles > 0 then
            local allVehiclesDestroyed = true
            local destroyedCount = 0
            
            for i, vehicle in ipairs(convoyVehicles) do
                if DoesEntityExist(vehicle) and not IsEntityDead(vehicle) then
                    allVehiclesDestroyed = false
                else
                    destroyedCount = destroyedCount + 1
                end
            end
            
            if destroyedCount > 0 then
                DebugPrint("Convoy status: ", destroyedCount, "/", #convoyVehicles, "vehicles destroyed")
            end
            
            if allVehiclesDestroyed then
                DebugPrint("All convoy vehicles destroyed, triggering event failure")
                TriggerServerEvent('djonluc_evidence_event:convoyDestroyed')
                break
            end
        end
    end
end)

-- Blip update thread
Citizen.CreateThread(function()
    DebugPrint("Starting convoy blip update thread")
    while true do
        Citizen.Wait(1000) -- Update every second
        
        if eventActive and convoyBlip then
            UpdateConvoyBlip()
            UpdateConvoyStatus() -- Update convoy status indicators
            
            -- Add distance indicator to blip name
            if convoyBlip and IsBlipVisible(convoyBlip) then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                
                -- Find convoy position
                local convoyCoords = nil
                for _, vehicle in ipairs(convoyVehicles) do
                    if DoesEntityExist(vehicle) then
                        local model = GetEntityModel(vehicle)
                        if model == GetHashKey("stockade") then
                            convoyCoords = GetEntityCoords(vehicle)
                            break
                        end
                    end
                end
                
                if convoyCoords then
                    local distance = #(playerCoords - convoyCoords)
                    local distanceText = string.format("Evidence Convoy (%.0fm)", distance)
                    
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(distanceText)
                    EndTextCommandSetBlipName(convoyBlip)
                end
            end
        end
    end
end)

-- Utility functions
function SpawnVehicle(model, position, heading)
    DebugPrint("SpawnVehicle called - Model:", model, "Position:", position.x, position.y, position.z, "Heading:", heading)
    
    if not model or not position then
        DebugPrint("ERROR: Invalid parameters for SpawnVehicle")
        return nil
    end
    
    -- Use GetHashKey directly instead of Utils.GetVehicleHash
    local vehicleHash = GetHashKey(model)
    DebugPrint("Vehicle hash:", vehicleHash)
    
    -- Request model with proper timeout (FiveM best practice)
    RequestModel(vehicleHash)
    local modelLoadStart = GetGameTimer()
    local modelLoaded = false
    
    while not HasModelLoaded(vehicleHash) and (GetGameTimer() - modelLoadStart) < 10000 do
        Citizen.Wait(0)  -- Use Wait(0) for proper model loading
    end
    
    modelLoaded = HasModelLoaded(vehicleHash)
    
    if modelLoaded then
        DebugPrint("Model loaded successfully, creating vehicle...")
        
        -- Check if position is valid
        if position.x == 0 and position.y == 0 and position.z == 0 then
            DebugPrint("ERROR: Invalid spawn position (0,0,0)")
            SetModelAsNoLongerNeeded(vehicleHash)
            return nil
        end
        
        -- Create vehicle with proper parameters (FiveM best practice)
        local vehicle = CreateVehicle(vehicleHash, position.x, position.y, position.z, heading, true, true)
        
        if DoesEntityExist(vehicle) then
            DebugPrint("Vehicle created successfully:", vehicle)
            
            -- Essential vehicle setup (FiveM best practice)
            SetEntityAsMissionEntity(vehicle, true, true)
            SetVehicleDoorsLocked(vehicle, 2)
            SetVehicleEngineOn(vehicle, true, true, false)
            
            -- Set vehicle properties based on config
            if model == "police" then
                -- Escort car modifications
                SetVehicleDoorsLocked(vehicle, 2)
                SetVehicleEngineHealth(vehicle, 1000.0)
                SetVehicleBodyHealth(vehicle, 1000.0)
                DebugPrint("Escort car modified - Doors locked, Health set")
            elseif model == "fbi2" then
                -- Escort SUV modifications
                SetVehicleDoorsLocked(vehicle, 2)
                SetVehicleEngineHealth(vehicle, 1000.0)
                SetVehicleBodyHealth(vehicle, 1000.0)
                DebugPrint("Escort SUV modified - Doors locked, Health set")
            elseif model == "stockade" then
                -- Evidence van modifications
                SetVehicleDoorsLocked(vehicle, 2)
                SetVehicleEngineHealth(vehicle, 2000.0)
                SetVehicleBodyHealth(vehicle, 2000.0)
                DebugPrint("Evidence van modified - Doors locked, Health set")
            end
            
            -- Clean up model (FiveM best practice)
            SetModelAsNoLongerNeeded(vehicleHash)
            
            return vehicle
        else
            DebugPrint("Failed to create vehicle entity")
        end
    else
        DebugPrint("Failed to load model:", model)
    end
    
    -- Clean up model if loading failed (FiveM best practice)
    SetModelAsNoLongerNeeded(vehicleHash)
    return nil
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    
    if onScreen then
        local px, py, pz = table.unpack(GetGameplayCamCoords())
        
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
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

-- QBCore notification wrapper for client-side
function Utils.QBCoreNotifyClient(message, type, duration)
    if Utils.Framework.name == "qbcore" or Utils.Framework.name == "qbox" then
        -- Latest QBCore notification method with proper parameters
        TriggerEvent('QBCore:Notify', message, type or 'primary', duration or 5000)
        return true
    end
    return false
end

-- QBCore progress bar wrapper for client-side
function Utils.QBCoreProgressBarClient(duration, label, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if Utils.Framework.name == "qbcore" or Utils.Framework.name == "qbox" then
        -- Check if QBCore progress bar is available
        local success = pcall(function()
            TriggerEvent('QBCore:Progressbar', duration, label, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
        end)
        return success
    end
    return false
end

-- QBCore target system wrapper for client-side
function Utils.QBCoreAddTargetEntityClient(entity, options)
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

-- QBCore menu system wrapper for client-side
function Utils.QBCoreShowMenuClient(menuData)
    if Utils.Framework.name == "qbcore" or Utils.Framework.name == "qbox" then
        -- Check if qb-menu is available
        if Utils.OptionalDeps.qb_menu then
            local success = pcall(function()
                TriggerEvent('qb-menu:client:openMenu', menuData)
            end)
            return success
        end
    end
    return false
end

-- Enhanced blip cleanup function
local function CleanupConvoyBlips()
    -- Remove main convoy blip
    if convoyBlip and DoesBlipExist(convoyBlip) then
        RemoveBlip(convoyBlip)
        convoyBlip = nil
        DebugPrint("Main convoy blip removed")
    end
    
    -- Remove destination blip
    if destinationBlip and DoesBlipExist(destinationBlip) then
        RemoveBlip(destinationBlip)
        destinationBlip = nil
        DebugPrint("Destination blip removed")
    end
    
    -- Remove all vehicle blips
    for _, blip in pairs(convoyBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
            DebugPrint("Vehicle blip removed:", blip)
        end
    end
    convoyBlips = {}
    
    DebugPrint("All convoy blips cleaned up")
end

-- Enhanced ped task management for better convoy behavior
local function ManagePedTasks(ped, vehicle, taskType)
    if not DoesEntityExist(ped) or not DoesEntityExist(vehicle) then
        return false
    end
    
    -- Clear any existing tasks immediately for instant response
    ClearPedTasksImmediately(ped)
    Citizen.Wait(100) -- Brief pause for task clearing
    
    if taskType == "drive" then
        -- Set ped to drive vehicle to destination
        if eventData and eventData.route and eventData.route.destruction then
            local destination = eventData.route.destruction
            local speed = Config.ConvoyMovement.speed or 20.0
            
            -- Use long-range driving for better convoy movement
            TaskVehicleDriveToCoordLongrange(ped, vehicle, destination.x, destination.y, destination.z, speed, 786603, 5.0)
            
            -- Set driving attributes for convoy behavior
            SetDriverAbility(ped, 1.0)
            SetDriverAggressiveness(ped, 0.3) -- Lower aggression for convoy driving
            
            DebugPrint("Ped set to drive vehicle to destination with speed:", speed)
            return true
        end
    elseif taskType == "follow" then
        -- Set ped to follow the evidence vehicle
        if #convoyVehicles > 0 then
            local evidenceVehicle = convoyVehicles[1]
            if DoesEntityExist(evidenceVehicle) then
                -- Use vehicle following behavior
                TaskVehicleFollow(ped, vehicle, evidenceVehicle, 20.0, 1, 5.0)
                
                DebugPrint("Ped set to follow evidence vehicle")
                return true
            end
        end
    elseif taskType == "escort" then
        -- Set ped to escort behavior (patrol around vehicle)
        local vehiclePos = GetEntityCoords(vehicle)
        local patrolRadius = 10.0
        
        -- Create patrol points around the vehicle
        local patrolPoints = {
            vector3(vehiclePos.x + patrolRadius, vehiclePos.y, vehiclePos.z),
            vector3(vehiclePos.x - patrolRadius, vehiclePos.y, vehiclePos.z),
            vector3(vehiclePos.x, vehiclePos.y + patrolRadius, vehiclePos.z),
            vector3(vehiclePos.x, vehiclePos.y - patrolRadius, vehiclePos.z)
        }
        
        -- Set ped to patrol between points
        TaskGoToCoordAnyMeans(ped, patrolPoints[1].x, patrolPoints[1].y, patrolPoints[1].z, 2.0, 0, false, 786603, 0)
        
        DebugPrint("Ped set to escort patrol mode")
        return true
    end
    
    return false
end

-- Professional convoy status and route visualization
local function CreateConvoyStatusSystem()
    -- Create convoy status indicator
    if not convoyBlips.statusIndicator then
        convoyBlips.statusIndicator = AddBlipForCoord(0, 0, 0)
        SetBlipSprite(convoyBlips.statusIndicator, 84) -- Checkered flag sprite
        SetBlipDisplay(convoyBlips.statusIndicator, 4)
        SetBlipScale(convoyBlips.statusIndicator, 0.6)
        SetBlipColour(convoyBlips.statusIndicator, 2) -- Green for active
        SetBlipAsShortRange(convoyBlips.statusIndicator, false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Convoy Status: ACTIVE")
        EndTextCommandSetBlipName(convoyBlips.statusIndicator)
        
        DebugPrint("Convoy status indicator created")
    end
    
    -- Create route progress indicator
    if eventData and eventData.route and eventData.route.start and eventData.route.destruction then
        local startPos = eventData.route.start
        local endPos = eventData.route.destruction
        
        -- Calculate route midpoint for progress indicator
        local midX = (startPos.x + endPos.x) / 2
        local midY = (startPos.y + endPos.y) / 2
        local midZ = (startPos.z + endPos.z) / 2
        
        if not convoyBlips.routeProgress then
            convoyBlips.routeProgress = AddBlipForCoord(midX, midY, midZ)
            SetBlipSprite(convoyBlips.routeProgress, 162) -- Route sprite
            SetBlipDisplay(convoyBlips.routeProgress, 4)
            SetBlipScale(convoyBlips.routeProgress, 0.5)
            SetBlipColour(convoyBlips.routeProgress, 5) -- Yellow for route
            SetBlipAsShortRange(convoyBlips.routeProgress, false)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Route Progress")
            EndTextCommandSetBlipName(convoyBlips.routeProgress)
            
            DebugPrint("Route progress indicator created")
        end
    end
end

-- Update convoy status based on current conditions
local function UpdateConvoyStatus()
    if not convoyBlips.statusIndicator or not eventActive then
        return
    end
    
    local status = "ACTIVE"
    local statusColor = 2 -- Green
    local isUnderAttack = false
    
    -- Check convoy health status
    for _, vehicle in ipairs(convoyVehicles) do
        if DoesEntityExist(vehicle) then
            local engineHealth = GetVehicleEngineHealth(vehicle)
            local bodyHealth = GetVehicleBodyHealth(vehicle)
            
            if engineHealth < 500 or bodyHealth < 500 then
                isUnderAttack = true
                break
            end
        end
    end
    
    -- Check if any escort peds are dead
    for _, ped in ipairs(_G.escortPeds) do
        if DoesEntityExist(ped) and IsEntityDead(ped) then
            isUnderAttack = true
            break
        end
    end
    
    -- Update status based on conditions
    if isUnderAttack then
        status = "UNDER ATTACK"
        statusColor = 1 -- Red
        -- Flash the status blip
        SetBlipFlashes(convoyBlips.statusIndicator, true)
    else
        status = "ACTIVE"
        statusColor = 2 -- Green
        SetBlipFlashes(convoyBlips.statusIndicator, false)
    end
    
    -- Update status blip
    SetBlipColour(convoyBlips.statusIndicator, statusColor)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Convoy Status: " .. status)
    EndTextCommandSetBlipName(convoyBlips.statusIndicator)
    
    DebugPrint("Convoy status updated:", status)
end

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
