# 🚀 Quick Start Guide - DjonLuc Evidence Destruction Event

## 🎯 Quick Start (3 Steps)

1. **Set a Route**: `/preset police` (or create your own)
2. **Start Event**: `/startevidence`
3. **Engage Convoy**: Attack the convoy for loot rewards!

---

## 🗺️ SUPER EASY ROUTE SETUP!

### Method 1: Use Preset Routes

```bash
/preset police    # Police station to remote location
/preset sandy     # Sandy Shores to Mount Chiliad
/preset airport   # Airport to beach
/preset city      # Downtown to Vinewood Hills
```

### Method 2: Quick Route Setup

```bash
/quickroute police beach    # Police station to beach
/quickroute sandy mountain  # Sandy Shores to Mount Chiliad
/quickroute airport city    # Airport to downtown
```

### Method 3: In-Game Route Creation (NEW!)

```bash
/createroute myroute        # Start creating a route
/setstart                   # Set start point (where you are)
/setend                     # Set end point (where you are)
/useroute myroute           # Use your created route
```

### Method 4: Manual Setup (Advanced)

```bash
# Console commands (admin only)
setspawn 402.76 -1019.04 29.33 355.06
setend -1594.21 2807.17 17.01 44.21
```

---

## 📋 Route Setup Commands

| Command                     | Description            | Example                        |
| --------------------------- | ---------------------- | ------------------------------ |
| `/easyroute`                | Show all route options | Displays complete command list |
| `/preset <name>`            | Use preset route       | `/preset police`               |
| `/listpresets`              | Show available presets | Lists all preset routes        |
| `/quickroute <start> <end>` | Quick setup            | `/quickroute police beach`     |
| `/nearby <location>`        | Find spawn points      | `/nearby police`               |

---

## 🎮 In-Game Route Creation Commands

| Command               | Description          | Usage                            |
| --------------------- | -------------------- | -------------------------------- |
| `/createroute <name>` | Start creating route | `/createroute myroute`           |
| `/setstart`           | Set start point      | Go to location, then use command |
| `/setend`             | Set end point        | Go to location, then use command |
| `/useroute <name>`    | Use created route    | `/useroute myroute`              |
| `/myroutes`           | List your routes     | Shows all your custom routes     |
| `/allroutes`          | List all routes      | Shows presets + custom routes    |
| `/deleteroute <name>` | Delete route         | `/deleteroute myroute`           |
| `/routehelp`          | Get help             | Shows creation instructions      |

---

## 🚗 Create Your Own Routes (4 Steps)

1. **Start Creation**: `/createroute routename`
2. **Go to Start**: Walk/drive to your desired start location
3. **Set Start**: `/setstart` (saves your current position)
4. **Go to End**: Walk/drive to your desired end location
5. **Set End**: `/setend` (saves your current position)
6. **Use Route**: `/useroute routename`

**💡 Tip**: Make sure you're facing the right direction when setting points!

---

## 🎯 Essential Commands

| Command          | Description       | Requirements        |
| ---------------- | ----------------- | ------------------- |
| `/startevidence` | Start the event   | Law enforcement job |
| `/checkjob`      | Check permissions | Any player          |
| `/easyroute`     | Route setup help  | Any player          |
| `/preset <name>` | Use preset route  | Any player          |

---

## 🎒 Loot System

### Vehicle Trunk Loot

- **Evidence Vehicle**: Contains valuable contraband in trunk
- **Access Method**: `/access_trunk` near the evidence vehicle
- **Loot Types**: Weapons, drugs, cash, and custom items

### Ped Drops

- **Escort Guards**: Drop items when killed
- **Drop Chance**: Configurable per item type
- **Item Types**: Cash, ammo, and other valuables

### Vehicle Destruction

- **Destroyed Vehicle**: Scatters items in area
- **Item Distribution**: Random spread around vehicle
- **Reward Types**: High-value items and contraband

---

## 🚗 Convoy Movement System

### Key Features

- **Formation Maintenance**: Vehicles maintain relative positions
- **Stuck Prevention**: Automatic detection and correction
- **Speed Control**: Configurable convoy speed
- **Destination Tracking**: Real-time progress monitoring

### Movement Behavior

1. **Evidence Vehicle**: Leads convoy to destination
2. **Escort Vehicles**: Maintain formation while following
3. **AI Drivers**: Intelligent driving with formation control
4. **Stuck Detection**: Monitors and corrects stuck vehicles

### Configuration

```lua
Config.ConvoyMovement = {
    speed = 15.0,                    -- Convoy speed in m/s
    follow_distance = 10.0,          -- Distance between vehicles
    formation_maintenance = true,     -- Maintain formation
    emergency_formation = true,       -- Emergency adjustments
    max_deviation = 15.0             -- Maximum deviation
}
```

---

## 🎮 Event Flow

1. **Start Event**: Law enforcement player uses `/startevidence`
2. **Convoy Spawns**: Evidence vehicle + escort vehicles appear
3. **AI Escorts**: Armed guards spawn and drive escort vehicles
4. **Convoy Moves**: All vehicles drive to destination in formation
5. **Player Engagement**: Players can attack convoy for loot
6. **Loot Rewards**: Items from vehicle trunk, ped drops, and destruction
7. **Event End**: When convoy reaches destination or is destroyed

---

## 🔧 Job Requirements

### Required Jobs (Configurable)

- **Police**: Standard law enforcement
- **Sheriff**: County law enforcement
- **DOJ**: Department of Justice
- **Custom**: Add your own job names

### Job Configuration

```lua
Config.StartJobs = {"police", "sheriff", "doj"}
Config.GuardIgnoreJobs = {"police", "sheriff"}
```

---

## 📍 Heading Guide

### Understanding Headings

- **0°**: North (facing up on map)
- **90°**: East (facing right on map)
- **180°**: South (facing down on map)
- **270°**: West (facing left on map)

### Default Spawn Points

```lua
-- Police Station (Mission Row)
start = vector4(402.76, -1019.04, 29.33, 355.06)

-- Sandy Shores
start = vector4(1853.45, 3689.67, 34.27, 210.0)

-- Airport
start = vector4(-1037.89, -2738.56, 20.17, 327.0)
```

---

## 🚨 Troubleshooting

### Common Issues

1. **"No permission"**: Check your job with `/checkjob`
2. **Convoy not moving**: Verify route is set with `/route`
3. **Peds not spawning**: Check console for error messages
4. **Vehicles not appearing**: Verify coordinates and vehicle models

### Getting Help

- **Console Commands**: Use `/evidence_status` for system info
- **Route Issues**: Check route with `/route` or `/convoyroute`
- **Job Problems**: Verify job with `/checkjob`
- **Framework Issues**: Check server console for detection messages

---

## 📚 Additional Resources

- **README.md**: Basic overview and installation
- **DOCUMENTATION.md**: Comprehensive feature documentation
- **examples/**: Configuration examples and best practices

---

**🎯 Ready to start? Use `/preset police` and then `/startevidence`!**

## 🚗 Convoy Formation System

The convoy now spawns in a **single file line formation** with the evidence vehicle at the front:

- **Evidence Vehicle**: Spawns at the front (your spawn coordinates)
- **Escort Cars**: Spawn behind the evidence vehicle in a line
- **Escort SUVs**: Spawn behind the escort cars in a line
- **Formation**: Vehicles are spaced 5.0 meters apart in a single file line

## 🚀 Enhanced Professional Features

### **📍 Advanced Blip System**

- **Individual Vehicle Tracking**: Each convoy vehicle has its own blip
- **Convoy Status Indicator**: Shows if convoy is ACTIVE or UNDER ATTACK
- **Protection Zone**: 50m radius red zone around convoy
- **Route Progress**: Visual indicator at route midpoint
- **Dynamic Distance**: Real-time distance to convoy

### **🧍 Enhanced Ped AI**

- **Smart Task Management**: Peds automatically drive to destination
- **Formation Maintenance**: Vehicles maintain proper convoy spacing
- **Instant Response**: Uses `CLEAR_PED_TASKS_IMMEDIATELY` for quick reactions
- **Professional Behavior**: Realistic convoy driving patterns

### **🎯 Professional Appearance**

- **Color-Coded Blips**: Different colors for different vehicle types
- **Status Indicators**: Real-time convoy health and status
- **Route Visualization**: Clear path from start to destination
- **Police Operation Look**: Professional appearance like real law enforcement

### Debug Commands

Use these commands to troubleshoot and test the system:

- `/debugspawn` - Check all convoy vehicles and escort peds
- `/testformation` - Analyze convoy formation and vehicle positions
- `/testpedspawn` - Test spawning peds in specific vehicles
- `/testvehicles` - Test vehicle spawning and positioning
- `/testcoords` - Check vehicle coordinates and spawn points
- `/testenhanced` - Test all enhanced convoy system features
