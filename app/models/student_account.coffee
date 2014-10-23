mongoose = require('mongoose')
plugins  = require('./concerns/plugins')

schema = new mongoose.Schema
  collegial_number: {type: String, unique: true}
  specialization: String
  teacher_id:
    type: mongoose.Schema.Types.ObjectId
    ref: 'TeacherAccount'
  courses_ids:
    type: [mongoose.Schema.Types.ObjectId]
    ref: 'Course'
    default: []

schema.plugin(plugins.accountable)

module.exports = mongoose.model('StudentAccount', schema)
