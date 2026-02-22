-- Bucu Core - Logger System
-- Provides structured logging with severity levels

local Logger = {
    level = "info",  -- Current log level
    
    -- Log level priorities
    _levels = {
        debug = 1,
        info = 2,
        warn = 3,
        error = 4
    },
    
    -- ANSI color codes for console output
    _colors = {
        debug = "\27[36m",  -- Cyan
        info = "\27[32m",   -- Green
        warn = "\27[33m",   -- Yellow
        error = "\27[31m",  -- Red
        reset = "\27[0m"
    }
}

-- Internal log method
function Logger:_log(level, message)
    -- Check if this log level should be output
    if self._levels[level] < self._levels[self.level] then
        return
    end
    
    -- Validate inputs
    if type(message) ~= "string" then
        message = tostring(message)
    end
    
    -- Format timestamp
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    
    -- Format message with color
    local color = self._colors[level] or ""
    local reset = self._colors.reset
    local formatted = string.format(
        "%s[%s] [%s]%s %s",
        color,
        timestamp,
        level:upper(),
        reset,
        message
    )
    
    -- Output to console
    print(formatted)
end

-- Public logging methods
function Logger:debug(message)
    self:_log("debug", message)
end

function Logger:info(message)
    self:_log("info", message)
end

function Logger:warn(message)
    self:_log("warn", message)
end

function Logger:error(message)
    self:_log("error", message)
end

-- Set log level
function Logger:setLevel(level)
    if self._levels[level] then
        self.level = level
        self:info("Log level set to: " .. level)
    else
        self:warn("Invalid log level: " .. tostring(level))
    end
end

-- Get current log level
function Logger:getLevel()
    return self.level
end

return Logger
