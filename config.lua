print("^5[CONVOY CHECKPOINT] config.lua loading...^7")
Config = {}

Config.Debug = {
    Enabled = true,   -- Turn off in production
    Verbose = true    -- Extra logs
}

---------------------------------------------------------------------
-- ROUTE SETTINGS
---------------------------------------------------------------------

-- Starting point of convoy
Config.Route = {
    Start = vector4(104.48, -998.14, 29.4, 337.34),
    Destination = vector4(-398.21, 132.82, 65.43, 88.54),
    DriveSpeed = 25.0
}

---------------------------------------------------------------------
-- VEHICLE SETTINGS
---------------------------------------------------------------------

-- You can use ANY vehicle model (addon compatible)
Config.Vehicles = {

    Van = {
        model = "stockade",
        engineOnSpawn = true,
        locked = true,
        bulletproofTires = true,
        livery = 0,
        extras = {},
        health = 6000
    },

    Escorts = {
        {
            model = "police3",
            seats = 4,
            bulletproofTires = true
        },
        {
            model = "police4",
            seats = 4,
            bulletproofTires = true
        },
        {
            model = "fbi2",
            seats = 4,
            bulletproofTires = true
        }
    }
}

---------------------------------------------------------------------
-- PED SETTINGS
---------------------------------------------------------------------

Config.Peds = {

    Driver = {
        model = "s_m_y_swat_01",
        weapon = "WEAPON_CARBINERIFLE",
        accuracy = 65,
        armor = 150
    },

    Guard = {
        model = "s_m_y_swat_01",
        weapon = "WEAPON_CARBINERIFLE",
        accuracy = 60,
        armor = 150
    }
}

---------------------------------------------------------------------
-- AI BEHAVIOR SETTINGS
---------------------------------------------------------------------

Config.AI = {
    CombatMovement = 2,
    CombatRange = 2,
    AlwaysFight = true,
    ExitOnAttack = true
}

---------------------------------------------------------------------
-- LAW PROTECTION SETTINGS
---------------------------------------------------------------------

Config.LawProtection = {
    Enabled = true,
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
    Cooldown = 1800,
    Timeout = 1800,
    LootDistance = 5.0,
    AdaptiveDifficulty = false,
    EnableBackup = false,
    EnableHeliSupport = false
}

---------------------------------------------------------------------
-- LOOT SETTINGS
---------------------------------------------------------------------

Config.Loot = {
    {
        item = "cokebrick",
        min = 2,
        max = 5
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
