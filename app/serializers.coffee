_ = require('lodash')

baseSerializer = (mongoRecord) ->
  object = if _.isObject(mongoRecord) then mongoRecord else mongoRecord.toObject()
  serialzedRecord    = _.omit(object, '_id', '__v')
  serialzedRecord.id = mongoRecord._id.toString() if mongoRecord._id
  serialzedRecord

accountSerializer = (account) ->
  serialzedAccount = _.clone(account)
  serialzedAccount.password = undefined
  serialzedAccount

module.exports =
  recruiterAccount: _.compose(baseSerializer, accountSerializer)
  adminAccount: _.compose(baseSerializer, accountSerializer)
  jobRequest: baseSerializer
