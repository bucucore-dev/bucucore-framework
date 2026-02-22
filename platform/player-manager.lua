-- Bucu Core - Player Manager
-- Manages player objects and lifecycle

local PlayerManager = {
    _players = {},  -- { [source] = Player }
}

-- Player class
local Player = {}
Player.__index = Player

-- Create a new player object
function Player.new(source, name, identifier)
    local self = setmetatable({}, Player)
    
    self.id = source
    self.name = name or "Unknown"
    self.identifier = identifier or ""
    self.ping = 0
    
    return self
end

-- Get player permission
function Player:getPermission()
    if PermissionManager then
        return PermissionManager:getPermission(self.id)
    end
    return "user"
end

-- Set player permission
function Player:setPermission(role)
    if PermissionManager then
        return PermissionManager:setPermission(self.id, role)
    end
    return false
end

-- Get player metadata
function Player:getMeta(key)
    if StateCache then
        local cacheKey = "player:" .. self.id .. ":meta:" .. key
        return StateCache:get(cacheKey)
    end
    return nil
end

-- Set player metadata
function Player:setMeta(key, value)
    if StateCache then
        local cacheKey = "player:" .. self.id .. ":meta:" .. key
        return StateCache:set(cacheKey, value)
    end
    return false
end

-- Kick player
function Player:kick(reason)
    reason = reason or "Kicked by administrator"
    
    if Logger then
        Logger:info(string.format(
            "Kicking player %s (%d): %s",
            self.name,
            self.id,
            reason
        ))
    end
    
    -- FiveM native call (will be handled by adapter)
    if DropPlayer then
        DropPlayer(self.id, reason)
    end
    
    return true
end

-- Update player ping
function Player:updatePing()
    if GetPlayerPing then
        self.ping = GetPlayerPing(self.id)
    end
end

-- Get player identifiers (license, steam, etc.)
function Player:getIdentifiers()
    if GetPlayerIdentifiers then
        return GetPlayerIdentifiers(self.id)
    end
    return {}
end

-- Check if player is online
function Player:isOnline()
    return PlayerManager:getPlayer(self.id) ~= nil
end

-- PlayerManager methods

-- Create and register a player
function PlayerManager:createPlayer(source, name, identifier)
    local player = Player.new(source, name, identifier)
    self._players[source] = player
    
    if Logger then
        Logger:info(string.format(
            "Player created: %s (%d) [%s]",
            name,
            source,
            identifier
        ))
    end
    
    -- Emit player connected event
    if EventSystem then
        EventSystem:emit("player:connected", player)
    end
    
    return player
end

-- Get a player by source
function PlayerManager:getPlayer(source)
    return self._players[source]
end

-- Get all players
function PlayerManager:getPlayers()
    local players = {}
    for _, player in pairs(self._players) do
        table.insert(players, player)
    end
    return players
end

-- Get player count
function PlayerManager:getPlayerCount()
    local count = 0
    for _ in pairs(self._players) do
        count = count + 1
    end
    return count
end

-- Remove a player
function PlayerManager:removePlayer(source)
    local player = self._players[source]
    
    if not player then
        return false
    end
    
    if Logger then
        Logger:info(string.format(
            "Player removed: %s (%d)",
            player.name,
            source
        ))
    end
    
    -- Emit player disconnected event
    if EventSystem then
        EventSystem:emit("player:disconnected", player)
    end
    
    -- Clear player metadata from cache
    if StateCache then
        local metaKeys = StateCache:keys()
        local prefix = "player:" .. source .. ":meta:"
        
        for _, key in ipairs(metaKeys) do
            if key:sub(1, #prefix) == prefix then
                StateCache:delete(key)
            end
        end
    end
    
    -- Clear permission cache
    if PermissionManager then
        PermissionManager:clearPermission(source)
    end
    
    -- Remove from players table
    self._players[source] = nil
    
    return true
end

-- Get player by identifier
function PlayerManager:getPlayerByIdentifier(identifier)
    for _, player in pairs(self._players) do
        if player.identifier == identifier then
            return player
        end
    end
    return nil
end

-- Get player by name (partial match)
function PlayerManager:getPlayerByName(name)
    name = name:lower()
    
    for _, player in pairs(self._players) do
        if player.name:lower():find(name, 1, true) then
            return player
        end
    end
    
    return nil
end

-- Update all player pings
function PlayerManager:updateAllPings()
    for _, player in pairs(self._players) do
        player:updatePing()
    end
end

return PlayerManager
