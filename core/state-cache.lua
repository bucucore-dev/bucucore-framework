-- Bucu Core - State Cache
-- Lightweight in-memory key-value store with TTL support

local StateCache = {
    _cache = {},  -- { [key] = { value, expiry } }
    _stats = {
        hits = 0,
        misses = 0,
        sets = 0,
        deletes = 0
    }
}

-- Set a value in cache with optional TTL
function StateCache:set(key, value, ttl)
    -- Validate key
    if type(key) ~= "string" or key == "" then
        if Logger then
            Logger:error("Cache key must be a non-empty string")
        end
        return false
    end
    
    -- Calculate expiry time
    local expiry = nil
    if ttl and type(ttl) == "number" and ttl > 0 then
        expiry = os.time() + ttl
    end
    
    -- Store in cache
    self._cache[key] = {
        value = value,
        expiry = expiry
    }
    
    self._stats.sets = self._stats.sets + 1
    return true
end

-- Get a value from cache
function StateCache:get(key)
    -- Validate key
    if type(key) ~= "string" or key == "" then
        return nil
    end
    
    local entry = self._cache[key]
    
    -- Check if entry exists
    if not entry then
        self._stats.misses = self._stats.misses + 1
        return nil
    end
    
    -- Check if entry has expired
    if entry.expiry and os.time() > entry.expiry then
        self._cache[key] = nil
        self._stats.misses = self._stats.misses + 1
        return nil
    end
    
    self._stats.hits = self._stats.hits + 1
    return entry.value
end

-- Delete a value from cache
function StateCache:delete(key)
    if type(key) ~= "string" or key == "" then
        return false
    end
    
    if self._cache[key] then
        self._cache[key] = nil
        self._stats.deletes = self._stats.deletes + 1
        return true
    end
    
    return false
end

-- Check if a key exists in cache
function StateCache:has(key)
    return self:get(key) ~= nil
end

-- Clear all cache entries
function StateCache:clear()
    local count = 0
    for _ in pairs(self._cache) do
        count = count + 1
    end
    
    self._cache = {}
    
    if Logger then
        Logger:info("Cache cleared: " .. count .. " entries removed")
    end
    
    return count
end

-- Clear expired entries
function StateCache:clearExpired()
    local count = 0
    local now = os.time()
    
    for key, entry in pairs(self._cache) do
        if entry.expiry and now > entry.expiry then
            self._cache[key] = nil
            count = count + 1
        end
    end
    
    if count > 0 and Logger then
        Logger:debug("Cleared " .. count .. " expired cache entries")
    end
    
    return count
end

-- Get cache statistics
function StateCache:getStats()
    local size = 0
    for _ in pairs(self._cache) do
        size = size + 1
    end
    
    return {
        size = size,
        hits = self._stats.hits,
        misses = self._stats.misses,
        sets = self._stats.sets,
        deletes = self._stats.deletes,
        hitRate = self._stats.hits + self._stats.misses > 0 
            and (self._stats.hits / (self._stats.hits + self._stats.misses) * 100) 
            or 0
    }
end

-- Get all keys (for debugging)
function StateCache:keys()
    local keys = {}
    for key, _ in pairs(self._cache) do
        table.insert(keys, key)
    end
    return keys
end

return StateCache
