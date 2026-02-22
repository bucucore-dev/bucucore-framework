// Bucu Core - Main Initialization (JavaScript)
// Assembles all services and exposes the Core API

// Services are already loaded globally by Lua side
// JavaScript side provides API parity

// Core API Object
const Core = {
    version: "1.0.0",
    
    // Internal services (private)
    _services: {
        logger: typeof Logger !== 'undefined' ? Logger : null,
        config: typeof ConfigManager !== 'undefined' ? ConfigManager : null,
        cache: typeof StateCache !== 'undefined' ? StateCache : null,
        events: typeof EventSystem !== 'undefined' ? EventSystem : null,
        permissions: typeof PermissionManager !== 'undefined' ? PermissionManager : null,
        modules: typeof ModuleLoader !== 'undefined' ? ModuleLoader : null,
        players: typeof PlayerManager !== 'undefined' ? PlayerManager : null,
        adapter: typeof FiveMAdapter !== 'undefined' ? FiveMAdapter : null,
        bridge: typeof JSLuaBridge !== 'undefined' ? JSLuaBridge : null
    },
    
    // Event System API
    on(eventName, callback) {
        if (typeof EventSystem !== 'undefined') {
            return EventSystem.on(eventName, callback);
        }
        return false;
    },
    
    emit(eventName, data) {
        if (typeof EventSystem !== 'undefined') {
            return EventSystem.emit(eventName, data);
        }
        return false;
    },
    
    off(eventName, callback) {
        if (typeof EventSystem !== 'undefined') {
            return EventSystem.off(eventName, callback);
        }
        return false;
    },
    
    // Player API
    getPlayer(source) {
        if (typeof PlayerManager !== 'undefined') {
            return PlayerManager.getPlayer(source);
        }
        return null;
    },
    
    getPlayers() {
        if (typeof PlayerManager !== 'undefined') {
            return PlayerManager.getPlayers();
        }
        return [];
    },
    
    getPlayerCount() {
        if (typeof PlayerManager !== 'undefined') {
            return PlayerManager.getPlayerCount();
        }
        return 0;
    },
    
    // Config API
    getConfig(key, defaultValue) {
        if (typeof ConfigManager !== 'undefined') {
            return ConfigManager.get(key, defaultValue);
        }
        return defaultValue;
    },
    
    setConfig(key, value) {
        if (typeof ConfigManager !== 'undefined') {
            return ConfigManager.set(key, value);
        }
        return false;
    },
    
    // Logging API
    log: {
        debug(msg) {
            if (typeof Logger !== 'undefined') {
                Logger.debug(msg);
            }
        },
        info(msg) {
            if (typeof Logger !== 'undefined') {
                Logger.info(msg);
            }
        },
        warn(msg) {
            if (typeof Logger !== 'undefined') {
                Logger.warn(msg);
            }
        },
        error(msg) {
            if (typeof Logger !== 'undefined') {
                Logger.error(msg);
            }
        },
        setLevel(level) {
            if (typeof Logger !== 'undefined') {
                Logger.setLevel(level);
            }
        },
        getLevel() {
            if (typeof Logger !== 'undefined') {
                return Logger.getLevel();
            }
            return "info";
        }
    },
    
    // Cache API
    cache: {
        get(key) {
            if (typeof StateCache !== 'undefined') {
                return StateCache.get(key);
            }
            return null;
        },
        set(key, value, ttl) {
            if (typeof StateCache !== 'undefined') {
                return StateCache.set(key, value, ttl);
            }
            return false;
        },
        delete(key) {
            if (typeof StateCache !== 'undefined') {
                return StateCache.delete(key);
            }
            return false;
        },
        has(key) {
            if (typeof StateCache !== 'undefined') {
                return StateCache.has(key);
            }
            return false;
        },
        clear() {
            if (typeof StateCache !== 'undefined') {
                return StateCache.clear();
            }
            return 0;
        },
        getStats() {
            if (typeof StateCache !== 'undefined') {
                return StateCache.getStats();
            }
            return { size: 0, hits: 0, misses: 0, sets: 0, deletes: 0, hitRate: 0 };
        }
    },
    
    // Module API
    getModule(name) {
        if (typeof ModuleLoader !== 'undefined') {
            return ModuleLoader.getModule(name);
        }
        return null;
    },
    
    isModuleLoaded(name) {
        if (typeof ModuleLoader !== 'undefined') {
            return ModuleLoader.isLoaded(name);
        }
        return false;
    },
    
    // Bridge API
    emitToLua(eventName, data) {
        if (typeof JSLuaBridge !== 'undefined') {
            return JSLuaBridge.emitToLua(eventName, data);
        }
        return false;
    },
    
    onFromLua(eventName, callback) {
        if (typeof JSLuaBridge !== 'undefined') {
            return JSLuaBridge.onFromLua(eventName, callback);
        }
        return false;
    },
    
    // Initialize (called by Lua side)
    init() {
        if (typeof Logger !== 'undefined') {
            Logger.info("Bucu Core (JS) initialized");
        }
        
        // Initialize FiveM Adapter (JS side)
        if (typeof FiveMAdapter !== 'undefined') {
            FiveMAdapter.init();
        }
        
        // Initialize Language Bridge (JS side)
        if (typeof JSLuaBridge !== 'undefined') {
            JSLuaBridge.init();
        }
        
        return true;
    }
};

// Create BucuCore alias
if (typeof global !== 'undefined') {
    global.BucuCore = Core;
    global.Core = Core;
}

// Export for Node.js
if (typeof module !== 'undefined' && module.exports) {
    module.exports = Core;
}

// Auto-initialize when loaded
if (typeof setImmediate !== 'undefined') {
    setImmediate(() => {
        Core.init();
    });
} else if (typeof setTimeout !== 'undefined') {
    setTimeout(() => {
        Core.init();
    }, 0);
}
