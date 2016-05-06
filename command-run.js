#!/usr/bin/env node
'use strict';

require('coffee-script/register');
var CommandRun, commandRun;
CommandRun = require('./command-run.coffee');
commandRun = new CommandRun(process.argv);
commandRun.run();
