-- Bucu Admin Module Configuration

return {
    -- Module enabled
    enabled = true,
    
    -- Default admin commands
    commands = {
        kick = true,
        setperm = true,
        getperm = true
    },
    
    -- Permission requirements
    permissions = {
        kick = "moderator",      -- Minimum role to kick
        setperm = "admin",       -- Minimum role to set permissions
        getperm = "user"         -- Anyone can check permissions
    },
    
    -- Logging
    logActions = true,
    
    -- Notifications
    notifyTarget = true,  -- Notify player when their permission changes
    notifyAdmins = true   -- Notify other admins of actions
}
