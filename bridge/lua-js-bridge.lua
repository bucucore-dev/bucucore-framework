-- Bucu Core - Lua-JavaScript Bridge
-- Enables cross-language event communication

local LuaJSBridge = {
    _initialized = false
}

-- Initialize bridge
function LuaJSBridge:init()
    if self._initialized then
        return false
    end
    
    if Logger then
        Logger:debug("Initializing Lua-JS Bridge")
    end
    
    -- Register listener for events from JavaScript
    if EventSystem then
        EventSystem:on("js:*", function(data)
            -- Events from JS are prefixed with "js:"
            -- This is handled automatically by the event system
        end)
    end
    
    self._initialized = true
    return true
end

-- Emit event to JavaScript runtime
function LuaJSBridge:emitToJS(eventName, data)
    if type(eventName) ~= "string" or eventName == "" then
        if Logger then
            Logger:error("Event name must be a non-empty string")
        end
        return false
    end
    
    -- Emit with "lua:" prefix so JS side knows it's from Lua
    if EventSystem then
        EventSystem:emit("lua:" .. eventName, data)
    end
    
    return true
end

-- Register listener for events from JavaScript
function LuaJSBridge:onFromJS(eventName, callback)
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
    
    -- Listen for events with "js:" prefix
    if EventSystem then
        EventSystem:on("js:" .. eventName, callback)
    end
    
    return true
end

-- Serialize data to JSON
function LuaJSBridge:serialize(data)
    return json.encode(data)
end

-- Deserialize JSON to data
function LuaJSBridge:deserialize(jsonStr)
    local success, data = pcall(json.decode, jsonStr)
    if success then
        return data
    else
        if Logger then
            Logger:error("Failed to deserialize JSON: " .. tostring(data))
        end
        return nil
    end
end

return LuaJSBridge
