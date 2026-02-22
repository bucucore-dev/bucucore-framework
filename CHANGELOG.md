# Changelog

All notable changes to Bucu Core will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-02-22

### Added
- **Core API Object** - Global `Core` and `BucuCore` objects with complete API
- **Event System** - Pub-sub event system with error isolation
- **Rate Limiting** - Configurable rate limits per event
- **Player Abstraction** - Player objects with metadata and permissions
- **Permission System** - Role-based permission management with hierarchy
- **Module Loader** - Dynamic module loading with dependency resolution
- **State Cache** - In-memory key-value cache with TTL support
- **Config Manager** - Configuration loading with dot notation access
- **Logger System** - Structured logging with 4 severity levels
- **FiveM Adapter** - Platform-specific bridge for FiveM APIs
- **Language Bridge** - Cross-language event communication (Lua ↔ JavaScript)
- **API Parity** - Complete 1:1 API between Lua and JavaScript
- **Error Isolation** - All external code runs in protected contexts
- **Lifecycle Events** - `core:ready`, `core:shutdown`, `player:connected`, `player:disconnected`
- **Statistics Tracking** - Performance metrics for all core systems

### Features
- ✅ Dual language support (Lua & JavaScript)
- ✅ Hot reload support (development mode)
- ✅ Module dependency resolution
- ✅ Circular dependency detection
- ✅ Automatic player cleanup on disconnect
- ✅ Permission cache management
- ✅ Event error isolation
- ✅ Configurable log levels
- ✅ TTL-based cache expiry
- ✅ Rate limit auto-reset

### Documentation
- Complete README with quick start guide
- API documentation for all core systems
- Contributing guidelines
- MIT License

### Technical Details
- **Lua Version**: 5.3+
- **JavaScript**: ES6+
- **FiveM**: Server build 5848+
- **OneSync**: Required

## [Unreleased]

### Planned for v1.1.0
- Performance optimizations
- Enhanced debugging tools
- Module marketplace integration
- WebSocket support for external tools

### Planned for v2.0.0
- Async event system (promises/coroutines)
- Built-in database abstraction
- Performance monitoring and metrics
- Distributed caching support

---

## Version History

- **v1.0.0** (2024-02-22) - Initial release

[1.0.0]: https://github.com/bucucore-dev/bucucore-framework/releases/tag/v1.0.0
[Unreleased]: https://github.com/bucucore-dev/bucucore-framework/compare/v1.0.0...HEAD
