{EventEmitter} = require 'events'
_              = require 'lodash'
meshblu        = require 'meshblu'
MeshbluHttp    = require 'meshblu-http'

class Sensor extends EventEmitter
  constructor: ({@uuid,@token}) ->
    throw new Error 'uuid is required'  unless @uuid?
    throw new Error 'token is required' unless @token?

  getName: =>
    @device.name

  run: (callback) =>
    callback = _.once callback
    @meshblu = meshblu.createConnection {@uuid, @token}
    @meshblu.once 'ready', =>
      @meshblu.whoami {}, (@device) =>
        callback()
    @meshblu.once 'error', callback
    @meshblu.once 'notReady', callback
    @meshblu.on 'error', (error) => @emit 'error', error
    @meshblu.on 'notReady', (error) => @emit 'error', error

    @meshblu.once 'ready', @_onReady
    @meshblu.on 'message', @_onMessage

  _emitTemperature: =>
    temperature = _.random 50, 80

    @emit 'temperature', temperature
    message = {
      devices: ['*']
      payload:
        temperature: temperature
    }

    meshblu = new MeshbluHttp {@uuid, @token}
    meshblu.message message, (error) =>
      @emit 'error', error if error?
    # @meshblu.message message, (error) =>
    #   @emit 'error', error if error?

  _onMessage: (message) =>
    return unless message.payload?.command == 'stop'
    clearInterval @interval
    @emit 'stop'

  _onReady: =>
    @interval = setInterval @_emitTemperature, 2000

module.exports = Sensor
