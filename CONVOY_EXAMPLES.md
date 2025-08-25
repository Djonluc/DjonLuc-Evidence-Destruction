# 🚗 Convoy Configuration Examples

**Made by DjonLuc** 🚔

This file shows you different ways to configure your convoy for the Evidence Destruction Event.

## 🎯 **Basic Convoy Setup**

### **Small Police Convoy (3 vehicles, 3 peds)**

```lua
Config.Vehicles = {
    escort_car = {
        model = "police",
        armor = 1000,
        count = 1,
        livery = 0,
        spawn_offset = 5.0,
        spawn_direction = "right"
    },
    escort_suv = {
        model = "fbi2",
        armor = 1500,
        count = 1,
        livery = 0,
        spawn_offset = 5.0,
        spawn_direction = "left"
    },
    evidence_van = {
        model = "stockade",
        armor = 2000,
        count = 1,
        livery = 0,
        spawn_offset = 0.0
    }
}

Config.Peds = {
    escort_cop = {
        model = "s_m_y_cop_01",
        weapon = "WEAPON_PISTOL",
        count = 1,
        behavior = "aggressive",
        health = 200,
        armor = 100,
        vehicle_assignment = "escort_car",
        seat_preference = "driver",
        driving_style = "defensive"
    },
    escort_swat = {
        model = "s_m_y_swat_01",
        weapon = "WEAPON_CARBINERIFLE",
        count = 1,
        behavior = "aggressive",
        health = 300,
        armor = 150,
        vehicle_assignment = "escort_suv",
        seat_preference = "driver",
        driving_style = "defensive"
    }
}
```

## 🚔 **Large Police Convoy (5 vehicles, 5 peds)**

### **Heavy Escort Setup**

```lua
Config.Vehicles = {
    escort_car = {
        model = "police",
        armor = 1000,
        count = 3,
        livery = 0,
        spawn_offset = 6.0,
        spawn_direction = "both" -- Spawns on both sides
    },
    escort_suv = {
        model = "fbi2",
        armor = 1500,
        count = 2,
        livery = 0,
        spawn_offset = 6.0,
        spawn_direction = "both"
    },
    evidence_van = {
        model = "stockade",
        armor = 2000,
        count = 1,
        livery = 0,
        spawn_offset = 0.0
    }
}

Config.Peds = {
    escort_cop = {
        model = "s_m_y_cop_01",
        weapon = "WEAPON_PISTOL",
        count = 3,
        behavior = "aggressive",
        health = 200,
        armor = 100,
        vehicle_assignment = "escort_car",
        seat_preference = "driver",
        driving_style = "aggressive"
    },
    escort_swat = {
        model = "s_m_y_swat_01",
        weapon = "WEAPON_CARBINERIFLE",
        count = 2,
        behavior = "aggressive",
        health = 300,
        armor = 150,
        vehicle_assignment = "escort_suv",
        seat_preference = "driver",
        driving_style = "aggressive"
    }
}
```

## 🚁 **Military-Style Convoy (7 vehicles, 7 peds)**

### **Maximum Security Setup**

```lua
Config.Vehicles = {
    escort_car = {
        model = "police",
        armor = 1500,
        count = 4,
        livery = 0,
        spawn_offset = 7.0,
        spawn_direction = "both"
    },
    escort_suv = {
        model = "fbi2",
        armor = 2000,
        count = 3,
        livery = 0,
        spawn_offset = 7.0,
        spawn_direction = "both"
    },
    evidence_van = {
        model = "stockade",
        armor = 2500,
        count = 1,
        livery = 0,
        spawn_offset = 0.0
    }
}

Config.Peds = {
    escort_cop = {
        model = "s_m_y_cop_01",
        weapon = "WEAPON_PISTOL",
        count = 4,
        behavior = "aggressive",
        health = 250,
        armor = 150,
        vehicle_assignment = "escort_car",
        seat_preference = "driver",
        driving_style = "aggressive"
    },
    escort_swat = {
        model = "s_m_y_swat_01",
        weapon = "WEAPON_CARBINERIFLE",
        count = 3,
        behavior = "aggressive",
        health = 350,
        armor = 200,
        vehicle_assignment = "escort_suv",
        seat_preference = "driver",
        driving_style = "aggressive"
    }
}
```

## 🚓 **Custom Vehicle Models**

### **Different Police Vehicles**

```lua
Config.Vehicles = {
    escort_car = {
        model = "police3", -- Unmarked police car
        armor = 1000,
        count = 2,
        livery = 0,
        spawn_offset = 5.0,
        spawn_direction = "right"
    },
    escort_suv = {
        model = "riot", -- Riot van
        armor = 2000,
        count = 1,
        livery = 0,
        spawn_offset = 5.0,
        spawn_direction = "left"
    },
    evidence_van = {
        model = "mule", -- Different evidence van
        armor = 2000,
        count = 1,
        livery = 0,
        spawn_offset = 0.0
    }
}
```

## 🎮 **Different Ped Types**

### **Mixed Security Team**

```lua
Config.Peds = {
    escort_cop = {
        model = "s_m_y_cop_01",
        weapon = "WEAPON_PISTOL",
        count = 2,
        behavior = "aggressive",
        health = 200,
        armor = 100,
        vehicle_assignment = "escort_car",
        seat_preference = "driver",
        driving_style = "defensive"
    },
    escort_swat = {
        model = "s_m_y_swat_01",
        weapon = "WEAPON_CARBINERIFLE",
        count = 1,
        behavior = "aggressive",
        health = 300,
        armor = 150,
        vehicle_assignment = "escort_suv",
        seat_preference = "driver",
        driving_style = "aggressive"
    },
    -- Add more ped types if needed
    escort_soldier = {
        model = "s_m_y_army_01",
        weapon = "WEAPON_SPECIALCARBINE",
        count = 1,
        behavior = "aggressive",
        health = 400,
        armor = 200,
        vehicle_assignment = "escort_suv",
        seat_preference = "passenger",
        driving_style = "normal"
    }
}
```

## 🚀 **Convoy Formation Options**

### **Tight Formation (Military Style)**

```lua
Config.ConvoyFormation = {
    formation_type = "diamond",
    spacing = 3.0, -- Tighter spacing
    max_convoy_width = 15.0,
    escort_positions = {
        front_left = true,
        front_right = true,
        rear_left = true,
        rear_right = true,
        side_left = false,
        side_right = false
    }
}

Config.ConvoyMovement = {
    speed = 25.0, -- Faster movement
    follow_distance = 5.0, -- Closer following
    formation_maintenance = true,
    emergency_formation = true,
    max_deviation = 8.0 -- Less deviation allowed
}
```

### **Loose Formation (Police Style)**

```lua
Config.ConvoyFormation = {
    formation_type = "line",
    spacing = 8.0, -- Wider spacing
    max_convoy_width = 25.0,
    escort_positions = {
        front_left = true,
        front_right = true,
        rear_left = true,
        rear_right = true,
        side_left = true,
        side_right = true
    }
}

Config.ConvoyMovement = {
    speed = 18.0, -- Slower, more controlled
    follow_distance = 12.0, -- More distance between vehicles
    formation_maintenance = true,
    emergency_formation = false,
    max_deviation = 20.0 -- More deviation allowed
}
```

## ⚡ **Performance Optimizations**

### **Lightweight Convoy (Better Performance)**

```lua
Config.Vehicles = {
    escort_car = {
        model = "police",
        armor = 1000,
        count = 1, -- Reduced count
        livery = 0,
        spawn_offset = 5.0,
        spawn_direction = "right"
    },
    escort_suv = {
        model = "fbi2",
        armor = 1500,
        count = 1, -- Reduced count
        livery = 0,
        spawn_offset = 5.0,
        spawn_direction = "left"
    },
    evidence_van = {
        model = "stockade",
        armor = 2000,
        count = 1,
        livery = 0,
        spawn_offset = 0.0
    }
}

Config.Peds = {
    escort_cop = {
        model = "s_m_y_cop_01",
        weapon = "WEAPON_PISTOL",
        count = 1, -- Reduced count
        behavior = "aggressive",
        health = 200,
        armor = 100,
        vehicle_assignment = "escort_car",
        seat_preference = "driver",
        driving_style = "defensive"
    },
    escort_swat = {
        model = "s_m_y_swat_01",
        weapon = "WEAPON_CARBINERIFLE",
        count = 1, -- Reduced count
        behavior = "aggressive",
        health = 300,
        armor = 150,
        vehicle_assignment = "escort_suv",
        seat_preference = "driver",
        driving_style = "defensive"
    }
}
```

## 🔧 **Configuration Tips**

### **1. Balance Performance vs. Realism**

- **Small servers**: Use 1-2 escort vehicles
- **Medium servers**: Use 2-3 escort vehicles
- **Large servers**: Use 3-4+ escort vehicles

### **2. Vehicle Spacing**

- **Tight formation**: 3.0 - 5.0 spacing
- **Normal formation**: 5.0 - 7.0 spacing
- **Loose formation**: 7.0+ spacing

### **3. Driving Styles**

- **defensive**: Cautious, maintains distance
- **aggressive**: Fast, close formation
- **normal**: Balanced approach

### **4. Spawn Directions**

- **"right"**: Spawns vehicles to the right
- **"left"**: Spawns vehicles to the left
- **"both"**: Alternates left and right

## 📊 **Quick Reference**

| Convoy Size | Vehicles | Peds     | Performance Impact |
| ----------- | -------- | -------- | ------------------ |
| Small       | 3        | 3        | Low                |
| Medium      | 5        | 5        | Medium             |
| Large       | 7        | 7        | High               |
| Custom      | Variable | Variable | Variable           |

## 🎯 **Testing Your Configuration**

1. **Use `/testconvoy`** to verify your settings
2. **Start with small numbers** and increase gradually
3. **Monitor server performance** while testing
4. **Adjust spacing** if vehicles clip or overlap

---

**Remember**: You can mix and match these configurations! Start simple and build up to your desired convoy size. 🚗💨
