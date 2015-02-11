config = require('config')

serializers = require(config.get('paths.serializers'))
helpers     = require('_helpers')
_           = require('lodash')

serializer = module.exports = (student) ->
  _.merge(helpers.accountSerializer(student), {guide_id: student.guide_id?.toString()})

serializer.class = _.curry (student, klass) ->
  if klass
    studentId   = student._id.toString()
    studentInfo = _.find klass.students, ((s) -> s._id.toString() == studentId)
    _.merge(serializers.class(klass), studentInfo)
  else
    null

serializer.guide = serializers.teacherAccount
