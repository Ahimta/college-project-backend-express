mongoose = require('mongoose')

Schema   = mongoose.Schema

CourseSchema = new Schema(
  code: {type: String, required: true, unique: true}
  name: {type: String, required: true}

  teachers_ids: {type: [Schema.Types.ObjectId], default: [], ref: 'TeacherAccount'}
  students_ids: {type: [Schema.Types.ObjectId], default: [], ref: 'StudentAccount'}
)

mongoose.model('Course', CourseSchema)
