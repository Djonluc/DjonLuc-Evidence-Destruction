# 🚓 Evidence Destruction Event

A dynamic FiveM script that spawns a high-security motorcade transporting confiscated items to a secure destruction site. Features configurable convoy composition, AI escort behavior, and loot crate mechanics.

## ✨ Features

- **Dynamic Convoy System**: Spawns armored vehicles with AI escorts
- **Job-Based Restrictions**: Only DOJ/LEO players can start events
- **Smart AI Guards**: Escort peds that engage non-law enforcement players
- **Loot Crate Mechanics**: Spawns when all escort guards are eliminated
- **Configurable Routes**: Multiple pre-defined routes with waypoints
- **Multi-Framework Support**: Auto-detects ESX, QBCore, QBox, and vRP
- **Smart Dependency Detection**: Automatically finds and uses available resources
- **Modular Design**: Easy to customize and extend

## 🚀 Installation

1. **Download** the script to your server's resources folder
2. **Add** `ensure djonluc_evidence_event` to your `server.cfg`
3. **Restart** your server or start the resource manually
4. **Configure** the script in `config.lua` to match your server

## 📋 Requirements

- FiveM Server
- **Framework Support**: ESX, QBCore, QBox, vRP (auto-detected)
- Basic Lua knowledge for customization

## 🔍 Auto-Detection System

The script automatically detects and adapts to your server's setup:

### Framework Detection

- **ESX**: Detects both legacy and export methods
- **QBCore**: Latest version support
- **QBox**: QBCore-based framework support
- **vRP**: Legacy framework support
- **Retry Mechanism**: Automatically retries detection if frameworks load late

### Optional Dependencies

- **Inventory Systems**: ox_inventory, qb-inventory
- **Target Systems**: ox_target, qb-target
- **Menu Systems**: ox_lib, qb-menu
- **Weapon Systems**: ox_weapons
- **Smart Fallbacks**: Uses framework defaults when optional deps aren't available

### ox_lib Integration

The script provides enhanced integration with ox_lib when available:

- **Modern Notifications**: Uses ox_lib's advanced notification system
- **Context Menus**: Interactive context menus for event control
- **Input Dialogs**: Fallback input dialogs if context menus fail
- **Automatic Fallbacks**: Gracefully degrades to framework defaults
- **Functionality Testing**: Built-in testing commands for ox_lib features

### Status Commands

- **Console**: `/evidence_status` - Full server status report
- **Console**: `/evidence_redetect` - Manually re-detect framework
- **Client**: `/evidence_check` - Client-side status check

## ⚙️ Configuration

### Job Restrictions

```lua
Config.StartJobs = {"doj", "leo"} -- Jobs that can start events
Config.GuardIgnoreJobs = {"police", "leo"} -- Jobs ignored by guards
```

### Convoy Setup

```lua
Config.Vehicles = {
    escort_car = {
        model = "police",
        armor = 1000,
        count = 2
    },
    evidence_van = {
        model = "stockade",
        armor = 2000,
        count = 1
    }
}
```

### AI Behavior

```lua
Config.EscortAIBehavior = {
    aggressiveness = "aggressive",
    support_radius = 50.0,
    alert_radius = 100.0
}
```

## 🎮 Usage

### Starting an Event

- **Command**: `/startevidence` (DOJ/LEO jobs only)
- **Permission**: Requires job type `doj` or `leo`

### Event Flow

1. **Event Triggered**: DOJ/LEO player starts event
2. **Convoy Spawns**: Vehicles and AI escorts appear
3. **Route Following**: Convoy follows configured waypoints
4. **Player Engagement**: Non-LEO players can attack convoy
5. **Loot Crate**: Spawns if all escort guards are killed
6. **Event End**: When convoy reaches destination or is intercepted

### Commands

- `/startevidence` - Start evidence destruction event
- `/endevent` - End current event (DOJ/LEO only)

### Console Commands for Convoy Routes

- `/setconvoystart <x> <y> <z>` - Set convoy start point
- `/setconvoyend <x> <y> <z>` - Set convoy end point
- `/setconvoyroute <start_x> <start_y> <start_z> <end_x> <end_y> <end_z>` - Set complete route
- `/resetconvoyroute` - Reset to default route
- `/convoyroute` - Show current route settings

### Console Commands for System Status

- `/evidence_status` - Full server status report
- `/evidence_redetect` - Manually re-detect framework
- `/test_oxlib` - Test ox_lib functionality and compatibility

## 🔧 Customization

### Adding New Routes

```lua
Config.Routes.route_3 = {
    start = vector3(x, y, z),
    destruction = vector3(x, y, z),
    waypoints = {
        vector3(x, y, z),
        vector3(x, y, z)
    }
}
```

### Programmatic Route Registration

```lua
-- From other resources
local customRoute = {
    start = vector3(100.0, 200.0, 30.0),
    destruction = vector3(500.0, 600.0, 40.0),
    waypoints = {
        vector3(150.0, 250.0, 32.0),
        vector3(200.0, 300.0, 35.0)
    }
}

exports['djonluc_evidence_event']:RegisterCustomRoute("my_route", customRoute)
```

### Dynamic Route Management

```lua
-- Set convoy start and end points programmatically
exports['djonluc_evidence_event']:SetConvoyStartPoint(100.0, 200.0, 30.0)
exports['djonluc_evidence_event']:SetConvoyEndPoint(500.0, 600.0, 40.0)

-- Get current dynamic route
local route = exports['djonluc_evidence_event']:GetCurrentDynamicRoute()

-- Reset to default route
exports['djonluc_evidence_event']:ResetConvoyRoute()
```

### Custom Loot Items

```lua
Config.LootCrateItems = {
    "weapon_pistol",
    "cocaine_brick",
    "cash",
    "your_custom_item"
}
```

### Vehicle Modifications

```lua
Config.Vehicles.custom_vehicle = {
    model = "your_vehicle_model",
    armor = 1500,
    count = 1,
    livery = 0
}
```

## 🐛 Troubleshooting

### Common Issues

1. **ESX Not Found**: Ensure ESX is properly installed and loaded
2. **Vehicles Not Spawning**: Check vehicle model names in config
3. **AI Not Working**: Verify ped model names and weapon hashes
4. **Permissions Denied**: Check job configuration and player permissions

### Dependency Testing

Run the included test script to verify all dependencies are working:

```lua
-- In server console
exec test_dependencies.lua
```

This will test:

- Framework detection
- Optional dependencies
- All exports
- Configuration loading
- Utility functions

### Debug Mode

Enable debug logging by adding to your server console:

```
set djonluc_evidence_event_debug 1
```

## 📁 File Structure

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
├── README.md           # This file
└── build.md            # Technical specifications
```

## 🔮 Future Enhancements

- [ ] Helicopter escort support
- [ ] Dynamic difficulty scaling
- [ ] Event notifications system
- [ ] Multiple convoy types
- [ ] Interactive evidence items
- [ ] Weather/time restrictions

## 🔌 Integration & Exports

### Available Exports

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

-- Manage custom routes
exports['djonluc_evidence_event']:RegisterCustomRoute(name, routeData)
exports['djonluc_evidence_event']:UnregisterCustomRoute(name)
```

### Framework Support

- **ESX**: Full compatibility with ESX Legacy and older versions
- **QBCore**: Complete QBCore integration with inventory system
- **QBox**: Full QBox framework support (QBCore-based)
- **vRP**: vRP framework support with user management
- **Auto-detection**: Automatically detects and configures for your framework

### Integration Examples

See `examples/integration.lua` for complete integration examples and usage patterns.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- **Discord**: Join our community server
- **Issues**: Report bugs on GitHub
- **Wiki**: Check the documentation
- **Forum**: Post questions in the FiveM forums

---

**Made with ❤️ for the FiveM community**
