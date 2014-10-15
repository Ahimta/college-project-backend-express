module.exports =

  getResourceName: (resource) ->
    resource.split('/').join('_')[0...-1]

  getResponseBody: (name) ->
    (record) ->
      responseBody = {}
      recordName   = if Array.isArray(record) then (name + 's') else name

      responseBody[recordName] = record
      responseBody

  notFound: (res) ->
    res.status(404).send(message: 'Not Found', status: 404)
