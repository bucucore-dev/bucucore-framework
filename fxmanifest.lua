fx_version 'cerulean'
game 'gta5'

name 'Bucu Core'
description 'Lightweight core framework for FiveM'
author 'Jofael Bucu'
version '1.0.0'

-- Lua files (Server)
server_scripts {
    'config/default-config.lua',
    'core/logger.lua',
    'core/config-manager.lua',
    'core/state-cache.lua',
    'core/event-system.lua',
    'core/permission-manager.lua',
    'core/module-loader.lua',
    'platform/player-manager.lua',
    'platform/fivem-adapter.lua',
    'bridge/lua-js-bridge.lua',
    'core/init.lua'
}

-- JavaScript files (Server)
server_scripts {
    '@bucu-core/core/logger.js',
    '@bucu-core/core/config-manager.js',
    '@bucu-core/core/state-cache.js',
    '@bucu-core/core/event-system.js',
    '@bucu-core/core/permission-manager.js',
    '@bucu-core/core/module-loader.js',
    '@bucu-core/platform/player-manager.js',
    '@bucu-core/platform/fivem-adapter.js',
    '@bucu-core/bridge/js-lua-bridge.js',
    '@bucu-core/core/init.js'
}

-- Dependencies
dependencies {
    '/server:5848',  -- Minimum FiveM server version
    '/onesync'       -- OneSync required
}
