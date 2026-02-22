// Bucu Core - Event System (JavaScript)
// Pub-sub event system with error isolation and rate limiting

const EventSystem = {
    _listeners: new Map(),     // Map<string, Function[]>
    _rateLimits: new Map(),    // Map<string, { count: number, resetTime: number }>
    _stats: {
        emitted: 0,
        blocked: 0,
        errors: 0
    },
    
    // Register an event listener
    on(eventName, callback) {
        // Validate inputs
        if (typeof eventName !== "string" || eventName === "") {
            if (typeof Logger !== 'undefined') {
                Logger.error("Event name must be a non-empty string");
            }
            return false;
        }
        
        if (typeof callback !== "function") {
            if (typeof Logger !== 'undefined') {
                Logger.error("Callback must be a function");
            }
            return false;
        }
        
        // Initialize listener array if needed
        if (!this._listeners.has(eventName)) {
            this._listeners.set(eventName, []);
        }
        
        // Add callback to listeners
        this._listeners.get(eventName).push(callback);
        
        if (typeof Logger !== 'undefined') {
            Logger.debug(`Event listener registered: ${eventName}`);
        }
        
        return true;
    },
    
    // Emit an event
    emit(eventName, data) {
        // Validate event name
        if (typeof eventName !== "string" || eventName === "") {
            if (typeof Logger !== 'undefined') {
                Logger.error("Event name must be a non-empty string");
            }
            return false;
        }
        
        // Check rate limit
        if (!this._checkRateLimit(eventName)) {
            this._stats.blocked++;
            if (typeof Logger !== 'undefined') {
                Logger.warn(`Rate limit exceeded for event: ${eventName}`);
            }
            return false;
        }
        
        // Get listeners for this event
        const listeners = this._listeners.get(eventName);
        if (!listeners || listeners.length === 0) {
            // No listeners, but not an error
            return true;
        }
        
        // Invoke all listeners with error isolation
        let successCount = 0;
        let errorCount = 0;
        
        listeners.forEach((callback, index) => {
            try {
                callback(data);
                successCount++;
            } catch (err) {
                errorCount++;
                this._stats.errors++;
                
                if (typeof Logger !== 'undefined') {
                    Logger.error(
                        `Error in event '${eventName}' callback #${index + 1}: ${err.message}`
                    );
                }
            }
        });
        
        this._stats.emitted++;
        
        if (typeof Logger !== 'undefined' && errorCount > 0) {
            Logger.debug(
                `Event '${eventName}' completed: ${successCount} success, ${errorCount} errors`
            );
        }
        
        return true;
    },
    
    // Remove an event listener
    off(eventName, callback) {
        if (typeof eventName !== "string" || eventName === "") {
            return false;
        }
        
        const listeners = this._listeners.get(eventName);
        if (!listeners) {
            return false;
        }
        
        // Find and remove the callback
        const index = listeners.indexOf(callback);
        if (index !== -1) {
            listeners.splice(index, 1);
            
            if (typeof Logger !== 'undefined') {
                Logger.debug(`Event listener removed: ${eventName}`);
            }
            
            return true;
        }
        
        return false;
    },
    
    // Remove all listeners for an event
    removeAllListeners(eventName) {
        if (eventName) {
            this._listeners.delete(eventName);
            if (typeof Logger !== 'undefined') {
                Logger.debug(`All listeners removed for event: ${eventName}`);
            }
        } else {
            this._listeners.clear();
            if (typeof Logger !== 'undefined') {
                Logger.debug("All event listeners removed");
            }
        }
    },
    
    // Get listener count for an event
    listenerCount(eventName) {
        const listeners = this._listeners.get(eventName);
        return listeners ? listeners.length : 0;
    },
    
    // Get all registered event names
    eventNames() {
        return Array.from(this._listeners.keys());
    },
    
    // Check rate limit for an event
    _checkRateLimit(eventName) {
        // Get rate limit config
        const rateLimitEnabled = typeof ConfigManager !== 'undefined' 
            ? ConfigManager.get("rateLimit.enabled", true)
            : true;
        
        if (!rateLimitEnabled) {
            return true;
        }
        
        // Get event-specific or default limit
        let limit = typeof ConfigManager !== 'undefined'
            ? ConfigManager.get(`rateLimit.events.${eventName}.limit`)
            : null;
        
        let window = typeof ConfigManager !== 'undefined'
            ? ConfigManager.get(`rateLimit.events.${eventName}.window`)
            : null;
        
        if (!limit) {
            limit = typeof ConfigManager !== 'undefined'
                ? ConfigManager.get("rateLimit.defaultLimit", 100)
                : 100;
            window = typeof ConfigManager !== 'undefined'
                ? ConfigManager.get("rateLimit.window", 60)
                : 60;
        }
        
        // Initialize rate limit tracking
        if (!this._rateLimits.has(eventName)) {
            this._rateLimits.set(eventName, {
                count: 0,
                resetTime: Date.now() + (window * 1000)
            });
        }
        
        const rateLimit = this._rateLimits.get(eventName);
        const now = Date.now();
        
        // Reset counter if window expired
        if (now >= rateLimit.resetTime) {
            rateLimit.count = 0;
            rateLimit.resetTime = now + (window * 1000);
        }
        
        // Check if limit exceeded
        if (rateLimit.count >= limit) {
            return false;
        }
        
        // Increment counter
        rateLimit.count++;
        return true;
    },
    
    // Get event system statistics
    getStats() {
        let listenerCount = 0;
        for (const listeners of this._listeners.values()) {
            listenerCount += listeners.length;
        }
        
        return {
            events: this._listeners.size,
            listeners: listenerCount,
            emitted: this._stats.emitted,
            blocked: this._stats.blocked,
            errors: this._stats.errors
        };
    },
    
    // Reset rate limits (for testing/debugging)
    resetRateLimits() {
        this._rateLimits.clear();
        if (typeof Logger !== 'undefined') {
            Logger.debug("Rate limits reset");
        }
    }
};

// Export for Node.js and FiveM
if (typeof module !== 'undefined' && module.exports) {
    module.exports = EventSystem;
}

// Make available globally in FiveM
if (typeof global !== 'undefined') {
    global.EventSystem = EventSystem;
}
