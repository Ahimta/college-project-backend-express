config = require('config')

serializers = require(config.get('paths.serializers'))
helpers     = require('_helpers')
_           = require('lodash')

serializer = module.exports = (student) ->

  serialized = helpers.accountSerializer(student)

  serialized.collegial_number = parseInt(student.collegial_number) if student.collegial_number
  serialized.guide_id         = getId(student.guide_id)            if student.guide_id

  serialized

serializer.class = _.curry (student, klass) ->
  if klass
    studentId   = student._id.toString()
    studentInfo = _.find klass.students, ((s) -> s._id.toString() == studentId)
    _.merge(serializers.class(klass), studentInfo)
  else
    null

serializer.guide = serializers.teacherAccount
