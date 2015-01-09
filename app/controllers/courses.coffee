express = require('express')
config  = require('config')
logger  = require config.get('paths.logger')
router  = express.Router()
_       = require('lodash')

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
simpleCrud       = require('./concerns/shared_controllers/simple_crud')
validator        = require('./concerns/middleware/validators').course

Course = require (config.get('paths.models') + '/course')
Class  = require (config.get('paths.models') + '/class')

constructor = require(config.get('paths.constructors')).course
serializers = require(config.get('paths.serializers'))
serializer  = require(config.get('paths.serializers')).course

module.exports = (app) ->
  app.use('/api/v0/courses', router)

router
  .get '/:id/classes', assertSupervisor, (req, res, next) ->
    Course.findById(req.params.id).exec()
      .then (course) ->
        return controllersUtils.notFound(res) unless course

        Class.find(course_id: course._id).populate('teacher_id students._id').exec()
          .then (classes) ->
            res.send
              course:  serializers.course(course)
              classes: classes.map (klass) ->
                _.merge serializers.class(klass),
                  students: klass.students.map(serializers.classStudent)
      .then null, controllersUtils.mongooseErr(res, next)

simpleCrud(router, Course, 'courses', serializer, constructor)
  .destroy(assertSupervisor)
  .create([assertSupervisor, validator])
  .update([assertSupervisor, validator])
  .index(assertSupervisor)
  .show(assertSupervisor)
