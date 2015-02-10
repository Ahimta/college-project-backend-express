mongoose = require('mongoose')
plugins  = require('./concerns/plugins')

schema = new mongoose.Schema
  collegial_number: {required: false, type: Number, unique: true, sparse: true}
  guide_id: {type: mongoose.Schema.Types.ObjectId, ref: 'TeacherAccount', index: true}
  level:    {required: true, type: Number, min: 1, max: 10, default: 1}

schema
  .plugin(plugins.accountable)
  .plugin(plugins.coursable)

module.exports = mongoose.model('StudentAccount', schema)
