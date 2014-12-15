config = require('config')
logger = require config.get('paths.logger')
_      = require('lodash')

assertSupervisor = require('../middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
serializers      = require(config.get('paths.serializers'))
Course           = require("#{config.get('paths.models')}/course")

module.exports = (router, model, entityName, options={serializer: _.identity}) ->

  serializer = options.serializer

  encapsulate = (coursable, obj) ->
    jsonRes             = _.clone(obj)
    jsonRes[entityName] = serializer(coursable)

    jsonRes
    
  addOrRemoveCourse = (isAdd) -> (req, res, next) ->
    studentId = req.params.id
    courseId  = req.params.courseId

    studentCommand = if isAdd then {$addToSet: {courses_ids: courseId}}
    else {$pull: {courses_ids: courseId}}

    Course.findById(courseId).exec()
      .then (course) ->
        return controllersUtils.notFound(res) unless course
        model.findByIdAndUpdate(studentId, studentCommand).exec()
          .then (coursable) ->
            if coursable
              res.send encapsulate(coursable, course: serializers.course(course))
            else
              controllersUtils.notFound(res)
          .then null, controllersUtils.mongooseErr(res, next)
      .then null, controllersUtils.mongooseErr(res, next)

  coursesCurrentOrNot = (isCurrent) -> (req, res, next) ->

      model.findById(req.params.id).exec()
        .then (coursable) ->
          return controllersUtils.notFound(res) unless coursable

          courseQuery = if isCurrent then {_id: {$in: coursable.courses_ids}}
          else {_id: {$nin: coursable.courses_ids} }

          Course.find(courseQuery).exec()
            .then (courses) ->
              res.send encapsulate(coursable, courses: courses.map(serializers.course))
            .then null, controllersUtils.mongooseErr(res, next)
        .then null, controllersUtils.mongooseErr(res, next)

  self = ->
    module.exports(router, model, entityName, options)

  write: (middleware=[]) ->
    router
      .put '/:id/courses/:courseId/remove', middleware, addOrRemoveCourse(false)
      .put '/:id/courses/:courseId/add', middleware, addOrRemoveCourse(true)
    self()

  read: (middleware=[]) ->
    router
      .get '/:id/courses/not_current', middleware, coursesCurrentOrNot(false)
      .get '/:id/courses/current', middleware, coursesCurrentOrNot(true)
      .get '/:id/courses', middleware, coursesCurrentOrNot(true)
    self()