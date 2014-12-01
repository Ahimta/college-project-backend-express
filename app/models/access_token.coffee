mongoose = require('mongoose')

schema =
  access_token:
    type: String
    unique: true
  user_role:
    enum: ['supervisor', 'recruiter', 'student', 'teacher', 'admin']
    required: true
    type: String
  user_id:
    type: mongoose.Schema.Types.ObjectId
    required: true

module.exports = mongoose.model('AccessToken', schema)
