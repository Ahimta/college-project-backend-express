express = require('express')
config  = require('config')
logger  = require config.get('paths.logger')
router  = express.Router()

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
simpleCrud       = require('./concerns/shared_controllers/simple_crud')
validator        = require('./concerns/middleware/validators').class
Class            = require (config.get('paths.models') + '/class')

constructor = require(config.get('paths.constructors')).class
serializers = require(config.get('paths.serializers'))
serializer  = require(config.get('paths.serializers')).class

module.exports = (app) ->
  app.use('/api/v0/classes', router)

router
  .get '/', (req, res, next) ->
    return next() unless req.query.expand
    Class.find().populate('teacher_id course_id students._id').exec()
      .then (classes) ->
        res.send
          classes: classes.map(serializers.classExpanded)
      .then null, controllersUtils.mongooseErr(res, next)

simpleCrud(router, Class, 'classes', serializer, constructor)
  .destroy(assertSupervisor)
  .create([assertSupervisor, validator])
  .update([assertSupervisor, validator])
  .index(assertSupervisor)
  .show(assertSupervisor)
