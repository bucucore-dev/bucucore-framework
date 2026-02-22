# Bucu Core

Framework core yang stabil dan ringan untuk FiveM (GTA V Roleplay).

## 🎯 Fitur Utama

- **Event System** - Pub-sub communication dengan rate limiting
- **Player Abstraction** - Wrapper konsisten untuk player management
- **Permission System** - Role-based access control
- **Module Loader** - Sistem plugin dengan dependency resolution
- **State Cache** - In-memory caching ringan
- **Lua & JavaScript** - API parity penuh antara kedua bahasa
- **CLI Tool** - Development tools untuk scaffolding dan hot reload
- **Platform Agnostic** - Core logic terpisah dari FiveM specifics

## 📦 Instalasi

### Sebagai FiveM Resource

1. Clone repository ke folder `resources/`:
```bash
cd resources/
git clone https://github.com/bucucore-dev/bucucore-framework.git bucu-core
```

2. Tambahkan ke `server.cfg`:
```
ensure bucu-core
```

3. Restart server FiveM

### Sebagai CLI Tool

```bash
npm install -g bucu-core
```

## 🚀 Quick Start

### Membuat Project Baru

```bash
bucu init my-server
cd my-server
```

### Membuat Module

```bash
bucu create module my-module
```

### Development Mode

```bash
bucu dev
```

## 📖 Dokumentasi

Dokumentasi lengkap tersedia di [docs/](./docs/)

- [Pengenalan](./docs/01-introduction.md)
- [Core API](./docs/02-core-api.md)
- [Event System](./docs/03-event-system.md)
- [Module System](./docs/04-module-system.md)
- [Player API](./docs/05-player-api.md)
- [Best Practices](./docs/06-best-practices.md)

## 🔧 Contoh Penggunaan

### Lua

```lua
-- Register event listener
Core.on("player:connected", function(player)
    Core.log.info("Player connected: " .. player.name)
    player:setMeta("joinTime", os.time())
end)

-- Emit custom event
Core.emit("custom:event", { message = "Hello World" })

-- Get player
local player = Core.getPlayer(source)
if player then
    local role = player:getPermission()
    Core.log.info("Player role: " .. role)
end
```

### JavaScript

```javascript
// Register event listener
Core.on("player:connected", (player) => {
    Core.log.info(`Player connected: ${player.name}`);
    player.setMeta("joinTime", Date.now());
});

// Emit custom event
Core.emit("custom:event", { message: "Hello World" });

// Get player
const player = Core.getPlayer(source);
if (player) {
    const role = player.getPermission();
    Core.log.info(`Player role: ${role}`);
}
```

## 🏗️ Struktur Project

```
bucu-core/
├── core/              # Core services
├── platform/          # FiveM adapter
├── bridge/            # Lua-JS bridge
├── cli/               # CLI tool
├── modules/           # Official modules
├── config/            # Configuration
└── docs/              # Documentation
```

## 🤝 Contributing

Contributions welcome! Silakan baca [CONTRIBUTING.md](./CONTRIBUTING.md) untuk guidelines.

## 📄 License

MIT License - lihat [LICENSE](./LICENSE) untuk detail.

## 🔗 Links

- [Documentation](./docs/)
- [GitHub Issues](https://github.com/bucucore-dev/bucucore-framework/issues)
- [Discord Community](https://discord.gg/bucu-core)

## ⚠️ Core Scope

Bucu Core **TIDAK** menyediakan:
- Inventory system
- Job system
- Money/economy system
- UI components
- Vehicle logic
- Gameplay data permanen

Fitur-fitur tersebut harus diimplementasikan sebagai **modules** eksternal.

## 🎯 Roadmap

- [x] v1.0.0 - Core foundation
- [ ] v1.1.0 - Performance optimizations
- [ ] v1.2.0 - Enhanced debugging tools
- [ ] v2.0.0 - Async event system

---

**Bucu Core** - Built for stability, designed for extensibility.
