-- Bucu Core - FiveM Adapter
-- Bridges Core and FiveM-specific APIs

local FiveMAdapter = {
    _initialized = false
}

-- Initialize FiveM adapter
function FiveMAdapter:init()
    if self._initialized then
        if Logger then
            Logger:warn("FiveM Adapter already initialized")
        end
        return false
    end
    
    if Logger then
        Logger:info("Initializing FiveM Adapter")
    end
    
    -- Register player connection handler
    AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
        local source = source
        
        deferrals.defer()
        
        -- Wait a bit for player data to be available
        Wait(0)
        
        -- Get player identifiers
        local identifiers = GetPlayerIdentifiers(source)
        local identifier = identifiers[1] or "unknown"
        
        -- Create player object
        if PlayerManager then
            PlayerManager:createPlayer(source, name, identifier)
        end
        
        deferrals.done()
    end)
    
    -- Register player dropped handler
    AddEventHandler("playerDropped", function(reason)
        local source = source
        
        if Logger then
            Logger:debug(string.format("Player %d dropped: %s", source, reason))
        end
        
        -- Remove player object
        if PlayerManager then
            PlayerManager:removePlayer(source)
        end
    end)
    
    -- Register resource start handler
    AddEventHandler("onResourceStart", function(resourceName)
        if GetCurrentResourceName() == resourceName then
            if Logger then
                Logger:info("Bucu Core started")
            end
            
            -- Emit core ready event
            if EventSystem then
                EventSystem:emit("core:ready", {})
            end
        end
    end)
    
    -- Register resource stop handler
    AddEventHandler("onResourceStop", function(resourceName)
        if GetCurrentResourceName() == resourceName then
            if Logger then
                Logger:info("Bucu Core stopping")
            end
            
            -- Emit core shutdown event
            if EventSystem then
                EventSystem:emit("core:shutdown", {})
            end
        end
    end)
    
    -- Register network events for cross-language communication
    RegisterNetEvent("bucu:clientEvent")
    AddEventHandler("bucu:clientEvent", function(eventName, data)
        local source = source
        
        if EventSystem then
            EventSystem:emit("client:" .. eventName, {
                source = source,
                data = data
            })
        end
    end)
    
    self._initialized = true
    
    if Logger then
        Logger:info("FiveM Adapter initialized")
    end
    
    return true
end

-- Trigger client event
function FiveMAdapter:triggerClient(source, eventName, data)
    if type(source) ~= "number" then
        if Logger then
            Logger:error("Source must be a number")
        end
        return false
    end
    
    if type(eventName) ~= "string" or eventName == "" then
        if Logger then
            Logger:error("Event name must be a non-empty string")
        end
        return false
    end
    
    TriggerClientEvent(eventName, source, data)
    return true
end

-- Trigger client event for all players
function FiveMAdapter:triggerClientAll(eventName, data)
    if type(eventName) ~= "string" or eventName == "" then
        if Logger then
            Logger:error("Event name must be a non-empty string")
        end
        return false
    end
    
    TriggerClientEvent(eventName, -1, data)
    return true
end

-- Get player name
function FiveMAdapter:getPlayerName(source)
    return GetPlayerName(source)
end

-- Get player identifiers
function FiveMAdapter:getPlayerIdentifiers(source)
    return GetPlayerIdentifiers(source)
end

-- Get player ping
function FiveMAdapter:getPlayerPing(source)
    return GetPlayerPing(source)
end

-- Get player endpoint (IP)
function FiveMAdapter:getPlayerEndpoint(source)
    return GetPlayerEndpoint(source)
end

-- Get all player sources
function FiveMAdapter:getPlayers()
    return GetPlayers()
end

-- Check if player exists
function FiveMAdapter:playerExists(source)
    return GetPlayerName(source) ~= nil
end

-- Drop player (kick)
function FiveMAdapter:dropPlayer(source, reason)
    DropPlayer(source, reason or "Kicked")
    return true
end

-- Register server event
function FiveMAdapter:registerServerEvent(eventName)
    RegisterNetEvent(eventName)
    return true
end

-- Trigger server event
function FiveMAdapter:triggerServerEvent(eventName, ...)
    TriggerEvent(eventName, ...)
    return true
end

return FiveMAdapter
