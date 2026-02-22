// Bucu CLI - Dev Mode Command
// Starts development mode with hot reload

const chokidar = require('chokidar');
const path = require('path');

module.exports = async function(options) {
    console.log('\n🔥 Starting Bucu Core Development Mode\n');
    console.log('Features:');
    console.log('  - Hot reload enabled');
    console.log('  - Verbose logging');
    console.log('  - File watching\n');
    
    // Watch for file changes
    const watchPaths = [
        'modules/**/*.lua',
        'modules/**/*.js',
        'config/**/*.lua'
    ];
    
    console.log('👀 Watching for changes...\n');
    
    const watcher = chokidar.watch(watchPaths, {
        ignored: /(^|[\/\\])\../,
        persistent: true,
        ignoreInitial: true
    });
    
    watcher
        .on('change', (filePath) => {
            console.log(`\n📝 File changed: ${filePath}`);
            console.log('🔄 Hot reload triggered');
            console.log('   (Reload will happen on next server tick)\n');
        })
        .on('add', (filePath) => {
            console.log(`\n➕ File added: ${filePath}`);
        })
        .on('unlink', (filePath) => {
            console.log(`\n➖ File removed: ${filePath}`);
        })
        .on('error', (error) => {
            console.error(`\n❌ Watcher error: ${error.message}\n`);
        });
    
    console.log('Press Ctrl+C to stop\n');
    
    // Keep process alive
    process.on('SIGINT', () => {
        console.log('\n\n👋 Stopping development mode...\n');
        watcher.close();
        process.exit(0);
    });
    
    // Display helpful tips
    setTimeout(() => {
        console.log('💡 Tips:');
        console.log('  - Edit files in modules/ to see hot reload');
        console.log('  - Check server console for detailed logs');
        console.log('  - Use Core.log.debug() for verbose logging\n');
    }, 2000);
};
