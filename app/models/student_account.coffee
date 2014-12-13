mongoose = require('mongoose')
plugins  = require('./concerns/plugins')

schema = new mongoose.Schema
  collegial_number: {type: String, required: false, unique: true, sparse: true}
  guide_id:
    type: mongoose.Schema.Types.ObjectId
    ref: 'TeacherAccount'
    index: true

schema
  .plugin(plugins.accountable)
  .plugin(plugins.coursable)

module.exports = mongoose.model('StudentAccount', schema)
