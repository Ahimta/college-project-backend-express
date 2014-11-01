module.exports =

  getResourceName: (resource) ->
    resource.split('/').join('_')[0...-1]

  getResponseBody: (resourceName) ->
    (record) ->
      responseBody = {}
      recordName   = if Array.isArray(record) then (resourceName + 's') else resourceName

      responseBody[recordName] = record
      responseBody

  unauthorized: (res) ->
    res.status(401).send(message: 'Unauthorized', status: 401)

  notFound: (res) ->
    res.status(404).send(message: 'Not Found', status: 404)

  mongooseErr: (res, next) ->
    (err) ->
      if err.name == 'CastError' then module.exports.notFound(res)
      else if err.code == 11000 then res.status(409).send(message: 'Conflict', status: 409)
      else next(err)
