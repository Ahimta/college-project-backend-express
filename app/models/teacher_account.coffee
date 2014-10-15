Schema = require('mongoose').Schema

models_utils = require('../utils/models')

schema =
  specialization: {type: String, required: true}
  is_guide: {type: Boolean, default: false}
  students_ids: {type: [Schema.Types.ObjectId], default: [], ref: 'StudentAccount'}
  courses_ids:  {type: [Schema.Types.ObjectId], default: [], ref: 'Course'}

models_utils.makeAccountableModel('TeacherAccount', schema)
