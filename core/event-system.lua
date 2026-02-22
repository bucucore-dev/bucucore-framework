-- Bucu Core - Event System
-- Pub-sub event system with error isolation and rate limiting

local EventSystem = {
    _listeners = {},     -- { [eventName] = { callback1, callback2, ... } }
    _rateLimits = {},    -- { [eventName] = { count, resetTime } }
    _stats = {
        emitted = 0,
        blocked = 0,
        errors = 0
    }
}

-- Register an event listener
function EventSystem:on(eventName, callback)
    -- Validate inputs
    if type(eventName) ~= "string" or eventName == "" then
        if Logger then
            Logger:error("Event name must be a non-empty string")
        end
        return false
    end
    
    if type(callback) ~= "function" then
        if Logger then
            Logger:error("Callback must be a function")
        end
        return false
    end
    
    -- Initialize listener array if needed
    if not self._listeners[eventName] then
        self._listeners[eventName] = {}
    end
    
    -- Add callback to listeners
    table.insert(self._listeners[eventName], callback)
    
    if Logger then
        Logger:debug("Event listener registered: " .. eventName)
    end
    
    return true
end

-- Emit an event
function EventSystem:emit(eventName, data)
    -- Validate event name
    if type(eventName) ~= "string" or eventName == "" then
        if Logger then
            Logger:error("Event name must be a non-empty string")
        end
        return false
    end
    
    -- Check rate limit
    if not self:_checkRateLimit(eventName) then
        self._stats.blocked = self._stats.blocked + 1
        if Logger then
            Logger:warn("Rate limit exceeded for event: " .. eventName)
        end
        return false
    end
    
    -- Get listeners for this event
    local listeners = self._listeners[eventName]
    if not listeners or #listeners == 0 then
        -- No listeners, but not an error
        return true
    end
    
    -- Invoke all listeners with error isolation
    local successCount = 0
    local errorCount = 0
    
    for i, callback in ipairs(listeners) do
        local success, err = pcall(callback, data)
        
        if success then
            successCount = successCount + 1
        else
            errorCount = errorCount + 1
            self._stats.errors = self._stats.errors + 1
            
            if Logger then
                Logger:error(string.format(
                    "Error in event '%s' callback #%d: %s",
                    eventName,
                    i,
                    tostring(err)
                ))
            end
        end
    end
    
    self._stats.emitted = self._stats.emitted + 1
    
    if Logger and errorCount > 0 then
        Logger:debug(string.format(
            "Event '%s' completed: %d success, %d errors",
            eventName,
            successCount,
            errorCount
        ))
    end
    
    return true
end

-- Remove an event listener
function EventSystem:off(eventName, callback)
    if type(eventName) ~= "string" or eventName == "" then
        return false
    end
    
    local listeners = self._listeners[eventName]
    if not listeners then
        return false
    end
    
    -- Find and remove the callback
    for i, cb in ipairs(listeners) do
        if cb == callback then
            table.remove(listeners, i)
            
            if Logger then
                Logger:debug("Event listener removed: " .. eventName)
            end
            
            return true
        end
    end
    
    return false
end

-- Remove all listeners for an event
function EventSystem:removeAllListeners(eventName)
    if eventName then
        self._listeners[eventName] = nil
        if Logger then
            Logger:debug("All listeners removed for event: " .. eventName)
        end
    else
        self._listeners = {}
        if Logger then
            Logger:debug("All event listeners removed")
        end
    end
end

-- Get listener count for an event
function EventSystem:listenerCount(eventName)
    local listeners = self._listeners[eventName]
    return listeners and #listeners or 0
end

-- Get all registered event names
function EventSystem:eventNames()
    local names = {}
    for name, _ in pairs(self._listeners) do
        table.insert(names, name)
    end
    return names
end

-- Check rate limit for an event
function EventSystem:_checkRateLimit(eventName)
    -- Get rate limit config
    local rateLimitEnabled = ConfigManager and ConfigManager:get("rateLimit.enabled", true)
    if not rateLimitEnabled then
        return true
    end
    
    -- Get event-specific or default limit
    local limit = ConfigManager and ConfigManager:get("rateLimit.events." .. eventName .. ".limit")
    local window = ConfigManager and ConfigManager:get("rateLimit.events." .. eventName .. ".window")
    
    if not limit then
        limit = ConfigManager and ConfigManager:get("rateLimit.defaultLimit", 100)
        window = ConfigManager and ConfigManager:get("rateLimit.window", 60)
    end
    
    -- Initialize rate limit tracking
    if not self._rateLimits[eventName] then
        self._rateLimits[eventName] = {
            count = 0,
            resetTime = os.time() + window
        }
    end
    
    local rateLimit = self._rateLimits[eventName]
    local now = os.time()
    
    -- Reset counter if window expired
    if now >= rateLimit.resetTime then
        rateLimit.count = 0
        rateLimit.resetTime = now + window
    end
    
    -- Check if limit exceeded
    if rateLimit.count >= limit then
        return false
    end
    
    -- Increment counter
    rateLimit.count = rateLimit.count + 1
    return true
end

-- Get event system statistics
function EventSystem:getStats()
    local listenerCount = 0
    for _, listeners in pairs(self._listeners) do
        listenerCount = listenerCount + #listeners
    end
    
    return {
        events = #self:eventNames(),
        listeners = listenerCount,
        emitted = self._stats.emitted,
        blocked = self._stats.blocked,
        errors = self._stats.errors
    }
end

-- Reset rate limits (for testing/debugging)
function EventSystem:resetRateLimits()
    self._rateLimits = {}
    if Logger then
        Logger:debug("Rate limits reset")
    end
end

return EventSystem
