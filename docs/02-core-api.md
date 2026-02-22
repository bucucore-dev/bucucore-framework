# Core API Reference

Dokumentasi lengkap untuk Bucu Core API.

## Global Objects

### Core / BucuCore

Kedua object ini adalah reference yang sama. Gunakan yang mana saja sesuai preferensi.

```lua
-- Lua
Core.log.info("Using Core")
BucuCore.log.info("Using BucuCore")
```

```javascript
// JavaScript
Core.log.info("Using Core");
BucuCore.log.info("Using BucuCore");
```

## Event System

### Core.on(eventName, callback)

Register event listener.

**Parameters:**
- `eventName` (string) - Nama event
- `callback` (function) - Callback function

**Returns:** boolean

**Example:**
```lua
Core.on("player:connected", function(player)
    print("Player joined: " .. player.name)
end)
```

### Core.emit(eventName, data)

Emit event ke semua listeners.

**Parameters:**
- `eventName` (string) - Nama event
- `data` (any) - Data yang dikirim ke listeners

**Returns:** boolean

**Example:**
```lua
Core.emit("custom:event", {
    message = "Hello",
    value = 123
})
```

### Core.off(eventName, callback)

Remove event listener.

**Parameters:**
- `eventName` (string) - Nama event
- `callback` (function) - Callback yang akan di-remove

**Returns:** boolean

## Player API

### Core.getPlayer(source)

Get player object by source ID.

**Parameters:**
- `source` (number) - Player source ID

**Returns:** Player object atau nil

**Example:**
```lua
local player = Core.getPlayer(source)
if player then
    print(player.name)
end
```

### Core.getPlayers()

Get semua player objects.

**Returns:** Array of Player objects

**Example:**
```lua
local players = Core.getPlayers()
for _, player in ipairs(players) do
    print(player.name)
end
```

### Core.getPlayerCount()

Get jumlah players online.

**Returns:** number

## Player Object

### Properties

- `player.id` (number) - Source ID
- `player.name` (string) - Player name
- `player.identifier` (string) - Unique identifier
- `player.ping` (number) - Current ping

### Methods

#### player:getPermission()

Get player permission role.

**Returns:** string (role name)

**Example:**
```lua
local role = player:getPermission()
print("Role: " .. role)
```

#### player:setPermission(role)

Set player permission role.

**Parameters:**
- `role` (string) - Role name

**Returns:** boolean

**Example:**
```lua
player:setPermission("admin")
```

#### player:getMeta(key)

Get player metadata.

**Parameters:**
- `key` (string) - Metadata key

**Returns:** any

**Example:**
```lua
local joinTime = player:getMeta("joinTime")
```

#### player:setMeta(key, value)

Set player metadata.

**Parameters:**
- `key` (string) - Metadata key
- `value` (any) - Metadata value

**Returns:** boolean

**Example:**
```lua
player:setMeta("joinTime", os.time())
```

#### player:kick(reason)

Kick player dari server.

**Parameters:**
- `reason` (string) - Kick reason

**Returns:** boolean

**Example:**
```lua
player:kick("Breaking rules")
```

## Configuration API

### Core.getConfig(key, default)

Get configuration value.

**Parameters:**
- `key` (string) - Config key (dot notation)
- `default` (any) - Default value jika tidak ada

**Returns:** any

**Example:**
```lua
local logLevel = Core.getConfig("core.logLevel", "info")
```

### Core.setConfig(key, value)

Set configuration value (runtime only).

**Parameters:**
- `key` (string) - Config key
- `value` (any) - Config value

**Returns:** boolean

## Logging API

### Core.log.debug(message)

Log debug message.

**Parameters:**
- `message` (string) - Log message

**Example:**
```lua
Core.log.debug("Debug information")
```

### Core.log.info(message)

Log info message.

### Core.log.warn(message)

Log warning message.

### Core.log.error(message)

Log error message.

### Core.log.setLevel(level)

Set log level.

**Parameters:**
- `level` (string) - "debug", "info", "warn", "error"

### Core.log.getLevel()

Get current log level.

**Returns:** string

## Cache API

### Core.cache.get(key)

Get value dari cache.

**Parameters:**
- `key` (string) - Cache key

**Returns:** any atau nil

**Example:**
```lua
local value = Core.cache.get("myKey")
```

### Core.cache.set(key, value, ttl)

Set value ke cache.

**Parameters:**
- `key` (string) - Cache key
- `value` (any) - Cache value
- `ttl` (number, optional) - Time to live in seconds

**Returns:** boolean

**Example:**
```lua
Core.cache.set("myKey", "myValue", 300)  -- 5 minutes
```

### Core.cache.delete(key)

Delete value dari cache.

**Parameters:**
- `key` (string) - Cache key

**Returns:** boolean

### Core.cache.has(key)

Check if key exists di cache.

**Parameters:**
- `key` (string) - Cache key

**Returns:** boolean

### Core.cache.clear()

Clear semua cache entries.

**Returns:** number (jumlah entries yang di-clear)

### Core.cache.getStats()

Get cache statistics.

**Returns:** table dengan stats

**Example:**
```lua
local stats = Core.cache.getStats()
print("Cache size: " .. stats.size)
print("Hit rate: " .. stats.hitRate .. "%")
```

## Module API

### Core.getModule(name)

Get loaded module by name.

**Parameters:**
- `name` (string) - Module name

**Returns:** Module object atau nil

### Core.isModuleLoaded(name)

Check if module is loaded.

**Parameters:**
- `name` (string) - Module name

**Returns:** boolean

## Language Bridge API

### Core.emitToJS(eventName, data)

Emit event ke JavaScript runtime.

**Parameters:**
- `eventName` (string) - Event name
- `data` (any) - Event data

**Returns:** boolean

**Example (Lua):**
```lua
Core.emitToJS("myEvent", { message = "Hello JS" })
```

### Core.onFromJS(eventName, callback)

Listen for events dari JavaScript.

**Parameters:**
- `eventName` (string) - Event name
- `callback` (function) - Callback function

**Returns:** boolean

**Example (Lua):**
```lua
Core.onFromJS("jsEvent", function(data)
    print("Received from JS: " .. data.message)
end)
```

### Core.emitToLua(eventName, data)

Emit event ke Lua runtime (JavaScript only).

**Example (JavaScript):**
```javascript
Core.emitToLua("myEvent", { message: "Hello Lua" });
```

### Core.onFromLua(eventName, callback)

Listen for events dari Lua (JavaScript only).

**Example (JavaScript):**
```javascript
Core.onFromLua("luaEvent", (data) => {
    console.log("Received from Lua:", data.message);
});
```

## Lifecycle Events

### core:ready

Emitted saat Core selesai initialize.

**Data:** `{ version: string }`

**Example:**
```lua
Core.on("core:ready", function(data)
    print("Core ready: v" .. data.version)
end)
```

### core:shutdown

Emitted saat server stopping.

### player:connected

Emitted saat player connect.

**Data:** Player object

### player:disconnected

Emitted saat player disconnect.

**Data:** Player object

### permission:changed

Emitted saat player permission berubah.

**Data:** `{ playerId, oldRole, newRole }`

### module:loaded

Emitted saat module berhasil loaded.

**Data:** `{ name, version }`

### module:failed

Emitted saat module gagal load.

**Data:** `{ name, error }`

## Best Practices

1. **Always check for nil** saat get player
2. **Use namespaced events** (e.g., "mymodule:event")
3. **Handle errors** dalam event callbacks
4. **Clean up** listeners saat tidak dibutuhkan
5. **Use cache** untuk data yang sering diakses
6. **Log appropriately** - debug untuk development, info untuk production

## Next Steps

- [Event System Guide](./03-event-system.md)
- [Module Development](./04-module-development.md)
- [Best Practices](./05-best-practices.md)
