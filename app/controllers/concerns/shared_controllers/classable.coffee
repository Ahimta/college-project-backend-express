config = require('config')
logger = require config.get('paths.logger')
_      = require('lodash')

assertSupervisor = require('../middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
serializers      = require(config.get('paths.serializers'))
Class           = require("#{config.get('paths.models')}/class")

module.exports = (router, model, entityName, fieldName, options={serializer: _.identity, isStudent: false}) ->

  serializer = options.serializer

  encapsulate = (classable, obj) ->
    jsonRes             = _.clone(obj)
    jsonRes[entityName] = serializer(classable)

    jsonRes

  objectWithKey = (key, value) ->
    obj      = {}
    obj[key] = value
    obj

  self = ->
    module.exports(router, model, entityName, fieldName, options)

  addOrRemoveClass = (isAdd) -> (req, res, next) ->
    model.findById(req.params.id).exec()
      .then (classable) ->
        return controllersUtils.notFound(res) unless classable
        command = if options.isStudent then objectWithKey('students', _id: classable._id)
        else objectWithKey(fieldName, classable._id)
        fullCommand = if isAdd then {$addToSet: command} else {$pull: command}
        console.log 'addOrRemoveClass command', command
        console.log 'addOrRemoveClass fullCommand', fullCommand
        Class.findByIdAndUpdate(req.params.classId, fullCommand).exec()
          .then (klass) ->
            if klass
              res.send encapsulate classable,
                class: serializers.class(klass)
            else
              controllersUtils.notFound(res)
          .then null, controllersUtils.mongooseErr(res, next)
      .then null, controllersUtils.mongooseErr(res, next)

  write: (middleware=[]) ->
    router
      .put '/:id/classes/:classId/remove', middleware, addOrRemoveClass(false)
      .put '/:id/classes/:classId/add', middleware, addOrRemoveClass(true)
    self()

  read: (middleware=[]) ->
    router
      .get '/:id/classes', middleware, (req, res, next) ->
        model.findById(req.params.id).exec()
          .then (classable) ->
            return controllersUtils.notFound(res) unless classable

            Class.find(objectWithKey(fieldName, classable._id))
              .populate('students._id teacher_id course_id')
              .exec()
              .then (current) ->
                  Class.find(objectWithKey(fieldName, $ne: classable._id))
                    .populate('students._id teacher_id course_id')
                    .exec()
                    .then (notCurrent) ->
                      res.send encapsulate classable,
                        classes:
                          not_current: notCurrent.map(serializers.classExpanded)
                          current: current.map(serializers.classExpanded)
              .then null, controllersUtils.mongooseErr(res, next)
          .then null, controllersUtils.mongooseErr(res, next)
    self()
