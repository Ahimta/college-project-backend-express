mongoose = require('mongoose')

schema = new mongoose.Schema
  hours: {default: 2, type: Number}
  code:  {required: true, unique: true, type: Number}
  name:  String
  room:  Number
  type:  {default: 'محاضرة',  type: String}
  day:   {default: 0, type: Number, min: 0, max: 4}
  semester:
    order: {default: 1, type: Number}
    year:  {default: '1436/1437', type: String}
  schedule:
    from: {type: Number, default: 16, min: 8, max: 22}
    to:   {type: Number, default: 18, min: 8, max: 22}
  teacher_id:
    required: true
    index:    true
    type:     mongoose.Schema.Types.ObjectId
    ref:      'TeacherAccount'
  course_id:
    required: true
    index:    true
    type:     mongoose.Schema.Types.ObjectId
    ref:      'Course'
  students:
    type: [
      _id:        {type: mongoose.Schema.Types.ObjectId, ref: 'StudentAccount'}
      attendance: {type: Number, default: 100}
      grades:
        midterm: {type: Number, default: 0}
        final:   {type: Number, default: 0}
    ]
    default: []
    index:   true

module.exports = mongoose.model('Class', schema)
