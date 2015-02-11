config = require('config')

serializers = require(config.get('paths.serializers'))
helpers     = require('./_helpers')
_           = require('lodash')

serializer = module.exports = helpers.accountSerializer

serializer.student = serializers.studentAccount

serializer.class = (klass) ->
  _.omit(serializers.class(klass), 'teacher_id')
