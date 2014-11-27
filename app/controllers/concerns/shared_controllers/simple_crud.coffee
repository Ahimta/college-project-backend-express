config = require('config')
_      = require('lodash')
Q      = require('q')

controllersUtils = require (config.get('paths.utils') + '/controllers')

defaultHooks =
  afterRemove: _.identity

module.exports = (router, model, resource, serializer, constructor=_.identity, hooks=defaultHooks) ->

  name = controllersUtils.getResourceName(resource)

  getResponseBody = controllersUtils.getResponseBody(name)

  self = ->
    module.exports(router, model, resource, serializer, constructor, hooks)

  helper = (cb) ->
    (middleware=[]) ->
      cb(middleware)
      self()

  destroy: helper (middleware) ->
    router.delete '/:id', middleware, (req, res, next) ->

      model.findByIdAndRemove(req.params.id).exec()
        .then (removedRecord) ->
          if removedRecord
            res.send(getResponseBody(serializer(removedRecord)))
            hooks.afterRemove(removedRecord)
          else
            controllersUtils.notFound(res)
        .then null, controllersUtils.mongooseErr(res, next)

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

      model.findById(req.params.id).exec()
        .then (record) ->
          if record then res.send(getResponseBody(serializer(record)))
          else controllersUtils.notFound(res)
        .then null, controllersUtils.mongooseErr(res, next)
