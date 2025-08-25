# DjonLuc Evidence Destruction Event

A comprehensive FiveM resource for creating dynamic evidence destruction events with AI-driven convoys, customizable routes, and integrated loot systems.

## 🚀 Features

- **Multi-Framework Support**: Compatible with QBCore, ESX, QBox, and vRP
- **Dynamic Route System**: Create custom routes in-game or use preset configurations
- **AI-Driven Convoys**: Intelligent escort peds with realistic behavior patterns
- **Vehicle Trunk Loot**: Integrated loot system with item drops and vehicle destruction rewards
- **Real-time Blips**: Live tracking of convoy movement and destination
- **Job-Based Access**: Configurable job requirements for event management
- **Persistent Storage**: Save and load custom routes across server restarts

## 🎯 Quick Start

1. **Install Dependencies**:

   - Ensure your framework (QBCore/ESX) is running
   - Optional: `ox_lib` for enhanced UI components

2. **Configure Routes**:

   ```lua
   -- Use preset routes
   /preset police

   -- Create custom routes
   /createroute myroute
   /setstart
   /setend
   ```

3. **Start Event**:
   ```lua
   /startevidence
   ```

## 🛠️ Configuration

### Essential Commands

| Command               | Description                          | Usage                                  |
| --------------------- | ------------------------------------ | -------------------------------------- |
| `/startevidence`      | Start the evidence destruction event | Requires law enforcement job           |
| `/preset <name>`      | Use a preset route                   | `police`, `sandy`, `airport`, `city`   |
| `/createroute <name>` | Create a custom route                | Follow prompts to set start/end points |
| `/easyroute`          | Show route setup options             | Displays all available commands        |
| `/checkjob`           | Verify your job permissions          | Check if you can start events          |

### Route Management

- **Preset Routes**: Pre-configured routes for common scenarios
- **Custom Routes**: Player-created routes saved persistently
- **Dynamic Routes**: Real-time route creation and modification

## 📁 File Structure

```
├── config.lua              # Main configuration file
├── server/main.lua         # Server-side logic and events
├── client/main.lua         # Client-side UI and convoy management
├── client/ai.lua           # AI behavior for escort peds
├── shared/utils.lua        # Shared utility functions
├── fxmanifest.lua          # Resource manifest
├── QUICK_START.md          # Quick start guide
├── DOCUMENTATION.md        # Comprehensive documentation
└── examples/               # Configuration examples
```

## 🔧 Framework Compatibility

- **QBCore**: Full support with official detection methods
- **ESX**: Compatible with ESX framework
- **QBox**: QBCore-based framework support
- **vRP**: Legacy framework support

## 🎮 In-Game Features

- **Convoy Formation**: Configurable vehicle spacing and formation types
- **AI Behavior**: Realistic escort ped behavior with combat and movement patterns
- **Loot System**: Vehicle trunk items, ped drops, and destruction rewards
- **Blip Management**: Real-time convoy tracking with route visualization

## 📚 Documentation

- **[QUICK_START.md](QUICK_START.md)**: Step-by-step setup guide
- **[DOCUMENTATION.md](DOCUMENTATION.md)**: Comprehensive feature documentation
- **[examples/](examples/)**: Configuration examples and best practices

## 🚨 Support

For issues or questions:

1. Check the documentation files
2. Verify your framework configuration
3. Review console logs for error messages

## 📝 Changelog

### Recent Updates

- Removed all test/debug commands for production use
- Cleaned up redundant code and unused variables
- Enhanced convoy movement system with stuck vehicle prevention
- Improved ped spawning reliability and AI behavior
- Updated documentation to reflect current codebase state

---

**Note**: This resource has been cleaned up and optimized for production use. All test commands and debug code have been removed to ensure stability and performance.
