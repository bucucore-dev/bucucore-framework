// Bucu Core - Permission Manager (JavaScript)
// Role-based permission system

const PermissionManager = {
    _permissions: new Map(),  // Map<number, string>
    _roleHierarchy: {
        // Higher number = higher permission level
        user: 0,
        moderator: 1,
        admin: 2,
        superadmin: 3
    },
    
    // Set player permission
    setPermission(playerId, role) {
        // Validate inputs
        if (typeof playerId !== "number") {
            if (typeof Logger !== 'undefined') {
                Logger.error("Player ID must be a number");
            }
            return false;
        }
        
        if (typeof role !== "string" || role === "") {
            if (typeof Logger !== 'undefined') {
                Logger.error("Role must be a non-empty string");
            }
            return false;
        }
        
        // Store old role for event
        const oldRole = this._permissions.get(playerId);
        
        // Set new role
        this._permissions.set(playerId, role);
        
        if (typeof Logger !== 'undefined') {
            Logger.info(
                `Permission set for player ${playerId}: ${oldRole || "none"} -> ${role}`
            );
        }
        
        // Emit permission changed event
        if (typeof EventSystem !== 'undefined') {
            EventSystem.emit("permission:changed", {
                playerId: playerId,
                oldRole: oldRole,
                newRole: role
            });
        }
        
        return true;
    },
    
    // Get player permission
    getPermission(playerId) {
        if (typeof playerId !== "number") {
            return null;
        }
        
        // Return stored permission or default
        const defaultRole = typeof ConfigManager !== 'undefined'
            ? ConfigManager.get("player.defaultPermission", "user")
            : "user";
        
        return this._permissions.get(playerId) || defaultRole;
    },
    
    // Check if player has specific permission
    hasPermission(playerId, requiredRole) {
        const playerRole = this.getPermission(playerId);
        
        // Get role levels
        const playerLevel = this._roleHierarchy[playerRole] || 0;
        const requiredLevel = this._roleHierarchy[requiredRole] || 0;
        
        return playerLevel >= requiredLevel;
    },
    
    // Check if player has exact role
    hasRole(playerId, role) {
        return this.getPermission(playerId) === role;
    },
    
    // Clear player permission
    clearPermission(playerId) {
        if (this._permissions.has(playerId)) {
            const oldRole = this._permissions.get(playerId);
            this._permissions.delete(playerId);
            
            if (typeof Logger !== 'undefined') {
                Logger.debug(
                    `Permission cleared for player ${playerId} (was: ${oldRole})`
                );
            }
            
            return true;
        }
        
        return false;
    },
    
    // Get all players with specific role
    getPlayersWithRole(role) {
        const players = [];
        
        for (const [playerId, playerRole] of this._permissions.entries()) {
            if (playerRole === role) {
                players.push(playerId);
            }
        }
        
        return players;
    },
    
    // Get all players with minimum permission level
    getPlayersWithMinLevel(role) {
        const players = [];
        const requiredLevel = this._roleHierarchy[role] || 0;
        
        for (const [playerId, playerRole] of this._permissions.entries()) {
            const playerLevel = this._roleHierarchy[playerRole] || 0;
            if (playerLevel >= requiredLevel) {
                players.push(playerId);
            }
        }
        
        return players;
    },
    
    // Set role hierarchy
    setRoleHierarchy(hierarchy) {
        if (typeof hierarchy !== "object" || hierarchy === null) {
            if (typeof Logger !== 'undefined') {
                Logger.error("Role hierarchy must be an object");
            }
            return false;
        }
        
        this._roleHierarchy = hierarchy;
        
        if (typeof Logger !== 'undefined') {
            Logger.info("Role hierarchy updated");
        }
        
        return true;
    },
    
    // Get role hierarchy
    getRoleHierarchy() {
        return this._roleHierarchy;
    },
    
    // Get role level
    getRoleLevel(role) {
        return this._roleHierarchy[role] || 0;
    },
    
    // Check if role exists in hierarchy
    roleExists(role) {
        return this._roleHierarchy[role] !== undefined;
    },
    
    // Get all defined roles
    getRoles() {
        const roles = Object.keys(this._roleHierarchy);
        
        // Sort by level
        roles.sort((a, b) => {
            return this._roleHierarchy[a] - this._roleHierarchy[b];
        });
        
        return roles;
    },
    
    // Get permission statistics
    getStats() {
        const stats = {
            total: 0,
            byRole: {}
        };
        
        for (const role of this._permissions.values()) {
            stats.total++;
            stats.byRole[role] = (stats.byRole[role] || 0) + 1;
        }
        
        return stats;
    }
};

// Export for Node.js and FiveM
if (typeof module !== 'undefined' && module.exports) {
    module.exports = PermissionManager;
}

// Make available globally in FiveM
if (typeof global !== 'undefined') {
    global.PermissionManager = PermissionManager;
}
