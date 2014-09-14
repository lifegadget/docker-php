#!/usr/bin/env node
'use strict';

var 
	program	= require('commander'),
	fs = require('fs'),
	execSync = require('exec-sync'),
	chalk = require('chalk');
	
var displayLogo = function() {
	var phpLogo = fs.readFileSync('resources/php.txt',{ encoding: 'utf8' });
	var dockerLogo = fs.readFileSync('resources/docker.txt',{ encoding: 'utf8' });
	console.log('%s\n   %s', phpLogo, dockerLogo);
};

// ### Program options ###
// ---------------------
program 
	.version('0.0.1');
	
program
	.command('start')
	.description('starts the PHP-FPM server; will create a "default" pool with an index.php to display')
	.option('-r, --raw', 'Outputs results as pure JSON data')
	.option('-v, --verbose', 'Shows all attributes of the lists versus just producing a simple named list')
	.action(function(options) {
		displayLogo();
		console.log('Version: %s\n\n', chalk.bold(program.version()));
		var fpmVersion = execSync('php-fpm -v | sed 1q | cut -d\' \' -f2');
		console.log('Starting PHP FPM daemon [%s]', chalk.dim(fpmVersion));
		var fpmResults = execSync('/');
	});

program
	.command('stop')
	.description('stops the PHP-FPM server')
	.option('-r, --raw', 'Outputs results as pure JSON data')
	.option('-v, --verbose', 'Shows all attributes of the lists versus just producing a simple named list')
	.action(function(options) {
		displayLogo();
	});
	
program 
	.command('version')
	.description('returns the version of PHP being used')
	.action(function(options) {
		var fpmVersion = execSync('php-fpm -v | sed 1q | cut -d\' \' -f2');
		console.log('PHP FPM version: %s', chalk.bold(fpmVersion));
	});

program 
	.command('enter')
	.description('allows shell access to the container')
	.action(function(options) {
		var giveAccess = execSync('/bin/bash');
	});

	
// ###Unknown Command###
// ----------------
program
	.command('*')
	.action(function(param) {
		if(param) {
			console.log(chalk.bold.red('Unknown command: ') + param + '\n');
			program.help();
		} 
	}
);

// ##Parse##
// ------------------
program.parse(process.argv);

if(process.argv.length === 2) {
	displayLogo();
	program.help();
}