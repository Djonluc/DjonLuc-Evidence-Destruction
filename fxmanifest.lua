fx_version 'cerulean'
game 'gta5'

author 'Djonluc'
description 'DjonLuc Evidence Destruction Event - Multi-Framework Convoy Escort System'
version '1.0.0'

-- Script loading order
shared_scripts {
    'config.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

-- Framework compatibility - Auto-detected
-- No hard dependencies required

-- Export functions for other resources
exports {
    'IsEventActive',
    'GetEventData',
    'StartEvidenceEvent',
    'EndEvidenceEvent',
    'GetConvoyPosition',
    'GetEscortPedsAlive',
    'GetCustomRoutes',
    'RegisterCustomRoute',
    'UnregisterCustomRoute',
    'GetPlayerJob',
    'InitializeEscortAI',
    'InitializeEnhancedEscortAI',
    'SetConvoyStartPoint',
    'SetConvoyEndPoint',
    'GetCurrentDynamicRoute',
    'ResetConvoyRoute'
}

-- Server exports
server_exports {
    'IsEventActive',
    'GetEventData',
    'StartEvidenceEvent',
    'EndEvidenceEvent',
    'GetConvoyPosition',
    'GetEscortPedsAlive',
    'GetCustomRoutes',
    'RegisterCustomRoute',
    'UnregisterCustomRoute',
    'GetPlayerJob',
    'SetConvoyStartPoint',
    'SetConvoyEndPoint',
    'GetCurrentDynamicRoute',
    'ResetConvoyRoute'
}

-- ========================================
-- FRAMEWORK SUPPORT & COMPATIBILITY
-- ========================================

-- Supported Frameworks (Auto-detected):
-- • QBCore (Latest Version) - Primary Framework
-- • QBox (QBCore-based Framework) - Full Compatibility
-- • ESX (ESX Legacy & Older Versions) - Fallback Support
-- • vRP (Legacy Version) - Fallback Support

-- ========================================
-- DEPENDENCIES BREAKDOWN
-- ========================================

-- 🚨 MANDATORY REQUIREMENTS:
-- • FiveM Server with Lua support (Lua 5.4 recommended)
-- • Framework: QBCore (Primary) - QBox, ESX, vRP (Fallback)
-- • Job System: DOJ, LEO, and police jobs must exist in QBCore
-- • Vehicle/Ped Models: All convoy vehicles and peds must be available
-- • QBCore Jobs: Ensure DOJ, LEO, and police jobs are configured

-- 🔧 OPTIONAL DEPENDENCIES (Auto-detected):
-- • qb-inventory - QBCore inventory system (Primary)
-- • ox_inventory - Modern inventory system (QBCore compatible)
-- • qb-target - QBCore target system (Primary)
-- • ox_target - Modern target system (QBCore compatible)
-- • qb-menu - QBCore menu system (Primary)
-- • ox_lib - Modern utility library (QBCore compatible)
-- • ox_weapons - Weapon management system (QBCore compatible)

-- ========================================
-- SERVER SETUP NOTES
-- ========================================

-- • Jobs must be recognized by AI for guard behavior (configure in config.lua)
-- • Inventory independence: Can use "dummy" loot crates if no inventory system
-- • Framework flexibility: Auto-detects and adapts to your setup
-- • AI behavior: Enhanced AI system included with realistic escort response
-- • Dynamic routes: Can set custom start/end points via console commands
-- • Auto-detection: No manual configuration required for dependencies

-- ========================================
-- CONSOLE COMMANDS
-- ========================================

-- Event Management:
-- • /startevidence - Start evidence destruction event
-- • /endevent - End current event (DOJ/LEO only)

-- Convoy Route Management:
-- • /setconvoystart <x> <y> <z> - Set convoy start point
-- • /setconvoyend <x> <y> <z> - Set convoy end point
-- • /setconvoyroute <start_x> <start_y> <start_z> <end_x> <end_y> <end_z> - Set complete route
-- • /resetconvoyroute - Reset to default route
-- • /convoyroute - Show current route settings

-- System Status:
-- • /evidence_status - Full server status report
-- • /evidence_redetect - Manually re-detect framework
-- • /test_oxlib - Test ox_lib functionality and compatibility

-- ========================================
-- INTEGRATION & USAGE
-- ========================================

-- The script automatically detects available resources and adapts accordingly
-- No manual dependency configuration required - just ensure your framework is running
-- Use the provided exports to integrate with other resources
-- All framework-specific functions are handled automatically

-- ========================================
-- QBCORE SETUP GUIDE
-- ========================================

-- For QBCore servers, ensure these jobs exist in qb-core/shared/jobs.lua:
-- 
-- ['doj'] = {
--     label = 'Department of Justice',
--     defaultGrade = 0,
--     grades = {
--         ['0'] = {
--             name = 'Agent',
--             payment = 50
--         }
--     }
-- },
-- 
-- ['leo'] = {
--     label = 'Law Enforcement',
--     defaultGrade = 0,
--     grades = {
--         ['0'] = {
--             name = 'Officer',
--             payment = 50
--         }
--     }
-- },
-- 
-- ['police'] = {
--             label = 'Police',
--             defaultGrade = 0,
--             grades = {
--                 ['0'] = {
--                     name = 'Recruit',
--                     payment = 50
--                 }
--             }
--         }
