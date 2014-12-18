config = require('config')
logger = require config.get('paths.logger')
_      = require('lodash')

module.exports =

  getResourceName: (resource) ->
    last = _.last(resource.split('/'))
    if last == 'classes' then 'class'
    else last[0...-1]

  getResponseBody: (resourceName) ->
    (record) ->
      collectionName = if resourceName == 'class' then 'classes' else (resourceName + 's')
      responseBody = {}
      recordName   = if Array.isArray(record) then collectionName else resourceName

      responseBody[recordName] = record
      responseBody

  unauthorized: (res) ->
    res.status(401).send(message: 'Unauthorized', status: 401)

  notFound: (res) ->
    res.status(404).send(message: 'Not Found', status: 404)

  mongooseErr: (res, next) ->
    (err) ->
      logger.error('controllersUtils.mongooseErr', err)

      if err.name == 'CastError' then module.exports.notFound(res)
      else if err.code?.toString() == '11000' then res.status(409).send(message: 'Conflict', status: 409)
      else next(err)
