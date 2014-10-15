mongoose = require('mongoose')

Schema = mongoose.Schema

AccessTokenSchema =
  access_tokens:
    type: [{token: String}]
    unique: true
  user_role:
    enum: ['recruiter', 'admin']
    required: true
    type: String
  user_id:
    required: true
    type: Schema.Types.ObjectId

mongoose.model('AccessToken', AccessTokenSchema)
