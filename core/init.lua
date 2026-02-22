-- Bucu Core - Main Initialization
-- Assembles all services and exposes the Core API

-- Load all services
local Logger = require('core/logger')
local ConfigManager = require('core/config-manager')
local StateCache = require('core/state-cache')
local EventSystem = require('core/event-system')
local PermissionManager = require('core/permission-manager')
local ModuleLoader = require('core/module-loader')
local PlayerManager = require('platform/player-manager')
local FiveMAdapter = require('platform/fivem-adapter')
local LuaJSBridge = require('bridge/lua-js-bridge')

-- Make services globally available (needed for cross-references)
_G.Logger = Logger
_G.ConfigManager = ConfigManager
_G.StateCache = StateCache
_G.EventSystem = EventSystem
_G.PermissionManager = PermissionManager
_G.ModuleLoader = ModuleLoader
_G.PlayerManager = PlayerManager
_G.FiveMAdapter = FiveMAdapter
_G.LuaJSBridge = LuaJSBridge

-- Core API Object
local Core = {
    version = "1.0.0",
    
    -- Internal services (private)
    _services = {
        logger = Logger,
        config = ConfigManager,
        cache = StateCache,
        events = EventSystem,
        permissions = PermissionManager,
        modules = ModuleLoader,
        players = PlayerManager,
        adapter = FiveMAdapter,
        bridge = LuaJSBridge
    },
    
    -- Event System API
    on = function(eventName, callback)
        return EventSystem:on(eventName, callback)
    end,
    
    emit = function(eventName, data)
        return EventSystem:emit(eventName, data)
    end,
    
    off = function(eventName, callback)
        return EventSystem:off(eventName, callback)
    end,
    
    -- Player API
    getPlayer = function(source)
        return PlayerManager:getPlayer(source)
    end,
    
    getPlayers = function()
        return PlayerManager:getPlayers()
    end,
    
    getPlayerCount = function()
        return PlayerManager:getPlayerCount()
    end,
    
    -- Config API
    getConfig = function(key, default)
        return ConfigManager:get(key, default)
    end,
    
    setConfig = function(key, value)
        return ConfigManager:set(key, value)
    end,
    
    -- Logging API
    log = {
        debug = function(msg) Logger:debug(msg) end,
        info = function(msg) Logger:info(msg) end,
        warn = function(msg) Logger:warn(msg) end,
        error = function(msg) Logger:error(msg) end,
        setLevel = function(level) Logger:setLevel(level) end,
        getLevel = function() return Logger:getLevel() end
    },
    
    -- Cache API
    cache = {
        get = function(key) return StateCache:get(key) end,
        set = function(key, value, ttl) return StateCache:set(key, value, ttl) end,
        delete = function(key) return StateCache:delete(key) end,
        has = function(key) return StateCache:has(key) end,
        clear = function() return StateCache:clear() end,
        getStats = function() return StateCache:getStats() end
    },
    
    -- Module API
    getModule = function(name)
        return ModuleLoader:getModule(name)
    end,
    
    isModuleLoaded = function(name)
        return ModuleLoader:isLoaded(name)
    end,
    
    -- Bridge API
    emitToJS = function(eventName, data)
        return LuaJSBridge:emitToJS(eventName, data)
    end,
    
    onFromJS = function(eventName, callback)
        return LuaJSBridge:onFromJS(eventName, callback)
    end
}

-- Initialize Core
function Core:init()
    print("^2========================================^0")
    print("^2  Bucu Core v" .. self.version .. "^0")
    print("^2  Initializing...^0")
    print("^2========================================^0")
    
    -- 1. Load configuration
    Logger:info("Loading configuration...")
    ConfigManager:load("config/default-config")
    
    -- Set log level from config
    local logLevel = ConfigManager:get("core.logLevel", "info")
    Logger:setLevel(logLevel)
    
    -- 2. Initialize Event System
    Logger:info("Event System ready")
    
    -- 3. Initialize State Cache
    Logger:info("State Cache ready")
    
    -- 4. Initialize Permission Manager
    Logger:info("Permission Manager ready")
    
    -- 5. Initialize FiveM Adapter
    Logger:info("Initializing FiveM Adapter...")
    FiveMAdapter:init()
    
    -- 6. Initialize Language Bridge
    Logger:info("Initializing Language Bridge...")
    LuaJSBridge:init()
    
    -- 7. Load Modules
    Logger:info("Loading modules...")
    ModuleLoader:loadModules()
    
    -- 8. Emit core:ready event
    Logger:info("Core initialization complete")
    EventSystem:emit("core:ready", { version = self.version })
    
    print("^2========================================^0")
    print("^2  Bucu Core Ready!^0")
    print("^2========================================^0")
    
    return true
end

-- Create BucuCore alias
_G.BucuCore = Core

-- Make Core globally available
_G.Core = Core

-- Auto-initialize
Citizen.CreateThread(function()
    Core:init()
end)

return Core
