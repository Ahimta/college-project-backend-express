mongoose = require('mongoose')

schema = new mongoose.Schema
  code: {type: String, required: true, unique: true}
  name: {type: String, required: true}

module.exports = mongoose.model('Course', schema)
