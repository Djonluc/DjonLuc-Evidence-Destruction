Config = {}

-- Job Restrictions
Config.StartJobs = {"doj", "leo", "police", "sheriff", "bcso", "state", "fbi", "highway"} -- Jobs allowed to start the event
Config.GuardIgnoreJobs = {"police", "leo", "sheriff", "bcso", "state", "fbi", "highway"} -- Jobs ignored by escort peds

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
        spawn_offset = 5.0, -- Distance between escort cars
        spawn_direction = "right" -- "right", "left", or "both"
    },
    escort_suv = {
        model = "fbi2",
        armor = 1500,
        count = 1,
        livery = 0,
        spawn_offset = 5.0, -- Distance between escort SUVs
        spawn_direction = "left" -- "right", "left", or "both"
    },
    evidence_van = {
        model = "stockade",
        armor = 2000,
        count = 1,
        livery = 0,
        spawn_offset = 0.0 -- Center position
    }
}

-- Ped Configuration
Config.Peds = {
    escort_cop = {
        model = "s_m_y_cop_01",
        weapon = "WEAPON_PISTOL",
        count = 2,
        behavior = "aggressive",
        health = 200,
        armor = 100,
        vehicle_assignment = "escort_car", -- Which vehicle type to assign to
        seat_preference = "driver", -- "driver", "passenger", or "any"
        driving_style = "defensive" -- "defensive", "aggressive", "normal"
    },
    escort_swat = {
        model = "s_m_y_swat_01",
        weapon = "WEAPON_CARBINERIFLE",
        count = 1,
        behavior = "aggressive",
        health = 300,
        armor = 150,
        vehicle_assignment = "escort_suv", -- Which vehicle type to assign to
        seat_preference = "driver", -- "driver", "passenger", or "any"
        driving_style = "defensive" -- "defensive", "aggressive", "normal"
    }
}

-- Convoy Formation Settings
Config.ConvoyFormation = {
    formation_type = "line", -- "line", "diamond", "wedge", "random"
    spacing = 5.0, -- Distance between vehicles
    max_convoy_width = 20.0, -- Maximum width of convoy formation
    evidence_center = true, -- Evidence vehicle spawns in center
    escort_positions = {
        front_left = true,
        front_right = true,
        rear_left = true,
        rear_right = true,
        side_left = true,
        side_right = true
    }
}

-- Convoy Movement Settings
Config.ConvoyMovement = {
    speed = 20.0, -- Speed in m/s
    follow_distance = 8.0, -- Distance escort vehicles maintain from evidence vehicle
    formation_maintenance = true, -- Keep formation while moving
    emergency_formation = true, -- Tighten formation when under attack
    max_deviation = 15.0 -- Maximum distance escort vehicles can deviate from formation
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

-- AI Behavior Settings
Config.EscortAIBehavior = {
    aggressiveness = "aggressive",
    patrol_type = "defensive",
    support_radius = 50.0,
    alert_radius = 100.0
}

-- Notification Settings
Config.Notifications = {
    event_started = "Evidence destruction event started! Convoy spotted near {location}",
    event_ended = "Evidence destruction event ended. Convoy reached destination.",
    event_failed = "Evidence destruction event failed. Convoy was intercepted."
}
