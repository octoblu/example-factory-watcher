colors       = require 'colors'
commander    = require 'commander'
fs           = require 'fs'
_            = require 'lodash'
MeshbluHttp  = require 'meshblu-http'
PACKAGE_JSON = require './package.json'
virtualDeviceUpdateGenerator = require './src/generators/virtual-device-update-generator'

class CommandAddFlow
  constructor: (@argv) ->

  getOpts: =>
    commander
      .version PACKAGE_JSON.version
      .usage "./command-add-flow.js --flow-uuid <uuid> <path/to/devices.json>"
      .description "Where devices.json is the output of ./command-setup.js"
      .option '-f, --flow-uuid <uuid>', 'The flow UUID'
      .parse @argv

    filePath = _.first commander.args
    {flowUuid} = commander.opts()

    if _.isEmpty(filePath) || _.isEmpty(flowUuid)
      console.error commander.helpInformation()
      console.error ''
      console.error colors.red '  Missing path to devices.json' if _.isEmpty filePath
      console.error colors.red '  Missing flow-uuid' if _.isEmpty flowUuid
      console.error ''
      process.exit 1

    devicesJSON = JSON.parse fs.readFileSync filePath
    return {
      flowUuid: flowUuid
      virtualDeviceConfig: devicesJSON.virtualDevice
    }

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    {flowUuid, virtualDeviceConfig} = @getOpts()

    @_addFlowUuidToVirtualDevice {flowUuid, virtualDeviceConfig}, (error) =>
      return @panic error if error?
      console.log 'Virtual Device updated'
      process.exit 0

  _addFlowUuidToVirtualDevice: ({flowUuid, virtualDeviceConfig}, callback) =>
    {uuid,token} = virtualDeviceConfig
    update = virtualDeviceUpdateGenerator {flowUuid}
    meshblu = new MeshbluHttp {uuid, token}
    meshblu.updateDangerously uuid, update, callback


module.exports = CommandAddFlow
