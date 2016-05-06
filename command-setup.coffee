async        = require 'async'
colors       = require 'colors'
commander    = require 'commander'
_            = require 'lodash'
MeshbluHttp  = require 'meshblu-http'
PACKAGE_JSON = require './package.json'
virtualDeviceGenerator = require './src/generators/virtual-device-generator'
sensorGenerator        = require './src/generators/sensor-generator'

class CommandSetup
  constructor: (@argv) ->

  getOpts: =>
    opts = commander
      .version PACKAGE_JSON.version
      .option '-n, --number-of-sensors <1>', 'Number of sensors to create, (default: 1)', '1'
      .option '-o, --owner-uuid <uuid>',     'Octoblu User UUID'
      .parse @argv
      .opts()

    if _.isEmpty opts.ownerUuid
      console.error commander.helpInformation()
      console.error colors.red '\n  -o, --owner-uuid is required\n'
      process.exit 1

    return {
      numberOfSensors: parseInt opts.numberOfSensors
      ownerUuid: opts.ownerUuid
    }

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    {numberOfSensors, ownerUuid} = @getOpts()

    @_createVirtualDevice {ownerUuid}, (error, virtualDevice) =>
      return @panic error if error?
      @_subscribeVirtualDeviceToItself {virtualDevice}, (error) =>
        return @panic error if error?
        @_createSensors {numberOfSensors, virtualDevice}, (error, sensors) =>
          return @panic error if error?
          @_subscribeVirtualDeviceToSensors {sensors, virtualDevice}, (error) =>
            return @panic error if error?
            @_printVirtualDeviceAndSensors {sensors, virtualDevice}
            process.exit 0

  _createSensors: ({numberOfSensors, virtualDevice}, callback) =>
    sensors = _.times numberOfSensors, (i) => sensorGenerator({virtualDevice, i})
    meshblu = new MeshbluHttp
    async.map sensors, meshblu.register, callback

  _createVirtualDevice: ({ownerUuid}, callback) =>
    virtualDevice = virtualDeviceGenerator({ownerUuid})
    meshblu = new MeshbluHttp
    meshblu.register virtualDevice, callback

  _printVirtualDeviceAndSensors: ({sensors, virtualDevice}) =>
    output = {
      virtualDevice: _.pick(virtualDevice, 'uuid', 'token')
      sensors: _.map sensors, (sensor) => _.pick(sensor, 'uuid', 'token')
    }

    console.log JSON.stringify(output, null, 2)

  _subscribeVirtualDeviceToItself: ({virtualDevice}, callback) =>
    subscription = {
      emitterUuid: virtualDevice.uuid
      subscriberUuid: virtualDevice.uuid
      type: 'broadcast.received'
    }
    meshblu = new MeshbluHttp virtualDevice
    meshblu.createSubscription subscription, callback

  _subscribeVirtualDeviceToSensor: (virtualDevice, sensor, callback) =>
    subscription = {
      emitterUuid: sensor.uuid
      subscriberUuid: virtualDevice.uuid
      type: 'broadcast.sent'
    }
    meshblu = new MeshbluHttp virtualDevice
    meshblu.createSubscription subscription, callback

  _subscribeVirtualDeviceToSensors: ({sensors, virtualDevice}, callback) =>
    async.each sensors, async.apply(@_subscribeVirtualDeviceToSensor, virtualDevice), callback

module.exports = CommandSetup
