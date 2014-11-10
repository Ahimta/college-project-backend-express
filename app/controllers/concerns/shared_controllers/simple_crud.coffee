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
        else res.send(getResponseBody(serializer(record)))

  create: helper (middleware) ->
    router.post '/', middleware, (req, res, next) ->

      Q(constructor(req.form[name]))
        .then (constructedDoc) ->
          model.create(constructedDoc)
        .then (record) ->
          res.status(201).send(getResponseBody(serializer(record)))
        .then null, controllersUtils.mongooseErr(res, next)

  update: helper (middleware) ->
    router.put '/:id', middleware, (req, res, next) ->

      model.findByIdAndUpdate(req.params.id, req.form[name]).exec()
        .then (record) ->
          if record then res.send(getResponseBody(serializer(record)))
          else controllersUtils.notFound(res)
        .then null, controllersUtils.mongooseErr(res, next)

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
        else res.send(getResponseBody(serializer(record)))
