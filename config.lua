print("^5[CONVOY CHECKPOINT] config.lua loading...^7")
Config = {}

Config.Debug = {
    Enabled = true,   -- Turn off in production
    Verbose = true    -- Extra logs
}

---------------------------------------------------------------------
-- ROUTE SETTINGS
---------------------------------------------------------------------
Config.Route = {
    Start = vector4(503.31, -1019.22, 28.06, 358.57), -- Where the Lead Bikes spawn (Front of convoy)
    Destination = vector4(-1693.0, 3007.2, 32.99, 7.62), -- The final goal for the secure van
    DriveSpeed = 20.0,
    DrivingStyle = 1074528293, -- SWAT mode: Ignores traffic, high aggression
    RouteSelection = "fastest",
}

---------------------------------------------------------------------
-- VEHICLE SETTINGS
---------------------------------------------------------------------
Config.Formation = {
    Bikes = {
        { model = "policeb", seats = 1 }, -- Primary front scouts
        { model = "policeb", seats = 1 }  
    },

    Patrol = {
        model = "police3", -- Secondary lead vehicle
        seats = 2
    },

    SUV = {
        model = "fbi", -- Middle security SUV
        seats = 4
    },

    Van = {
        model = "riot", -- Switched to Armored Riot for emergency pathing
        health = 12000, -- Buffed HP
        bulletproofTires = true,
        engineOnSpawn = true,
        locked = true -- Keeps peds inside and players out until destroyed
    },

    Rear = {
        model = "fbi2", -- Tailgate security
        seats = 4
    }
}

---------------------------------------------------------------------
-- PED SETTINGS
---------------------------------------------------------------------
Config.Peds = {
    Driver = {
        model = "s_m_y_swat_01",
        weapon = "WEAPON_MICROSMG", -- Recommended for drive-bys
        accuracy = 95, -- Buffed for tactical difficulty
        armor = 200 -- Super armor
    },

    Guard = {
        model = "s_m_y_swat_01",
        weapon = "WEAPON_MICROSMG",
        accuracy = 90,
        armor = 200
    }
}

---------------------------------------------------------------------
-- AI BEHAVIOR SETTINGS
---------------------------------------------------------------------
Config.AI = {
    CombatMovement = 1, -- 1: Advance (Aggressive), 2: Defensive (Stay near car)
    CombatRange = 2,    -- 1: Short, 2: Medium (Hard AI), 3: Long
    AlwaysFight = true, -- If true, guards will never surrender or flee
    ExitOnAttack = true -- If true, guards exit vehicle when the van is stopped/stuck under fire
}

---------------------------------------------------------------------
-- LAW PROTECTION SETTINGS
---------------------------------------------------------------------
Config.LawProtection = {
    Enabled = true, -- If true, listed jobs are ignored by the convoy's aggression
    Jobs = {
        police = true,
        sheriff = true,
        state = true,
        fbi = true,
        swat = true
    }
}

---------------------------------------------------------------------
-- EVENT SETTINGS
---------------------------------------------------------------------
Config.Event = {
    StartDelay = 5,  -- Increased to 5s to allow formation to settle
    Cooldown = 1800, -- Secondary event cooldown (Seconds)
    Timeout = 1800,  -- Time before convoy automatically cleans up if not finished
    LootDistance = 5.0, -- Distance a player must be to the destroyed van to loot
    
    -- AdaptiveDifficulty: [EXPERIMENTAL]
    -- Scales guard accuracy and health based on player count nearby.
    AdaptiveDifficulty = false, 
    
    EnableBackup = false, -- [FUTURE] Calls more police units if van is under 50% HP
    EnableHeliSupport = false -- [FUTURE] Spawns a patrol helicopter
}

---------------------------------------------------------------------
-- LOOT SETTINGS
---------------------------------------------------------------------
Config.Loot = {
    {
        item = "cokebrick", -- The technical item name
        min = 2, -- Minimum count
        max = 5  -- Maximum count
    },
    {
        item = "goldbar",
        min = 2,
        max = 6
    },
    {
        item = "weapon_pistol",
        min = 1,
        max = 2
    }
}
