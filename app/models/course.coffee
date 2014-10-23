mongoose = require('mongoose')

schema = new mongoose.Schema
  code: {type: String, required: true, unique: true}
  name: {type: String, required: true}

  teachers_ids:
    type: [mongoose.Schema.Types.ObjectId]
    ref: 'TeacherAccount'
    default: []
  students_ids:
    type: [mongoose.Schema.Types.ObjectId]
    ref: 'StudentAccount'
    default: []

module.exports = mongoose.model('Course', schema)
