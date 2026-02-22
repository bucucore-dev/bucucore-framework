// Bucu Core - JavaScript-Lua Bridge
// Enables cross-language event communication

const JSLuaBridge = {
    _initialized: false,
    
    // Initialize bridge
    init() {
        if (this._initialized) {
            return false;
        }
        
        if (typeof Logger !== 'undefined') {
            Logger.debug("Initializing JS-Lua Bridge");
        }
        
        // Register listener for events from Lua
        if (typeof EventSystem !== 'undefined') {
            // Events from Lua are prefixed with "lua:"
            // This is handled automatically by the event system
        }
        
        this._initialized = true;
        return true;
    },
    
    // Emit event to Lua runtime
    emitToLua(eventName, data) {
        if (typeof eventName !== "string" || eventName === "") {
            if (typeof Logger !== 'undefined') {
                Logger.error("Event name must be a non-empty string");
            }
            return false;
        }
        
        // Emit with "js:" prefix so Lua side knows it's from JavaScript
        if (typeof EventSystem !== 'undefined') {
            EventSystem.emit(`js:${eventName}`, data);
        }
        
        return true;
    },
    
    // Register listener for events from Lua
    onFromLua(eventName, callback) {
        if (typeof eventName !== "string" || eventName === "") {
            if (typeof Logger !== 'undefined') {
                Logger.error("Event name must be a non-empty string");
            }
            return false;
        }
        
        if (typeof callback !== "function") {
            if (typeof Logger !== 'undefined') {
                Logger.error("Callback must be a function");
            }
            return false;
        }
        
        // Listen for events with "lua:" prefix
        if (typeof EventSystem !== 'undefined') {
            EventSystem.on(`lua:${eventName}`, callback);
        }
        
        return true;
    },
    
    // Serialize data to JSON
    serialize(data) {
        try {
            return JSON.stringify(data);
        } catch (err) {
            if (typeof Logger !== 'undefined') {
                Logger.error(`Failed to serialize data: ${err.message}`);
            }
            return null;
        }
    },
    
    // Deserialize JSON to data
    deserialize(jsonStr) {
        try {
            return JSON.parse(jsonStr);
        } catch (err) {
            if (typeof Logger !== 'undefined') {
                Logger.error(`Failed to deserialize JSON: ${err.message}`);
            }
            return null;
        }
    }
};

// Export for Node.js and FiveM
if (typeof module !== 'undefined' && module.exports) {
    module.exports = JSLuaBridge;
}

// Make available globally in FiveM
if (typeof global !== 'undefined') {
    global.JSLuaBridge = JSLuaBridge;
}
