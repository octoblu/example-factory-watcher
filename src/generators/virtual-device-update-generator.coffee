module.exports = ({flowUuid}) =>
  throw new Error 'flowUuid is required' unless flowUuid?

  return {
    $set:
      online: true
    $addToSet:
      'meshblu.whitelists.broadcast.sent': {uuid: flowUuid}
      'meshblu.whitelists.message.from': {uuid: flowUuid}
  }
