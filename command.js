#!/usr/bin/env node
'use strict';

require('coffee-script/register');
var Command, command;
Command = require('./command.coffee');
command = new Command(process.argv);
command.run();
