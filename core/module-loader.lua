-- Bucu Core - Module Loader
-- Discovers, validates, and initializes external modules with dependency resolution

local ModuleLoader = {
    _modules = {},           -- { [name] = module }
    _loadedModules = {},     -- { [name] = true }
    _failedModules = {},     -- { [name] = error }
    _stats = {
        total = 0,
        loaded = 0,
        failed = 0
    }
}

-- Load all modules from directory
function ModuleLoader:loadModules()
    local modulesDir = ConfigManager and ConfigManager:get("modules.directory", "modules") or "modules"
    local autoLoad = ConfigManager and ConfigManager:get("modules.autoLoad", true) or true
    
    if not autoLoad then
        if Logger then
            Logger:info("Module auto-load is disabled")
        end
        return true
    end
    
    if Logger then
        Logger:info("Loading modules from: " .. modulesDir)
    end
    
    -- Discover modules
    local discoveredModules = self:_discoverModules(modulesDir)
    
    if #discoveredModules == 0 then
        if Logger then
            Logger:warn("No modules found in: " .. modulesDir)
        end
        return true
    end
    
    if Logger then
        Logger:info(string.format("Discovered %d modules", #discoveredModules))
    end
    
    -- Validate module contracts
    local validModules = self:_validateModules(discoveredModules)
    
    -- Resolve dependencies
    local sortedModules = self:_resolveDependencies(validModules)
    
    -- Initialize modules in dependency order
    self:_initializeModules(sortedModules)
    
    -- Log summary
    if Logger then
        Logger:info(string.format(
            "Module loading complete: %d loaded, %d failed",
            self._stats.loaded,
            self._stats.failed
        ))
    end
    
    return true
end

-- Discover modules in directory
function ModuleLoader:_discoverModules(directory)
    local modules = {}
    
    -- In FiveM, we need to manually specify modules
    -- This is a placeholder - actual implementation would scan filesystem
    -- For now, we'll check if modules exist by trying to require them
    
    local moduleNames = {
        "bucu-admin"
        -- Add more module names here
    }
    
    for _, moduleName in ipairs(moduleNames) do
        local modulePath = directory .. "/" .. moduleName .. "/module"
        local configPath = directory .. "/" .. moduleName .. "/config"
        
        -- Try to load module
        local success, module = pcall(require, modulePath)
        if success and type(module) == "table" then
            -- Try to load config
            local configSuccess, config = pcall(require, configPath)
            if configSuccess and type(config) == "table" then
                module.config = config
            end
            
            module._path = modulePath
            table.insert(modules, module)
            self._stats.total = self._stats.total + 1
        end
    end
    
    return modules
end

-- Validate module contracts
function ModuleLoader:_validateModules(modules)
    local validModules = {}
    
    for _, module in ipairs(modules) do
        if self:_validateModuleContract(module) then
            table.insert(validModules, module)
        else
            self._stats.failed = self._stats.failed + 1
        end
    end
    
    return validModules
end

-- Validate single module contract
function ModuleLoader:_validateModuleContract(module)
    -- Check required fields
    if not module.name or type(module.name) ~= "string" then
        if Logger then
            Logger:error("Module missing required field: name")
        end
        return false
    end
    
    if not module.version or type(module.version) ~= "string" then
        if Logger then
            Logger:error(string.format(
                "Module '%s' missing required field: version",
                module.name
            ))
        end
        return false
    end
    
    if not module.init or type(module.init) ~= "function" then
        if Logger then
            Logger:error(string.format(
                "Module '%s' missing required field: init (function)",
                module.name
            ))
        end
        return false
    end
    
    -- Check if module is disabled
    local disabledModules = ConfigManager and ConfigManager:get("modules.disabled", {}) or {}
    for _, disabledName in ipairs(disabledModules) do
        if module.name == disabledName then
            if Logger then
                Logger:info(string.format("Module '%s' is disabled", module.name))
            end
            return false
        end
    end
    
    return true
end

-- Resolve module dependencies (topological sort)
function ModuleLoader:_resolveDependencies(modules)
    local sorted = {}
    local visited = {}
    local visiting = {}
    
    -- Create module lookup table
    local moduleLookup = {}
    for _, module in ipairs(modules) do
        moduleLookup[module.name] = module
    end
    
    -- Depth-first search for topological sort
    local function visit(moduleName)
        if visited[moduleName] then
            return true
        end
        
        if visiting[moduleName] then
            if Logger then
                Logger:error(string.format(
                    "Circular dependency detected: %s",
                    moduleName
                ))
            end
            return false
        end
        
        local module = moduleLookup[moduleName]
        if not module then
            return false
        end
        
        visiting[moduleName] = true
        
        -- Visit dependencies first
        if module.dependencies then
            for _, depName in ipairs(module.dependencies) do
                if not moduleLookup[depName] then
                    if Logger then
                        Logger:error(string.format(
                            "Module '%s' requires missing dependency '%s'",
                            moduleName,
                            depName
                        ))
                    end
                    self._failedModules[moduleName] = "Missing dependency: " .. depName
                    visiting[moduleName] = nil
                    return false
                end
                
                if not visit(depName) then
                    visiting[moduleName] = nil
                    return false
                end
            end
        end
        
        visiting[moduleName] = nil
        visited[moduleName] = true
        table.insert(sorted, module)
        
        return true
    end
    
    -- Visit all modules
    for _, module in ipairs(modules) do
        if not visited[module.name] then
            visit(module.name)
        end
    end
    
    return sorted
end

-- Initialize modules in order
function ModuleLoader:_initializeModules(modules)
    for _, module in ipairs(modules) do
        self:_initializeModule(module)
    end
end

-- Initialize single module
function ModuleLoader:_initializeModule(module)
    if Logger then
        Logger:info(string.format(
            "Initializing module: %s v%s",
            module.name,
            module.version
        ))
    end
    
    -- Call module init with error isolation
    local success, err = pcall(function()
        module.init(Core)
    end)
    
    if success then
        self._modules[module.name] = module
        self._loadedModules[module.name] = true
        self._stats.loaded = self._stats.loaded + 1
        
        if Logger then
            Logger:info(string.format(
                "Module loaded successfully: %s",
                module.name
            ))
        end
        
        -- Emit module loaded event
        if EventSystem then
            EventSystem:emit("module:loaded", {
                name = module.name,
                version = module.version
            })
        end
    else
        self._failedModules[module.name] = tostring(err)
        self._stats.failed = self._stats.failed + 1
        
        if Logger then
            Logger:error(string.format(
                "Failed to initialize module '%s': %s",
                module.name,
                tostring(err)
            ))
        end
        
        -- Emit module failed event
        if EventSystem then
            EventSystem:emit("module:failed", {
                name = module.name,
                error = tostring(err)
            })
        end
    end
end

-- Get loaded module
function ModuleLoader:getModule(name)
    return self._modules[name]
end

-- Check if module is loaded
function ModuleLoader:isLoaded(name)
    return self._loadedModules[name] == true
end

-- Get all loaded modules
function ModuleLoader:getLoadedModules()
    local modules = {}
    for name, _ in pairs(self._loadedModules) do
        table.insert(modules, name)
    end
    return modules
end

-- Get failed modules
function ModuleLoader:getFailedModules()
    return self._failedModules
end

-- Get module statistics
function ModuleLoader:getStats()
    return {
        total = self._stats.total,
        loaded = self._stats.loaded,
        failed = self._stats.failed
    }
end

-- Reload a module (development mode only)
function ModuleLoader:reloadModule(name)
    local devMode = ConfigManager and ConfigManager:get("core.devMode", false) or false
    
    if not devMode then
        if Logger then
            Logger:warn("Module reload is only available in development mode")
        end
        return false
    end
    
    local module = self._modules[name]
    if not module then
        if Logger then
            Logger:error(string.format("Module not found: %s", name))
        end
        return false
    end
    
    if Logger then
        Logger:info(string.format("Reloading module: %s", name))
    end
    
    -- Unload module from package cache
    if module._path then
        package.loaded[module._path] = nil
    end
    
    -- Try to reload
    local success, newModule = pcall(require, module._path)
    if not success then
        if Logger then
            Logger:error(string.format(
                "Failed to reload module '%s': %s",
                name,
                tostring(newModule)
            ))
        end
        return false
    end
    
    -- Re-initialize
    success, err = pcall(function()
        newModule.init(Core)
    end)
    
    if success then
        self._modules[name] = newModule
        
        if Logger then
            Logger:info(string.format("Module reloaded: %s", name))
        end
        
        -- Emit module reloaded event
        if EventSystem then
            EventSystem:emit("module:reloaded", { name = name })
        end
        
        return true
    else
        if Logger then
            Logger:error(string.format(
                "Failed to re-initialize module '%s': %s",
                name,
                tostring(err)
            ))
        end
        return false
    end
end

return ModuleLoader
