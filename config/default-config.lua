-- Bucu Core Default Configuration
-- File ini berisi konfigurasi default untuk Bucu Core
-- Copy file ini ke server.cfg atau buat config.lua untuk override

return {
    -- Core settings
    core = {
        version = "1.0.0",
        devMode = false,
        logLevel = "info"  -- debug, info, warn, error
    },
    
    -- Module settings
    modules = {
        directory = "modules",
        autoLoad = true,
        -- Daftar module yang di-disable
        disabled = {}
    },
    
    -- Rate limiting settings
    rateLimit = {
        enabled = true,
        defaultLimit = 100,  -- Max events per window
        window = 60,         -- Window in seconds
        -- Per-event limits (override default)
        events = {
            -- ["custom:event"] = { limit = 50, window = 30 }
        }
    },
    
    -- Cache settings
    cache = {
        defaultTTL = 300,  -- Default TTL in seconds (5 minutes)
        maxSize = 10000    -- Maximum cache entries
    },
    
    -- Player settings
    player = {
        defaultPermission = "user",
        -- Metadata yang di-persist (future feature)
        persistMeta = false
    },
    
    -- Logging settings
    logging = {
        -- Log format: timestamp, level, message
        format = "[%s] [%s] %s",
        -- Enable/disable specific log types
        enableDebug = false,
        enableInfo = true,
        enableWarn = true,
        enableError = true
    }
}
