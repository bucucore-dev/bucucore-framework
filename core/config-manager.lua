-- Bucu Core - Config Manager
-- Handles configuration loading and access

local ConfigManager = {
    _config = {},
    _loaded = false
}

-- Load configuration from file
function ConfigManager:load(configPath)
    configPath = configPath or "config/default-config"
    
    local success, config = pcall(require, configPath)
    
    if not success then
        -- Log error if Logger is available
        if Logger then
            Logger:warn("Failed to load config from: " .. configPath)
            Logger:info("Using empty configuration")
        end
        self._config = {}
        self._loaded = false
        return false
    end
    
    self._config = config
    self._loaded = true
    
    if Logger then
        Logger:info("Configuration loaded from: " .. configPath)
    end
    
    return true
end

-- Get configuration value with dot notation support
-- Example: ConfigManager:get("core.version", "1.0.0")
function ConfigManager:get(key, default)
    if not self._loaded then
        return default
    end
    
    -- Split key by dots
    local keys = {}
    for k in string.gmatch(key, "[^.]+") do
        table.insert(keys, k)
    end
    
    -- Navigate through nested tables
    local value = self._config
    for _, k in ipairs(keys) do
        if type(value) == "table" and value[k] ~= nil then
            value = value[k]
        else
            return default
        end
    end
    
    return value
end

-- Set configuration value (runtime only, not persisted)
function ConfigManager:set(key, value)
    -- Split key by dots
    local keys = {}
    for k in string.gmatch(key, "[^.]+") do
        table.insert(keys, k)
    end
    
    -- Navigate and set value
    local current = self._config
    for i = 1, #keys - 1 do
        local k = keys[i]
        if type(current[k]) ~= "table" then
            current[k] = {}
        end
        current = current[k]
    end
    
    current[keys[#keys]] = value
end

-- Get entire configuration
function ConfigManager:getAll()
    return self._config
end

-- Check if configuration is loaded
function ConfigManager:isLoaded()
    return self._loaded
end

-- Validate configuration structure
function ConfigManager:_validate()
    -- Basic validation
    if type(self._config) ~= "table" then
        if Logger then
            Logger:error("Configuration must be a table")
        end
        return false
    end
    
    -- Validate required sections
    local requiredSections = { "core", "modules", "rateLimit", "cache" }
    for _, section in ipairs(requiredSections) do
        if not self._config[section] then
            if Logger then
                Logger:warn("Missing configuration section: " .. section)
            end
        end
    end
    
    return true
end

return ConfigManager
