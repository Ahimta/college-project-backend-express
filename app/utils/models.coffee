mongoose = require('mongoose')
_        = require('lodash')

Schema = mongoose.Schema

default_schema =
  is_active: Boolean
  username: {type: String, required: true, unique: true}
  password: {type: String, required: true}
  fullname: String
  phone: String
  email: String

module.exports.makeAccountableModel = (modelName, optional_schema = {}) ->

  schema       = _.merge(default_schema, optional_schema)
  schemaObject = new Schema(schema)

  mongoose.model(modelName, schemaObject)
