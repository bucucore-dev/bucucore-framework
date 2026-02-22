# Requirements Document: Bucu Core

## Introduction

Bucu Core is a stable, lightweight core framework for FiveM (GTA V Roleplay) designed for long-term stability and extensibility. The framework provides essential server infrastructure including event management, player abstraction, permission systems, and module loading while maintaining strict backward compatibility within the v1.x version line. The core is intentionally minimal, delegating gameplay features to external modules to ensure stability and maintainability.

## Glossary

- **Core**: The primary API object exposed to developers for framework interaction
- **BucuCore**: Branding alias that references the same object as Core
- **Module**: An external package that extends Core functionality through a defined contract
- **Player_Object**: An abstraction layer representing a connected player with metadata and permissions
- **Event_System**: The pub-sub mechanism for inter-component communication
- **Platform_Adapter**: The bridge layer between Core and FiveM-specific APIs
- **CLI_Tool**: The command-line interface tool named "bucu" for development tasks
- **Permission_Cache**: Runtime storage for player permission data
- **State_Cache**: Lightweight in-memory storage for runtime data (player cache, permissions, metadata, rate limits)
- **Module_Contract**: The required structure and fields a module must implement
- **Hot_Reload**: Development feature that reloads code changes without server restart
- **API_Parity**: The requirement that Lua and JavaScript APIs have identical functionality

## Requirements

### Requirement 1: Core API Object

**User Story:** As a developer, I want to access framework functionality through a global Core object, so that I have a consistent interface for all framework operations.

#### Acceptance Criteria

1. THE System SHALL expose a global object named "Core" in both Lua and JavaScript environments
2. THE System SHALL expose a global object named "BucuCore" that references the same object as "Core"
3. WHEN accessing Core or BucuCore THEN THE System SHALL return the same object reference
4. THE Core object SHALL remain accessible throughout the server lifecycle
5. THE Core object SHALL provide all framework APIs as methods and properties

### Requirement 2: Event System

**User Story:** As a developer, I want to register and emit events, so that I can implement loosely-coupled communication between components.

#### Acceptance Criteria

1. THE Core SHALL provide a method "on(eventName, callback)" for registering event listeners
2. THE Core SHALL provide a method "emit(eventName, data)" for triggering events
3. WHEN an event is emitted THEN THE Event_System SHALL invoke all registered callbacks for that event name
4. THE Event_System SHALL support event names using string format with ':' for namespacing
5. WHEN a callback throws an error THEN THE Event_System SHALL isolate the error and continue invoking other callbacks
6. THE Event_System SHALL pass the data parameter to all registered callbacks
7. WHEN multiple callbacks are registered for the same event THEN THE Event_System SHALL invoke them in registration order

### Requirement 3: Player Abstraction Layer

**User Story:** As a developer, I want to interact with players through a consistent Player object, so that I can manage player data without dealing with platform-specific APIs.

#### Acceptance Criteria

1. THE System SHALL provide a Player_Object for each connected player
2. THE Player_Object SHALL expose properties: id, name, identifier, ping
3. THE Player_Object SHALL provide method "getPermission()" that returns the player's current permission role
4. THE Player_Object SHALL provide method "setPermission(role)" that updates the player's permission role
5. THE Player_Object SHALL provide method "getMeta(key)" that retrieves player metadata by key
6. THE Player_Object SHALL provide method "setMeta(key, value)" that stores player metadata
7. THE Player_Object SHALL provide method "kick(reason)" that disconnects the player with a reason message
8. THE Player_Object SHALL NOT contain inventory, job, or money data
9. WHEN a player disconnects THEN THE System SHALL clean up the associated Player_Object

### Requirement 4: Permission System

**User Story:** As a developer, I want to manage player permissions, so that I can control access to features and commands.

#### Acceptance Criteria

1. THE System SHALL provide a permission system accessible through Player_Object methods
2. THE System SHALL validate permissions only on the server side
3. THE Permission_Cache SHALL store player permission data in memory during runtime
4. WHEN setPermission is called THEN THE System SHALL update the Permission_Cache immediately
5. WHEN getPermission is called THEN THE System SHALL return the cached permission value
6. THE System SHALL emit an event when a player's permission changes
7. THE System SHALL clear permission cache entries when players disconnect

### Requirement 5: Module Loader System

**User Story:** As a developer, I want to load external modules, so that I can extend Core functionality without modifying the core codebase.

#### Acceptance Criteria

1. THE System SHALL provide a module loading mechanism that discovers and initializes modules
2. WHEN loading a module THEN THE System SHALL require the presence of "module.lua" and "config.lua" files
3. THE System SHALL validate that each module implements the Module_Contract with fields: name, version, dependencies, init(Core)
4. WHEN a module's init function is called THEN THE System SHALL pass the Core object as a parameter
5. WHEN a module throws an error during initialization THEN THE System SHALL isolate the error and continue loading other modules
6. THE System SHALL prevent modules from directly modifying Core internal state
7. WHEN a module declares dependencies THEN THE System SHALL load dependencies before the dependent module
8. IF a module's dependency is missing THEN THE System SHALL log an error and skip loading that module

### Requirement 6: Configuration System

**User Story:** As a server administrator, I want to configure Core behavior through configuration files, so that I can customize the framework without code changes.

#### Acceptance Criteria

1. THE System SHALL provide a configuration loading mechanism
2. THE System SHALL load configuration from a designated config file at startup
3. WHEN configuration is loaded THEN THE System SHALL validate the configuration structure
4. THE System SHALL provide a method to access configuration values
5. IF configuration is invalid or missing THEN THE System SHALL use default values and log a warning

### Requirement 7: Logging System

**User Story:** As a developer, I want to log messages at different severity levels, so that I can debug issues and monitor system behavior.

#### Acceptance Criteria

1. THE System SHALL provide logging methods: info, warn, error, debug
2. WHEN a log method is called THEN THE System SHALL output the message with timestamp and severity level
3. THE System SHALL support configurable log levels to filter output
4. WHEN in development mode THEN THE System SHALL enable verbose logging by default
5. THE System SHALL format log messages consistently across all severity levels

### Requirement 8: Lifecycle Management

**User Story:** As a developer, I want to hook into server lifecycle events, so that I can initialize and cleanup resources properly.

#### Acceptance Criteria

1. THE System SHALL emit a "core:ready" event when initialization is complete
2. THE System SHALL emit a "core:shutdown" event when the server is stopping
3. THE System SHALL emit a "player:connected" event when a player joins
4. THE System SHALL emit a "player:disconnected" event when a player leaves
5. WHEN the server starts THEN THE System SHALL initialize in the following order: config, logging, event system, module loader, platform adapter
6. WHEN the server stops THEN THE System SHALL cleanup resources in reverse initialization order

### Requirement 9: State Cache

**User Story:** As a developer, I want lightweight in-memory caching for runtime data, so that I can improve performance without external dependencies.

#### Acceptance Criteria

1. THE System SHALL provide a State_Cache for storing runtime data
2. THE State_Cache SHALL support storing player cache data
3. THE State_Cache SHALL support storing permission cache data
4. THE State_Cache SHALL support storing runtime metadata
5. THE State_Cache SHALL support storing rate limit data
6. WHEN the server restarts THEN THE State_Cache SHALL be cleared
7. THE State_Cache SHALL NOT persist data to disk
8. THE System SHALL provide methods to get, set, and delete cache entries

### Requirement 10: Security and Error Isolation

**User Story:** As a server administrator, I want the framework to handle errors gracefully, so that one component's failure doesn't crash the entire server.

#### Acceptance Criteria

1. THE System SHALL wrap all module initialization calls in error handlers (pcall in Lua, try-catch in JavaScript)
2. THE System SHALL wrap all event callbacks in error handlers
3. WHEN an error occurs in a module THEN THE System SHALL log the error and continue operation
4. WHEN an error occurs in an event callback THEN THE System SHALL log the error and continue invoking other callbacks
5. THE System SHALL validate all input parameters to public API methods
6. THE System SHALL provide fail-safe recovery for critical operations

### Requirement 11: Rate Limiting

**User Story:** As a server administrator, I want to rate limit event emissions and API calls, so that I can prevent abuse and ensure server stability.

#### Acceptance Criteria

1. THE System SHALL provide a rate limiting mechanism for events
2. WHEN an event is emitted THEN THE System SHALL check rate limit thresholds
3. IF a rate limit is exceeded THEN THE System SHALL reject the event emission and log a warning
4. THE System SHALL store rate limit data in the State_Cache
5. THE System SHALL provide configurable rate limit thresholds per event type
6. THE System SHALL reset rate limit counters at configurable intervals

### Requirement 12: Platform Adapter for FiveM

**User Story:** As a framework maintainer, I want to isolate FiveM-specific code in an adapter layer, so that the core logic remains platform-agnostic.

#### Acceptance Criteria

1. THE System SHALL provide a Platform_Adapter that bridges Core and FiveM APIs
2. THE Platform_Adapter SHALL handle RegisterNetEvent for network event registration
3. THE Platform_Adapter SHALL handle TriggerClientEvent for client communication
4. THE Platform_Adapter SHALL bridge player join events to "player:connected" core events
5. THE Platform_Adapter SHALL bridge player leave events to "player:disconnected" core events
6. THE Platform_Adapter SHALL provide a JavaScript-Lua bridge for cross-language communication
7. THE Core logic SHALL NOT directly call FiveM-specific APIs
8. THE Platform_Adapter SHALL be the only component that imports FiveM natives

### Requirement 13: Language Parity (Lua and JavaScript)

**User Story:** As a developer, I want to use either Lua or JavaScript with identical APIs, so that I can choose my preferred language without feature limitations.

#### Acceptance Criteria

1. THE System SHALL provide complete API_Parity between Lua and JavaScript implementations
2. WHEN a method exists in Lua THEN THE System SHALL provide the same method in JavaScript with identical signature
3. WHEN a method exists in JavaScript THEN THE System SHALL provide the same method in Lua with identical signature
4. THE System SHALL ensure identical behavior for all API methods across both languages
5. THE System SHALL provide the same Core object structure in both languages
6. THE System SHALL provide the same Player_Object structure in both languages
7. THE System SHALL support cross-language event communication (Lua can emit events consumed by JavaScript and vice versa)

### Requirement 14: CLI Tool

**User Story:** As a developer, I want a command-line tool to manage my Bucu Core project, so that I can streamline development workflows.

#### Acceptance Criteria

1. THE System SHALL provide a CLI_Tool named "bucu"
2. THE CLI_Tool SHALL provide a command "init" that creates a new project structure
3. THE CLI_Tool SHALL provide a command "create module" that scaffolds a new module
4. THE CLI_Tool SHALL provide a command "dev" that starts development mode
5. WHEN "bucu init" is executed THEN THE CLI_Tool SHALL create the necessary directory structure and configuration files
6. WHEN "bucu create module" is executed THEN THE CLI_Tool SHALL generate module.lua, config.lua, and a basic module contract implementation
7. WHEN "bucu dev" is executed THEN THE CLI_Tool SHALL enable hot reload and verbose logging

### Requirement 15: Development Mode and Hot Reload

**User Story:** As a developer, I want to reload code changes without restarting the server, so that I can iterate quickly during development.

#### Acceptance Criteria

1. THE System SHALL provide a development mode that can be enabled via configuration or CLI
2. WHEN development mode is enabled THEN THE System SHALL enable Hot_Reload functionality
3. WHEN development mode is enabled THEN THE System SHALL enable verbose logging
4. WHEN a file change is detected THEN THE Hot_Reload system SHALL reload the affected module
5. WHEN an error occurs during hot reload THEN THE System SHALL log a clear error message and maintain the previous working state
6. THE System SHALL provide clear error messages with file names and line numbers in development mode
7. THE Hot_Reload system SHALL NOT be available in production mode

### Requirement 16: Backward Compatibility Contract

**User Story:** As a server administrator, I want API stability within v1.x versions, so that I can update the framework without breaking my modules.

#### Acceptance Criteria

1. THE System SHALL maintain backward compatibility for all public APIs within v1.x versions
2. WHEN a new v1.x version is released THEN THE System SHALL NOT remove or rename existing public API methods
3. WHEN a new v1.x version is released THEN THE System SHALL NOT change existing method signatures
4. WHEN a new v1.x version is released THEN THE System SHALL NOT change existing event names
5. IF a public API needs to be deprecated THEN THE System SHALL maintain the deprecated API and log a deprecation warning
6. THE System SHALL document all public APIs as part of the v1.x contract

### Requirement 17: Core Scope Restrictions

**User Story:** As a framework maintainer, I want to enforce strict scope boundaries, so that the core remains lightweight and stable.

#### Acceptance Criteria

1. THE Core SHALL NOT implement inventory system functionality
2. THE Core SHALL NOT implement job system functionality
3. THE Core SHALL NOT implement money system functionality
4. THE Core SHALL NOT implement UI components
5. THE Core SHALL NOT implement vehicle logic
6. THE Core SHALL NOT store permanent gameplay data
7. WHEN a feature request falls outside core scope THEN THE System SHALL direct implementation to external modules

### Requirement 18: Official Reference Module (bucu-admin)

**User Story:** As a module developer, I want a reference implementation, so that I can understand best practices and quality standards.

#### Acceptance Criteria

1. THE System SHALL provide an official module named "bucu-admin"
2. THE bucu-admin module SHALL demonstrate proper Module_Contract implementation
3. THE bucu-admin module SHALL demonstrate permission system usage
4. THE bucu-admin module SHALL implement admin commands as examples
5. THE bucu-admin module SHALL serve as a quality standard reference for third-party modules
6. THE bucu-admin module SHALL include comprehensive inline documentation

### Requirement 19: Documentation

**User Story:** As a developer, I want comprehensive documentation in Bahasa Indonesia, so that I can learn and use the framework effectively.

#### Acceptance Criteria

1. THE System SHALL provide documentation in Bahasa Indonesia
2. THE documentation SHALL prioritize runnable examples over theoretical explanations
3. THE documentation SHALL include sections: Introduction, Installation, Basic Concepts, Core API, Player, Event System, Module System, Permissions, Dev Mode, JS Support, Best Practices, Migration, FAQ
4. WHEN an example is provided THEN THE documentation SHALL ensure it is complete and runnable
5. THE documentation SHALL be written for beginners with clear explanations
6. THE documentation SHALL include code examples for both Lua and JavaScript

### Requirement 20: Error Messages and Developer Experience

**User Story:** As a developer, I want clear error messages, so that I can quickly identify and fix issues.

#### Acceptance Criteria

1. WHEN an error occurs THEN THE System SHALL provide error messages with context (file name, line number, operation)
2. WHEN a module fails to load THEN THE System SHALL log the module name and specific error reason
3. WHEN an API is called with invalid parameters THEN THE System SHALL provide a descriptive error message indicating expected types
4. WHEN a dependency is missing THEN THE System SHALL log which module requires which dependency
5. THE System SHALL provide helpful suggestions in error messages when possible
6. WHEN in development mode THEN THE System SHALL provide stack traces for all errors
