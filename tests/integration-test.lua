-- Bucu Core Integration Tests
-- Run these tests to verify Core functionality

local Tests = {
    passed = 0,
    failed = 0,
    results = {}
}

-- Test helper
function Tests:assert(condition, testName)
    if condition then
        self.passed = self.passed + 1
        table.insert(self.results, {
            name = testName,
            status = "PASS"
        })
        print("✓ " .. testName)
    else
        self.failed = self.failed + 1
        table.insert(self.results, {
            name = testName,
            status = "FAIL"
        })
        print("✗ " .. testName)
    end
end

-- Run all tests
function Tests:run()
    print("\n========================================")
    print("  Bucu Core Integration Tests")
    print("========================================\n")
    
    self:testLogger()
    self:testConfig()
    self:testCache()
    self:testEvents()
    self:testPermissions()
    
    print("\n========================================")
    print("  Test Results")
    print("========================================")
    print("Passed: " .. self.passed)
    print("Failed: " .. self.failed)
    print("Total:  " .. (self.passed + self.failed))
    print("========================================\n")
    
    return self.failed == 0
end

-- Test Logger
function Tests:testLogger()
    print("\n--- Testing Logger ---")
    
    -- Test log levels
    self:assert(Logger ~= nil, "Logger exists")
    self:assert(type(Logger.info) == "function", "Logger.info is function")
    self:assert(type(Logger.warn) == "function", "Logger.warn is function")
    self:assert(type(Logger.error) == "function", "Logger.error is function")
    self:assert(type(Logger.debug) == "function", "Logger.debug is function")
    
    -- Test log level setting
    Logger:setLevel("debug")
    self:assert(Logger:getLevel() == "debug", "Log level set to debug")
    
    Logger:setLevel("info")
    self:assert(Logger:getLevel() == "info", "Log level set to info")
end

-- Test Config Manager
function Tests:testConfig()
    print("\n--- Testing Config Manager ---")
    
    self:assert(ConfigManager ~= nil, "ConfigManager exists")
    self:assert(ConfigManager:isLoaded(), "Config is loaded")
    
    -- Test get with default
    local value = ConfigManager:get("nonexistent.key", "default")
    self:assert(value == "default", "Config get with default works")
    
    -- Test set and get
    ConfigManager:set("test.key", "test value")
    local retrieved = ConfigManager:get("test.key")
    self:assert(retrieved == "test value", "Config set and get works")
    
    -- Test dot notation
    local version = ConfigManager:get("core.version")
    self:assert(version ~= nil, "Config dot notation works")
end

-- Test State Cache
function Tests:testCache()
    print("\n--- Testing State Cache ---")
    
    self:assert(StateCache ~= nil, "StateCache exists")
    
    -- Test set and get
    StateCache:set("test_key", "test_value")
    local value = StateCache:get("test_key")
    self:assert(value == "test_value", "Cache set and get works")
    
    -- Test delete
    StateCache:delete("test_key")
    local deleted = StateCache:get("test_key")
    self:assert(deleted == nil, "Cache delete works")
    
    -- Test TTL
    StateCache:set("ttl_key", "ttl_value", 1)
    local immediate = StateCache:get("ttl_key")
    self:assert(immediate == "ttl_value", "Cache TTL immediate get works")
    
    -- Wait for expiry
    Citizen.Wait(1100)
    local expired = StateCache:get("ttl_key")
    self:assert(expired == nil, "Cache TTL expiry works")
    
    -- Test has
    StateCache:set("has_key", "value")
    self:assert(StateCache:has("has_key") == true, "Cache has() works")
    
    -- Test stats
    local stats = StateCache:getStats()
    self:assert(type(stats.size) == "number", "Cache stats works")
end

-- Test Event System
function Tests:testEvents()
    print("\n--- Testing Event System ---")
    
    self:assert(EventSystem ~= nil, "EventSystem exists")
    
    -- Test event registration and emission
    local eventFired = false
    local eventData = nil
    
    EventSystem:on("test:event", function(data)
        eventFired = true
        eventData = data
    end)
    
    EventSystem:emit("test:event", { message = "test" })
    
    Citizen.Wait(100)
    
    self:assert(eventFired == true, "Event listener triggered")
    self:assert(eventData.message == "test", "Event data passed correctly")
    
    -- Test multiple listeners
    local count = 0
    EventSystem:on("test:multiple", function() count = count + 1 end)
    EventSystem:on("test:multiple", function() count = count + 1 end)
    EventSystem:emit("test:multiple", {})
    
    Citizen.Wait(100)
    
    self:assert(count == 2, "Multiple listeners work")
    
    -- Test listener count
    local listenerCount = EventSystem:listenerCount("test:multiple")
    self:assert(listenerCount == 2, "Listener count correct")
end

-- Test Permission Manager
function Tests:testPermissions()
    print("\n--- Testing Permission Manager ---")
    
    self:assert(PermissionManager ~= nil, "PermissionManager exists")
    
    -- Test set and get permission
    PermissionManager:setPermission(1, "admin")
    local role = PermissionManager:getPermission(1)
    self:assert(role == "admin", "Permission set and get works")
    
    -- Test default permission
    local defaultRole = PermissionManager:getPermission(999)
    self:assert(defaultRole == "user", "Default permission works")
    
    -- Test has permission
    PermissionManager:setPermission(2, "moderator")
    local hasPerm = PermissionManager:hasPermission(2, "user")
    self:assert(hasPerm == true, "Permission hierarchy works")
    
    -- Test clear permission
    PermissionManager:clearPermission(1)
    local cleared = PermissionManager:getPermission(1)
    self:assert(cleared == "user", "Permission clear works")
end

-- Register test command
RegisterCommand("test-core", function()
    Tests:run()
end, false)

-- Auto-run tests on core:ready (if in dev mode)
if ConfigManager and ConfigManager:get("core.devMode", false) then
    Core.on("core:ready", function()
        Citizen.Wait(2000)  -- Wait for everything to initialize
        Tests:run()
    end)
end

return Tests
