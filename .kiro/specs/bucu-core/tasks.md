# Implementation Tasks: Bucu Core

## Overview

Dokumen ini berisi breakdown task implementasi Bucu Core v1.0.0. Tasks diorganisir berdasarkan prioritas dan dependencies, dengan estimasi effort untuk setiap task.

## Phase 1: Core Foundation (Priority: Critical)

### Task 1.1: Project Structure Setup
**Estimasi**: 1 hour  
**Dependencies**: None  
**Status**: Not Started

**Subtasks**:
- [ ] Buat struktur direktori utama (core/, platform/, bridge/, cli/, modules/, config/)
- [ ] Setup fxmanifest.lua dengan konfigurasi dasar
- [ ] Setup package.json untuk CLI tool
- [ ] Buat .gitignore dan README.md
- [ ] Setup default-config.lua

**Acceptance Criteria**:
- Struktur direktori sesuai design document
- fxmanifest.lua valid dan bisa di-load FiveM
- package.json valid dengan dependencies CLI

---

### Task 1.2: Logger System (Lua)
**Estimasi**: 2 hours  
**Dependencies**: Task 1.1  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi Logger class di core/logger.lua
- [ ] Implementasi method: info, warn, error, debug
- [ ] Implementasi log level filtering
- [ ] Implementasi timestamp formatting
- [ ] Test manual dengan berbagai log levels

**Acceptance Criteria**:
- Logger dapat log dengan 4 severity levels
- Log level filtering berfungsi
- Format output konsisten: [timestamp] [LEVEL] message
- Error handling untuk invalid inputs

**Test Cases**:
```lua
-- Test log levels
Logger:info("Info message")
Logger:warn("Warning message")
Logger:error("Error message")
Logger:debug("Debug message")

-- Test filtering
Logger.level = "warn"
Logger:info("Should not appear")
Logger:warn("Should appear")
```

---

### Task 1.3: Logger System (JavaScript)
**Estimasi**: 2 hours  
**Dependencies**: Task 1.2  
**Status**: Not Started

**Subtasks**:
- [ ] Port Logger ke core/logger.js
- [ ] Ensure API parity dengan Lua version
- [ ] Test manual dengan berbagai log levels
- [ ] Validasi output format sama dengan Lua

**Acceptance Criteria**:
- API 1:1 dengan Lua version
- Behavior identik dengan Lua version
- Format output sama persis

---

### Task 1.4: Config Manager (Lua)
**Estimasi**: 3 hours  
**Dependencies**: Task 1.2  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi ConfigManager class di core/config-manager.lua
- [ ] Implementasi method load(configPath)
- [ ] Implementasi method get(key, default) dengan dot notation support
- [ ] Implementasi validation untuk config structure
- [ ] Buat default-config.lua dengan semua settings
- [ ] Test dengan berbagai config scenarios

**Acceptance Criteria**:
- Config dapat di-load dari file
- Dot notation berfungsi (e.g., "core.version")
- Default values berfungsi untuk missing keys
- Validation mendeteksi invalid config
- Error handling untuk missing/corrupt config files

**Test Cases**:
```lua
-- Test dot notation
local version = ConfigManager:get("core.version", "1.0.0")

-- Test default values
local missing = ConfigManager:get("nonexistent.key", "default")

-- Test nested access
local logLevel = ConfigManager:get("core.logLevel", "info")
```

---

### Task 1.5: Config Manager (JavaScript)
**Estimasi**: 2 hours  
**Dependencies**: Task 1.4  
**Status**: Not Started

**Subtasks**:
- [ ] Port ConfigManager ke core/config-manager.js
- [ ] Ensure API parity dengan Lua version
- [ ] Test dengan berbagai config scenarios

**Acceptance Criteria**:
- API 1:1 dengan Lua version
- Behavior identik dengan Lua version

---

### Task 1.6: State Cache (Lua)
**Estimasi**: 3 hours  
**Dependencies**: Task 1.2  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi StateCache class di core/state-cache.lua
- [ ] Implementasi method get(key)
- [ ] Implementasi method set(key, value, ttl)
- [ ] Implementasi method delete(key)
- [ ] Implementasi TTL expiry checking
- [ ] Test dengan berbagai scenarios (dengan/tanpa TTL)

**Acceptance Criteria**:
- Get/set/delete berfungsi
- TTL expiry otomatis
- Lazy expiry checking (saat get)
- Memory efficient (cleanup expired entries)

**Test Cases**:
```lua
-- Test basic operations
StateCache:set("key1", "value1")
assert(StateCache:get("key1") == "value1")
StateCache:delete("key1")
assert(StateCache:get("key1") == nil)

-- Test TTL
StateCache:set("key2", "value2", 2)  -- 2 seconds TTL
assert(StateCache:get("key2") == "value2")
-- Wait 3 seconds
assert(StateCache:get("key2") == nil)
```

---

### Task 1.7: State Cache (JavaScript)
**Estimasi**: 2 hours  
**Dependencies**: Task 1.6  
**Status**: Not Started

**Subtasks**:
- [ ] Port StateCache ke core/state-cache.js
- [ ] Ensure API parity dengan Lua version
- [ ] Test dengan berbagai scenarios

**Acceptance Criteria**:
- API 1:1 dengan Lua version
- Behavior identik dengan Lua version

---

## Phase 2: Event System (Priority: Critical)

### Task 2.1: Event System Core (Lua)
**Estimasi**: 4 hours  
**Dependencies**: Task 1.2, Task 1.6  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi EventSystem class di core/event-system.lua
- [ ] Implementasi method on(eventName, callback)
- [ ] Implementasi method emit(eventName, data)
- [ ] Implementasi method off(eventName, callback) [optional]
- [ ] Implementasi error isolation per callback (pcall)
- [ ] Implementasi listener storage (array per event)
- [ ] Test dengan multiple listeners per event

**Acceptance Criteria**:
- Multiple listeners dapat register untuk same event
- Listeners dipanggil dalam registration order
- Error di satu callback tidak affect callbacks lain
- Event data di-pass ke semua callbacks
- Namespace dengan ':' didukung

**Test Cases**:
```lua
-- Test multiple listeners
local called1, called2 = false, false
EventSystem:on("test:event", function(data)
    called1 = true
end)
EventSystem:on("test:event", function(data)
    called2 = true
end)
EventSystem:emit("test:event", {})
assert(called1 and called2)

-- Test error isolation
EventSystem:on("test:error", function()
    error("Intentional error")
end)
EventSystem:on("test:error", function()
    called1 = true
end)
EventSystem:emit("test:error", {})
assert(called1)  -- Second callback should still run
```

---

### Task 2.2: Rate Limiting for Events (Lua)
**Estimasi**: 3 hours  
**Dependencies**: Task 2.1  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi rate limit checking di EventSystem
- [ ] Implementasi method _checkRateLimit(eventName)
- [ ] Implementasi counter reset logic
- [ ] Integrate dengan ConfigManager untuk thresholds
- [ ] Test dengan berbagai rate limit scenarios

**Acceptance Criteria**:
- Rate limit per event name
- Configurable thresholds
- Automatic counter reset
- Warning log saat limit exceeded
- Event emission blocked saat over limit

**Test Cases**:
```lua
-- Test rate limiting
ConfigManager:set("rateLimit.test:event", { limit = 5, window = 1 })
for i = 1, 5 do
    EventSystem:emit("test:event", {})  -- Should succeed
end
EventSystem:emit("test:event", {})  -- Should be blocked
```

---

### Task 2.3: Event System (JavaScript)
**Estimasi**: 3 hours  
**Dependencies**: Task 2.2  
**Status**: Not Started

**Subtasks**:
- [ ] Port EventSystem ke core/event-system.js
- [ ] Port rate limiting logic
- [ ] Ensure API parity dengan Lua version
- [ ] Test dengan berbagai scenarios

**Acceptance Criteria**:
- API 1:1 dengan Lua version
- Behavior identik dengan Lua version
- Rate limiting berfungsi sama

---

## Phase 3: Player System (Priority: High)

### Task 3.1: Player Object (Lua)
**Estimasi**: 3 hours  
**Dependencies**: Task 1.6, Task 2.1  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi Player class di platform/player-manager.lua
- [ ] Implementasi properties: id, name, identifier, ping
- [ ] Implementasi method getMeta(key)
- [ ] Implementasi method setMeta(key, value)
- [ ] Implementasi method kick(reason)
- [ ] Integrate dengan StateCache untuk metadata storage
- [ ] Test dengan mock player data

**Acceptance Criteria**:
- Player object properties accessible
- Metadata stored in StateCache dengan namespace
- kick() method berfungsi (mock untuk testing)
- Player object lightweight (no heavy data)

**Test Cases**:
```lua
-- Test player creation
local player = Player.new(1, "TestPlayer", "license:abc123")
assert(player.id == 1)
assert(player.name == "TestPlayer")

-- Test metadata
player:setMeta("joinTime", os.time())
assert(player:getMeta("joinTime") ~= nil)
```

---

### Task 3.2: Permission Manager (Lua)
**Estimasi**: 3 hours  
**Dependencies**: Task 2.1  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi PermissionManager class di core/permission-manager.lua
- [ ] Implementasi method setPermission(playerId, role)
- [ ] Implementasi method getPermission(playerId)
- [ ] Implementasi method hasPermission(playerId, requiredRole)
- [ ] Emit event "permission:changed" saat permission update
- [ ] Test dengan berbagai permission scenarios

**Acceptance Criteria**:
- Permission dapat di-set dan di-get per player
- Default permission "user" untuk new players
- Event emitted saat permission changes
- Server-side only (no client exposure)

**Test Cases**:
```lua
-- Test permission management
PermissionManager:setPermission(1, "admin")
assert(PermissionManager:getPermission(1) == "admin")

-- Test default permission
assert(PermissionManager:getPermission(999) == "user")

-- Test event emission
local eventFired = false
Core.on("permission:changed", function(data)
    eventFired = true
end)
PermissionManager:setPermission(1, "moderator")
assert(eventFired)
```

---

### Task 3.3: Player Manager Integration (Lua)
**Estimasi**: 2 hours  
**Dependencies**: Task 3.1, Task 3.2  
**Status**: Not Started

**Subtasks**:
- [ ] Integrate Player.getPermission() dengan PermissionManager
- [ ] Integrate Player.setPermission() dengan PermissionManager
- [ ] Implement player cleanup on disconnect
- [ ] Test full player lifecycle

**Acceptance Criteria**:
- Player methods delegate ke PermissionManager
- Player metadata cleared on disconnect
- Permission cache cleared on disconnect

---

### Task 3.4: Player System (JavaScript)
**Estimasi**: 4 hours  
**Dependencies**: Task 3.3  
**Status**: Not Started

**Subtasks**:
- [ ] Port Player class ke platform/player-manager.js
- [ ] Port PermissionManager ke core/permission-manager.js
- [ ] Ensure API parity dengan Lua versions
- [ ] Test full player lifecycle

**Acceptance Criteria**:
- API 1:1 dengan Lua versions
- Behavior identik dengan Lua versions

---

## Phase 4: Module System (Priority: High)

### Task 4.1: Module Loader Core (Lua)
**Estimasi**: 5 hours  
**Dependencies**: Task 1.4, Task 2.1  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi ModuleLoader class di core/module-loader.lua
- [ ] Implementasi module discovery (scan directory)
- [ ] Implementasi module contract validation
- [ ] Implementasi method loadModules()
- [ ] Implementasi error isolation per module (pcall)
- [ ] Test dengan mock modules

**Acceptance Criteria**:
- Module directory dapat di-scan
- Module contract validated (name, version, init)
- Invalid modules skipped dengan error log
- Module init() wrapped dalam pcall
- Modules tidak bisa modify Core directly

**Test Cases**:
```lua
-- Test valid module loading
local validModule = {
    name = "test-module",
    version = "1.0.0",
    init = function(Core)
        -- Setup
    end
}

-- Test invalid module (missing init)
local invalidModule = {
    name = "bad-module",
    version = "1.0.0"
}
```

---

### Task 4.2: Dependency Resolution (Lua)
**Estimasi**: 4 hours  
**Dependencies**: Task 4.1  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi dependency resolution algorithm (topological sort)
- [ ] Implementasi method _resolveDependencies(modules)
- [ ] Handle circular dependencies
- [ ] Handle missing dependencies
- [ ] Test dengan complex dependency graphs

**Acceptance Criteria**:
- Modules loaded dalam dependency order
- Circular dependencies detected dan logged
- Missing dependencies logged dengan clear message
- Dependent modules skipped jika dependency missing

**Test Cases**:
```lua
-- Test dependency order
-- Module A depends on Module B
-- Module B depends on Module C
-- Expected load order: C, B, A

-- Test missing dependency
-- Module X depends on Module Y (not exists)
-- Expected: Module X skipped, error logged
```

---

### Task 4.3: Module Loader (JavaScript)
**Estimasi**: 4 hours  
**Dependencies**: Task 4.2  
**Status**: Not Started

**Subtasks**:
- [ ] Port ModuleLoader ke core/module-loader.js
- [ ] Port dependency resolution logic
- [ ] Ensure API parity dengan Lua version
- [ ] Test dengan mock modules

**Acceptance Criteria**:
- API 1:1 dengan Lua version
- Behavior identik dengan Lua version
- Dependency resolution sama

---

## Phase 5: Platform Integration (Priority: High)

### Task 5.1: FiveM Adapter (Lua)
**Estimasi**: 4 hours  
**Dependencies**: Task 2.1, Task 3.3  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi FiveMAdapter di platform/fivem-adapter.lua
- [ ] Bridge playerConnecting event ke "player:connected"
- [ ] Bridge playerDropped event ke "player:disconnected"
- [ ] Implementasi RegisterNetEvent wrapper
- [ ] Implementasi TriggerClientEvent wrapper
- [ ] Test dengan FiveM server (manual)

**Acceptance Criteria**:
- FiveM events bridged ke Core events
- Player lifecycle managed correctly
- Network events dapat registered
- Client events dapat triggered
- Core tidak directly call FiveM natives

**Test Cases**:
```lua
-- Test player connection bridging
-- Trigger FiveM playerConnecting
-- Verify "player:connected" event emitted

-- Test network event registration
FiveMAdapter:registerNetEvent("test:event")
-- Verify RegisterNetEvent called
```

---

### Task 5.2: FiveM Adapter (JavaScript)
**Estimasi**: 3 hours  
**Dependencies**: Task 5.1  
**Status**: Not Started

**Subtasks**:
- [ ] Port FiveMAdapter ke platform/fivem-adapter.js
- [ ] Ensure API parity dengan Lua version
- [ ] Test dengan FiveM server (manual)

**Acceptance Criteria**:
- API 1:1 dengan Lua version
- Behavior identik dengan Lua version

---

## Phase 6: Language Bridge (Priority: Medium)

### Task 6.1: Lua-JS Bridge
**Estimasi**: 5 hours  
**Dependencies**: Task 2.1  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi LuaJSBridge di bridge/lua-js-bridge.lua
- [ ] Implementasi JSLuaBridge di bridge/js-lua-bridge.js
- [ ] Implementasi emitToJS() di Lua side
- [ ] Implementasi emitToLua() di JS side
- [ ] Implementasi JSON serialization/deserialization
- [ ] Test cross-language event communication

**Acceptance Criteria**:
- Lua dapat emit events ke JavaScript
- JavaScript dapat emit events ke Lua
- Data serialization berfungsi (JSON)
- Event namespacing untuk cross-language ("js:", "lua:")

**Test Cases**:
```lua
-- Lua side
LuaJSBridge:emitToJS("test:event", { message = "Hello from Lua" })

-- JS side
JSLuaBridge.onFromLua("test:event", (data) => {
    console.log(data.message);  // "Hello from Lua"
});
```

---

## Phase 7: Core API Object (Priority: Critical)

### Task 7.1: Core API Assembly (Lua)
**Estimasi**: 3 hours  
**Dependencies**: Task 2.3, Task 3.3, Task 4.3, Task 1.5  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi Core object di core/init.lua
- [ ] Wire semua services ke Core API
- [ ] Implementasi BucuCore alias
- [ ] Implementasi initialization sequence
- [ ] Emit "core:ready" event setelah init
- [ ] Test full initialization

**Acceptance Criteria**:
- Core object exposed globally
- BucuCore references same object as Core
- All API methods accessible
- Initialization order correct
- "core:ready" event emitted

**Initialization Order**:
1. ConfigManager
2. Logger
3. StateCache
4. EventSystem
5. PermissionManager
6. ModuleLoader
7. FiveMAdapter
8. Emit "core:ready"

---

### Task 7.2: Core API Assembly (JavaScript)
**Estimasi**: 3 hours  
**Dependencies**: Task 7.1  
**Status**: Not Started

**Subtasks**:
- [ ] Port Core object ke core/init.js
- [ ] Wire semua services ke Core API
- [ ] Ensure API parity dengan Lua version
- [ ] Test full initialization

**Acceptance Criteria**:
- API 1:1 dengan Lua version
- Initialization order sama
- Behavior identik

---

## Phase 8: CLI Tool (Priority: Medium)

### Task 8.1: CLI Foundation
**Estimasi**: 3 hours  
**Dependencies**: Task 1.1  
**Status**: Not Started

**Subtasks**:
- [ ] Setup CLI project di cli/bucu-cli.js
- [ ] Install commander.js dependency
- [ ] Implementasi basic CLI structure
- [ ] Implementasi version command
- [ ] Test CLI executable

**Acceptance Criteria**:
- CLI dapat dijalankan: `bucu --version`
- Help command berfungsi: `bucu --help`
- Command structure ready untuk subcommands

---

### Task 8.2: CLI Command - Init
**Estimasi**: 4 hours  
**Dependencies**: Task 8.1  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi command init di cli/commands/init.js
- [ ] Buat project template structure
- [ ] Generate fxmanifest.lua
- [ ] Generate default config
- [ ] Generate example module
- [ ] Test dengan berbagai project names

**Acceptance Criteria**:
- `bucu init <name>` creates project structure
- All necessary files generated
- Generated files valid dan runnable
- Error handling untuk existing directories

---

### Task 8.3: CLI Command - Create Module
**Estimasi**: 3 hours  
**Dependencies**: Task 8.1  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi command create module di cli/commands/create-module.js
- [ ] Buat module template
- [ ] Generate module.lua dengan contract
- [ ] Generate config.lua
- [ ] Generate README.md
- [ ] Test dengan berbagai module names

**Acceptance Criteria**:
- `bucu create module <name>` generates module files
- Generated module valid dan loadable
- Module contract complete
- Error handling untuk existing modules

---

### Task 8.4: CLI Command - Dev Mode
**Estimasi**: 5 hours  
**Dependencies**: Task 8.1  
**Status**: Not Started

**Subtasks**:
- [ ] Implementasi command dev di cli/commands/dev.js
- [ ] Implementasi file watcher untuk hot reload
- [ ] Enable verbose logging
- [ ] Set development mode flag
- [ ] Test hot reload functionality

**Acceptance Criteria**:
- `bucu dev` starts development mode
- File changes trigger hot reload
- Verbose logging enabled
- Clear error messages on reload failures

---

## Phase 9: Official Module (Priority: Medium)

### Task 9.1: bucu-admin Module
**Estimasi**: 6 hours  
**Dependencies**: Task 7.2  
**Status**: Not Started

**Subtasks**:
- [ ] Buat module structure di modules/bucu-admin/
- [ ] Implementasi module.lua dengan contract
- [ ] Implementasi admin commands (kick, setperm, etc.)
- [ ] Implementasi permission checks
- [ ] Add comprehensive documentation
- [ ] Test semua commands

**Acceptance Criteria**:
- Module loadable oleh ModuleLoader
- Admin commands berfungsi
- Permission system demonstrated
- Code quality sebagai reference standard
- Documentation lengkap

**Commands**:
- `/kick <player> <reason>` - Kick player
- `/setperm <player> <role>` - Set player permission
- `/getperm <player>` - Get player permission

---

## Phase 10: Testing & Documentation (Priority: High)

### Task 10.1: Integration Testing
**Estimasi**: 8 hours  
**Dependencies**: Task 7.2, Task 9.1  
**Status**: Not Started

**Subtasks**:
- [ ] Setup test FiveM server
- [ ] Test full server startup sequence
- [ ] Test player connection/disconnection
- [ ] Test module loading dengan dependencies
- [ ] Test event system end-to-end
- [ ] Test cross-language communication
- [ ] Test error scenarios
- [ ] Test hot reload

**Acceptance Criteria**:
- All core features berfungsi di FiveM server
- No critical bugs
- Error handling robust
- Performance acceptable

---

### Task 10.2: Documentation (Bahasa Indonesia)
**Estimasi**: 12 hours  
**Dependencies**: Task 10.1  
**Status**: Not Started

**Subtasks**:
- [ ] Tulis Introduction
- [ ] Tulis Installation guide
- [ ] Tulis Basic Concepts
- [ ] Tulis Core API reference
- [ ] Tulis Player API reference
- [ ] Tulis Event System guide
- [ ] Tulis Module System guide
- [ ] Tulis Permission System guide
- [ ] Tulis Dev Mode guide
- [ ] Tulis JS Support guide
- [ ] Tulis Best Practices
- [ ] Tulis Migration guide
- [ ] Tulis FAQ
- [ ] Add runnable examples untuk setiap section

**Acceptance Criteria**:
- Documentation lengkap dalam Bahasa Indonesia
- Semua examples runnable
- Clear untuk beginners
- Covers semua features
- Includes troubleshooting

---

## Phase 11: Polish & Release (Priority: Medium)

### Task 11.1: Error Message Improvement
**Estimasi**: 3 hours  
**Dependencies**: Task 10.1  
**Status**: Not Started

**Subtasks**:
- [ ] Review semua error messages
- [ ] Add context (file, line, operation)
- [ ] Add helpful suggestions
- [ ] Ensure consistency
- [ ] Test error scenarios

**Acceptance Criteria**:
- Error messages clear dan actionable
- Context provided untuk debugging
- Suggestions helpful
- Consistent format

---

### Task 11.2: Performance Optimization
**Estimasi**: 4 hours  
**Dependencies**: Task 10.1  
**Status**: Not Started

**Subtasks**:
- [ ] Profile event system performance
- [ ] Optimize cache lookups
- [ ] Optimize module loading
- [ ] Review memory usage
- [ ] Test under load

**Acceptance Criteria**:
- Event emission < 1ms average
- Module loading < 100ms per module
- Memory usage reasonable
- No memory leaks

---

### Task 11.3: Release Preparation
**Estimasi**: 4 hours  
**Dependencies**: Task 10.2, Task 11.2  
**Status**: Not Started

**Subtasks**:
- [ ] Finalize version number (1.0.0)
- [ ] Update all version references
- [ ] Create CHANGELOG.md
- [ ] Create LICENSE file
- [ ] Create CONTRIBUTING.md
- [ ] Prepare release notes
- [ ] Tag release in git

**Acceptance Criteria**:
- All version numbers consistent
- Changelog complete
- License clear
- Release notes comprehensive
- Git tag created

---

## Summary

**Total Estimated Hours**: ~110 hours  
**Total Tasks**: 35 tasks  
**Critical Path**: Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 7 → Phase 10

**Priorities**:
- Critical: Core foundation, Event system, Core API assembly, Testing
- High: Player system, Module system, Platform integration
- Medium: Language bridge, CLI tool, Official module, Polish

**Next Steps**:
1. Start dengan Phase 1 (Core Foundation)
2. Complete tasks sequentially dalam each phase
3. Test setiap component sebelum move to next phase
4. Maintain API parity antara Lua dan JavaScript
5. Document as you go
