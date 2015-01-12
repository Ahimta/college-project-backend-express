mongoose = require('mongoose')

schema = new mongoose.Schema
  hours: {default: 2, type: Number}
  code:  {required: true, unique: true, type: Number}
  name:  String
  room:  String
  type:  {default: 'محاضرة',  type: String}
  day:   {default: 'الإثنين', type: String}
  semester:
    order: {default: 1, type: Number}
    year:  {default: '1436/1437', type: String}
  schedule:
    from: {default: 16, type: Number}
    to:   {default: 18, type: Number}
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
      attendance: {default: 100, type: Number}
      grades:
        midterm: {default: 0, type: Number}
        final:   {default: 0, type: Number}
    ]
    default: []
    index: true

module.exports = mongoose.model('Class', schema)
