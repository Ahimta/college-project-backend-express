mongoose = require('mongoose')
plugins  = require('./concerns/plugins')

schema = new mongoose.Schema()
  .plugin(plugins.accountable)

module.exports = mongoose.model('RecruiterAccount', schema)
