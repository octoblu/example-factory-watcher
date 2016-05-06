async        = require 'async'
colors       = require 'colors'
commander    = require 'commander'
fs           = require 'fs'
_            = require 'lodash'
PACKAGE_JSON = require './package.json'
Sensor       = require './src/sensor'

class CommandRun
  constructor: (@argv) ->

  getOpts: =>
    commander
      .version PACKAGE_JSON.version
      .usage "./command-run.js <path/to/devices.json>"
      .description "Where devices.json is the output of ./command-setup.js"
      .parse @argv

    filePath = _.first commander.args
    if _.isEmpty(filePath)
      console.error commander.helpInformation()
      console.error colors.red '\n  Missing path to devices.json\n'
      process.exit 1

    devicesJSON = JSON.parse fs.readFileSync filePath
    return {
      sensorConfigs: devicesJSON.sensors
    }

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    {sensorConfigs} = @getOpts()
    sensors = @_buildSensors {sensorConfigs}
    @_startSensors {sensors}, (error) =>
      return @panic error if error?
      console.log "Sensors started"

  _buildSensors: ({sensorConfigs}) =>
    _.map sensorConfigs, (sensorConfig) => new Sensor sensorConfig

  _startSensor: (sensor, callback) =>
    sensor.on 'temperature', (temperature) =>
      console.log "#{sensor.getName()}: #{temperature}"

    sensor.on 'stop', =>
      console.log "#{sensor.getName()}: stop command received, shutting down"

    sensor.run callback

  _startSensors: ({sensors}, callback) =>
    async.each sensors, @_startSensor, callback

module.exports = CommandRun
