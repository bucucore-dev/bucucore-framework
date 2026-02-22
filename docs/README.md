# Bucu Core Documentation

Dokumentasi lengkap untuk Bucu Core Framework.

## 📚 Table of Contents

### Getting Started
1. [Quick Start Guide](./01-quick-start.md) - Instalasi dan penggunaan dasar
2. [Core API Reference](./02-core-api.md) - Dokumentasi API lengkap
3. [Best Practices](./03-best-practices.md) - Panduan best practices
4. [Troubleshooting](./04-troubleshooting.md) - Solusi masalah umum

### Core Concepts

#### Event System
- Pub-sub event communication
- Error isolation per callback
- Rate limiting
- Cross-language events

#### Player Management
- Player abstraction layer
- Metadata storage
- Permission integration
- Lifecycle management

#### Permission System
- Role-based access control
- Permission hierarchy
- Runtime permission changes
- Event notifications

#### Module System
- Dynamic module loading
- Dependency resolution
- Module contract
- Hot reload (dev mode)

#### State Cache
- In-memory key-value storage
- TTL support
- Statistics tracking
- Performance optimization

#### Configuration
- Dot notation access
- Default values
- Runtime updates
- Module-specific config

#### Logging
- 4 severity levels (debug, info, warn, error)
- Color-coded output
- Configurable log levels
- Structured logging

### Advanced Topics

#### Language Bridge
- Lua ↔ JavaScript communication
- Event serialization
- Cross-runtime data sharing
- API parity maintenance

#### Platform Adapter
- FiveM-specific bridge
- Platform-agnostic core
- Native API wrapping
- Player lifecycle hooks

#### CLI Tool
- Project initialization
- Module scaffolding
- Development mode
- Hot reload watching

## 🎯 Quick Links

### For Beginners
- [Installation](./01-quick-start.md#instalasi)
- [First Module](./01-quick-start.md#membuat-module)
- [Basic Examples](./01-quick-start.md#contoh-penggunaan)

### For Developers
- [API Reference](./02-core-api.md)
- [Module Development](./01-quick-start.md#membuat-module)
- [Best Practices](./03-best-practices.md)

### For Troubleshooting
- [Common Issues](./04-troubleshooting.md)
- [Error Messages](./04-troubleshooting.md#error-messages)
- [Debug Tips](./04-troubleshooting.md#debug-tips)

## 📖 Documentation by Topic

### Events
```lua
-- Register listener
Core.on("event:name", function(data)
    -- Handle event
end)

-- Emit event
Core.emit("event:name", { key = "value" })
```

[Full Event System Documentation →](./02-core-api.md#event-system)

### Players
```lua
-- Get player
local player = Core.getPlayer(source)

-- Player methods
player:setMeta("key", "value")
player:setPermission("admin")
player:kick("reason")
```

[Full Player API Documentation →](./02-core-api.md#player-api)

### Cache
```lua
-- Set with TTL
Core.cache.set("key", "value", 300)  -- 5 minutes

-- Get value
local value = Core.cache.get("key")
```

[Full Cache API Documentation →](./02-core-api.md#cache-api)

### Permissions
```lua
-- Set permission
player:setPermission("admin")

-- Check permission
local role = player:getPermission()
```

[Full Permission Documentation →](./02-core-api.md#player-object)

### Configuration
```lua
-- Get config value
local value = Core.getConfig("core.logLevel", "info")

-- Set config (runtime)
Core.setConfig("custom.setting", "value")
```

[Full Config Documentation →](./02-core-api.md#configuration-api)

### Logging
```lua
-- Log messages
Core.log.debug("Debug info")
Core.log.info("Information")
Core.log.warn("Warning")
Core.log.error("Error")
```

[Full Logging Documentation →](./02-core-api.md#logging-api)

## 🔧 Development Workflow

### 1. Setup Project
```bash
bucu init my-server
cd my-server
```

### 2. Create Module
```bash
bucu create-module my-module
```

### 3. Development
```bash
bucu dev  # Start dev mode with hot reload
```

### 4. Testing
```lua
-- Run integration tests
/test-core
```

### 5. Production
- Disable dev mode
- Set appropriate log level
- Review security settings

## 📝 Code Examples

### Complete Module Example

```lua
-- modules/my-module/module.lua
return {
    name = "my-module",
    version = "1.0.0",
    author = "Your Name",
    description = "My awesome module",
    dependencies = {},
    
    init = function(Core)
        Core.log.info("Initializing my-module")
        
        -- Wait for core ready
        Core.on("core:ready", function()
            -- Register commands
            RegisterCommand("mycommand", function(source, args)
                local player = Core.getPlayer(source)
                if not player then return end
                
                -- Check permission
                if player:getPermission() ~= "admin" then
                    return
                end
                
                -- Execute command
                Core.log.info("Command executed by: " .. player.name)
            end, false)
            
            -- Listen for player events
            Core.on("player:connected", function(player)
                Core.log.info("Player joined: " .. player.name)
                player:setMeta("joinTime", os.time())
            end)
        end)
        
        Core.log.info("my-module initialized")
    end
}
```

### Cross-Language Communication

```lua
-- Lua side
Core.emitToJS("luaEvent", { message = "Hello JS" })

Core.onFromJS("jsEvent", function(data)
    print("Received from JS: " .. data.message)
end)
```

```javascript
// JavaScript side
Core.emitToLua("jsEvent", { message: "Hello Lua" });

Core.onFromLua("luaEvent", (data) => {
    console.log("Received from Lua:", data.message);
});
```

## 🎓 Learning Path

### Beginner
1. Read [Quick Start Guide](./01-quick-start.md)
2. Try basic examples
3. Create your first module
4. Explore [Core API](./02-core-api.md)

### Intermediate
1. Study [Best Practices](./03-best-practices.md)
2. Implement complex modules
3. Use advanced features (cache, permissions)
4. Optimize performance

### Advanced
1. Contribute to Core
2. Create official modules
3. Help community
4. Write documentation

## 🆘 Getting Help

### Documentation
- Read relevant docs section
- Check [Troubleshooting Guide](./04-troubleshooting.md)
- Review code examples

### Community
- GitHub Issues: Bug reports and feature requests
- Discord: Real-time help and discussion
- GitHub Discussions: General questions

### Support
- Check existing issues first
- Provide detailed information
- Include error messages and logs
- Share minimal reproduction code

## 🤝 Contributing

Want to improve documentation?

1. Fork repository
2. Edit documentation files
3. Submit pull request
4. Follow [Contributing Guidelines](../CONTRIBUTING.md)

## 📄 License

Documentation is licensed under MIT License, same as Bucu Core.

## 🔗 External Resources

- [FiveM Documentation](https://docs.fivem.net)
- [Lua 5.3 Reference](https://www.lua.org/manual/5.3/)
- [JavaScript MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript)

---

**Last Updated:** February 22, 2024  
**Version:** 1.0.0
