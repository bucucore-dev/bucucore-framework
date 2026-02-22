-- Bucu Core - Permission Manager
-- Role-based permission system

local PermissionManager = {
    _permissions = {},  -- { [playerId] = "role" }
    _roleHierarchy = {
        -- Higher number = higher permission level
        user = 0,
        moderator = 1,
        admin = 2,
        superadmin = 3
    }
}

-- Set player permission
function PermissionManager:setPermission(playerId, role)
    -- Validate inputs
    if type(playerId) ~= "number" then
        if Logger then
            Logger:error("Player ID must be a number")
        end
        return false
    end
    
    if type(role) ~= "string" or role == "" then
        if Logger then
            Logger:error("Role must be a non-empty string")
        end
        return false
    end
    
    -- Store old role for event
    local oldRole = self._permissions[playerId]
    
    -- Set new role
    self._permissions[playerId] = role
    
    if Logger then
        Logger:info(string.format(
            "Permission set for player %d: %s -> %s",
            playerId,
            oldRole or "none",
            role
        ))
    end
    
    -- Emit permission changed event
    if EventSystem then
        EventSystem:emit("permission:changed", {
            playerId = playerId,
            oldRole = oldRole,
            newRole = role
        })
    end
    
    return true
end

-- Get player permission
function PermissionManager:getPermission(playerId)
    if type(playerId) ~= "number" then
        return nil
    end
    
    -- Return stored permission or default
    local defaultRole = ConfigManager and ConfigManager:get("player.defaultPermission", "user") or "user"
    return self._permissions[playerId] or defaultRole
end

-- Check if player has specific permission
function PermissionManager:hasPermission(playerId, requiredRole)
    local playerRole = self:getPermission(playerId)
    
    -- Get role levels
    local playerLevel = self._roleHierarchy[playerRole] or 0
    local requiredLevel = self._roleHierarchy[requiredRole] or 0
    
    return playerLevel >= requiredLevel
end

-- Check if player has exact role
function PermissionManager:hasRole(playerId, role)
    return self:getPermission(playerId) == role
end

-- Clear player permission
function PermissionManager:clearPermission(playerId)
    if self._permissions[playerId] then
        local oldRole = self._permissions[playerId]
        self._permissions[playerId] = nil
        
        if Logger then
            Logger:debug(string.format(
                "Permission cleared for player %d (was: %s)",
                playerId,
                oldRole
            ))
        end
        
        return true
    end
    
    return false
end

-- Get all players with specific role
function PermissionManager:getPlayersWithRole(role)
    local players = {}
    
    for playerId, playerRole in pairs(self._permissions) do
        if playerRole == role then
            table.insert(players, playerId)
        end
    end
    
    return players
end

-- Get all players with minimum permission level
function PermissionManager:getPlayersWithMinLevel(role)
    local players = {}
    local requiredLevel = self._roleHierarchy[role] or 0
    
    for playerId, playerRole in pairs(self._permissions) do
        local playerLevel = self._roleHierarchy[playerRole] or 0
        if playerLevel >= requiredLevel then
            table.insert(players, playerId)
        end
    end
    
    return players
end

-- Set role hierarchy
function PermissionManager:setRoleHierarchy(hierarchy)
    if type(hierarchy) ~= "table" then
        if Logger then
            Logger:error("Role hierarchy must be a table")
        end
        return false
    end
    
    self._roleHierarchy = hierarchy
    
    if Logger then
        Logger:info("Role hierarchy updated")
    end
    
    return true
end

-- Get role hierarchy
function PermissionManager:getRoleHierarchy()
    return self._roleHierarchy
end

-- Get role level
function PermissionManager:getRoleLevel(role)
    return self._roleHierarchy[role] or 0
end

-- Check if role exists in hierarchy
function PermissionManager:roleExists(role)
    return self._roleHierarchy[role] ~= nil
end

-- Get all defined roles
function PermissionManager:getRoles()
    local roles = {}
    for role, _ in pairs(self._roleHierarchy) do
        table.insert(roles, role)
    end
    
    -- Sort by level
    table.sort(roles, function(a, b)
        return self._roleHierarchy[a] < self._roleHierarchy[b]
    end)
    
    return roles
end

-- Get permission statistics
function PermissionManager:getStats()
    local stats = {
        total = 0,
        byRole = {}
    }
    
    for _, role in pairs(self._permissions) do
        stats.total = stats.total + 1
        stats.byRole[role] = (stats.byRole[role] or 0) + 1
    end
    
    return stats
end

return PermissionManager
