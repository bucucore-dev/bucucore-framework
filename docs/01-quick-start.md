# Quick Start Guide

Panduan cepat untuk memulai dengan Bucu Core.

## Instalasi

### 1. Download

Clone repository ke folder `resources/` FiveM server Anda:

```bash
cd resources/
git clone https://github.com/bucucore-dev/bucucore-framework.git bucu-core
```

### 2. Konfigurasi

Edit `server.cfg` dan tambahkan:

```cfg
ensure bucu-core
```

### 3. Start Server

Restart FiveM server Anda. Bucu Core akan otomatis initialize.

## Verifikasi

Cek console log untuk memastikan Bucu Core loaded:

```
========================================
  Bucu Core v1.0.0
  Initializing...
========================================
[INFO] Loading configuration...
[INFO] Event System ready
[INFO] State Cache ready
[INFO] Permission Manager ready
[INFO] Initializing FiveM Adapter...
[INFO] Loading modules...
[INFO] Core initialization complete
========================================
  Bucu Core Ready!
========================================
```

## Contoh Penggunaan

### Lua

```lua
-- Register event listener
Core.on("player:connected", function(player)
    Core.log.info("Player joined: " .. player.name)
    
    -- Set metadata
    player:setMeta("joinTime", os.time())
    
    -- Check permission
    local role = player:getPermission()
    Core.log.info("Player role: " .. role)
end)

-- Emit custom event
Core.emit("custom:event", {
    message = "Hello World"
})

-- Use cache
Core.cache.set("myKey", "myValue", 300)  -- 5 minutes TTL
local value = Core.cache.get("myKey")

-- Get player
local player = Core.getPlayer(source)
if player then
    player:kick("Goodbye!")
end
```

### JavaScript

```javascript
// Register event listener
Core.on("player:connected", (player) => {
    Core.log.info(`Player joined: ${player.name}`);
    
    // Set metadata
    player.setMeta("joinTime", Date.now());
    
    // Check permission
    const role = player.getPermission();
    Core.log.info(`Player role: ${role}`);
});

// Emit custom event
Core.emit("custom:event", {
    message: "Hello World"
});

// Use cache
Core.cache.set("myKey", "myValue", 300);  // 5 minutes TTL
const value = Core.cache.get("myKey");

// Get player
const player = Core.getPlayer(source);
if (player) {
    player.kick("Goodbye!");
}
```

## Membuat Module

### 1. Struktur Module

```
modules/
└── my-module/
    ├── module.lua
    ├── config.lua
    └── README.md
```

### 2. module.lua

```lua
return {
    name = "my-module",
    version = "1.0.0",
    author = "Your Name",
    description = "My awesome module",
    dependencies = {},
    
    init = function(Core)
        Core.log.info("My module initialized!")
        
        Core.on("core:ready", function()
            -- Your module logic here
        end)
    end
}
```

### 3. config.lua

```lua
return {
    enabled = true,
    setting1 = "value1",
    setting2 = 123
}
```

### 4. Load Module

Module akan otomatis di-load saat server start.

## Admin Commands

Bucu Core includes module `bucu-admin` dengan commands:

- `/kick [id] [reason]` - Kick player
- `/setperm [id] [role]` - Set permission
- `/getperm [id]` - Check permission

## Next Steps

- [Core API Reference](./02-core-api.md)
- [Event System](./03-event-system.md)
- [Module Development](./04-module-development.md)
- [Best Practices](./05-best-practices.md)

## Troubleshooting

### Module tidak load

1. Cek console untuk error messages
2. Pastikan `module.lua` dan `config.lua` ada
3. Verify module contract (name, version, init)

### Permission tidak work

1. Cek role hierarchy di `PermissionManager`
2. Verify permission checks di code
3. Check logs untuk permission changes

### Event tidak trigger

1. Verify event name (case-sensitive)
2. Check listener registration
3. Look for errors in callbacks

## Support

- GitHub Issues: https://github.com/bucucore-dev/bucucore-framework/issues
- Discord: https://discord.gg/bucu-core
- Documentation: https://docs.bucu-core.com
