fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_script 'config.lua'

server_scripts {
    'bridge/framework.lua',
    'bridge/inventory.lua',
    'server/spawn.lua',
    'server/cleanup.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua',
    'client/ai.lua',
    'client/blips.lua'
}
