express = require('express')
config  = require('config')
router  = express.Router()

StudentAccount = require (config.get('paths.models') + '/student_account')
assertSupervisor  = require('./concerns/middleware/authentication').assertSupervisor
simpleCrud     = require('./concerns/shared_controllers/simple_crud')
validator      = require('./concerns/middleware/validators').studentAccount

constructor = require(config.get('paths.constructors')).studentAccount
serializer  = require(config.get('paths.serializers')).studentAccount

module.exports = (app) ->
  app.use('/api/v0/student_accounts', router)

simpleCrud(router, StudentAccount, 'student_accounts', serializer, constructor)
  .destroy(assertSupervisor)
  .create([assertSupervisor, validator])
  .update([assertSupervisor, validator])
  .index(assertSupervisor)
  .show(assertSupervisor)