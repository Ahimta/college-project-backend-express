mongoose = require('mongoose')
plugins  = require('./concerns/plugins')

schema = new mongoose.Schema
  collegial_number: {type: String, required: false, unique: true, sparse: true}
  specialization: {type: String, required: false}
  teacher_id:
    type: mongoose.Schema.Types.ObjectId
    ref: 'TeacherAccount'
    index: true
  courses_ids:
    type: [mongoose.Schema.Types.ObjectId]
    ref: 'Course'
    default: []

schema.plugin(plugins.accountable)

module.exports = mongoose.model('StudentAccount', schema)
