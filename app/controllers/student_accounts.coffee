express = require('express')
config  = require('config')
logger  = require config.get('paths.logger')
router  = express.Router()

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
StudentAccount   = require (config.get('paths.models') + '/student_account')
simpleCrud       = require('./concerns/shared_controllers/simple_crud')
coursable        = require('./concerns/shared_controllers/coursable')
validator        = require('./concerns/middleware/validators').studentAccount

constructor = require(config.get('paths.constructors')).studentAccount
serializer  = require(config.get('paths.serializers')).studentAccount

module.exports = (app) ->
  app.use('/api/v0/student_accounts', router)



router
  .get '/without_guide', assertSupervisor, (req, res, next) ->
    StudentAccount.find(guide_id: {$exists: false}).exec()
      .then (students) ->
        res.send(student_accounts: students.map(serializer))
      .then null, controllersUtils.mongooseErr(res, next)

coursable(router, StudentAccount, 'student_account', serializer: serializer)

simpleCrud(router, StudentAccount, 'student_accounts', serializer, constructor)
  .destroy(assertSupervisor)
  .create([assertSupervisor, validator])
  .update([assertSupervisor, validator])
  .index(assertSupervisor)
  .show(assertSupervisor)
