#!/usr/bin/env node
'use strict';

require('coffee-script/register');
var CommandSetup, commandSetup;
CommandSetup = require('./command-setup.coffee');
commandSetup = new CommandSetup(process.argv);
commandSetup.run();
