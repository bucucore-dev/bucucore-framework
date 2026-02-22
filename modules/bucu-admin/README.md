# Bucu Admin Module

Module admin resmi untuk Bucu Core yang mendemonstrasikan best practices dalam pembuatan module.

## Fitur

- ✅ Permission management
- ✅ Admin commands (kick, setperm, getperm)
- ✅ Role-based access control
- ✅ Action logging
- ✅ Player notifications

## Commands

### /kick [player_id] [reason]
Kick player dari server.

**Permission**: `moderator` atau lebih tinggi

**Contoh**:
```
/kick 1 Breaking rules
```

### /setperm [player_id] [role]
Set permission role untuk player.

**Permission**: `admin` atau lebih tinggi

**Roles**: `user`, `moderator`, `admin`, `superadmin`

**Contoh**:
```
/setperm 1 admin
```

### /getperm [player_id]
Cek permission role player. Jika player_id tidak diberikan, cek permission sendiri.

**Permission**: `user` (semua orang)

**Contoh**:
```
/getperm
/getperm 1
```

## Installation

Module ini sudah included dalam Bucu Core. Tidak perlu instalasi tambahan.

## Configuration

Edit `modules/bucu-admin/config.lua` untuk customize behavior:

```lua
return {
    enabled = true,
    
    commands = {
        kick = true,
        setperm = true,
        getperm = true
    },
    
    permissions = {
        kick = "moderator",
        setperm = "admin",
        getperm = "user"
    },
    
    logActions = true,
    notifyTarget = true,
    notifyAdmins = true
}
```

## Development

Module ini adalah reference implementation. Gunakan sebagai template untuk membuat module Anda sendiri.

### Module Structure

```
bucu-admin/
├── module.lua    # Main module file
├── config.lua    # Configuration
└── README.md     # Documentation
```

### Module Contract

```lua
return {
    name = "module-name",
    version = "1.0.0",
    author = "Your Name",
    description = "Module description",
    dependencies = {},  -- Optional
    
    init = function(Core)
        -- Module initialization
    end
}
```

## Best Practices

1. **Error Handling** - Always validate inputs
2. **Permission Checks** - Check permissions before executing commands
3. **Logging** - Log important actions
4. **User Feedback** - Provide clear messages to users
5. **Documentation** - Document all commands and features

## License

MIT License - Same as Bucu Core
