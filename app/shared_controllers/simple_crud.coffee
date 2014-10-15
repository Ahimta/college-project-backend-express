controllers_utils = require('../utils/controllers')

module.exports = (router, model, resource) ->

  name = controllers_utils.getResourceName(resource)

  getResponseBody = controllers_utils.getResponseBody(name)

  self = ->
    module.exports(router, model, resource)

  destroy: (middleware=[]) ->
    router.delete '/:id', middleware, (req, res, next) ->

      model.findByIdAndRemove req.params.id, (err, record) ->
        if !record then controllers_utils.notFound(res)
        else if err then next(err)
        else res.send(getResponseBody(record))

    self()

  create: (middleware=[]) ->
    router.post '/', middleware, (req, res, next) ->

      model.create req.body[name], (err, record) ->
        if err then next(err)
        else res.send(getResponseBody(record))

    self()

  update: (middleware=[]) ->
    router.put '/:id', middleware, (req, res, next) ->

      model.findByIdAndUpdate req.params.id, req.body[name], {new: true}, (err, record) ->
        if !record then controllers_utils.notFound(res)
        else if err then next(err)
        else res.send(getResponseBody(record))

    self()

  index: (middleware=[])->
    router.get '/', middleware, (req, res, next) ->

      model.find (err, records) ->
        if err then next(err)
        else res.send(getResponseBody(records))

    self()

  show: (middleware=[]) ->
    router.get '/:id', middleware, (req, res, next) ->

      model.findById req.params.id, (err, record) ->
        if !record then controllers_utils.notFound(res)
        else if err then next(err)
        else res.send(getResponseBody(record))

    self()
