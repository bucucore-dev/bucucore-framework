# Best Practices

Panduan best practices untuk development dengan Bucu Core.

## Module Development

### 1. Module Structure

```
my-module/
├── module.lua          # Main module file
├── config.lua          # Configuration
├── README.md           # Documentation
└── commands/           # Optional: Command handlers
    ├── kick.lua
    └── ban.lua
```

### 2. Module Contract

Selalu implement contract lengkap:

```lua
return {
    name = "my-module",           -- Required
    version = "1.0.0",            -- Required
    author = "Your Name",         -- Recommended
    description = "Description",  -- Recommended
    dependencies = {},            -- Optional
    
    init = function(Core)         -- Required
        -- Initialization logic
    end
}
```

### 3. Error Handling

Selalu handle errors:

```lua
Core.on("player:connected", function(player)
    local success, err = pcall(function()
        -- Your logic here
        player:setMeta("joinTime", os.time())
    end)
    
    if not success then
        Core.log.error("Error in player:connected: " .. tostring(err))
    end
end)
```

### 4. Permission Checks

Selalu validate permissions:

```lua
RegisterCommand("admin", function(source, args)
    local player = Core.getPlayer(source)
    if not player then return end
    
    -- Check permission
    if player:getPermission() ~= "admin" then
        -- Deny access
        return
    end
    
    -- Execute command
end)
```

## Event System

### 1. Event Naming

Gunakan namespace untuk events:

```lua
-- Good
Core.emit("mymodule:playerJoined", data)
Core.emit("mymodule:itemUsed", data)

-- Bad
Core.emit("playerJoined", data)  -- Too generic
Core.emit("event1", data)        -- Not descriptive
```

### 2. Event Data

Kirim data yang structured:

```lua
-- Good
Core.emit("shop:purchase", {
    playerId = player.id,
    itemId = "weapon_pistol",
    price = 500,
    timestamp = os.time()
})

-- Bad
Core.emit("shop:purchase", player.id, "weapon_pistol", 500)
```

### 3. Cleanup Listeners

Remove listeners yang tidak dibutuhkan:

```lua
local callback = function(data)
    -- Handle event
end

Core.on("temp:event", callback)

-- Later...
Core.off("temp:event", callback)
```

## Performance

### 1. Use Cache

Cache data yang sering diakses:

```lua
-- Bad: Query setiap kali
function getPlayerData(playerId)
    -- Expensive database query
    return database:query("SELECT * FROM players WHERE id = ?", playerId)
end

-- Good: Cache result
function getPlayerData(playerId)
    local cacheKey = "player:" .. playerId
    local cached = Core.cache.get(cacheKey)
    
    if cached then
        return cached
    end
    
    local data = database:query("SELECT * FROM players WHERE id = ?", playerId)
    Core.cache.set(cacheKey, data, 300)  -- Cache 5 minutes
    
    return data
end
```

### 2. Batch Operations

Batch operations untuk efficiency:

```lua
-- Bad: Loop dengan individual operations
for _, player in ipairs(Core.getPlayers()) do
    player:setMeta("lastUpdate", os.time())
end

-- Good: Batch update
local timestamp = os.time()
for _, player in ipairs(Core.getPlayers()) do
    player:setMeta("lastUpdate", timestamp)
end
```

### 3. Avoid Blocking

Jangan block main thread:

```lua
-- Bad: Blocking operation
function processLargeData()
    for i = 1, 1000000 do
        -- Heavy computation
    end
end

-- Good: Chunked processing
function processLargeData()
    local chunk = 1000
    local index = 0
    
    Citizen.CreateThread(function()
        while index < 1000000 do
            for i = 1, chunk do
                -- Process chunk
                index = index + 1
            end
            Citizen.Wait(0)  -- Yield
        end
    end)
end
```

## Security

### 1. Server-Side Validation

Selalu validate di server:

```lua
-- Bad: Trust client data
RegisterNetEvent("shop:buy")
AddEventHandler("shop:buy", function(itemId, price)
    -- Use price from client (DANGEROUS!)
    player:removeMoney(price)
end)

-- Good: Validate server-side
RegisterNetEvent("shop:buy")
AddEventHandler("shop:buy", function(itemId)
    local actualPrice = getItemPrice(itemId)  -- Server-side lookup
    player:removeMoney(actualPrice)
end)
```

### 2. Permission Validation

Check permissions untuk sensitive operations:

```lua
function deletePlayer(adminId, targetId)
    local admin = Core.getPlayer(adminId)
    
    -- Validate permission
    if not admin or admin:getPermission() ~= "superadmin" then
        Core.log.warn("Unauthorized delete attempt by: " .. adminId)
        return false
    end
    
    -- Execute operation
    -- ...
end
```

### 3. Input Sanitization

Sanitize user inputs:

```lua
function setPlayerName(playerId, name)
    -- Sanitize input
    name = name:gsub("[^%w%s]", "")  -- Remove special chars
    name = name:sub(1, 32)           -- Limit length
    
    if name == "" then
        return false
    end
    
    -- Set name
    -- ...
end
```

## Logging

### 1. Appropriate Log Levels

```lua
-- Debug: Development info
Core.log.debug("Player data: " .. json.encode(playerData))

-- Info: Normal operations
Core.log.info("Player " .. player.name .. " purchased item")

-- Warn: Potential issues
Core.log.warn("Player " .. player.id .. " has high ping: " .. player.ping)

-- Error: Actual errors
Core.log.error("Failed to save player data: " .. err)
```

### 2. Structured Logging

Include context dalam logs:

```lua
-- Good
Core.log.info(string.format(
    "Purchase: player=%s, item=%s, price=%d",
    player.name,
    itemId,
    price
))

-- Bad
Core.log.info("Purchase successful")
```

## Code Organization

### 1. Separate Concerns

```lua
-- commands.lua
local Commands = {}

function Commands.kick(source, args)
    -- Kick logic
end

return Commands

-- module.lua
local Commands = require('commands')

return {
    init = function(Core)
        RegisterCommand("kick", Commands.kick)
    end
}
```

### 2. Configuration

Gunakan config untuk values yang bisa berubah:

```lua
-- config.lua
return {
    maxPlayers = 32,
    kickTimeout = 60,
    enableFeatureX = true
}

-- module.lua
local config = require('config')

if config.enableFeatureX then
    -- Feature logic
end
```

## Testing

### 1. Test Error Cases

```lua
function testPlayerKick()
    -- Test valid kick
    local result = kickPlayer(1, "Test reason")
    assert(result == true)
    
    -- Test invalid player
    local result = kickPlayer(999, "Test")
    assert(result == false)
    
    -- Test missing reason
    local result = kickPlayer(1, nil)
    assert(result == false)
end
```

### 2. Test Edge Cases

```lua
-- Test empty string
-- Test nil values
-- Test negative numbers
-- Test very large numbers
-- Test special characters
```

## Documentation

### 1. Code Comments

```lua
-- Calculate player damage based on weapon and armor
-- @param weaponDamage number Base weapon damage
-- @param armorValue number Player armor value (0-100)
-- @return number Final damage after armor reduction
function calculateDamage(weaponDamage, armorValue)
    local reduction = armorValue / 100
    return weaponDamage * (1 - reduction)
end
```

### 2. README

Setiap module harus punya README dengan:
- Description
- Features
- Installation
- Configuration
- Usage examples
- API documentation

## Common Pitfalls

### ❌ Don't

```lua
-- Global variables
myGlobalVar = "bad"

-- Blocking operations
while true do
    -- No Wait()
end

-- Trust client data
RegisterNetEvent("setMoney")
AddEventHandler("setMoney", function(amount)
    player.money = amount  -- DANGEROUS
end)

-- Ignore errors
player:setMeta("key", value)  -- No error check
```

### ✅ Do

```lua
-- Local variables
local myVar = "good"

-- Non-blocking
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        -- Logic
    end
end)

-- Validate server-side
RegisterNetEvent("requestMoney")
AddEventHandler("requestMoney", function(amount)
    if isValidAmount(amount) then
        player.money = amount
    end
end)

-- Handle errors
local success = player:setMeta("key", value)
if not success then
    Core.log.error("Failed to set meta")
end
```

## Checklist

Sebelum release module:

- [ ] Module contract complete
- [ ] Error handling implemented
- [ ] Permission checks added
- [ ] Input validation done
- [ ] Performance optimized
- [ ] Security reviewed
- [ ] Logging appropriate
- [ ] Code documented
- [ ] README written
- [ ] Tested thoroughly

## Resources

- [Lua Performance Tips](https://www.lua.org/gems/sample.pdf)
- [FiveM Best Practices](https://docs.fivem.net/docs/scripting-manual/introduction/best-practices/)
- [Bucu Core Examples](https://github.com/bucucore-dev/bucucore-examples)
