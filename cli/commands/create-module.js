// Bucu CLI - Create Module Command
// Scaffolds a new module with template files

const fs = require('fs-extra');
const path = require('path');

module.exports = async function(moduleName, options) {
    console.log(`\n📦 Creating module: ${moduleName}\n`);
    
    const moduleDir = path.join(process.cwd(), 'modules', moduleName);
    
    // Check if module exists
    if (fs.existsSync(moduleDir)) {
        console.error(`❌ Error: Module '${moduleName}' already exists`);
        process.exit(1);
    }
    
    try {
        // Create module directory
        console.log('📁 Creating module structure...');
        fs.mkdirSync(moduleDir, { recursive: true });
        
        // Create module.lua
        console.log('📝 Creating module.lua...');
        const moduleLua = `-- ${moduleName} Module
-- ${options.description || 'Module description'}

return {
    name = "${moduleName}",
    version = "1.0.0",
    author = "${options.author}",
    description = "${options.description || 'Module description'}",
    dependencies = {},  -- Add dependencies here
    
    -- Module initialization
    init = function(Core)
        Core.log.info("Initializing ${moduleName} module")
        
        -- Register event listeners
        Core.on("core:ready", function()
            Core.log.info("${moduleName}: Ready")
            
            -- Your module logic here
        end)
        
        -- Example: Player connected event
        Core.on("player:connected", function(player)
            Core.log.debug("${moduleName}: Player connected - " .. player.name)
        end)
        
        Core.log.info("${moduleName} module initialized")
    end
}
`;
        fs.writeFileSync(path.join(moduleDir, 'module.lua'), moduleLua);
        
        // Create config.lua
        console.log('⚙️  Creating config.lua...');
        const configLua = `-- ${moduleName} Configuration

return {
    enabled = true,
    
    -- Add your configuration here
    setting1 = "value1",
    setting2 = 123,
    
    -- Example: Feature toggles
    features = {
        feature1 = true,
        feature2 = false
    }
}
`;
        fs.writeFileSync(path.join(moduleDir, 'config.lua'), configLua);
        
        // Create README.md
        console.log('📄 Creating README.md...');
        const readme = `# ${moduleName}

${options.description || 'Module description'}

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

This module is automatically loaded by Bucu Core.

## Configuration

Edit \`modules/${moduleName}/config.lua\`:

\`\`\`lua
return {
    enabled = true,
    setting1 = "value1"
}
\`\`\`

## Usage

### Lua

\`\`\`lua
-- Example usage
Core.on("custom:event", function(data)
    -- Handle event
end)
\`\`\`

### JavaScript

\`\`\`javascript
// Example usage
Core.on("custom:event", (data) => {
    // Handle event
});
\`\`\`

## API

### Events

- \`${moduleName}:event1\` - Description
- \`${moduleName}:event2\` - Description

### Functions

- \`Module.function1()\` - Description
- \`Module.function2()\` - Description

## License

MIT License

## Author

${options.author}
`;
        fs.writeFileSync(path.join(moduleDir, 'README.md'), readme);
        
        console.log('\n✅ Module created successfully!\n');
        console.log('Module location:');
        console.log(`  modules/${moduleName}/\n`);
        console.log('Files created:');
        console.log(`  - module.lua`);
        console.log(`  - config.lua`);
        console.log(`  - README.md\n`);
        console.log('Next steps:');
        console.log(`  1. Edit modules/${moduleName}/module.lua`);
        console.log(`  2. Implement your module logic`);
        console.log(`  3. Restart server to load module\n`);
        
    } catch (error) {
        console.error(`❌ Error: ${error.message}`);
        process.exit(1);
    }
};
