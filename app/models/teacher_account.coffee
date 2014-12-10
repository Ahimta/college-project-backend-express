mongoose = require('mongoose')
plugins  = require('./concerns/plugins')

schema = new mongoose.Schema
  specialization: {type: String, required: false}
  is_guide: {type: Boolean, default: false, index: true}
  courses_ids:
    type: [mongoose.Schema.Types.ObjectId]
    ref: 'Course'
    default: []

schema.plugin(plugins.accountable)

module.exports = mongoose.model('TeacherAccount', schema)
