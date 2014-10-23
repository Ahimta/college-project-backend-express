_ = require('lodash')
Q = require('q')

controllersUtils = require('../../../utils/controllers')

module.exports = (router, model, resource, serializer, constructor=_.identity) ->

  name = controllersUtils.getResourceName(resource)

  getResponseBody = controllersUtils.getResponseBody(name)

  self = ->
    module.exports(router, model, resource, serializer, constructor)

  helper = (cb) ->
    (middleware=[]) ->
      cb(middleware)
      self()

  destroy: helper (middleware) ->
    router.delete '/:id', middleware, (req, res, next) ->

      model.findByIdAndRemove req.params.id, (err, record) ->
        if !record then controllersUtils.notFound(res)
        else if err then next(err)
        else res.send(serializer(getResponseBody(record)))

  create: helper (middleware) ->
    router.post '/', middleware, (req, res, next) ->

      Q(constructor(req.body[name]))
        .then (x) ->
          model.create(x)
        .then (record) ->
          res.status(201).send(serializer(getResponseBody(record)))
        .then null, next

  update: helper (middleware) ->
    router.put '/:id', middleware, (req, res, next) ->

      model.findByIdAndUpdate req.params.id, req.body[name], (err, record) ->
        if !record then controllersUtils.notFound(res)
        else if err then next(err)
        else res.send(serializer(getResponseBody(record)))

  index: helper (middleware)->
    router.get '/', middleware, (req, res, next) ->

      model.find().exec()
        .then (records) ->
          res.send(getResponseBody(_.map(records, serializer)))
        .then null, next

  show: helper (middleware) ->
    router.get '/:id', middleware, (req, res, next) ->

      model.findById req.params.id, (err, record) ->
        if !record then controllersUtils.notFound(res)
        else if err then next(err)
        else res.send(serializer(getResponseBody(record)))
