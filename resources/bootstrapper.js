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
	console.log("%s\n   %s", phpLogo, dockerLogo);
}

// ### Program options ###
// ---------------------
program 
	.version('0.0.1');
	
program
	.command('start')
	.description('displays the logo for this docker image')
	.option('-r, --raw', 'Outputs results as pure JSON data')
	.option('-v, --verbose', 'Shows all attributes of the lists versus just producing a simple named list')
	.action(function(options) {
		displayLogo();
		console.log('Version: %s\n\n', chalk.bold(program.version()));
		var fpmVersion = execSync('php-fpm -v | sed 1q | cut -d\' \' -f2');
		console.log('Starting PHP FPM daemon [%s]', chalk.dim(fpmVersion));
		var fpmResults = execSync('/opt/couchbase/bin/couchbase-server start');
	});

program
	.command('stop')
	.description('displays the logo for this docker image')
	.option('-r, --raw', 'Outputs results as pure JSON data')
	.option('-v, --verbose', 'Shows all attributes of the lists versus just producing a simple named list')
	.action(function(options) {
		displayLogo();
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

if(process.argv.length == 2) {
	displayLogo();
	program.help();
}