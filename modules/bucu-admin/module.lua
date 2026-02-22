-- Bucu Admin Module
-- Official reference module demonstrating best practices

return {
    name = "bucu-admin",
    version = "1.0.0",
    author = "Bucu Team",
    description = "Official admin module with permission management and commands",
    dependencies = {},  -- No dependencies
    
    -- Module initialization
    init = function(Core)
        Core.log.info("Initializing bucu-admin module")
        
        -- Register admin commands
        Core.on("core:ready", function()
            Core.log.info("bucu-admin: Registering commands")
            
            -- Command: /kick
            RegisterCommand("kick", function(source, args, rawCommand)
                local player = Core.getPlayer(source)
                
                if not player then
                    return
                end
                
                -- Check permission
                if not player:getPermission() or player:getPermission() == "user" then
                    TriggerClientEvent("chat:addMessage", source, {
                        color = {255, 0, 0},
                        multiline = true,
                        args = {"System", "You don't have permission to use this command"}
                    })
                    return
                end
                
                -- Parse arguments
                local targetId = tonumber(args[1])
                local reason = table.concat(args, " ", 2) or "No reason specified"
                
                if not targetId then
                    TriggerClientEvent("chat:addMessage", source, {
                        color = {255, 255, 0},
                        multiline = true,
                        args = {"Usage", "/kick [player_id] [reason]"}
                    })
                    return
                end
                
                -- Get target player
                local targetPlayer = Core.getPlayer(targetId)
                if not targetPlayer then
                    TriggerClientEvent("chat:addMessage", source, {
                        color = {255, 0, 0},
                        multiline = true,
                        args = {"Error", "Player not found"}
                    })
                    return
                end
                
                -- Kick player
                targetPlayer:kick(reason)
                
                -- Notify admin
                TriggerClientEvent("chat:addMessage", source, {
                    color = {0, 255, 0},
                    multiline = true,
                    args = {"Success", string.format("Kicked %s: %s", targetPlayer.name, reason)}
                })
                
                Core.log.info(string.format(
                    "Admin %s kicked %s: %s",
                    player.name,
                    targetPlayer.name,
                    reason
                ))
            end, false)
            
            -- Command: /setperm
            RegisterCommand("setperm", function(source, args, rawCommand)
                local player = Core.getPlayer(source)
                
                if not player then
                    return
                end
                
                -- Check permission (only admin and superadmin can set permissions)
                local playerRole = player:getPermission()
                if playerRole ~= "admin" and playerRole ~= "superadmin" then
                    TriggerClientEvent("chat:addMessage", source, {
                        color = {255, 0, 0},
                        multiline = true,
                        args = {"System", "You don't have permission to use this command"}
                    })
                    return
                end
                
                -- Parse arguments
                local targetId = tonumber(args[1])
                local role = args[2]
                
                if not targetId or not role then
                    TriggerClientEvent("chat:addMessage", source, {
                        color = {255, 255, 0},
                        multiline = true,
                        args = {"Usage", "/setperm [player_id] [role]"}
                    })
                    return
                end
                
                -- Get target player
                local targetPlayer = Core.getPlayer(targetId)
                if not targetPlayer then
                    TriggerClientEvent("chat:addMessage", source, {
                        color = {255, 0, 0},
                        multiline = true,
                        args = {"Error", "Player not found"}
                    })
                    return
                end
                
                -- Set permission
                targetPlayer:setPermission(role)
                
                -- Notify admin
                TriggerClientEvent("chat:addMessage", source, {
                    color = {0, 255, 0},
                    multiline = true,
                    args = {"Success", string.format("Set %s permission to: %s", targetPlayer.name, role)}
                })
                
                -- Notify target player
                TriggerClientEvent("chat:addMessage", targetId, {
                    color = {0, 255, 255},
                    multiline = true,
                    args = {"System", string.format("Your permission has been set to: %s", role)}
                })
                
                Core.log.info(string.format(
                    "Admin %s set %s permission to: %s",
                    player.name,
                    targetPlayer.name,
                    role
                ))
            end, false)
            
            -- Command: /getperm
            RegisterCommand("getperm", function(source, args, rawCommand)
                local player = Core.getPlayer(source)
                
                if not player then
                    return
                end
                
                -- Parse arguments
                local targetId = tonumber(args[1]) or source
                
                -- Get target player
                local targetPlayer = Core.getPlayer(targetId)
                if not targetPlayer then
                    TriggerClientEvent("chat:addMessage", source, {
                        color = {255, 0, 0},
                        multiline = true,
                        args = {"Error", "Player not found"}
                    })
                    return
                end
                
                local role = targetPlayer:getPermission()
                
                TriggerClientEvent("chat:addMessage", source, {
                    color = {0, 255, 255},
                    multiline = true,
                    args = {"Permission", string.format("%s: %s", targetPlayer.name, role)}
                })
            end, false)
            
            Core.log.info("bucu-admin: Commands registered successfully")
        end)
        
        Core.log.info("bucu-admin module initialized")
    end
}
