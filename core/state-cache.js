// Bucu Core - State Cache (JavaScript)
// Lightweight in-memory key-value store with TTL support

const StateCache = {
    _cache: new Map(),  // Map<string, { value: any, expiry: number | null }>
    _stats: {
        hits: 0,
        misses: 0,
        sets: 0,
        deletes: 0
    },
    
    // Set a value in cache with optional TTL
    set(key, value, ttl) {
        // Validate key
        if (typeof key !== "string" || key === "") {
            if (typeof Logger !== 'undefined') {
                Logger.error("Cache key must be a non-empty string");
            }
            return false;
        }
        
        // Calculate expiry time
        let expiry = null;
        if (ttl && typeof ttl === "number" && ttl > 0) {
            expiry = Date.now() + (ttl * 1000);  // Convert seconds to milliseconds
        }
        
        // Store in cache
        this._cache.set(key, {
            value: value,
            expiry: expiry
        });
        
        this._stats.sets++;
        return true;
    },
    
    // Get a value from cache
    get(key) {
        // Validate key
        if (typeof key !== "string" || key === "") {
            return null;
        }
        
        const entry = this._cache.get(key);
        
        // Check if entry exists
        if (!entry) {
            this._stats.misses++;
            return null;
        }
        
        // Check if entry has expired
        if (entry.expiry && Date.now() > entry.expiry) {
            this._cache.delete(key);
            this._stats.misses++;
            return null;
        }
        
        this._stats.hits++;
        return entry.value;
    },
    
    // Delete a value from cache
    delete(key) {
        if (typeof key !== "string" || key === "") {
            return false;
        }
        
        if (this._cache.has(key)) {
            this._cache.delete(key);
            this._stats.deletes++;
            return true;
        }
        
        return false;
    },
    
    // Check if a key exists in cache
    has(key) {
        return this.get(key) !== null;
    },
    
    // Clear all cache entries
    clear() {
        const count = this._cache.size;
        this._cache.clear();
        
        if (typeof Logger !== 'undefined') {
            Logger.info(`Cache cleared: ${count} entries removed`);
        }
        
        return count;
    },
    
    // Clear expired entries
    clearExpired() {
        let count = 0;
        const now = Date.now();
        
        for (const [key, entry] of this._cache.entries()) {
            if (entry.expiry && now > entry.expiry) {
                this._cache.delete(key);
                count++;
            }
        }
        
        if (count > 0 && typeof Logger !== 'undefined') {
            Logger.debug(`Cleared ${count} expired cache entries`);
        }
        
        return count;
    },
    
    // Get cache statistics
    getStats() {
        const totalRequests = this._stats.hits + this._stats.misses;
        const hitRate = totalRequests > 0 
            ? (this._stats.hits / totalRequests * 100) 
            : 0;
        
        return {
            size: this._cache.size,
            hits: this._stats.hits,
            misses: this._stats.misses,
            sets: this._stats.sets,
            deletes: this._stats.deletes,
            hitRate: hitRate
        };
    },
    
    // Get all keys (for debugging)
    keys() {
        return Array.from(this._cache.keys());
    }
};

// Export for Node.js and FiveM
if (typeof module !== 'undefined' && module.exports) {
    module.exports = StateCache;
}

// Make available globally in FiveM
if (typeof global !== 'undefined') {
    global.StateCache = StateCache;
}
