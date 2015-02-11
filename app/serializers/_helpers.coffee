_ = require('lodash')

isMongooseRecord = (record) ->
  record?.toObject

getId = (objectOrId) ->
  if typeof objectOrId == 'string' then objectOrId
  else objectOrId?._id?.toString() || objectOrId.toString()

exports.baseSerializer = (mongoRecord) ->
  object = if isMongooseRecord(mongoRecord) then mongoRecord.toObject() else mongoRecord
  serialzedRecord    = _.omit(_.clone(object), '_id', '__v')
  serialzedRecord.id = mongoRecord._id.toString() if mongoRecord._id
  serialzedRecord

exports.accountSerializer = (account) ->
  _.omit(baseSerializer(account), 'password')

exports.nullOrResult = _.curry (f, x) ->
  if x then f(x) else null
