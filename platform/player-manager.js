// Bucu Core - Player Manager (JavaScript)
// Manages player objects and lifecycle

const PlayerManager = {
    _players: new Map(),  // Map<number, Player>
};

// Player class
class Player {
    constructor(source, name, identifier) {
        this.id = source;
        this.name = name || "Unknown";
        this.identifier = identifier || "";
        this.ping = 0;
    }
    
    // Get player permission
    getPermission() {
        if (typeof PermissionManager !== 'undefined') {
            return PermissionManager.getPermission(this.id);
        }
        return "user";
    }
    
    // Set player permission
    setPermission(role) {
        if (typeof PermissionManager !== 'undefined') {
            return PermissionManager.setPermission(this.id, role);
        }
        return false;
    }
    
    // Get player metadata
    getMeta(key) {
        if (typeof StateCache !== 'undefined') {
            const cacheKey = `player:${this.id}:meta:${key}`;
            return StateCache.get(cacheKey);
        }
        return null;
    }
    
    // Set player metadata
    setMeta(key, value) {
        if (typeof StateCache !== 'undefined') {
            const cacheKey = `player:${this.id}:meta:${key}`;
            return StateCache.set(cacheKey, value);
        }
        return false;
    }
    
    // Kick player
    kick(reason = "Kicked by administrator") {
        if (typeof Logger !== 'undefined') {
            Logger.info(`Kicking player ${this.name} (${this.id}): ${reason}`);
        }
        
        // FiveM native call (will be handled by adapter)
        if (typeof DropPlayer !== 'undefined') {
            DropPlayer(this.id.toString(), reason);
        }
        
        return true;
    }
    
    // Update player ping
    updatePing() {
        if (typeof GetPlayerPing !== 'undefined') {
            this.ping = GetPlayerPing(this.id.toString());
        }
    }
    
    // Get player identifiers (license, steam, etc.)
    getIdentifiers() {
        if (typeof GetPlayerIdentifiers !== 'undefined') {
            return GetPlayerIdentifiers(this.id.toString());
        }
        return [];
    }
    
    // Check if player is online
    isOnline() {
        return PlayerManager.getPlayer(this.id) !== null;
    }
}

// PlayerManager methods

// Create and register a player
PlayerManager.createPlayer = function(source, name, identifier) {
    const player = new Player(source, name, identifier);
    this._players.set(source, player);
    
    if (typeof Logger !== 'undefined') {
        Logger.info(`Player created: ${name} (${source}) [${identifier}]`);
    }
    
    // Emit player connected event
    if (typeof EventSystem !== 'undefined') {
        EventSystem.emit("player:connected", player);
    }
    
    return player;
};

// Get a player by source
PlayerManager.getPlayer = function(source) {
    return this._players.get(source) || null;
};

// Get all players
PlayerManager.getPlayers = function() {
    return Array.from(this._players.values());
};

// Get player count
PlayerManager.getPlayerCount = function() {
    return this._players.size;
};

// Remove a player
PlayerManager.removePlayer = function(source) {
    const player = this._players.get(source);
    
    if (!player) {
        return false;
    }
    
    if (typeof Logger !== 'undefined') {
        Logger.info(`Player removed: ${player.name} (${source})`);
    }
    
    // Emit player disconnected event
    if (typeof EventSystem !== 'undefined') {
        EventSystem.emit("player:disconnected", player);
    }
    
    // Clear player metadata from cache
    if (typeof StateCache !== 'undefined') {
        const metaKeys = StateCache.keys();
        const prefix = `player:${source}:meta:`;
        
        metaKeys.forEach(key => {
            if (key.startsWith(prefix)) {
                StateCache.delete(key);
            }
        });
    }
    
    // Clear permission cache
    if (typeof PermissionManager !== 'undefined') {
        PermissionManager.clearPermission(source);
    }
    
    // Remove from players map
    this._players.delete(source);
    
    return true;
};

// Get player by identifier
PlayerManager.getPlayerByIdentifier = function(identifier) {
    for (const player of this._players.values()) {
        if (player.identifier === identifier) {
            return player;
        }
    }
    return null;
};

// Get player by name (partial match)
PlayerManager.getPlayerByName = function(name) {
    const searchName = name.toLowerCase();
    
    for (const player of this._players.values()) {
        if (player.name.toLowerCase().includes(searchName)) {
            return player;
        }
    }
    
    return null;
};

// Update all player pings
PlayerManager.updateAllPings = function() {
    for (const player of this._players.values()) {
        player.updatePing();
    }
};

// Export for Node.js and FiveM
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { PlayerManager, Player };
}

// Make available globally in FiveM
if (typeof global !== 'undefined') {
    global.PlayerManager = PlayerManager;
    global.Player = Player;
}
