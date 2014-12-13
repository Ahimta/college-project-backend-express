mongoose = require('mongoose')
plugins  = require('./concerns/plugins')

schema = new mongoose.Schema
  is_guide: {type: Boolean, default: false, index: true}

schema
  .plugin(plugins.accountable)
  .plugin(plugins.coursable)

module.exports = mongoose.model('TeacherAccount', schema)
