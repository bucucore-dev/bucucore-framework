// Bucu Core - Module Loader (JavaScript)
// Discovers, validates, and initializes external modules with dependency resolution

const ModuleLoader = {
    _modules: new Map(),           // Map<string, module>
    _loadedModules: new Set(),     // Set<string>
    _failedModules: new Map(),     // Map<string, error>
    _stats: {
        total: 0,
        loaded: 0,
        failed: 0
    },
    
    // Load all modules from directory
    loadModules() {
        const modulesDir = typeof ConfigManager !== 'undefined'
            ? ConfigManager.get("modules.directory", "modules")
            : "modules";
        
        const autoLoad = typeof ConfigManager !== 'undefined'
            ? ConfigManager.get("modules.autoLoad", true)
            : true;
        
        if (!autoLoad) {
            if (typeof Logger !== 'undefined') {
                Logger.info("Module auto-load is disabled");
            }
            return true;
        }
        
        if (typeof Logger !== 'undefined') {
            Logger.info(`Loading modules from: ${modulesDir}`);
        }
        
        // Discover modules
        const discoveredModules = this._discoverModules(modulesDir);
        
        if (discoveredModules.length === 0) {
            if (typeof Logger !== 'undefined') {
                Logger.warn(`No modules found in: ${modulesDir}`);
            }
            return true;
        }
        
        if (typeof Logger !== 'undefined') {
            Logger.info(`Discovered ${discoveredModules.length} modules`);
        }
        
        // Validate module contracts
        const validModules = this._validateModules(discoveredModules);
        
        // Resolve dependencies
        const sortedModules = this._resolveDependencies(validModules);
        
        // Initialize modules in dependency order
        this._initializeModules(sortedModules);
        
        // Log summary
        if (typeof Logger !== 'undefined') {
            Logger.info(
                `Module loading complete: ${this._stats.loaded} loaded, ${this._stats.failed} failed`
            );
        }
        
        return true;
    },
    
    // Discover modules in directory
    _discoverModules(directory) {
        const modules = [];
        
        // In FiveM, we need to manually specify modules
        // This is a placeholder - actual implementation would scan filesystem
        const moduleNames = [
            "bucu-admin"
            // Add more module names here
        ];
        
        for (const moduleName of moduleNames) {
            const modulePath = `${directory}/${moduleName}/module`;
            const configPath = `${directory}/${moduleName}/config`;
            
            try {
                // Try to load module
                const module = require(modulePath);
                if (typeof module === 'object' && module !== null) {
                    // Try to load config
                    try {
                        const config = require(configPath);
                        if (typeof config === 'object' && config !== null) {
                            module.config = config;
                        }
                    } catch (err) {
                        // Config is optional
                    }
                    
                    module._path = modulePath;
                    modules.push(module);
                    this._stats.total++;
                }
            } catch (err) {
                // Module not found or error loading
            }
        }
        
        return modules;
    },
    
    // Validate module contracts
    _validateModules(modules) {
        const validModules = [];
        
        for (const module of modules) {
            if (this._validateModuleContract(module)) {
                validModules.push(module);
            } else {
                this._stats.failed++;
            }
        }
        
        return validModules;
    },
    
    // Validate single module contract
    _validateModuleContract(module) {
        // Check required fields
        if (!module.name || typeof module.name !== "string") {
            if (typeof Logger !== 'undefined') {
                Logger.error("Module missing required field: name");
            }
            return false;
        }
        
        if (!module.version || typeof module.version !== "string") {
            if (typeof Logger !== 'undefined') {
                Logger.error(`Module '${module.name}' missing required field: version`);
            }
            return false;
        }
        
        if (!module.init || typeof module.init !== "function") {
            if (typeof Logger !== 'undefined') {
                Logger.error(`Module '${module.name}' missing required field: init (function)`);
            }
            return false;
        }
        
        // Check if module is disabled
        const disabledModules = typeof ConfigManager !== 'undefined'
            ? ConfigManager.get("modules.disabled", [])
            : [];
        
        if (disabledModules.includes(module.name)) {
            if (typeof Logger !== 'undefined') {
                Logger.info(`Module '${module.name}' is disabled`);
            }
            return false;
        }
        
        return true;
    },
    
    // Resolve module dependencies (topological sort)
    _resolveDependencies(modules) {
        const sorted = [];
        const visited = new Set();
        const visiting = new Set();
        
        // Create module lookup table
        const moduleLookup = new Map();
        for (const module of modules) {
            moduleLookup.set(module.name, module);
        }
        
        // Depth-first search for topological sort
        const visit = (moduleName) => {
            if (visited.has(moduleName)) {
                return true;
            }
            
            if (visiting.has(moduleName)) {
                if (typeof Logger !== 'undefined') {
                    Logger.error(`Circular dependency detected: ${moduleName}`);
                }
                return false;
            }
            
            const module = moduleLookup.get(moduleName);
            if (!module) {
                return false;
            }
            
            visiting.add(moduleName);
            
            // Visit dependencies first
            if (module.dependencies && Array.isArray(module.dependencies)) {
                for (const depName of module.dependencies) {
                    if (!moduleLookup.has(depName)) {
                        if (typeof Logger !== 'undefined') {
                            Logger.error(
                                `Module '${moduleName}' requires missing dependency '${depName}'`
                            );
                        }
                        this._failedModules.set(moduleName, `Missing dependency: ${depName}`);
                        visiting.delete(moduleName);
                        return false;
                    }
                    
                    if (!visit(depName)) {
                        visiting.delete(moduleName);
                        return false;
                    }
                }
            }
            
            visiting.delete(moduleName);
            visited.add(moduleName);
            sorted.push(module);
            
            return true;
        };
        
        // Visit all modules
        for (const module of modules) {
            if (!visited.has(module.name)) {
                visit(module.name);
            }
        }
        
        return sorted;
    },
    
    // Initialize modules in order
    _initializeModules(modules) {
        for (const module of modules) {
            this._initializeModule(module);
        }
    },
    
    // Initialize single module
    _initializeModule(module) {
        if (typeof Logger !== 'undefined') {
            Logger.info(`Initializing module: ${module.name} v${module.version}`);
        }
        
        // Call module init with error isolation
        try {
            module.init(Core);
            
            this._modules.set(module.name, module);
            this._loadedModules.add(module.name);
            this._stats.loaded++;
            
            if (typeof Logger !== 'undefined') {
                Logger.info(`Module loaded successfully: ${module.name}`);
            }
            
            // Emit module loaded event
            if (typeof EventSystem !== 'undefined') {
                EventSystem.emit("module:loaded", {
                    name: module.name,
                    version: module.version
                });
            }
        } catch (err) {
            this._failedModules.set(module.name, err.message);
            this._stats.failed++;
            
            if (typeof Logger !== 'undefined') {
                Logger.error(`Failed to initialize module '${module.name}': ${err.message}`);
            }
            
            // Emit module failed event
            if (typeof EventSystem !== 'undefined') {
                EventSystem.emit("module:failed", {
                    name: module.name,
                    error: err.message
                });
            }
        }
    },
    
    // Get loaded module
    getModule(name) {
        return this._modules.get(name) || null;
    },
    
    // Check if module is loaded
    isLoaded(name) {
        return this._loadedModules.has(name);
    },
    
    // Get all loaded modules
    getLoadedModules() {
        return Array.from(this._loadedModules);
    },
    
    // Get failed modules
    getFailedModules() {
        return Object.fromEntries(this._failedModules);
    },
    
    // Get module statistics
    getStats() {
        return {
            total: this._stats.total,
            loaded: this._stats.loaded,
            failed: this._stats.failed
        };
    },
    
    // Reload a module (development mode only)
    reloadModule(name) {
        const devMode = typeof ConfigManager !== 'undefined'
            ? ConfigManager.get("core.devMode", false)
            : false;
        
        if (!devMode) {
            if (typeof Logger !== 'undefined') {
                Logger.warn("Module reload is only available in development mode");
            }
            return false;
        }
        
        const module = this._modules.get(name);
        if (!module) {
            if (typeof Logger !== 'undefined') {
                Logger.error(`Module not found: ${name}`);
            }
            return false;
        }
        
        if (typeof Logger !== 'undefined') {
            Logger.info(`Reloading module: ${name}`);
        }
        
        // Unload module from require cache
        if (module._path) {
            delete require.cache[require.resolve(module._path)];
        }
        
        // Try to reload
        try {
            const newModule = require(module._path);
            
            // Re-initialize
            newModule.init(Core);
            
            this._modules.set(name, newModule);
            
            if (typeof Logger !== 'undefined') {
                Logger.info(`Module reloaded: ${name}`);
            }
            
            // Emit module reloaded event
            if (typeof EventSystem !== 'undefined') {
                EventSystem.emit("module:reloaded", { name: name });
            }
            
            return true;
        } catch (err) {
            if (typeof Logger !== 'undefined') {
                Logger.error(`Failed to reload module '${name}': ${err.message}`);
            }
            return false;
        }
    }
};

// Export for Node.js and FiveM
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ModuleLoader;
}

// Make available globally in FiveM
if (typeof global !== 'undefined') {
    global.ModuleLoader = ModuleLoader;
}
