#!/usr/bin/env node
'use strict';
/* exported shell,shellSync */

var 
	program	= require('commander'),
	fs = require('fs'),
	RSVP = require('rsvp'),
	extend = require('xtend'),
	Future = require('fibers/future'),
	Fiber = require('fibers'),
	debug = require('debug')('docker-php'),
	chalk = require('chalk');
	
// ### Display Logo ###
// -------------------
var displayLogo = function() {
	var phpLogo = fs.readFileSync('resources/php.txt',{ encoding: 'utf8' });
	var dockerLogo = fs.readFileSync('resources/docker.txt',{ encoding: 'utf8' });
	console.log('%s\n   %s', phpLogo, dockerLogo);
};

// ### Shell Command ###
// -------------------
var shell = function (params,options) {
	options = extend({timeout: 4000},options);
	var commandResponse = '';
	var errorMessage ='';
	// typecast params to an array
	params = typeof params === 'string' ? [params] : params;
	// resolve with a promise
	return new RSVP.Promise(function(resolve,reject) {
		var spawn = require('child_process').spawn;
		var timeout = setTimeout(function() {
			reject(new Error('Timed out'));
		}, options.timeout);
		var shellCommand;
		try {
			shellCommand = spawn(params.shift(),params);
		} catch (err) {
			clearTimeout(timeout);
			reject(err);
		}
		shellCommand.stdout.setEncoding('utf8');
		shellCommand.stderr.setEncoding('utf8');
		shellCommand.stdout.on('data', function (data) {
			commandResponse = commandResponse + data;
		});
		shellCommand.stderr.on('data', function (data) {
			errorMessage = errorMessage + data;
		});
		shellCommand.on('close', function (code) {
			if(code !== 0) {
				clearTimeout(timeout);
				reject({code:code, message:errorMessage});
			} else {
				clearTimeout(timeout);
				resolve(commandResponse);
			}
		});
	}); // return promise
};

// ###Synchronous shell###
// -----------------------
var shellSync = function (params,options) {
	var future = new Future();
	var shellResults = null;
	options = extend({},options);
	shell(params,options).then(
		function(results) {
			debug('Synch shell returned with results: %s', results);
			future.return({results: results});
		},
		function(err) {
			debug('Synch shell experienced an error trying to run "%s": %s', JSON.stringify(params), err);
			future.return({err: err});
		}
	);

	var ret = future.wait();
	if(ret.err) {
		throw ret.err;
	} else {
		return ret.results;
	}
};

// ### Get PHP Version ###
// ---------------------
// > utility function
var getPhpVersion = function() {
	return new RSVP.Promise(function(resolve,reject) {
		shell(['php-fpm','-v']).then(
			function(results) {
				var versionNumber = results.split(' ')[1];
				resolve(versionNumber);
			},
			function(err) {
				reject(err);
			}
		);
	});
};

// ### Start FPM Daemon ###
// ----------------------
var fpmDaemon = function() {
	return new RSVP.Promise(function(resolve,reject) {
		shell('php-fpm').then(
			function(results) {
				resolve(results);
			},
			function(err) {
				reject(err);
			}
		);		
	});
};

// ## Program options ##
// ---------------------
program 
	.version('0.0.1');
	
program
	.command('start')
	.description('starts the PHP-FPM server; will create a "default" pool with an index.php to display')
	.option('-r, --raw', 'Outputs results as pure JSON data')
	.option('-v, --verbose', 'Shows all attributes of the lists versus just producing a simple named list')
	.action(function(options) {
		var pools = [];
		options = extend({},options);
		displayLogo();
		console.log('Supervisor script version: %s', chalk.bold(program.version()));
		getPhpVersion().then(
			function(results) {
				console.log('PHP/FPM version: %s',chalk.bold(results));
				/* TODO: get pools */
				console.log('Registered pools: %s', chalk.dim(JSON.stringify(pools)));
				fpmDaemon().then(
					function() {
						console.log(chalk.green('FPM process started!'));
					}, 
					function(err) {
						console.log(chalk.red('Problem starting FPM: ') + JSON.stringify(err));
					}
				);
			}
		);
	});

program
	.command('stop')
	.description('stops the PHP-FPM server')
	.option('-r, --raw', 'Outputs results as pure JSON data')
	.option('-v, --verbose', 'Shows all attributes of the lists versus just producing a simple named list')
	.action(function(options) {
		options = extend({},options);
		shell(['ps','-ef','|','grep','fpm','|','grep','master']).then(function(results) {
			console.log('Master process:: %s', results);
			var params = results.split(/[ ,]+/); // user, process, parent-process, start-time, ?, ?, description
			shell(['kill',params[1]]).then(
				function() {
					console.log(chalk.red('FPM process shutdown'));
				},
				function(err) {
					console.error('%s\n%s', chalk.red('Problems shutting down FPM:\n'), chalk.grey() );
				}
			
			);
			
		});
	}
);
	
program 
	.command('info')
	.description('returns the version of PHP being used')
	.action(function(options) {
		options = extend({},options);
		getPhpVersion().then(
			function(results) {
				console.log('Docker-PHP Bootstrap Script: %s', program.version() )
				console.log('FPM version: %s',chalk.bold(results));
			}
		);
	}
);

program 
	.command('ps')
	.description('returns the version of PHP being used')
	.action(function(options) {
		options = extend({},options);
		shell(['ps','-ef','|','grep','fpm']).then(
			function(results) {
				console.log('FPM running processes: \n%s', results);
			},
			function(err) {
				console.log(chalk.red('Problem getting FPM processes! [%s]\n') + chalk.grey(err.message), err.code);
			}
		);
	}
);

	
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

// Handle uncaught exceptions
var atException = function(err) {
	console.error(chalk.bold.red('Unhandled exception:\n'));
	console.error(chalk.grey(err.stack));
	process.exit(1);
};

process.on('uncaughtException', atException);

