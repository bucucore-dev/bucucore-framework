# Bucu Core v1.0.0 - Release Notes

**Release Date:** February 22, 2024  
**Status:** Production Ready ✅

## 🎉 Initial Release

Bucu Core v1.0.0 adalah release pertama dari framework core yang stabil dan ringan untuk FiveM (GTA V Roleplay). Framework ini dirancang untuk long-term stability dengan strict backward compatibility dalam v1.x version line.

## ✨ Key Features

### Core Functionality
- ✅ **Dual Global Objects** - `Core` dan `BucuCore` (same reference)
- ✅ **Event System** - Pub-sub dengan error isolation dan rate limiting
- ✅ **Player Abstraction** - Lightweight player objects dengan metadata
- ✅ **Permission System** - Role-based dengan hierarchy support
- ✅ **Module Loader** - Dynamic loading dengan dependency resolution
- ✅ **State Cache** - In-memory cache dengan TTL support
- ✅ **Config Manager** - Dot notation configuration access
- ✅ **Logger System** - 4 severity levels dengan color coding
- ✅ **FiveM Adapter** - Platform-agnostic core dengan FiveM bridge
- ✅ **Language Bridge** - Lua ↔ JavaScript event communication

### Language Support
- ✅ **Complete API Parity** - 100% identical API antara Lua dan JavaScript
- ✅ **Cross-Language Events** - Seamless communication between runtimes
- ✅ **Dual Implementation** - Semua core services available di kedua bahasa

### Developer Experience
- ✅ **CLI Tool** - `bucu` command untuk project dan module management
- ✅ **Hot Reload** - Development mode dengan file watching
- ✅ **Error Isolation** - Modules dan callbacks run dalam protected contexts
- ✅ **Statistics Tracking** - Performance metrics untuk semua systems
- ✅ **Comprehensive Docs** - Lengkap dalam Bahasa Indonesia

### Official Modules
- ✅ **bucu-admin** - Reference implementation dengan admin commands

## 📦 What's Included

### Core Files
- Complete Lua implementation (7 core services)
- Complete JavaScript implementation (API parity)
- FiveM platform adapter (Lua & JS)
- Language bridge (cross-runtime communication)
- Default configuration
- FiveM resource manifest

### CLI Tool
- `bucu init` - Initialize new project
- `bucu create-module` - Scaffold new module
- `bucu dev` - Development mode dengan hot reload

### Documentation
- Quick Start Guide
- Complete API Reference
- Best Practices Guide
- Troubleshooting Guide
- Module Development Guide

### Official Module
- bucu-admin dengan commands: `/kick`, `/setperm`, `/getperm`

### Tests
- Integration test suite
- Manual testing guide

## 🚀 Getting Started

### Installation

```bash
cd resources/
git clone https://github.com/bucucore-dev/bucucore-framework.git bucu-core
```

Add to `server.cfg`:
```cfg
ensure bucu-core
```

### Quick Example

```lua
-- Lua
Core.on("player:connected", function(player)
    Core.log.info("Player joined: " .. player.name)
    player:setMeta("joinTime", os.time())
end)
```

```javascript
// JavaScript
Core.on("player:connected", (player) => {
    Core.log.info(`Player joined: ${player.name}`);
    player.setMeta("joinTime", Date.now());
});
```

## 🎯 Design Principles

1. **Stability First** - Backward compatible dalam v1.x
2. **Minimal Core** - Gameplay features di modules, bukan core
3. **API Parity** - Lua dan JavaScript 100% identical
4. **Error Isolation** - One component failure tidak crash server
5. **Developer Friendly** - Clear APIs, good docs, helpful tools

## 📊 Technical Specifications

- **Lua Version:** 5.3+
- **JavaScript:** ES6+
- **FiveM Server:** Build 5848+
- **OneSync:** Required
- **Lines of Code:** ~5,000+
- **Files:** 40+
- **Test Coverage:** Integration tests included

## 🔒 Core Scope

**Included in Core:**
- Event system
- Player management
- Permission system
- Module loading
- Configuration
- Logging
- Caching
- Platform adapter

**NOT in Core (use modules):**
- Inventory system
- Job system
- Money/economy
- UI components
- Vehicle logic
- Gameplay features

## 🐛 Known Issues

None at release. Report issues at: https://github.com/bucucore-dev/bucucore-framework/issues

## 🔄 Upgrade Path

This is the initial release. Future v1.x updates will be backward compatible.

## 📝 Breaking Changes

None (initial release).

## 🙏 Credits

- **Bucu Team** - Core development
- **FiveM Community** - Feedback and testing
- **Contributors** - See CONTRIBUTORS.md

## 📄 License

MIT License - See LICENSE file

## 🔗 Links

- **GitHub:** https://github.com/bucucore-dev/bucucore-framework
- **Documentation:** https://docs.bucu-core.com
- **Discord:** https://discord.gg/bucu-core
- **Issues:** https://github.com/bucucore-dev/bucucore-framework/issues

## 🎯 Roadmap

### v1.1.0 (Planned)
- Performance optimizations
- Enhanced debugging tools
- Additional official modules
- Extended documentation

### v1.2.0 (Planned)
- Module marketplace integration
- WebSocket support
- Advanced monitoring tools

### v2.0.0 (Future)
- Async event system
- Built-in database abstraction
- Performance metrics
- Distributed caching

## 💬 Feedback

We welcome feedback! Please:
- Report bugs via GitHub Issues
- Suggest features via GitHub Discussions
- Join our Discord community
- Contribute via Pull Requests

## 🎉 Thank You!

Thank you for using Bucu Core! We're excited to see what you build with it.

---

**Bucu Core v1.0.0** - Built for stability, designed for extensibility.
