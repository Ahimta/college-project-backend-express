_ = require('lodash')

baseSerializer = (mongoRecord) ->
  object = if mongoRecord.toObject then mongoRecord.toObject() else mongoRecord
  serialzedRecord    = _.omit(_.clone(object), '_id', '__v')
  serialzedRecord.id = mongoRecord._id.toString() if mongoRecord._id
  serialzedRecord

accountSerializer = (account) ->
  _.omit(baseSerializer(account), 'password')

module.exports =
  supervisorAccount: accountSerializer
  recruiterAccount: accountSerializer
  studentAccount: accountSerializer
  teacherAccount: accountSerializer
  adminAccount: accountSerializer
  jobRequest: baseSerializer
  account: accountSerializer