commander    = require 'commander'
PACKAGE_JSON = require './package.json'

class Command
  constructor: (@argv) ->

  getOpts: =>
    commander
      .version PACKAGE_JSON.version
      .description """
      Example:
        ./command.js setup    --owner-uuid 123a... > devices.json
        ./command.js add-flow --flow-uuid abcd...  devices.json
        ./command.js run                           devices.json
      """
      .command 'add-flow', 'Add the flow to the virtual device\'s whitelists'
      .command 'run',      'run the sensors, emitting random temperatures till told to stop'
      .command 'setup',    'setup a new setup with virtual devices and sensors'
      .parse @argv

  run: =>
    @getOpts()

module.exports = Command
