// Bucu Core - Logger System (JavaScript)
// Provides structured logging with severity levels

const Logger = {
    level: "info",  // Current log level
    
    // Log level priorities
    _levels: {
        debug: 1,
        info: 2,
        warn: 3,
        error: 4
    },
    
    // ANSI color codes for console output
    _colors: {
        debug: "\x1b[36m",  // Cyan
        info: "\x1b[32m",   // Green
        warn: "\x1b[33m",   // Yellow
        error: "\x1b[31m",  // Red
        reset: "\x1b[0m"
    },
    
    // Internal log method
    _log(level, message) {
        // Check if this log level should be output
        if (this._levels[level] < this._levels[this.level]) {
            return;
        }
        
        // Validate inputs
        if (typeof message !== "string") {
            message = String(message);
        }
        
        // Format timestamp
        const now = new Date();
        const timestamp = now.toISOString().replace('T', ' ').substring(0, 19);
        
        // Format message with color
        const color = this._colors[level] || "";
        const reset = this._colors.reset;
        const formatted = `${color}[${timestamp}] [${level.toUpperCase()}]${reset} ${message}`;
        
        // Output to console
        console.log(formatted);
    },
    
    // Public logging methods
    debug(message) {
        this._log("debug", message);
    },
    
    info(message) {
        this._log("info", message);
    },
    
    warn(message) {
        this._log("warn", message);
    },
    
    error(message) {
        this._log("error", message);
    },
    
    // Set log level
    setLevel(level) {
        if (this._levels[level]) {
            this.level = level;
            this.info(`Log level set to: ${level}`);
        } else {
            this.warn(`Invalid log level: ${level}`);
        }
    },
    
    // Get current log level
    getLevel() {
        return this.level;
    }
};

// Export for Node.js and FiveM
if (typeof module !== 'undefined' && module.exports) {
    module.exports = Logger;
}

// Make available globally in FiveM
if (typeof global !== 'undefined') {
    global.Logger = Logger;
}
