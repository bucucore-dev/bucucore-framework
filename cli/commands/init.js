// Bucu CLI - Init Command
// Creates a new Bucu Core project structure

const fs = require('fs-extra');
const path = require('path');

module.exports = async function(projectName, options) {
    console.log(`\n🚀 Initializing Bucu Core project: ${projectName}\n`);
    
    const targetDir = path.join(options.directory, projectName);
    
    // Check if directory exists
    if (fs.existsSync(targetDir)) {
        console.error(`❌ Error: Directory '${projectName}' already exists`);
        process.exit(1);
    }
    
    try {
        // Create project structure
        console.log('📁 Creating project structure...');
        
        fs.mkdirSync(targetDir, { recursive: true });
        fs.mkdirSync(path.join(targetDir, 'modules'), { recursive: true });
        fs.mkdirSync(path.join(targetDir, 'config'), { recursive: true });
        
        // Create server.cfg
        console.log('📝 Creating server.cfg...');
        const serverCfg = `# FiveM Server Configuration
endpoint_add_tcp "0.0.0.0:30120"
endpoint_add_udp "0.0.0.0:30120"

# Server info
sv_hostname "${projectName} - Powered by Bucu Core"
sv_maxclients 32

# License key (get from https://keymaster.fivem.net)
sv_licenseKey "YOUR_LICENSE_KEY_HERE"

# Resources
ensure bucu-core

# Your resources here
# ensure your-resource
`;
        fs.writeFileSync(path.join(targetDir, 'server.cfg'), serverCfg);
        
        // Create example config
        console.log('⚙️  Creating configuration...');
        const config = `-- Custom Configuration
-- Override default Bucu Core settings here

return {
    core = {
        devMode = false,
        logLevel = "info"
    },
    
    modules = {
        directory = "modules",
        autoLoad = true,
        disabled = {}
    }
}
`;
        fs.writeFileSync(path.join(targetDir, 'config', 'config.lua'), config);
        
        // Create README
        console.log('📄 Creating README...');
        const readme = `# ${projectName}

FiveM server powered by Bucu Core.

## Setup

1. Install Bucu Core:
\`\`\`bash
cd resources/
git clone https://github.com/bucucore-dev/bucucore-framework.git bucu-core
\`\`\`

2. Add your license key to \`server.cfg\`

3. Start server:
\`\`\`bash
./FXServer.exe +exec server.cfg
\`\`\`

## Development

Create new modules:
\`\`\`bash
bucu create-module my-module
\`\`\`

Start dev mode:
\`\`\`bash
bucu dev
\`\`\`

## Documentation

- [Bucu Core Docs](https://docs.bucu-core.com)
- [FiveM Docs](https://docs.fivem.net)
`;
        fs.writeFileSync(path.join(targetDir, 'README.md'), readme);
        
        // Create .gitignore
        const gitignore = `cache/
server-data/
*.log
node_modules/
`;
        fs.writeFileSync(path.join(targetDir, '.gitignore'), gitignore);
        
        console.log('\n✅ Project initialized successfully!\n');
        console.log('Next steps:');
        console.log(`  cd ${projectName}`);
        console.log('  # Add your license key to server.cfg');
        console.log('  # Install Bucu Core to resources/bucu-core');
        console.log('  # Start your server\n');
        
    } catch (error) {
        console.error(`❌ Error: ${error.message}`);
        process.exit(1);
    }
};
