helpers = require('./_helpers')
_       = require('lodash')

f = (request) ->
  request.id_num = parseInt(request.id_num)
  request

serializer = module.exports = _.compose(f, helpers.baseSerializer)
