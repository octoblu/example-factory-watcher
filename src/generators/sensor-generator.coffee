module.exports = ({i, virtualDevice}) =>
  throw new Error 'i is required' unless i?
  throw new Error 'virtualDevice is required' unless virtualDevice?

  return {
    type: 'device:generic'
    name: "Sensor #{i}"
    meshblu:
      version: '2.0.0'
      whitelists:
        broadcast:
          receive: [{
            uuid: virtualDevice.uuid
          }]
        message:
          from: [{
            uuid: virtualDevice.uuid
          }]
  }
