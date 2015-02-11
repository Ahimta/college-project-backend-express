config = require('config')

serializers = require(config.get('paths.serializers'))
helpers     = require('./_helpers')
_           = require('lodash')

serializer = module.exports = (alert) ->
  _.merge helpers.baseSerializer(alert),
    student_id: alert.student_id?.toString()
    teacher_id: alert.teacher_id?.toString()

serializer.student = serializers.studentAccount
serializer.teacher = serializers.teacherAccount
