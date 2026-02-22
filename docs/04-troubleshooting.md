# Troubleshooting Guide

Solusi untuk masalah umum dengan Bucu Core.

## Installation Issues

### Core tidak start

**Symptoms:**
- Tidak ada log dari Bucu Core
- Server start tapi Core tidak initialize

**Solutions:**

1. Check `server.cfg`:
```cfg
ensure bucu-core
```

2. Verify file structure:
```
resources/
└── bucu-core/
    ├── fxmanifest.lua
    ├── core/
    ├── platform/
    └── ...
```

3. Check console untuk error messages

4. Verify FiveM server version (minimum 5848)

### Module tidak load

**Symptoms:**
- Module tidak muncul di loaded modules
- No initialization log

**Solutions:**

1. Check module contract:
```lua
return {
    name = "module-name",  -- Required
    version = "1.0.0",     -- Required
    init = function(Core)  -- Required
        -- Logic
    end
}
```

2. Check module location:
```
modules/
└── my-module/
    ├── module.lua
    └── config.lua
```

3. Check for errors:
```lua
Core.log.error("Check this log")
```

4. Verify dependencies:
```lua
dependencies = { "other-module" }
```

## Runtime Issues

### Events tidak trigger

**Symptoms:**
- Event listeners tidak dipanggil
- No callback execution

**Solutions:**

1. Verify event name (case-sensitive):
```lua
-- Correct
Core.on("player:connected", callback)

-- Wrong
Core.on("Player:Connected", callback)
```

2. Check listener registration timing:
```lua
-- Good: Register in core:ready
Core.on("core:ready", function()
    Core.on("custom:event", callback)
end)

-- Bad: Register too early
Core.on("custom:event", callback)  -- Core might not be ready
```

3. Check for errors dalam callback:
```lua
Core.on("event", function(data)
    local success, err = pcall(function()
        -- Your logic
    end)
    if not success then
        Core.log.error("Callback error: " .. err)
    end
end)
```

4. Verify rate limits:
```lua
-- Check if event is rate limited
local stats = EventSystem:getStats()
print("Blocked events: " .. stats.blocked)
```

### Permission tidak work

**Symptoms:**
- Permission checks selalu fail
- Players tidak punya correct role

**Solutions:**

1. Set permission explicitly:
```lua
player:setPermission("admin")
```

2. Check default permission:
```lua
-- config.lua
player = {
    defaultPermission = "user"
}
```

3. Verify permission check:
```lua
local role = player:getPermission()
Core.log.info("Player role: " .. role)
```

4. Check role hierarchy:
```lua
local hasPermission = PermissionManager:hasPermission(playerId, "moderator")
```

### Cache tidak work

**Symptoms:**
- Cache.get() returns nil
- Data tidak persist

**Solutions:**

1. Check TTL expiry:
```lua
-- Set with TTL
Core.cache.set("key", "value", 300)  -- 5 minutes

-- Check if expired
local value = Core.cache.get("key")
if not value then
    Core.log.warn("Cache expired or not set")
end
```

2. Verify cache key:
```lua
-- Keys are case-sensitive
Core.cache.set("myKey", "value")
local value = Core.cache.get("myKey")  -- Correct
local value = Core.cache.get("mykey")  -- Wrong
```

3. Check cache stats:
```lua
local stats = Core.cache.getStats()
print("Cache size: " .. stats.size)
print("Hit rate: " .. stats.hitRate)
```

## Performance Issues

### High server lag

**Symptoms:**
- Server FPS drops
- High tick time
- Players experiencing lag

**Solutions:**

1. Check event frequency:
```lua
-- Bad: Too frequent
Citizen.CreateThread(function()
    while true do
        Core.emit("update", {})
        Citizen.Wait(0)  -- Every tick!
    end
end)

-- Good: Reasonable frequency
Citizen.CreateThread(function()
    while true do
        Core.emit("update", {})
        Citizen.Wait(1000)  -- Every second
    end
end)
```

2. Profile module performance:
```lua
local startTime = os.clock()
-- Your code
local endTime = os.clock()
Core.log.debug("Execution time: " .. (endTime - startTime) .. "s")
```

3. Check cache usage:
```lua
local stats = Core.cache.getStats()
if stats.hitRate < 50 then
    Core.log.warn("Low cache hit rate: " .. stats.hitRate .. "%")
end
```

4. Review rate limits:
```lua
-- Increase if needed
rateLimit = {
    defaultLimit = 200,  -- Increase from 100
    window = 60
}
```

### Memory leaks

**Symptoms:**
- Memory usage increases over time
- Server becomes unstable

**Solutions:**

1. Clear player data on disconnect:
```lua
Core.on("player:disconnected", function(player)
    -- Clear metadata
    Core.cache.delete("player:" .. player.id .. ":*")
end)
```

2. Remove unused listeners:
```lua
Core.off("event", callback)
```

3. Clear expired cache:
```lua
-- Periodic cleanup
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)  -- 5 minutes
        Core.cache.clearExpired()
    end
end)
```

## Development Issues

### Hot reload tidak work

**Symptoms:**
- File changes tidak detected
- Module tidak reload

**Solutions:**

1. Enable dev mode:
```lua
-- config.lua
core = {
    devMode = true
}
```

2. Use CLI dev command:
```bash
bucu dev
```

3. Manual reload:
```lua
ModuleLoader:reloadModule("module-name")
```

### Lua-JS communication issues

**Symptoms:**
- Events tidak cross language boundary
- Data tidak received

**Solutions:**

1. Use correct bridge methods:
```lua
-- Lua to JS
Core.emitToJS("event", data)

-- JS to Lua
Core.emitToLua("event", data)
```

2. Check event prefixes:
```lua
-- Listen for JS events in Lua
Core.onFromJS("jsEvent", callback)

-- Listen for Lua events in JS
Core.onFromLua("luaEvent", callback)
```

3. Verify data serialization:
```lua
-- Simple data types work best
local data = {
    string = "text",
    number = 123,
    boolean = true
}
Core.emitToJS("event", data)
```

## Error Messages

### "Module missing required field: name"

**Cause:** Module contract incomplete

**Solution:**
```lua
return {
    name = "my-module",  -- Add this
    version = "1.0.0",
    init = function(Core) end
}
```

### "Circular dependency detected"

**Cause:** Module A depends on B, B depends on A

**Solution:** Restructure dependencies atau merge modules

### "Rate limit exceeded"

**Cause:** Too many events emitted

**Solution:** 
1. Reduce event frequency
2. Increase rate limit in config
3. Use batching

### "Player not found"

**Cause:** Player disconnected atau invalid source

**Solution:**
```lua
local player = Core.getPlayer(source)
if not player then
    Core.log.warn("Player not found: " .. source)
    return
end
```

## Debug Tips

### Enable verbose logging

```lua
-- config.lua
core = {
    logLevel = "debug"
}

-- Or runtime
Core.log.setLevel("debug")
```

### Check system stats

```lua
-- Event system
local eventStats = EventSystem:getStats()
print(json.encode(eventStats))

-- Cache
local cacheStats = Core.cache.getStats()
print(json.encode(cacheStats))

-- Modules
local moduleStats = ModuleLoader:getStats()
print(json.encode(moduleStats))

-- Permissions
local permStats = PermissionManager:getStats()
print(json.encode(permStats))
```

### Monitor player count

```lua
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)  -- Every minute
        local count = Core.getPlayerCount()
        Core.log.info("Players online: " .. count)
    end
end)
```

## Getting Help

### Before asking for help:

1. Check console logs
2. Enable debug logging
3. Review this troubleshooting guide
4. Check GitHub issues

### When reporting issues:

Include:
- Bucu Core version
- FiveM server version
- Error messages (full stack trace)
- Steps to reproduce
- Relevant code snippets
- Server logs

### Support Channels

- GitHub Issues: https://github.com/bucucore-dev/bucucore-framework/issues
- Discord: https://discord.gg/bucu-core
- Documentation: https://docs.bucu-core.com

## Common Questions

**Q: Can I use Bucu Core with ESX/QBCore?**  
A: Yes, but you'll need compatibility modules.

**Q: Does Bucu Core support OneSync?**  
A: Yes, OneSync is required.

**Q: Can I modify Core files?**  
A: Not recommended. Use modules instead.

**Q: How do I update Bucu Core?**  
A: Pull latest changes, backup config, restart server.

**Q: Is Bucu Core production ready?**  
A: Yes, v1.0.0 is stable for production use.
