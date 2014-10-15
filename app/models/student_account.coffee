Schema = require('mongoose').Schema

models_utils = require('../utils/models')

schema =
  collegial_number: {type: String, unique: true}
  specialization: String
  teacher_id: {type: Schema.Types.ObjectId, ref: 'TeacherAccount'}
  courses_ids: {type: [Schema.Types.ObjectId], default: [], ref: 'Course'}

models_utils.makeAccountableModel('StudentAccount', schema)
