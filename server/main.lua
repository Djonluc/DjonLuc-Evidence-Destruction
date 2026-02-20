-- server/main.lua
print("^2[CONVOY] server/main.lua loaded successfully.^7")

local function DebugLog(type, message)
    if not Config.Debug.Enabled then return end
    print("^3[CONVOY "..type.."]^7 "..message)
end

local function ErrorLog(message)
    print("^1[CONVOY ERROR]^7 "..message)
end

local function ValidateConfig()
    if Config.Route.Start == vector4(0.0,0.0,0.0,0.0) then
        ErrorLog("StartCoords not set.")
        return false
    end

    if Config.Route.Destination == vector4(0.0,0.0,0.0,0.0) then
        ErrorLog("Destination not set.")
        return false
    end

    DebugLog("INFO", "Config validated successfully.")
    return true
end

function CheckClientNatives()
    -- Audit: Ensure no client-only natives like TaskCombatPed exist here.
end

local cooldownActive = false
HostileList = {} -- Global for cleanup visibility

-- Helper to start cooldown
local function StartCooldown()
    cooldownActive = true
    Convoy.lastEvent = os.time()
    SetTimeout(Config.Event.Cooldown * 1000, function()
        cooldownActive = false
    end)
end

-- Driving Style Synchronization (Delegated to Client)
function SyncConvoyTasks()
    if not Convoy.active or not Convoy.van then return end
    
    local vanNetId = NetworkGetNetworkIdFromEntity(Convoy.van)
    local escortNetIds = {}
    local leaderNetId = vanNetId -- Default to van
    
    -- If we have escorts, the first one (Bikes or Patrol) should lead the physical movement
    if #Convoy.escorts > 0 then
        leaderNetId = NetworkGetNetworkIdFromEntity(Convoy.escorts[1])
    end

    for _, escort in ipairs(Convoy.escorts) do
        table.insert(escortNetIds, NetworkGetNetworkIdFromEntity(escort))
    end

    TriggerClientEvent("djonluc:client:syncConvoyTasks", -1, {
        vanNetId = vanNetId,
        leaderNetId = leaderNetId,
        escortNetIds = escortNetIds,
        state = Convoy.state,
        dest = Config.Route.Destination,
        speed = Config.Route.DriveSpeed or 20.0,
        style = Config.Route.DrivingStyle or 786603
    })
    
    DebugLog("INFO", "Syncing convoy tasks to clients (State: " .. Convoy.state .. ")")
end

-- Movement Logic
function StartConvoyMovement()
    Convoy.state = "CALM"
    SyncConvoyTasks()
end


-- Monitor Thread
CreateThread(function()
    while true do
        Wait(2000)

        if Convoy.active and Convoy.van then
            if DoesEntityExist(Convoy.van) then
                local health = GetEntityHealth(Convoy.van)
                local maxHealth = Config.Formation.Van.health
                Convoy.health = health

                -- State Machine logic
                local newState = "CALM"
                local hostileCount = 0
                for _ in pairs(HostileList) do hostileCount = hostileCount + 1 end

                if hostileCount > 0 or health < (maxHealth * 0.9) then
                    newState = "ALERT"
                end

                if hostileCount >= 3 or health < (maxHealth * 0.5) then
                    newState = "DEFENSIVE"
                end

                if newState ~= Convoy.state then
                    Convoy.state = newState
                    SyncConvoyTasks()
                    
                    if Convoy.state == "ALERT" and not Convoy.underAttack then
                        Convoy.underAttack = true
                        Framework.Notify(-1, "The evidence convoy is on high alert!", "error")
                    elseif Convoy.state == "DEFENSIVE" then
                        Framework.Notify(-1, "The evidence convoy has engaged maximum defensive protocols!", "error")
                    end
                end

                if health <= 0 and not Convoy.destroyed then
                    Convoy.destroyed = true
                    Convoy.active = false
                    Convoy.state = "CALM"
                    TriggerClientEvent("djonluc:client:vanDestroyed", -1)
                    TriggerClientEvent("djonluc:client:updateConvoyState", -1, "CALM")
                    Framework.Notify(-1, "The evidence van has been destroyed! Loot it now!", "success")

                    StartCooldown()
                end
            else
                if Convoy.active then
                    CleanupConvoy()
                end
            end
        end
    end
end)


-- Success and Timeout check
CreateThread(function()
    while true do
        Wait(5000)
        if Convoy.active and Convoy.van then
            local vanCoords = GetEntityCoords(Convoy.van)
            local dest = Config.Route.Destination
            
            if #(vanCoords - vector3(dest.x, dest.y, dest.z)) < 20.0 then
                Framework.Notify(-1, "The evidence has been successfully secured.", "success")
                CleanupConvoy()
                StartCooldown()
            end
            
            if os.time() - Convoy.startedAt > Config.Event.Timeout then
                CleanupConvoy()
                StartCooldown()
            end
        end
    end
end)

RegisterCommand("convoystart", function(source)
    local src = source
    DebugLog("INFO", "Command '/convoystart' triggered by " .. src)

    local success, err = pcall(function()
        if Convoy.active then
            ErrorLog("Convoy already active.")
            return
        end

        if not ValidateConfig() then
            ErrorLog("Convoy start failed due to config issues.")
            return
        end

        if cooldownActive and src ~= 0 then
            ErrorLog("Event is on cooldown.")
            return
        end

        -- Authorization check
        local job = Framework.GetJob(src)
        local allowed = (src == 0) or Config.Debug.Enabled -- Allow console or anyone in debug mode
        if not allowed then
            for j, _ in pairs(Config.LawProtection.Jobs) do
                if j == job then allowed = true break end
            end
        end

        if not allowed then
            ErrorLog("Unauthorized attempt to start convoy by player " .. src .. ". Ensure you have a law enforcement job or enable Config.Debug.")
            return
        end

        DebugLog("INFO", "Spawning convoy entities...")
        if SpawnFullConvoy() then
            Convoy.active = true
            Convoy.startedAt = os.time()
            Convoy.health = Config.Formation.Van.health
            Convoy.destroyed = false
            Convoy.underAttack = false
            
            Wait(100) -- Small delay for net-sync
            
            -- Wait for formation to settle
            local delay = (Config.Event.StartDelay or 3) * 1000
            DebugLog("INFO", "Waiting " .. (delay/1000) .. "s for formation to settle...")
            Wait(delay)

            StartConvoyMovement()
            
            TriggerClientEvent("djonluc:client:startBlips", -1, NetworkGetNetworkIdFromEntity(Convoy.van))
            Framework.Notify(-1, "A high-security evidence convoy is moving out!", "primary")
            DebugLog("INFO", "Convoy successfully started.")
        else
            ErrorLog("Van failed to spawn or convoy initialization failed.")
        end
    end)

    if not success then
        ErrorLog("CRITICAL ERROR during convoystart: " .. tostring(err))
    end
end)


RegisterCommand("convoystop", function(source)
    DebugLog("INFO", "Stopping and cleaning up convoy...")
    CleanupConvoy()
    DebugLog("INFO", "Convoy cleaned up.")
end)

RegisterCommand("convoytest", function(source, args)
    local testType = args[1]

    if not testType then
        DebugLog("INFO", "Usage: /convoytest spawn|route|loot|ai")
        return
    end

    if testType == "spawn" then
        DebugLog("TEST", "Testing vehicle spawn system...")
        SpawnFullConvoy()

    elseif testType == "route" then
        DebugLog("TEST", "Testing driving to destination...")
        if Convoy.van and DoesEntityExist(Convoy.van) then
            StartConvoyMovement()
        else
            ErrorLog("No active van to test route. Spawn one first.")
        end

    elseif testType == "loot" then
        DebugLog("TEST", "Testing loot system...")
        -- Manually trigger the loot event logic
        if Convoy.destroyed then
            TriggerEvent("djonluc:server:loot") -- Internal server trigger
        else
            ErrorLog("Van must be destroyed to test loot.")
        end

    elseif testType == "ai" then
        local count = 0
        for _ in pairs(HostileList) do count = count + 1 end
        DebugLog("TEST", "Reactive AI Logic diagnostic: Hostile List size: " .. count)

    else
        ErrorLog("Unknown test type: "..testType)
    end
end)

RegisterCommand("convoyspawnhere", function(source)
    DebugLog("INFO", "Command '/convoyspawnhere' triggered by " .. source)
    
    local sx, sy, sz, sw = 0.0, 0.0, 0.0, 0.0
    if source > 0 then
        local ped = GetPlayerPed(source)
        local pos = GetEntityCoords(ped)
        local head = GetEntityHeading(ped)
        sx, sy, sz, sw = pos.x + 5.0, pos.y, pos.z, head
    else
        -- Default test coords for console
        sx, sy, sz, sw = Config.Route.Start.x, Config.Route.Start.y, Config.Route.Start.z, Config.Route.Start.w
    end

    local vehicle = SpawnConfiguredVehicle(Config.Formation.Van, vector4(sx, sy, sz, sw))
    if vehicle then
        SpawnPedInVehicle(vehicle, Config.Peds.Driver, -1)
        DebugLog("OK", "Successfully spawned test vehicle near player.")
    end
end)

RegisterCommand("convoydebug", function()
    print("^5==== CONVOY DEBUG ====^7")
    print("Active: " .. tostring(Convoy.active))
    print("Destroyed: " .. tostring(Convoy.destroyed))
    print("Van Exists: " .. tostring(Convoy.van and DoesEntityExist(Convoy.van)))
    print("Escort Count: " .. #Convoy.escorts)
    print("Guard Count: " .. #Convoy.guards)
    print("StartedAt: " .. Convoy.startedAt)
    print("Under Attack: " .. tostring(Convoy.underAttack))
    print("^5======================^7")
end)

-- Original RegisterCommand("startconvoy", ...) removed to avoid duplication

-- Law Status Sync
function UpdateLawStatus(src)
    local job = Framework.GetJob(src)
    if job and Config.LawProtection.Jobs[job] then
        LawPlayers[src] = true
    else
        LawPlayers[src] = nil
    end
    TriggerClientEvent("djonluc:client:updateLawPlayers", -1, LawPlayers)
end

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function() UpdateLawStatus(source) end)
RegisterNetEvent('esx:playerLoaded', function(playerId) UpdateLawStatus(playerId) end)
RegisterNetEvent('QBCore:Server:OnJobUpdate', function(job) UpdateLawStatus(source) end)

-- Hostile Management
RegisterNetEvent("djonluc:server:markHostile", function(targetId)
    if not Convoy.active then return end
    
    -- Validation: Ignore Law Enforcement
    local job = Framework.GetJob(targetId)
    if job and Config.LawProtection.Jobs[job] then
        return
    end

    if not HostileList[targetId] then
        HostileList[targetId] = true
        TriggerClientEvent("djonluc:client:updateHostiles", -1, HostileList)
        print("^1[Convoy] WARNING: Player " .. targetId .. " marked as HOSTILE.^7")
    end
end)

-- Initial Sync
CreateThread(function()
    while true do
        for _, src in ipairs(GetPlayers()) do
            UpdateLawStatus(tonumber(src))
        end
        Wait(300000) -- Re-sync every 5 mins
    end
end)

-- Loot Handler
RegisterNetEvent("djonluc:server:loot", function()
    local src = source
    if not Convoy.destroyed then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local vanCoords = GetEntityCoords(Convoy.van)

    if #(coords - vanCoords) > Config.Event.LootDistance then
        DropPlayer(src, "Exploit detected: Distance spoof")
        return
    end

    for _, loot in pairs(Config.Loot) do
        local amount = math.random(loot.min, loot.max)
        Inventory.AddItem(src, loot.item, amount)
    end
    
    Framework.Notify(src, "Loot secured!", "success")
end)

-- Final initialization diagnostics
CreateThread(function()
    Wait(2000)
    print("^5[CONVOY DIAGNOSTICS]^7")
    print("Framework Type:", tostring(Framework.Type))
    print("SpawnFullConvoy:", type(SpawnFullConvoy))
    print("CleanupConvoy:", type(CleanupConvoy))
    print("StartCoords:", tostring(Config.Route.Start))
    print("^5[CONVOY DIAGNOSTICS END]^7")
end)
