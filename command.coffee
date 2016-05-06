commander    = require 'commander'
PACKAGE_JSON = require './package.json'

class Command
  constructor: (@argv) ->

  getOpts: =>
    commander
      .version PACKAGE_JSON.version
      .command 'run',   'run the sensors, emitting random temperatures till told to stop'
      .command 'setup', 'setup a new setup with virtual devices and sensors'
      .parse @argv

  run: =>
    @getOpts()

module.exports = Command
