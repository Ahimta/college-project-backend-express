_ = require('lodash')

baseSerializer = (mongoRecord) ->
  object = if mongoRecord.toObject then mongoRecord.toObject() else mongoRecord
  serialzedRecord    = _.omit(_.clone(object), '_id', '__v')
  serialzedRecord.id = mongoRecord._id.toString() if mongoRecord._id
  serialzedRecord

accountSerializer = (account) ->
  _.omit(_.clone(account), 'password')

module.exports =
  recruiterAccount: _.compose(accountSerializer, baseSerializer)
  adminAccount: _.compose(accountSerializer, baseSerializer)
  jobRequest: baseSerializer