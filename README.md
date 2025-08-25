# 🚔 DjonLuc Evidence Destruction Event

A high-security convoy escort mission script for FiveM servers featuring dynamic routes, armed escorts, and immersive gameplay.

## 📋 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Commands](#-commands)
- [Dependencies](#-dependencies)
- [Future Plans](#-future-plans)
- [Support](#-support)
- [Author](#-author)

## ✨ Features

### 🚗 **Convoy System**

- **Dynamic Route Generation** - Create custom routes in-game
- **Multi-Vehicle Formation** - Evidence van with police escort vehicles
- **Professional Blip System** - Real-time convoy tracking with status indicators
- **Formation Maintenance** - AI-driven convoy positioning and movement

### 👮 **Armed Escort System**

- **14 Armed Officers** - Fully manned convoy with professional AI
- **Seat Management** - All vehicle seats occupied by armed peds
- **Combat AI** - Advanced ped behavior with cover and tactics
- **Health Monitoring** - Real-time status tracking of all convoy members

### 🎯 **Mission Features**

- **In-Game Route Creation** - Set start/end points dynamically
- **Route Persistence** - Save and load custom routes
- **Distance Calculations** - Real-time progress tracking
- **Mission Success/Failure** - Dynamic event outcomes

### 🎒 **Loot & Inventory System**

- **Vehicle Trunk Loot** - Stockade filled with evidence items
- **Visual Item Spawning** - Realistic loot objects in vehicle trunks
- **Item Interaction** - Loot dropped items in the world
- **Configurable Loot Tables** - Customize available items

### 🎮 **Player Experience**

- **Multiple Menu Systems** - ox_lib, qb-menu, and fallback options
- **Keybind Support** - F6 menu access
- **Notification System** - ox_lib and fallback notifications
- **Debug Commands** - Comprehensive testing and monitoring tools

## 🚀 Installation

### 1. **Download & Extract**

```bash
# Download the script
git clone https://github.com/DjonLuc/evidence-destruction-event.git

# Extract to your resources folder
# Path: resources/[local]/DjonLuc%20Evidence%20Destruction/
```

### 2. **Dependencies**

The script automatically detects and uses available dependencies:

#### **Required:**

- **Framework**: QBCore, ESX, QBox, or vRP
- **FiveM Server** (Latest version recommended)

#### **Optional (Enhanced Features):**

- **ox_lib** - Advanced UI and notifications
- **qb-target** - Entity targeting system
- **qb-menu** - Menu system
- **qb_inventory** - Inventory integration
- **ox_inventory** - Alternative inventory system
- **ox_weapons** - Weapon system integration

### 3. **Server Configuration**

```lua
-- Add to server.cfg
ensure DjonLuc%20Evidence%20Destruction
```

### 4. **Permissions Setup**

```lua
-- Configure required jobs in config.lua
Config.StartJobs = {
    "police",
    "sheriff",
    "fbi",
    "swat"
}
```

## ⚙️ Configuration

### **Quick Setup**

1. **Edit `config.lua`** to customize your server settings
2. **Set spawn coordinates** for your preferred locations
3. **Configure vehicle models** and ped types
4. **Adjust loot tables** for your economy

### **Key Configuration Areas**

- **Vehicle Spawning** - Models, counts, and positions
- **Ped Configuration** - Types, weapons, and behavior
- **Route Settings** - Default routes and spawn points
- **Loot System** - Item types and spawn rates
- **Convoy Movement** - Speed, formation, and AI behavior

## 🎮 Commands

### **Player Commands**

- `/evidence_menu` - Open main event menu (F6 keybind)
- `/access_trunk` - Access evidence vehicle trunk
- `/toggleblip` - Toggle convoy blip visibility
- `/evidence_check` - Check system status

### **Admin Commands**

- `/startevidence` - Start the evidence destruction event
- `/setstart` - Set convoy start point
- `/setend` - Set convoy destination
- `/saveroute` - Save current route
- `/loadroute` - Load saved route
- `/routes` - List available routes

## 🔧 Dependencies

### **Framework Detection**

The script automatically detects and adapts to:

- **QBCore** (Latest versions)
- **ESX** (Legacy and Legacy+)
- **QBox** (QBCore variant)
- **vRP** (Legacy framework)

### **Optional Dependencies**

- **ox_lib** - Enhanced UI and notifications
- **qb-target** - Entity targeting
- **qb-menu** - Menu system
- **qb_inventory** - Inventory management

## 🚀 Future Plans

### **Phase 1: Combat Enhancement**

- [ ] **Dynamic Ambush System** - Random enemy spawns along routes
- [ ] **Advanced Ped AI** - Cover system and tactical formations
- [ ] **Weapon Progression** - Unlockable weapons and equipment
- [ ] **Mission Variants** - Different convoy types and objectives

### **Phase 2: Multiplayer Features**

- [ ] **Multi-Player Convoys** - Team-based missions
- [ ] **Role System** - Driver, Gunner, Medic, Scout
- [ ] **Crew Management** - Form permanent teams
- [ ] **Competitive Rankings** - Leaderboards and achievements

### **Phase 3: Environmental Enhancement**

- [ ] **Weather System** - Rain, fog, and night missions
- [ ] **Traffic AI** - Civilian vehicle reactions
- [ ] **Dynamic Routes** - Procedural mission generation
- [ ] **Environmental Hazards** - Construction zones, bridge crossings

### **Phase 4: Economy & Progression**

- [ ] **Evidence Collection** - Gather specific items for rewards
- [ ] **Black Market** - Sell evidence for higher prices
- [ ] **Vehicle Customization** - Armor, weapons, and performance upgrades
- [ ] **Reputation System** - Build standing with factions

### **Phase 5: Advanced Features**

- [ ] **Drone Reconnaissance** - Scout ahead for threats
- [ ] **EMP Systems** - Disable enemy vehicles
- [ ] **Thermal Vision** - Night operation equipment
- [ ] **Phone Integration** - Mission management app

## 🆘 Support

### **Discord Community**

Join our community for support, updates, and discussions:
**[Discord Server](https://discord.gg/k47HCwRCAJ)**

### **Documentation**

- **In-Game Help** - Use `/evidence_check` for system status
- **Debug Commands** - Available in `client/test_commands.lua`
- **Configuration Guide** - Detailed comments in `config.lua`

### **Troubleshooting**

1. **Check Framework Detection** - Use `/evidence_check` command
2. **Verify Dependencies** - Ensure required resources are started
3. **Check Permissions** - Verify job permissions in config
4. **Review Console Logs** - Look for error messages

## 👨‍💻 Author

### **DjonLuc**

- **Script Developer** - FiveM resource creator
- **Discord** - [Join Community](https://discord.gg/k47HCwRCAJ)
- **YouTube** - [DjonLuc Channel](https://www.youtube.com/@Djonluc)

### **Contributions**

- **Core Script Development**
- **AI and Ped Behavior Systems**
- **Vehicle and Convoy Management**
- **Loot and Economy Systems**
- **User Interface and Experience**

## 📄 License

This script is developed by DjonLuc for the FiveM community. Please respect the author's work and provide proper attribution when using or modifying this script.

---

**🎯 Ready to deploy high-security convoy missions? Start with the installation guide above and join our Discord for support!**

_Last Updated: December 2025_
