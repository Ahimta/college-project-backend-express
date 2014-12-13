express = require('express')
config  = require('config')
logger  = require config.get('paths.logger')
router  = express.Router()

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
simpleCrud       = require('./concerns/shared_controllers/simple_crud')
validator        = require('./concerns/middleware/validators').course
Course           = require (config.get('paths.models') + '/course')

constructor = require(config.get('paths.constructors')).course
serializer  = require(config.get('paths.serializers')).course

module.exports = (app) ->
  app.use('/api/v0/courses', router)

simpleCrud(router, Course, 'courses', serializer, constructor)
  .destroy(assertSupervisor)
  .create([assertSupervisor, validator])
  .update([assertSupervisor, validator])
  .index(assertSupervisor)
  .show(assertSupervisor)