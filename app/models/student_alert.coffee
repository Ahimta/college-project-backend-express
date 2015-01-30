mongoose = require('mongoose')

schema = new mongoose.Schema
  student_id: {required: true, type: mongoose.Schema.Types.ObjectId, index: true}
  teacher_id: {required: true, type: mongoose.Schema.Types.ObjectId, index: true}
  title:      {required: true, type: String}
  body:       {required: true, type: String}

module.exports = mongoose.model('StudentAlert', schema)
