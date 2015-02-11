config = require('config')

serializers = require(config.get('paths.serializers'))
helpers     = require('./_helpers')
_           = require('lodash')

serializer = module.exports = (klass) ->
  _.merge _.omit(helpers.baseSerializer(klass), 'students'),
    students_ids: klass.students.map ((student) -> student._id.toString())
    teacher_id:   klass.teacher_id?.toString()
    course_id:    klass.course_id?.toString()

serializer.student = (student) ->
  studentInfo = _.pick(student, 'attendance', 'grades')

  if student._id
    _.merge(studentInfo, serializers.studentAccount(student._id))
  else
    studentInfo

serializer.teacher = helpers.nullOrResult(serializers.teacherAccount)

serializer.course  = helpers.nullOrResult(serializers.course)

serializer.expand = _.curry (fields, klass) ->
  serialized = _.omit(helpers.baseSerializer(klass), 'students')
  serialized.students_ids = klass.students.map ((student) -> student._id.toString())

  if fields.teacher and klass.teacher_id
    serialized.teacher_id = klass.teacher_id._id.toString()
    serialized.teacher    = serializer.teacher(klass.teacher_id) if fields.teacher
  else
    serialized.teacher_id = klass.teacher_id?.toString()

  if fields.course and klass.course_id
    serialized.course_id = klass.course_id._id.toString()
    serialized.course    = serializer.course(klass.course_id)
  else
    serialized.course_id = klass.course_id?.toString()

  serialized.students = klass.students.map(serializer.student) if fields.students

  serialized
