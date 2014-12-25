mongoose = require('mongoose')

schema = new mongoose.Schema
  name:
    required: true
    unique: true
    type: String
  hours: Number
  type: String
  day: String
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
      attendance:
        default: 100
        type: Number
      grades:
        midterm:
          default: 0
          type: Number
        final:
          default: 0
          type: Number
    ]
    index: true
    default: []

module.exports = mongoose.model('Class', schema)
