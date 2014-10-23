module.exports.accountable = (schema, options) ->

  schema.add(
    is_active: Boolean
    username: {type: String, required: true, unique: true}
    password: {type: String, required: true}
    fullname: String
    phone: String
    email: String
  )
