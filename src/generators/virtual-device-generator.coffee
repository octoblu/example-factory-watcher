module.exports = ({ownerUuid}) =>
  throw new Error 'ownerUuid is required' unless ownerUuid?

  return {
    owner: ownerUuid
    type: 'device:generic'
    name: 'Virtual Device'
    meshblu:
      version: '2.0.0'
      forwarders:
        broadcast:
          received: [{
            "type": "meshblu",
            "emitType": "broadcast.sent"
          }]
      whitelists:
        discover:
          view: [{
            uuid: ownerUuid
          }]
        configure:
          update: [{
            uuid: ownerUuid
          }]
  }
