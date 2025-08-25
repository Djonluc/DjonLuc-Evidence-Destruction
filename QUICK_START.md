# 🚔 Djonluc Evidence Event - Quick Start Guide

## 🚀 **SUPER EASY ROUTE SETUP!**

### **🎯 Method 1: Use Preset Routes (Easiest!)**

```bash
# Use a preset route (recommended for beginners)
preset police

# Available presets: police, sandy, airport, city
# Use /listpresets to see all options
```

### **⚡ Method 2: Quick Route Setup**

```bash
# Quick setup with location names
quickroute police beach
quickroute airport mountain
quickroute sandy city

# Available locations: police, sandy, airport, city, beach, mountain, downtown
```

### **🎮 Method 3: In-Game Route Creation (NEW!)**

```bash
# Create your own routes while playing!
createroute myroute
setstart
setend

# Then use your route:
useroute myroute
```

### **🗺️ Method 4: Manual Setup (Advanced)**

```bash
# Set spawn point with heading (x, y, z, heading)
setspawn 402.76 -1019.04 29.33 355.06

# Set destination with heading (x, y, heading)
setend -1594.21 2807.17 17.01 44.21
```

### **🔍 Route Setup Commands**

| Command                     | What It Does                  | Example                    |
| --------------------------- | ----------------------------- | -------------------------- |
| `/easyroute`                | Shows all route setup options | `/easyroute`               |
| `/preset <name>`            | Use a preset route            | `/preset police`           |
| `/quickroute <start> <end>` | Quick setup with names        | `/quickroute police beach` |
| `/listpresets`              | Show all preset routes        | `/listpresets`             |
| `/nearby <location>`        | Find nearby spawn points      | `/nearby police`           |
| `/route`                    | Check current route status    | `/route`                   |

### **🎮 In-Game Route Creation Commands**

| Command               | What It Does                        | Example                |
| --------------------- | ----------------------------------- | ---------------------- |
| `/createroute <name>` | Start creating a custom route       | `/createroute myroute` |
| `/setstart`           | Set start point at current location | `/setstart`            |
| `/setend`             | Set end point at current location   | `/setend`              |
| `/useroute <name>`    | Use your created route              | `/useroute myroute`    |
| `/myroutes`           | Show your created routes            | `/myroutes`            |
| `/allroutes`          | Show all available routes           | `/allroutes`           |
| `/deleteroute <name>` | Delete your route                   | `/deleteroute myroute` |
| `/cancelroute`        | Cancel route creation               | `/cancelroute`         |
| `/routehelp`          | Get route creation help             | `/routehelp`           |

### **📋 Preset Routes Available**

- **`police`** - Police Station → Remote Location (Default)
- **`sandy`** - Sandy Shores → Mount Chiliad
- **`airport`** - Airport → Beach
- **`city`** - Downtown → Vinewood Hills

### **🎮 Quick Start (3 Steps)**

1. **Set Route**: `/preset police`
2. **Check Status**: `/route`
3. **Start Event**: `/startevidence`

**That's it!** 🎉

### **🎯 Create Your Own Routes (4 Steps)**

1. **Start Creation**: `/createroute myroute`
2. **Set Start**: Go to location → `/setstart`
3. **Set End**: Go to location → `/setend`
4. **Use Route**: `/useroute myroute`

**Your routes are saved automatically!** 💾

## 🚙 **Convoy Movement System**

### **Key Features**

- **Automatic Destination**: Convoy automatically drives to the end point
- **Formation Control**: Escort vehicles maintain proper positioning
- **Stuck Prevention**: Automatic detection and correction of stuck vehicles
- **Real-time Monitoring**: Continuous tracking of convoy progress

### **Testing Movement**

```bash
# Test the convoy movement system
testmovement

# This will show:
# - Current convoy position
# - Distance to destination
# - Movement configuration status
# - Vehicle and ped status
```

### **Movement Configuration**

The convoy movement is controlled by these settings in `config.lua`:

```lua
Config.ConvoyMovement = {
    speed = 20.0,                    -- Convoy speed in m/s
    follow_distance = 8.0,           -- Distance between vehicles
    formation_maintenance = true,     -- Keep formation
    max_deviation = 15.0             -- Max deviation from formation
}
```

### **What Happens During Movement**

1. **Start**: All vehicles begin moving toward destination immediately
2. **Formation**: Escort vehicles maintain relative positions
3. **Progress**: Continuous monitoring of destination progress
4. **Arrival**: Automatic detection when within 15m of destination
5. **Completion**: Event automatically completes upon arrival

## 🎯 **Required Jobs**

You need one of these jobs to start the event:

- `doj` (Department of Justice)
- `leo` (Law Enforcement Officer)
- `police` (Police Officer)
- `sheriff` (Sheriff)
- `bcso` (Blaine County Sheriff)
- `state` (State Police)
- `fbi` (Federal Bureau)
- `highway` (Highway Patrol)

## 🔧 **Debug Commands**

### **Check Your Job Permission**

```bash
checkjob
```

### **Test Event System**

```bash
test_evidence
```

### **Test Ped Spawning System**

```bash
testpeds
```

### **Test Route Creation System**

```bash
testroutes
```

### **Test Route Data**

```bash
testroute
```

### **Test Convoy Spawning System**

```bash
testconvoy
```

### **Test Convoy Movement**

```bash
testmovement
```

### **Check Route Status**

```bash
route
```

### **Check Event Status**

```bash
evidence_status
```

## 📍 **Default Spawn Points**

- **Start**: Police Station (402.76, -1019.04, 29.33, 355.06°)
- **End**: Remote Location (-1594.21, 2807.17, 17.01, 44.21°)

## 🚨 **Troubleshooting**

### **Event Won't Start?**

1. Check your job: `/checkjob`
2. Test the system: `/test_evidence`
3. Check route status: `/route`

### **No Convoy Spawning?**

1. Make sure you set both spawn points with headings
2. Check console for errors
3. Verify your job has permission

### **Framework Issues?**

1. Check console for framework detection
2. Use `/evidence_redetect` to re-detect
3. Ensure QBCore/ESX is running

## 🎮 **Player Commands**

- **F6** - Open event menu (if ox_lib available)
- **`/evidence_menu`** - Open event menu
- **`/toggleblip`** - Toggle convoy blip

## 📋 **What Happens When Event Starts**

1. ✅ Convoy spawns at set location with correct heading
2. ✅ Police escort vehicles spawn around it
3. ✅ Armed escort peds spawn in vehicles
4. ✅ Convoy drives to destination
5. ✅ Live blip shows convoy location
6. ✅ Players can intercept the convoy

## 🎒 **Loot System**

### **Vehicle Trunk Loot**

- **Evidence vehicle trunk** is automatically filled with valuable contraband when the event starts
- **Access trunk**: Use `/access_trunk` command near the evidence vehicle
- **Trunk contents**: Weapons, drugs, cash, and other valuable items

### **Item Drops**

- **Escort peds killed**: Drop random items (weapons, drugs, cash)
- **Vehicle destroyed**: Scatters all trunk items in the area
- **Dropped items**: Visible as 3D objects with interaction prompts
- **Auto-cleanup**: Items disappear after 5 minutes if not looted

### **Loot Configuration**

```lua
Config.VehicleTrunkLoot = {
    enabled = true,
    -- Items in vehicle trunk
    trunk_items = {
        weapon_pistol = { count = 5, weight = 1.0 },
        cocaine_brick = { count = 3, weight = 2.0 },
        cash = { count = 20000, weight = 0.1 }
    },
    -- Items dropped by killed peds
    ped_drop_items = {
        weapon_pistol = { chance = 0.7, count = {1, 2} },
        cash = { chance = 0.8, count = {1000, 5000} }
    }
}
```

## 🆘 **Need Help?**

- Check console for error messages
- Use debug commands to identify issues
- Ensure all dependencies are loaded
- Verify job permissions are correct

---

**Made by DjonLuc** 🚔
