#!/usr/bin/env node
'use strict';

require('coffee-script/register');
var CommandAddFlow, commandAddFlow;
CommandAddFlow = require('./command-add-flow.coffee');
commandAddFlow = new CommandAddFlow(process.argv);
commandAddFlow.run();
