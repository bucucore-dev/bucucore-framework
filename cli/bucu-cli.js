#!/usr/bin/env node

// Bucu Core CLI Tool
// Command-line interface for project and module management

const { Command } = require('commander');
const program = new Command();

// Import commands
const initCommand = require('./commands/init');
const createModuleCommand = require('./commands/create-module');
const devCommand = require('./commands/dev');

program
    .name('bucu')
    .description('Bucu Core CLI - Framework management tool for FiveM')
    .version('1.0.0');

// Init command
program
    .command('init <name>')
    .description('Initialize a new Bucu Core project')
    .option('-d, --directory <path>', 'Target directory', '.')
    .action(initCommand);

// Create module command
program
    .command('create-module <name>')
    .alias('module')
    .description('Create a new module')
    .option('-a, --author <name>', 'Module author', 'Unknown')
    .option('-d, --description <text>', 'Module description', '')
    .action(createModuleCommand);

// Dev mode command
program
    .command('dev')
    .description('Start development mode with hot reload')
    .option('-p, --port <number>', 'Server port', '30120')
    .option('-v, --verbose', 'Verbose logging', false)
    .action(devCommand);

// Parse arguments
program.parse(process.argv);

// Show help if no command provided
if (!process.argv.slice(2).length) {
    program.outputHelp();
}
