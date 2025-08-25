Config = {}

-- Job Restrictions
Config.StartJobs = {"doj", "leo", "police", "sheriff", "bcso", "state", "fbi", "highway"} -- Jobs allowed to start the event
Config.GuardIgnoreJobs = {"police", "leo", "sheriff", "bcso", "state", "fbi", "highway"} -- Jobs ignored by escort peds

-- Event Settings
Config.EventDuration = 1800000 -- Event duration in milliseconds (30 minutes)

-- Debug Settings
Config.Debug = {
    enabled = true,
    verbose_logging = true,
    show_debug_commands = true
}

-- Dynamic Route Settings
Config.DynamicRoutes = {
    enabled = true,
    default_start = vector4(402.76, -1019.04, 29.33, 355.06), -- Police station
    default_end = vector4(-1594.21, 2807.17, 17.01, 44.21)    -- Remote location
}

-- Convoy Configuration
Config.Vehicles = {
    escort_car = {
        model = "police",
        armor = 1000,
        count = 2,
        livery = 0,
        spawn_offset = 5.0, -- Distance between vehicles in the line
        spawn_direction = "behind" -- "behind" for single file line formation
    },
    escort_suv = {
        model = "fbi2",
        armor = 1500,
        count = 1,
        livery = 0,
        spawn_offset = 5.0, -- Distance between vehicles in the line
        spawn_direction = "behind" -- "behind" for single file line formation
    },
    evidence_van = {
        model = "stockade",
        armor = 2000,
        count = 1,
        livery = 0,
        spawn_offset = 0.0 -- Front position
    }
}

-- Ped Configuration - All seats filled for maximum security
-- 
-- SEATING ARRANGEMENT:
-- 🚗 Police Cars (2): 4 seats each = 8 cops total
--   - Driver seat (-1): 1 cop per car
--   - Front passenger (0): 1 cop per car  
--   - Back left (1): 1 cop per car
--   - Back right (2): 1 cop per car
--
-- 🚙 FBI SUV (1): 4 seats = 4 SWAT total
--   - Driver seat (-1): 1 SWAT
--   - Front passenger (0): 1 SWAT
--   - Back left (1): 1 SWAT
--   - Back right (2): 1 SWAT
--
-- 🚐 Stockade (1): 2 seats = 2 cops total
--   - Driver seat (0): 1 cop
--   - Passenger seat (1): 1 cop
--
-- TOTAL: 14 armed officers protecting the convoy
--
Config.Peds = {
    escort_cop = {
        model = "s_m_y_cop_01",
        weapon = "WEAPON_PISTOL",
        count = 8, -- 2 police cars × 4 seats = 8 cops
        behavior = "aggressive",
        health = 200,
        armor = 100,
        seat_preference = "any" -- Fill any available seat
    },
    escort_swat = {
        model = "s_m_y_swat_01",
        weapon = "WEAPON_CARBINERIFLE",
        count = 4, -- 1 FBI SUV × 4 seats = 4 SWAT
        behavior = "aggressive",
        health = 300,
        armor = 150,
        seat_preference = "any" -- Fill any available seat
    },
    evidence_driver = {
        model = "s_m_y_cop_01",
        weapon = "WEAPON_PISTOL",
        count = 2, -- Stockade has 2 seats (driver + passenger)
        behavior = "aggressive",
        health = 250,
        armor = 150,
        seat_preference = "any" -- Fill any available seat
    }
}

-- Convoy Formation Settings
Config.ConvoyFormation = {
    formation_type = "line", -- "line" for single file formation
    spacing = 5.0, -- Distance between vehicles
    evidence_center = true -- Evidence vehicle spawns in center
}

-- Convoy Movement Settings
Config.ConvoyMovement = {
    speed = 20.0, -- Speed in m/s
    follow_distance = 8.0, -- Distance escort vehicles maintain from evidence vehicle
    formation_maintenance = true, -- Keep formation while moving
    emergency_formation = true, -- Tighten formation when under attack
    max_deviation = 15.0 -- Maximum distance escort vehicles can deviate from formation
}

-- Blip Settings (matching actual implementation)
Config.BlipSettings = {
    evidence_vehicle = {
        sprite = 67, -- Police car sprite
        color = 1,   -- Red color
        scale = 1.0,
        name = "Evidence Vehicle"
    },
    escort_car = {
        sprite = 56, -- Police car sprite
        color = 3,   -- Blue color
        scale = 1.0,
        name = "Escort Car"
    },
    escort_suv = {
        sprite = 56, -- Police car sprite
        color = 5,   -- Yellow color
        scale = 1.0,
        name = "Escort SUV"
    },
    main_convoy = {
        sprite = 67, -- Police car sprite
        color = 3,   -- Blue color
        scale = 1.0,
        name = "Evidence Convoy"
    },
    destination = {
        sprite = 1,  -- Destination sprite
        color = 2,   -- Green color
        scale = 1.0,
        name = "Destination"
    },
    protection_zone = {
        sprite = 1,  -- Standard sprite
        color = 1,   -- Red color
        scale = 50.0,
        alpha = 128,
        name = "Protection Zone"
    },
    status_indicator = {
        sprite = 84, -- Checkered flag sprite
        color = 2,   -- Green for active
        scale = 1.0,
        name = "Convoy Status"
    },
    route_progress = {
        sprite = 162, -- Route sprite
        color = 5,    -- Yellow for route
        scale = 1.0,
        name = "Route Progress"
    }
}

-- Evidence Items (items transported by convoy)
Config.EvidenceItems = {
    weapon_pistol = 5,
    cocaine_brick = 3,
    cash = 20000,
    meth = 2,
    weed_brick = 4,
    gold_bar = 1
}

-- Vehicle Trunk Loot System (replaces loot crate)
Config.VehicleTrunkLoot = {
    enabled = true,
    -- Items that spawn in evidence vehicle trunk when event starts
    trunk_items = {
        weapon_pistol = { count = 5, weight = 1.0 },
        cocaine_brick = { count = 3, weight = 2.0 },
        cash = { count = 20000, weight = 0.1 },
        meth = { count = 2, weight = 1.5 },
        weed_brick = { count = 4, weight = 1.0 },
        gold_bar = { count = 1, weight = 5.0 }
    },
    -- Items that drop when escort peds are killed
    ped_drop_items = {
        weapon_pistol = { chance = 0.7, count = {1, 2} },
        cocaine_brick = { chance = 0.5, count = {1, 1} },
        cash = { chance = 0.8, count = {1000, 5000} },
        meth = { chance = 0.3, count = {1, 1} }
    },
    -- Items that spawn when evidence vehicle is destroyed
    vehicle_destroyed_items = {
        weapon_pistol = { count = {2, 4} },
        cocaine_brick = { count = {1, 3} },
        cash = { count = {5000, 15000} },
        meth = { count = {1, 2} },
        weed_brick = { count = {2, 4} },
        gold_bar = { count = {1, 2} }
    }
}

-- Routes
Config.Routes = {
    route_1 = {
        start = vector4(402.76, -1019.04, 29.33, 355.06),        -- Convoy spawn point with heading
        destruction = vector4(-1594.21, 2807.17, 17.01, 44.21)   -- Final destination with heading
    }
}

-- Notification Settings
Config.Notifications = {
    event_started = "Evidence destruction event started! Convoy spotted near {location}",
    event_ended = "Evidence destruction event ended. Convoy reached destination.",
    event_failed = "Evidence destruction event failed. Convoy was intercepted."
}

-- ========================================
-- CONFIG NOTES
-- ========================================
-- 
-- ACTUALLY IMPLEMENTED FEATURES:
-- ✅ Job restrictions (Config.StartJobs, Config.GuardIgnoreJobs)
-- ✅ Event duration (Config.EventDuration)
-- ✅ Debug settings (Config.Debug)
-- ✅ Dynamic routes (Config.DynamicRoutes)
-- ✅ Vehicle configuration (Config.Vehicles)
-- ✅ Ped configuration (Config.Peds) - ALL SEATS FILLED
-- ✅ Convoy formation (Config.ConvoyFormation)
-- ✅ Convoy movement (Config.ConvoyMovement)
-- ✅ Blip settings (Config.BlipSettings) - matches actual implementation
-- ✅ Evidence items (Config.EvidenceItems)
-- ✅ Vehicle trunk loot (Config.VehicleTrunkLoot)
-- ✅ Routes (Config.Routes)
-- ✅ Notifications (Config.Notifications)
--
-- NEW: FULL SEATING CONFIGURATION
-- 🚗 2 Police Cars: 8 cops (4 seats × 2 cars)
-- 🚙 1 FBI SUV: 4 SWAT (4 seats × 1 SUV)  
-- 🚐 1 Stockade: 2 cops (2 seats × 1 van)
-- 🎯 TOTAL: 14 armed officers protecting the convoy
--
-- NOT IMPLEMENTED (removed):
-- ❌ Config.LootSettings - not used in current implementation
-- ❌ Config.EscortAIBehavior - not used in current implementation
-- ❌ Config.Peds.*.vehicle_assignment - not used in current implementation
-- ❌ Config.Peds.*.driving_style - not used in current implementation
-- ❌ Config.ConvoyFormation.escort_positions - not used in current implementation
--
-- ========================================
