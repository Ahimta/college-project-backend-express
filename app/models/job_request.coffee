mongoose = require('mongoose')

schema = new mongoose.Schema
  specialization: {type: String, required: true}
  fullname:       {type: String, required: true}
  address:        {type: String, required: true}
  degree:         {type: String, required: true}
  email:          {type: String, required: true}
  phone:          {type: String, required: true}
  token: {type: String, unique: true}
  files: [String]
  status:
    enum: ['pending', 'accepted', 'rejected']
    default: 'pending'
    type: String
  highschool_location: {type: String, required: true}
  highschool_name: {type: String, required: true}
  current_location: {type: String, required: true}
  university: {type: String, required: true}
  id_num: {type: String, required: true}
  job: {type: String, required: true}

module.exports = mongoose.model('JobRequest', schema)
