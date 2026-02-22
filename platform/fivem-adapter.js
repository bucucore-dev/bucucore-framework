// Bucu Core - FiveM Adapter (JavaScript)
// Bridges Core and FiveM-specific APIs

const FiveMAdapter = {
    _initialized: false,
    
    // Initialize FiveM adapter
    init() {
        if (this._initialized) {
            if (typeof Logger !== 'undefined') {
                Logger.warn("FiveM Adapter already initialized");
            }
            return false;
        }
        
        if (typeof Logger !== 'undefined') {
            Logger.info("Initializing FiveM Adapter (JS)");
        }
        
        // Note: Player connection/disconnection is handled by Lua side
        // JS side focuses on event bridging and utility functions
        
        // Register network events for cross-language communication
        if (typeof RegisterNetEvent !== 'undefined') {
            RegisterNetEvent("bucu:clientEventJS");
            on("bucu:clientEventJS", (eventName, data) => {
                const source = global.source;
                
                if (typeof EventSystem !== 'undefined') {
                    EventSystem.emit(`client:${eventName}`, {
                        source: source,
                        data: data
                    });
                }
            });
        }
        
        this._initialized = true;
        
        if (typeof Logger !== 'undefined') {
            Logger.info("FiveM Adapter (JS) initialized");
        }
        
        return true;
    },
    
    // Trigger client event
    triggerClient(source, eventName, data) {
        if (typeof source !== "number") {
            if (typeof Logger !== 'undefined') {
                Logger.error("Source must be a number");
            }
            return false;
        }
        
        if (typeof eventName !== "string" || eventName === "") {
            if (typeof Logger !== 'undefined') {
                Logger.error("Event name must be a non-empty string");
            }
            return false;
        }
        
        if (typeof TriggerClientEvent !== 'undefined') {
            TriggerClientEvent(eventName, source.toString(), data);
        }
        return true;
    },
    
    // Trigger client event for all players
    triggerClientAll(eventName, data) {
        if (typeof eventName !== "string" || eventName === "") {
            if (typeof Logger !== 'undefined') {
                Logger.error("Event name must be a non-empty string");
            }
            return false;
        }
        
        if (typeof TriggerClientEvent !== 'undefined') {
            TriggerClientEvent(eventName, "-1", data);
        }
        return true;
    },
    
    // Get player name
    getPlayerName(source) {
        if (typeof GetPlayerName !== 'undefined') {
            return GetPlayerName(source.toString());
        }
        return null;
    },
    
    // Get player identifiers
    getPlayerIdentifiers(source) {
        if (typeof GetPlayerIdentifiers !== 'undefined') {
            return GetPlayerIdentifiers(source.toString());
        }
        return [];
    },
    
    // Get player ping
    getPlayerPing(source) {
        if (typeof GetPlayerPing !== 'undefined') {
            return GetPlayerPing(source.toString());
        }
        return 0;
    },
    
    // Get player endpoint (IP)
    getPlayerEndpoint(source) {
        if (typeof GetPlayerEndpoint !== 'undefined') {
            return GetPlayerEndpoint(source.toString());
        }
        return null;
    },
    
    // Get all player sources
    getPlayers() {
        if (typeof GetPlayers !== 'undefined') {
            const players = GetPlayers();
            return players.map(p => parseInt(p));
        }
        return [];
    },
    
    // Check if player exists
    playerExists(source) {
        return this.getPlayerName(source) !== null;
    },
    
    // Drop player (kick)
    dropPlayer(source, reason = "Kicked") {
        if (typeof DropPlayer !== 'undefined') {
            DropPlayer(source.toString(), reason);
        }
        return true;
    },
    
    // Register server event
    registerServerEvent(eventName) {
        if (typeof RegisterNetEvent !== 'undefined') {
            RegisterNetEvent(eventName);
        }
        return true;
    },
    
    // Trigger server event
    triggerServerEvent(eventName, ...args) {
        if (typeof TriggerEvent !== 'undefined') {
            TriggerEvent(eventName, ...args);
        }
        return true;
    }
};

// Export for Node.js and FiveM
if (typeof module !== 'undefined' && module.exports) {
    module.exports = FiveMAdapter;
}

// Make available globally in FiveM
if (typeof global !== 'undefined') {
    global.FiveMAdapter = FiveMAdapter;
}
