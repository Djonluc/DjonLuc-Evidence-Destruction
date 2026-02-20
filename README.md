<p align="center">
  <img src="https://img.shields.io/badge/DEVELOPED%20BY-DjonStNix-blue?style=for-the-badge&logo=github" alt="DjonStNix" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-FiveM-orange?style=flat-square&logo=fivem" alt="FiveM" />
  <img src="https://img.shields.io/badge/Language-Lua-blue?style=flat-square&logo=lua" alt="Lua" />
  <img src="https://img.shields.io/badge/Framework-Multi--Framework-brightgreen?style=flat-square" alt="Multi-Framework" />
  <img src="https://img.shields.io/badge/Maintained-Yes-brightgreen?style=flat-square" alt="Maintained" />
  <img src="https://img.shields.io/badge/Version-2.0-blue?style=flat-square" alt="Version 2.0" />
</p>

---

# 🚔 DjonLuc Evidence Destruction — Elite Convoy System

> **A high-stakes convoy interception event for FiveM. Six armored vehicles. Lethal AI guards. One target.**

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Convoy Formation](#-convoy-formation)
- [Features](#-features)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Commands](#-commands)
- [Dependencies](#-dependencies)
- [Project Structure](#-project-structure)
- [Support](#-support)
- [Author](#-author)

---

## 🎯 Overview

A **6-vehicle armored convoy** transports high-value evidence across the map. Players must intercept, disable, and loot the armored van — while surviving an elite AI security detail trained to kill on sight.

The convoy features a **reactive state machine** (CALM → ALERT → DEFENSIVE) that dynamically adjusts AI behavior, formation speed, and engagement protocols based on player aggression.

---

## 🚗 Convoy Formation

The Elite Formation deploys **6 vehicles** in a tight, synchronized column:

| Position | Vehicle | Model | Crew | Role |
|----------|---------|-------|------|------|
| 🏍️ Front Left | Lead Bike | `policeb` | 1 Driver | Point Scout |
| 🏍️ Front Right | Lead Bike | `policeb` | 1 Driver | Point Scout |
| 🚓 8m behind | Patrol Car | `police3` | Driver + 1 Guard | Forward Security |
| 🚙 16m behind | FBI SUV | `fbi` | Driver + 3 Guards | Mid Security |
| 🚐 26m behind | **Armored Van** | `riot` | Driver + 1 Guard | **Primary Target** |
| 🚙 36m behind | Rear Escort | `fbi2` | Driver + 3 Guards | Tail Protection |

> **Total Personnel:** ~14 armed SWAT operatives with 90-95% accuracy and 200 armor.

---

## ✨ Features

### 🛡️ Elite AI System
- **Lethal Accuracy** — Guards hit with 90-95% precision
- **No Surrender** — AI will never flee, panic, or put hands up
- **Drive-By Combat** — Guards engage from moving vehicles
- **Dismount Protocol** — Guards exit and fight on foot when hostiles approach within 60m
- **Reactive Targeting** — 120m threat detection radius

### 🚦 State Machine
| State | Trigger | Behavior |
|-------|---------|----------|
| **CALM** | Default | Normal patrol speed, weapons holstered |
| **ALERT** | 1+ hostile or <90% HP | Speed +5 MPH, weapons drawn |
| **DEFENSIVE** | 3+ hostiles or <50% HP | **Convoy halts**, guards deploy on foot |

### ⚡ Formation Control
- **Hard Speed Lock** — Client-side thread prevents any escort from outrunning the leader
- **TaskVehicleEscort** — All vehicles maintain tight formation behind the leader
- **Synchronized Sirens** — Emergency lights active on all law vehicles
- **Aggressive Pathing** — Convoy ignores traffic lights and civilian vehicles

### 🎒 Loot System
- Configurable loot tables (drugs, weapons, valuables)
- `ox_lib` progress bar or fallback timer
- `qb-target` / `ox_target` entity interaction support
- Server-side validation with distance checks

### 🌐 Multi-Framework Support
- **QBCore** (v1/v2) — Full job & inventory integration
- **ESX** (Legacy/Legacy+) — Complete compatibility
- **QBox** — QBCore-based framework support
- **vRP** (v1/v2) — Group permission system
- **Standalone** — Works without any framework

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Djonluc/DjonLuc-Evidence-Destruction.git
```

### 2. Add to Server Resources

Place the folder in your `resources/[addons]/` directory.

### 3. Update `server.cfg`

```cfg
ensure DjonLuc-Evidence-Destruction
```

### 4. Configure

Edit `config.lua` to set your spawn coordinates, route, AI difficulty, and loot tables.

---

## ⚙️ Configuration

All settings are in `config.lua` with detailed comments:

| Section | What it Controls |
|---------|-----------------|
| `Config.Route` | Start/destination coords, speed, driving style |
| `Config.Formation` | Vehicle models for Bikes, Patrol, SUV, Van, Rear |
| `Config.Peds` | Guard/driver models, weapons, accuracy, armor |
| `Config.AI` | Combat movement, range, relationship groups |
| `Config.Event` | Cooldown, start delay, loot distance, permissions |
| `Config.Loot` | Item names, min/max quantities |

### Key Settings

```lua
Config.Route.DrivingStyle = 1074528293  -- Aggressive SWAT (ignores traffic)
Config.Route.DriveSpeed = 35.0          -- MPH

Config.Formation.Van.health = 12000     -- Armored van HP
Config.Peds.Guard.accuracy = 90         -- AI hit rate
Config.Peds.Guard.armor = 200           -- AI durability
```

---

## 🎮 Commands

| Command | Permission | Description |
|---------|-----------|-------------|
| `/convoystart` | Admin | Spawn and start the convoy |
| `/convoystop` | Admin | Destroy and clean up the convoy |
| `/convoyspawnhere` | Admin | Spawn a test van at your location |
| `/convoydebug` | Admin | Print entity diagnostics |

---

## 🔧 Dependencies

### Required
- **FiveM Server** (Latest build)
- **Framework**: QBCore, ESX, QBox, vRP, or Standalone

### Optional (Enhanced Features)
- [ox_lib](https://github.com/overextended/ox_lib) — Progress bars, notifications
- [qb-target](https://github.com/qbcore-framework/qb-target) — Entity interaction
- [ox_target](https://github.com/overextended/ox_target) — Alternative targeting
- [qb-inventory](https://github.com/qbcore-framework/qb-inventory) — Inventory system
- [ox_inventory](https://github.com/overextended/ox_inventory) — Alternative inventory

---

## 📁 Project Structure

```
DjonLuc-Evidence-Destruction/
├── config.lua              # All configuration settings
├── fxmanifest.lua          # Resource manifest
├── bridge/
│   ├── framework.lua       # Auto-detect QBCore/ESX/QBox/vRP
│   └── inventory.lua       # Inventory bridge (qb/ox/esx)
├── server/
│   ├── main.lua            # State machine, sync, events
│   ├── spawn.lua           # Vehicle & ped spawning
│   └── cleanup.lua         # Entity cleanup routines
├── client/
│   ├── main.lua            # Movement, escort, speed lock
│   ├── ai.lua              # Combat AI, targeting, groups
│   └── blips.lua           # Map blip management
└── README.md
```

---

## 🆘 Support

### Discord
**[Join the Community](https://discord.gg/k47HCwRCAJ)** — Support, updates, and feature requests.

### Troubleshooting
1. Run `/convoydebug` to check entity states
2. Check the F8 console for `[CONVOY]` prefixed logs
3. Verify your framework is detected with the startup print
4. Ensure `ox_lib` is started **before** this resource

---

## 👨‍💻 Author

<p align="center">
  <img src="https://img.shields.io/badge/DjonStNix-Official-blue?style=for-the-badge" alt="DjonStNix Official" />
</p>

**Djon StNix** — Software Developer & Digital Creator

| Platform | Link |
|----------|------|
| 🐙 GitHub | [github.com/Djonluc](https://github.com/Djonluc) |
| 📧 Email | [djonstnix@gmail.com](mailto:djonstnix@gmail.com) |
| 🎬 YouTube | [@Djonluc](https://www.youtube.com/@Djonluc) |
| 📸 Instagram | [@Djonluc](https://www.instagram.com/Djonluc) |
| 💬 Discord | [Community Server](https://discord.gg/k47HCwRCAJ) |

---

## 📝 License

This project is developed by **Djon StNix** for the FiveM community.
Attribution is required when using or modifying this script.

© 2026 Djon StNix — All rights reserved.

---

<p align="center">
  <sub>Built with precision by <strong>DjonStNix</strong> · <em>Modern. Scalable. Intentional.</em></sub>
</p>
