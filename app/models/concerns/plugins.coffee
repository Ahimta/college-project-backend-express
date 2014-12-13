mongoose = require('mongoose')

exports.accountable = (schema, options) ->
  schema.add
    username: {type: String, required: true, unique: true}
    password: {type: String, required: true}
    fullname: String
    phone: String
    email: String

exports.coursable = (schema, options) ->
  schema.add
    specialization: {type: String, required: false}
    courses_ids:
      type: [mongoose.Schema.Types.ObjectId]
      ref: 'Course'
      index: true
      default: []