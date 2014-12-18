mongoose = require('mongoose')

schema = new mongoose.Schema
  teacher_id:
    type: mongoose.Schema.Types.ObjectId
    index: true
    ref: 'TeacherAccount'
    required: true
  course_id:
    type: mongoose.Schema.Types.ObjectId
    index: true
    ref: 'Course'
    required: true
  students:
    type: [
      _id:
        type: mongoose.Schema.Types.ObjectId
        ref: 'StudentAccount'
      attendance: Number
      grades:
        midterm: Number
        final: Number
    ]
    index: true
    default: []

module.exports = mongoose.model('Class', schema)
