# 🚓 DjonLuc Evidence Destruction Event - QBCore Documentation

## 📋 Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [QBCore Setup](#qbcore-setup)
4. [Configuration](#configuration)
5. [Usage](#usage)
6. [Commands](#commands)
7. [Exports & Integration](#exports--integration)
8. [Troubleshooting](#troubleshooting)
9. [API Reference](#api-reference)
10. [Examples](#examples)

---

## 🎯 Overview

The **Evidence Destruction Event** is a dynamic FiveM script designed specifically for QBCore servers. It creates high-security motorcade missions where players must escort evidence vehicles to destruction sites while defending against attacks.

### ✨ Key Features

- **Multi-Framework Support**: Native QBCore with ESX, QBox, vRP fallbacks
- **Enhanced Convoy System**: Spawns armored vehicles with AI escorts
- **Job-Based Restrictions**: Only DOJ/LEO players can start events
- **Smart AI Guards**: Escort peds that engage non-law enforcement players
- **Vehicle Trunk Loot**: Evidence vehicle contains valuable contraband
- **Simplified Routes**: Start and end points only (no waypoints)
- **Dynamic Route Management**: Set custom start/end points via console
- **In-Game Route Creation**: Create and save routes while playing

---

## 🚀 Installation

### Prerequisites

- FiveM Server
- QBCore Framework (Latest Version)
- Lua 5.4 support

### Installation Steps

1. **Download** the script to your server's resources folder
2. **Add** `ensure djonluc_evidence_event` to your `server.cfg`
3. **Restart** your server or start the resource manually
4. **Configure** the script in `config.lua` to match your server

### File Structure

```
djonluc_evidence_event/
├── fxmanifest.lua      # Resource manifest
├── config.lua          # Main configuration
├── shared/
│   └── utils.lua      # Shared utility functions
├── server/
│   └── main.lua       # Server-side logic
├── client/
│   ├── main.lua       # Client-side logic
│   └── ai.lua         # AI behavior system
├── README.md           # Basic documentation
├── DOCUMENTATION.md    # This comprehensive guide
├── build.md            # Technical specifications
└── test_dependencies.lua # Dependency testing script
```

---

## 🔧 QBCore Setup

### Required Jobs

Add these jobs to your `qb-core/shared/jobs.lua`:

```lua
['doj'] = {
    label = 'Department of Justice',
    defaultGrade = 0,
    grades = {
        ['0'] = {
            name = 'Agent',
            payment = 50
        },
        ['1'] = {
            name = 'Senior Agent',
            payment = 75
        }
    }
},

['leo'] = {
    label = 'Law Enforcement',
    defaultGrade = 0,
    grades = {
        ['0'] = {
            name = 'Officer',
            payment = 50
        },
        ['1'] = {
            name = 'Senior Officer',
            payment = 75
        }
    }
},

['police'] = {
    label = 'Police',
    defaultGrade = 0,
    grades = {
        ['0'] = {
            name = 'Recruit',
            payment = 50
        },
        ['1'] = {
            name = 'Officer',
            payment = 75
        }
    }
}
```

### Optional QBCore Resources

For enhanced functionality, ensure these resources are running:

- **`qb-inventory`** - Inventory integration
- **`qb-target`** - Interaction system
- **`qb-menu`** - Menu system

---

## ⚙️ Configuration

### Basic Configuration

Edit `config.lua` to customize the script:

```lua
Config = {}

-- Job Restrictions
Config.StartJobs = {"doj", "leo"} -- Jobs allowed to start events
Config.GuardIgnoreJobs = {"police", "leo"} -- Jobs ignored by escort peds

-- Event Settings
Config.EventSpawnMode = "manual" -- "manual" or "random"
Config.EventDuration = 300000 -- 5 minutes in milliseconds
Config.LootCrateLifetime = 60000 -- 1 minute for loot crate
```

### Convoy Configuration

```lua
Config.Vehicles = {
    escort_car = {
        model = "police",
        armor = 1000,
        count = 2,
        livery = 0
    },
    escort_suv = {
        model = "fbi2",
        armor = 1500,
        count = 1,
        livery = 0
    },
    evidence_van = {
        model = "stockade",
        armor = 2000,
        count = 1,
        livery = 0
    }
}
```

### Ped Configuration

```lua
Config.Peds = {
    escort_cop = {
        model = "s_m_y_cop_01",
        weapon = "WEAPON_PISTOL",
        count = 2,
        behavior = "aggressive",
        health = 200,
        armor = 100
    },
    escort_swat = {
        model = "s_m_y_swat_01",
        weapon = "WEAPON_CARBINERIFLE",
        count = 1,
        behavior = "aggressive",
        health = 300,
        armor = 150
    }
}
```

### Dynamic Routes

```lua
Config.DynamicRoutes = {
    enabled = true,
    default_start = vector3(123.45, 678.90, 12.34),
    default_end = vector3(-100.50, 200.75, 60.25),
    waypoint_count = 3,
    min_distance = 50.0,
    max_distance = 200.0
}
```

### Vehicle Trunk Loot Configuration

```lua
Config.VehicleTrunkLoot = {
    enabled = true,
    -- Items in evidence vehicle trunk
    trunk_items = {
        weapon_pistol = { count = 5, weight = 1.0 },
        cocaine_brick = { count = 3, weight = 2.0 },
        cash = { count = 20000, weight = 0.1 },
        meth = { count = 2, weight = 1.5 },
        weed_brick = { count = 4, weight = 1.0 },
        gold_bar = { count = 1, weight = 5.0 }
    },
    -- Items dropped by killed peds
    ped_drop_items = {
        weapon_pistol = { chance = 0.7, count = {1, 2} },
        cash = { chance = 0.8, count = {1000, 5000} },
        cocaine_brick = { chance = 0.3, count = {1, 1} }
    },
    -- Items scattered when vehicle is destroyed
    vehicle_destroyed_items = {
        weapon_pistol = { chance = 0.9, count = {2, 4} },
        cash = { chance = 1.0, count = {5000, 15000} },
        cocaine_brick = { chance = 0.8, count = {2, 3} }
    }
}
```

---

## 🎮 Usage

### Starting an Event

#### Method 1: Command

```bash
/startevidence
```

**Requirements**: Player must have `doj` or `leo` job

#### Method 2: F6 Menu

- Press `F6` to open the event menu
- Select "Start Event" from the context menu

#### Method 3: Programmatic

```lua
-- From another resource
local success = exports['djonluc_evidence_event']:StartEvidenceEvent(source)
```

### Event Flow

1. **Event Triggered**: DOJ/LEO player starts event
2. **Convoy Spawns**: Vehicles and AI escorts appear at start point
3. **Route Following**: Convoy drives directly to destination
4. **Player Engagement**: Non-LEO players can attack convoy
5. **Loot System**: Vehicle trunk contains items, peds drop items when killed
6. **Event End**: When convoy reaches destination or is intercepted

### Ending Events

```bash
/endevent
```

**Requirements**: Player must have `doj` or `leo` job

---

## ⌨️ Commands

### Player Commands

| Command           | Description                      | Requirements |
| ----------------- | -------------------------------- | ------------ |
| `/startevidence`  | Start evidence destruction event | DOJ/LEO job  |
| `/endevent`       | End current event                | DOJ/LEO job  |
| `/evidence_menu`  | Open event menu                  | Any player   |
| `/evidence_check` | Check client status              | Any player   |
| `/testroute`      | Test route data                  | Any player   |
| `/testmovement`   | Test convoy movement system      | Any player   |

### Console Commands

| Command              | Description                  | Usage        |
| -------------------- | ---------------------------- | ------------ |
| `/evidence_status`   | Full server status report    | Console only |
| `/evidence_redetect` | Manually re-detect framework | Console only |
| `/test_oxlib`        | Test ox_lib functionality    | Console only |
| `/testroute`         | Test route data              | Console only |

### Convoy Route Management

| Command                                                                 | Description                 | Usage        |
| ----------------------------------------------------------------------- | --------------------------- | ------------ |
| `/setconvoystart <x> <y> <z>`                                           | Set convoy start point      | Console only |
| `/setconvoyend <x> <y> <z>`                                             | Set convoy end point        | Console only |
| `/setconvoyroute <start_x> <start_y> <start_z> <end_x> <end_y> <end_z>` | Set complete route          | Console only |
| `/resetconvoyroute`                                                     | Reset to default route      | Console only |
| `/convoyroute`                                                          | Show current route settings | Console only |

---

## 🔌 Exports & Integration

### Available Exports

#### Event Management

```lua
-- Check event status
local isActive = exports['djonluc_evidence_event']:IsEventActive()
local eventData = exports['djonluc_evidence_event']:GetEventData()

-- Control events
local success = exports['djonluc_evidence_event']:StartEvidenceEvent(source)
exports['djonluc_evidence_event']:EndEvidenceEvent(success)
```

#### Event Information

```lua
-- Get event information
local convoyPos = exports['djonluc_evidence_event']:GetConvoyPosition()
local pedsAlive = exports['djonluc_evidence_event']:GetEscortPedsAlive()
```

#### Route Management

```lua
-- Manage custom routes
exports['djonluc_evidence_event']:RegisterCustomRoute(name, routeData)
exports['djonluc_evidence_event']:UnregisterCustomRoute(name)

-- Dynamic route management
exports['djonluc_evidence_event']:SetConvoyStartPoint(x, y, z)
exports['djonluc_evidence_event']:SetConvoyEndPoint(x, y, z)
local route = exports['djonluc_evidence_event']:GetCurrentDynamicRoute()
exports['djonluc_evidence_event']:ResetConvoyRoute()
```

#### Player Management

```lua
-- Get player job
local job = exports['djonluc_evidence_event']:GetPlayerJob(source)
```

#### AI Management

```lua
-- Initialize AI for escort peds
exports['djonluc_evidence_event']:InitializeEscortAI(ped, config)
exports['djonluc_evidence_event']:InitializeEnhancedEscortAI(ped, config)
```

### Integration Examples

#### Basic Integration

```lua
-- In your resource
local function StartEvidenceMission(playerId)
    local success = exports['djonluc_evidence_event']:StartEvidenceEvent(playerId)
    if success then
        print("Evidence mission started for player " .. playerId)
    else
        print("Failed to start evidence mission")
    end
end

-- Check if event is active
local function IsMissionActive()
    return exports['djonluc_evidence_event']:IsEventActive()
end
```

#### Custom Route Registration

```lua
-- Register a custom route
local customRoute = {
    start = vector3(100.0, 200.0, 30.0),
    destruction = vector3(500.0, 600.0, 40.0),
    waypoints = {
        vector3(150.0, 250.0, 32.0),
        vector3(200.0, 300.0, 35.0)
    }
}

exports['djonluc_evidence_event']:RegisterCustomRoute("my_custom_route", customRoute)
```

#### Dynamic Route Setting

```lua
-- Set convoy route programmatically
exports['djonluc_evidence_event']:SetConvoyStartPoint(100.0, 200.0, 30.0)
exports['djonluc_evidence_event']:SetConvoyEndPoint(500.0, 600.0, 40.0)

-- Get current route
local currentRoute = exports['djonluc_evidence_event']:GetCurrentDynamicRoute()
print("Start: " .. currentRoute.start.x .. ", " .. currentRoute.start.y)
print("End: " .. currentRoute.end.x .. ", " .. currentRoute.end.y)
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. QBCore Not Detected

**Problem**: Script shows "QBCore not detected"
**Solution**:

- Ensure `qb-core` is started before this resource
- Check resource loading order in `server.cfg`
- Verify QBCore exports are working

#### 2. Jobs Not Recognized

**Problem**: Players get "You do not have permission" error
**Solution**:

- Add required jobs to `qb-core/shared/jobs.lua`
- Restart QBCore after adding jobs
- Check job names match exactly (case-sensitive)

#### 3. Vehicles Not Spawning

**Problem**: Convoy vehicles don't appear
**Solution**:

- Verify vehicle model names in `config.lua`
- Check if vehicle models are available on your server
- Ensure coordinates are valid

#### 4. AI Not Working

**Problem**: Escort peds don't engage players
**Solution**:

- Check ped model names in `config.lua`
- Verify weapon hashes are correct
- Ensure AI behavior settings are configured

### Dependency Testing

Run the included test script to verify all dependencies:

```bash
# In server console
exec test_dependencies.lua
```

This will test:

- Framework detection
- Optional dependencies
- All exports
- Configuration loading
- Utility functions

### Debug Mode

Enable debug logging:

```bash
# In server console
set djonluc_evidence_event_debug 1
```

---

## 📚 API Reference

### Events

#### Client Events

| Event                                          | Description                 | Parameters                      |
| ---------------------------------------------- | --------------------------- | ------------------------------- |
| `djonluc_evidence_event:spawnConvoy`           | Spawn convoy for player     | route (table)                   |
| `djonluc_evidence_event:addItemToVehicleTrunk` | Add item to vehicle trunk   | vehicleNetId, itemName, count   |
| `djonluc_evidence_event:spawnDroppedItem`      | Spawn dropped item in world | position, itemName, count       |
| `djonluc_evidence_event:cleanupConvoy`         | Clean up convoy             | None                            |
| `djonluc_evidence_event:showNotification`      | Show notification           | message (string), type (string) |

#### Server Events

| Event                                             | Description                | Parameters     |
| ------------------------------------------------- | -------------------------- | -------------- |
| `djonluc_evidence_event:escortPedDied`            | Escort ped died            | pedId (number) |
| `djonluc_evidence_event:updatePedCount`           | Update ped count           | count (number) |
| `djonluc_evidence_event:lootCrateInteracted`      | Loot crate interaction     | None           |
| `djonluc_evidence_event:convoyReachedDestination` | Convoy reached destination | None           |
| `djonluc_evidence_event:convoyDestroyed`          | Convoy destroyed           | None           |

### Functions

#### Utils Functions

```lua
-- Framework detection
Utils.IsFrameworkReady()
Utils.GetFrameworkStatus()
Utils.PrintFrameworkStatus()
Utils.ReDetectFramework()

-- Player management
Utils.GetPlayerJob(source)
Utils.HasRequiredJob(playerJob)
Utils.ShouldIgnorePlayer(playerJob)

-- Route management
Utils.GenerateDynamicRoute(startPoint, endPoint)
Utils.ValidateRoutePoints(startPoint, endPoint)
Utils.GetRandomRoute()

-- Item management
Utils.GiveItemToPlayer(source, item, count)
Utils.GiveWeaponToPlayer(source, weapon, ammo)
Utils.GiveMoneyToPlayer(source, amount)

-- Notifications
Utils.ShowNotification(source, message, type)
Utils.ShowAdvancedNotification(source, title, message, type, duration)
```

---

## 💡 Examples

### Complete Integration Example

```lua
-- In your resource file
local function SetupEvidenceEvent()
    -- Register custom route
    local customRoute = {
        start = vector3(100.0, 200.0, 30.0),
        destruction = vector3(500.0, 600.0, 40.0),
        waypoints = {
            vector3(150.0, 250.0, 32.0),
            vector3(200.0, 300.0, 35.0)
        }
    }

    exports['djonluc_evidence_event']:RegisterCustomRoute("my_route", customRoute)

    -- Set dynamic route
    exports['djonluc_evidence_event']:SetConvoyStartPoint(100.0, 200.0, 30.0)
    exports['djonluc_evidence_event']:SetConvoyEndPoint(500.0, 600.0, 40.0)

    print("Evidence event setup complete")
end

-- Start event for specific player
local function StartEventForPlayer(playerId)
    if exports['djonluc_evidence_event']:IsEventActive() then
        print("Event already active")
        return false
    end

    local success = exports['djonluc_evidence_event']:StartEvidenceEvent(playerId)
    if success then
        print("Event started for player " .. playerId)
        return true
    else
        print("Failed to start event")
        return false
    end
end

-- Monitor event status
local function MonitorEvent()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5000) -- Check every 5 seconds

            if exports['djonluc_evidence_event']:IsEventActive() then
                local eventData = exports['djonluc_evidence_event']:GetEventData()
                local pedsAlive = exports['djonluc_evidence_event']:GetEscortPedsAlive()

                print("Event active - Peds alive: " .. pedsAlive)

                if pedsAlive <= 0 then
                    print("All escort peds eliminated - loot crate should spawn")
                end
            end

            Citizen.Wait(5000)
        end
    end)
end

-- Initialize
Citizen.CreateThread(function()
    SetupEvidenceEvent()
    MonitorEvent()
end)
```

### QBCore Job Integration

```lua
-- Check if player can start event
local function CanPlayerStartEvent(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    local job = Player.PlayerData.job.name
    return exports['djonluc_evidence_event']:HasRequiredJob(job)
end

-- Start event with QBCore integration
local function StartEventWithQBCore(source)
    if not CanPlayerStartEvent(source) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to start this event', 'error')
        return false
    end

    local success = exports['djonluc_evidence_event']:StartEvidenceEvent(source)
    if success then
        TriggerClientEvent('QBCore:Notify', source, 'Evidence destruction event started!', 'success')
        return true
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to start event', 'error')
        return false
    end
end
```

---

## 🚙 Enhanced Convoy Movement System

The convoy movement system has been significantly improved to ensure all vehicles properly reach the destination.

### Key Features

- **Dual Movement System**: Primary movement thread + reinforcement thread
- **Destination Tracking**: Continuous monitoring of convoy progress
- **Stuck Vehicle Prevention**: Automatic detection and correction of stuck vehicles
- **Formation Maintenance**: Configurable escort vehicle positioning
- **Speed Control**: Configurable convoy speed and movement parameters

### Movement Configuration

```lua
Config.ConvoyMovement = {
    speed = 20.0,                    -- Convoy speed in m/s
    follow_distance = 8.0,           -- Distance between escort vehicles
    formation_maintenance = true,     -- Maintain convoy formation
    emergency_formation = true,       -- Emergency formation when under attack
    max_deviation = 15.0             -- Maximum deviation from formation
}
```

### Vehicle Movement Types

- **Evidence Vehicle**: Leads the convoy directly to destination
- **Escort Vehicles**: Follow formation while moving toward destination
- **Formation Control**: Maintains relative positions during movement
- **Stuck Detection**: Monitors vehicle movement and corrects stuck vehicles

### Testing Commands

- **`/testmovement`**: Comprehensive convoy movement testing
- **Movement Status**: Shows current convoy position and destination progress
- **Configuration Check**: Verifies all movement settings are properly configured
- **Real-time Monitoring**: Tracks convoy progress toward destination

### Movement Behavior

1. **Initial Movement**: All vehicles start moving toward destination immediately
2. **Formation Control**: Escort vehicles maintain relative positions
3. **Destination Check**: Arrival threshold set to 15m for reliable detection
4. **Reinforcement**: Secondary thread ensures continuous movement
5. **Stuck Prevention**: Automatic correction of vehicles that stop moving

### Performance Optimizations

- **Update Frequency**: Movement updates every 3 seconds for responsiveness
- **Distance Checks**: Efficient distance calculations using native functions
- **Thread Management**: Separate threads for different movement aspects
- **Memory Management**: Proper cleanup of movement monitoring threads

## 🧹 Recent Code Improvements

### Code Cleanup (Latest Update)

- **Removed Unused Functions**: Eliminated unused loot crate and item giving functions
- **Simplified Configuration**: Removed redundant event duration and player limit settings
- **Streamlined Server Logic**: Cleaned up server-side event handling
- **Optimized Dependencies**: Removed hardcoded framework dependencies

### Removed Components

```lua
-- Removed from config.lua
Config.EventDuration = 300000        -- Event duration (unused)
Config.MaxPlayers = 32               -- Max players (unused)
Config.MinPlayers = 1                -- Min players (unused)
Config.EscalationRules = {...}       -- AI escalation (unused)

-- Removed from server/main.lua
local lootCrate = nil                -- Loot crate variable
function SpawnLootCrate()            -- Loot crate spawning
function OnLootCrateInteraction()    -- Loot crate interaction

-- Removed from shared/utils.lua
Utils.GetRandomLootItems()           -- Random loot generation
Utils.GiveWeaponToPlayer()           -- Weapon giving
Utils.GiveMoneyToPlayer()            -- Money giving
Utils.GiveItemToPlayer()             -- Item giving
```

### Benefits of Cleanup

- **Reduced Memory Usage**: Eliminated unused variables and functions
- **Improved Performance**: Cleaner code execution paths
- **Better Maintainability**: Easier to understand and modify
- **Reduced Conflicts**: Less chance of function name collisions

---

## 🔮 Future Enhancements

- [ ] Helicopter escort support
- [ ] Dynamic difficulty scaling
- [ ] Event notifications system
- [ ] Multiple convoy types
- [ ] Interactive evidence items
- [ ] Weather/time restrictions
- [ ] Advanced AI behaviors
- [ ] Multi-language support

---

## 📞 Support

### Getting Help

1. **Check Documentation**: Review this file and README.md
2. **Run Tests**: Use `test_dependencies.lua` to diagnose issues
3. **Check Console**: Look for error messages in server console
4. **Verify Setup**: Ensure QBCore and required jobs are configured

### Common Solutions

- **Framework Issues**: Restart QBCore before this resource
- **Job Problems**: Verify job names match exactly in QBCore
- **Vehicle Issues**: Check model names and coordinates
- **AI Problems**: Verify ped models and weapon hashes

---

## 📄 License

This project is licensed under the MIT License.

---

**Made with ❤️ for the QBCore community**

_For additional support, check the README.md file or run the test script to diagnose any issues._
