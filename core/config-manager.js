// Bucu Core - Config Manager (JavaScript)
// Handles configuration loading and access

const ConfigManager = {
    _config: {},
    _loaded: false,
    
    // Load configuration from file
    load(configPath = "config/default-config") {
        try {
            // In FiveM, we need to load from Lua side
            // This is a placeholder for JS-side config
            this._config = {};
            this._loaded = false;
            
            if (typeof Logger !== 'undefined') {
                Logger.warn("JS ConfigManager: Config should be loaded from Lua side");
                Logger.info("Using empty configuration");
            }
            
            return false;
        } catch (error) {
            if (typeof Logger !== 'undefined') {
                Logger.warn(`Failed to load config: ${error.message}`);
                Logger.info("Using empty configuration");
            }
            this._config = {};
            this._loaded = false;
            return false;
        }
    },
    
    // Get configuration value with dot notation support
    // Example: ConfigManager.get("core.version", "1.0.0")
    get(key, defaultValue) {
        if (!this._loaded) {
            return defaultValue;
        }
        
        // Split key by dots
        const keys = key.split('.');
        
        // Navigate through nested objects
        let value = this._config;
        for (const k of keys) {
            if (typeof value === 'object' && value !== null && k in value) {
                value = value[k];
            } else {
                return defaultValue;
            }
        }
        
        return value;
    },
    
    // Set configuration value (runtime only, not persisted)
    set(key, value) {
        // Split key by dots
        const keys = key.split('.');
        
        // Navigate and set value
        let current = this._config;
        for (let i = 0; i < keys.length - 1; i++) {
            const k = keys[i];
            if (typeof current[k] !== 'object' || current[k] === null) {
                current[k] = {};
            }
            current = current[k];
        }
        
        current[keys[keys.length - 1]] = value;
    },
    
    // Get entire configuration
    getAll() {
        return this._config;
    },
    
    // Check if configuration is loaded
    isLoaded() {
        return this._loaded;
    },
    
    // Validate configuration structure
    _validate() {
        // Basic validation
        if (typeof this._config !== 'object' || this._config === null) {
            if (typeof Logger !== 'undefined') {
                Logger.error("Configuration must be an object");
            }
            return false;
        }
        
        // Validate required sections
        const requiredSections = ["core", "modules", "rateLimit", "cache"];
        for (const section of requiredSections) {
            if (!(section in this._config)) {
                if (typeof Logger !== 'undefined') {
                    Logger.warn(`Missing configuration section: ${section}`);
                }
            }
        }
        
        return true;
    }
};

// Export for Node.js and FiveM
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ConfigManager;
}

// Make available globally in FiveM
if (typeof global !== 'undefined') {
    global.ConfigManager = ConfigManager;
}
