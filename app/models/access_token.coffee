mongoose = require('mongoose')

schema =
  access_token:
    required: true
    unique:   true
    type:     String
  user_role:
    required: true
    enum:     ['supervisor', 'recruiter', 'student', 'teacher', 'admin']
    type:     String
  user_id:
    required: true
    type:     mongoose.Schema.Types.ObjectId
    index:    true

module.exports = mongoose.model('AccessToken', schema)
