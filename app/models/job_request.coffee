mongoose = require('mongoose')

schema = new mongoose.Schema
  specialization: {type: String, required: true}
  fullname:       {type: String, required: true}
  address:        {type: String, required: true}
  degree:         {type: String, required: true}
  email:          {type: String, required: true}
  phone:          {type: String, required: true}
  token: {type: String, unique: true}
  status:
    enum: ['pending', 'accepted', 'rejected']
    default: 'pending'
    type: String

module.exports = mongoose.model('JobRequest', schema)
