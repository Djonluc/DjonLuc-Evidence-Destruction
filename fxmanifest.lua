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
