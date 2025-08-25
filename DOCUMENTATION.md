# DjonLuc Evidence Destruction Event - Documentation

## 📋 Table of Contents

1. [Overview](#overview)
2. [Key Features](#key-features)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Commands](#commands)
6. [Event Flow](#event-flow)
7. [Framework Integration](#framework-integration)
8. [Customization](#customization)
9. [Troubleshooting](#troubleshooting)

## 🎯 Overview

The DjonLuc Evidence Destruction Event is a comprehensive FiveM resource that creates dynamic, AI-driven convoy events for evidence transportation and destruction. The system features intelligent escort behavior, customizable routes, and integrated loot mechanics.

## ✨ Key Features

- **Multi-Framework Support**: Compatible with QBCore, ESX, QBox, and vRP
- **Enhanced Convoy System**: Intelligent vehicle formation and movement
- **Vehicle Trunk Loot**: Integrated loot system replacing traditional loot crates
- **Simplified Routes**: Streamlined route system without complex waypoints
- **In-Game Route Creation**: Create and save custom routes during gameplay
- **Real-time Blips**: Live tracking of convoy movement and destination
- **Job-Based Access**: Configurable job requirements for event management

## 🚀 Installation

### Requirements

- FiveM Server
- Framework: QBCore, ESX, QBox, or vRP
- Optional: `ox_lib` for enhanced UI components

### Setup Steps

1. Download the resource to your server's resources folder
2. Add `ensure djonluc_evidence_event` to your `server.cfg`
3. Configure `config.lua` to match your server settings
4. Restart your server

## ⚙️ Configuration

### Core Configuration

```lua
Config.StartJobs = {"police", "sheriff", "doj"} -- Jobs that can start events
Config.GuardIgnoreJobs = {"police", "sheriff"} -- Jobs ignored by AI guards

Config.Routes = {
    route_1 = {
        start = vector4(402.76, -1019.04, 29.33, 355.06),
        destruction = vector4(-1594.21, 2807.17, 17.01, 44.21)
    }
}
```

### Vehicle Configuration

```lua
Config.Vehicles = {
    evidence_van = {
        model = "stockade",
        count = 1,
        armor = 2000,
        spawn_offset = 0.0,
        spawn_direction = 0.0
    },
    escort_car = {
        model = "police",
        count = 2,
        armor = 1000,
        spawn_offset = 5.0,
        spawn_direction = 90.0
    }
}
```

### Ped Configuration

```lua
Config.Peds = {
    escort_guard = {
        model = "s_m_y_swat_01",
        count = 4,
        weapon = "weapon_carbinerifle",
        health = 200,
        armor = 100,
        behavior = "aggressive",
        vehicle_assignment = "escort_car",
        seat_preference = "driver",
        driving_style = 786603
    }
}
```

### Convoy Formation

```lua
Config.ConvoyFormation = {
    formation_type = "line",
    spacing = 8.0,
    max_convoy_width = 20.0
}
```

### Convoy Movement

```lua
Config.ConvoyMovement = {
    speed = 15.0,
    follow_distance = 10.0,
    formation_maintenance = true,
    emergency_formation = true,
    max_deviation = 15.0
}
```

### Vehicle Trunk Loot Configuration

```lua
Config.VehicleTrunkLoot = {
    enabled = true,
    trunk_items = {
        ["cocaine_brick"] = {count = 5, weight = 1.0},
        ["weapon_pistol"] = {count = 2, weight = 2.0}
    },
    ped_drop_items = {
        ["cash"] = {chance = 0.7, count = {100, 500}},
        ["ammo"] = {chance = 0.5, count = {10, 30}}
    },
    vehicle_destroyed_items = {
        ["gold_bar"] = {count = {1, 3}},
        ["diamond"] = {count = {1, 2}}
    }
}
```

## 🎮 Commands

### Server Commands

| Command                           | Description                          | Usage                        |
| --------------------------------- | ------------------------------------ | ---------------------------- |
| `/startevidence`                  | Start the evidence destruction event | Requires law enforcement job |
| `/endevent`                       | End current event                    | Admin/LEO only               |
| `/evidence_status`                | Show event status                    | Console only                 |
| `/evidence_redetect`              | Re-detect framework                  | Console only                 |
| `/setspawn <x> <y> <z> <heading>` | Set convoy spawn point               | Console only                 |
| `/setend <x> <y> <z> <heading>`   | Set convoy destination               | Console only                 |
| `/route`                          | Show current route status            | Console only                 |
| `/resetconvoyroute`               | Reset to default route               | Console only                 |
| `/convoyroute`                    | Show current convoy route            | Console only                 |
| `/checkjob`                       | Check player job permissions         | Player command               |
| `/easyroute`                      | Show route setup options             | Player command               |
| `/preset <name>`                  | Use preset route                     | Player command               |
| `/listpresets`                    | List available preset routes         | Player command               |
| `/quickroute <start> <end>`       | Quick route setup                    | Player command               |
| `/nearby <location>`              | Find nearby spawn points             | Player command               |
| `/createroute <name>`             | Start creating custom route          | Player command               |
| `/setstart`                       | Set start point for route creation   | Player command               |
| `/setend`                         | Set end point for route creation     | Player command               |
| `/useroute <name>`                | Use player-created route             | Player command               |
| `/myroutes`                       | List your created routes             | Player command               |
| `/allroutes`                      | List all available routes            | Player command               |
| `/deleteroute <name>`             | Delete your route                    | Player command               |
| `/cancelroute`                    | Cancel route creation                | Player command               |
| `/routehelp`                      | Show route creation help             | Player command               |

### Client Commands

| Command         | Description                    | Usage                 |
| --------------- | ------------------------------ | --------------------- |
| `/access_trunk` | Access vehicle trunk inventory | Near evidence vehicle |

## 🔄 Event Flow

1. **Event Initiation**: Law enforcement player starts event with `/startevidence`
2. **Route Selection**: System uses preset route, custom route, or dynamic route
3. **Convoy Spawning**: Evidence vehicle and escort vehicles spawn at start point
4. **Ped Assignment**: AI escorts are spawned and assigned to vehicles
5. **Convoy Movement**: Convoy drives directly to destination with formation maintenance
6. **Vehicle Trunk Filled**: Evidence vehicle trunk is populated with configured loot
7. **Player Interaction**: Players can engage convoy for loot rewards
8. **Event Completion**: Event ends when convoy reaches destination or is destroyed

## 🔧 Framework Integration

### QBCore Integration

```lua
-- Job checking
local playerJob = Player.PlayerData.job.name

-- Inventory integration (if available)
if exports['qb-inventory'] then
    -- Use QBCore inventory system
end
```

### ESX Integration

```lua
-- Job checking
local playerJob = ESX.GetPlayerData().job.name

-- Inventory integration (if available)
if exports['es_extended'] then
    -- Use ESX inventory system
end
```

### Export Functions

```lua
-- Check event status
local isActive = exports['djonluc_evidence_event']:IsEventActive()
local eventData = exports['djonluc_evidence_event']:GetEventData()

-- Control events
local success = exports['djonluc_evidence_event']:StartEvidenceEvent(source)
exports['djonluc_evidence_event']:EndEvidenceEvent(success)

-- Get event information
local convoyPos = exports['djonluc_evidence_event']:GetConvoyPosition()
local pedsAlive = exports['djonluc_evidence_event']:GetEscortPedsAlive()
```

## 🎨 Customization

### Adding New Routes

```lua
Config.Routes.new_route = {
    start = vector4(x, y, z, heading),
    destruction = vector4(x, y, z, heading)
}
```

### Custom Vehicle Types

```lua
Config.Vehicles.custom_type = {
    model = "your_vehicle_model",
    count = 1,
    armor = 1500,
    spawn_offset = 0.0,
    spawn_direction = 0.0
}
```

### Custom Ped Types

```lua
Config.Peds.custom_guard = {
    model = "your_ped_model",
    count = 2,
    weapon = "weapon_carbinerifle",
    behavior = "defensive",
    vehicle_assignment = "custom_type"
}
```

## 🚨 Enhanced Convoy Movement System

### Key Features

- **Primary Movement**: Evidence vehicle drives directly to destination
- **Formation Maintenance**: Escort vehicles maintain relative positions
- **Stuck Vehicle Prevention**: Automatic detection and correction of stuck vehicles
- **Speed Control**: Configurable convoy speed and follow distances
- **Emergency Formation**: Automatic formation adjustment during combat

### Testing

Use `/testmovement` to test the convoy movement system and verify all vehicles are moving correctly.

### Configuration

```lua
Config.ConvoyMovement = {
    speed = 15.0,                    -- Convoy speed in m/s
    follow_distance = 10.0,          -- Distance between vehicles
    formation_maintenance = true,     -- Maintain formation during movement
    emergency_formation = true,       -- Emergency formation adjustments
    max_deviation = 15.0             -- Maximum deviation from formation
}
```

## 🚗 Enhanced Convoy System

### Convoy Formation

The convoy now spawns in a proper line formation with the evidence vehicle in the center:

- **Evidence Vehicle**: Spawns at the center point (spawn coordinates)
- **Escort Cars**: Spawn to the RIGHT of center with 5.0m spacing
- **Escort SUVs**: Spawn to the LEFT of center with 5.0m spacing
- **Formation**: Vehicles maintain optimal spacing for convoy movement

### Debug Commands

Use these commands to troubleshoot and test the system:

- `/debugspawn` - Comprehensive check of all convoy vehicles and escort peds
- `/testformation` - Analyze convoy formation and vehicle positions
- `/testpedspawn` - Test spawning peds in specific vehicles
- `/testvehicles` - Test vehicle spawning and positioning
- `/testcoords` - Check vehicle coordinates and spawn points

### Vehicle Assignment

Peds are automatically assigned to the correct vehicle types:

- **Escort Cops** → Escort Cars (driver seat)
- **Escort SWAT** → Escort SUVs (driver seat)

## 🐛 Troubleshooting

### Common Issues

1. **Peds Not Spawning**: Check ped model names and vehicle assignments
2. **Vehicles Not Moving**: Verify route coordinates and vehicle models
3. **Permission Denied**: Check job configuration in `Config.StartJobs`
4. **Framework Not Detected**: Ensure framework is loaded before this resource

### Debug Information

- Check server console for framework detection messages
- Use `/evidence_status` for comprehensive system status
- Verify all coordinates use `vector4` format with headings

## 📝 Recent Code Improvements

### Cleanup and Optimization

- **Removed Test Commands**: All test/debug commands removed for production use
- **Code Cleanup**: Eliminated redundant variables and unused functions
- **Performance Optimization**: Streamlined convoy movement and AI systems
- **Documentation Updates**: Comprehensive documentation reflecting current codebase

### Best Practices Implementation

- **FiveM Standards**: Adherence to FiveM best practices for entity creation and management
- **Framework Integration**: Proper framework detection and integration methods
- **Thread Management**: Efficient thread creation and management
- **Event Handling**: Robust event handling with proper validation

---

**Note**: This resource has been optimized for production use with all test commands and debug code removed. The codebase follows FiveM and framework best practices for maximum stability and performance.
