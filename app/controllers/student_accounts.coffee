express = require('express')
config  = require('config')
router  = express.Router()

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
StudentAccount   = require (config.get('paths.models') + '/student_account')
simpleCrud       = require('./concerns/shared_controllers/simple_crud')
validator        = require('./concerns/middleware/validators').studentAccount

constructor = require(config.get('paths.constructors')).studentAccount
serializer  = require(config.get('paths.serializers')).studentAccount

module.exports = (app) ->
  app.use('/api/v0/student_accounts', router)

router
  .get '/without_guide', assertSupervisor, (req, res, next) ->
    StudentAccount.find(teacher_id: {$eq: null}).exec()
      .then (students) ->
        res.send(student_accounts: students.map(serializer))
      .then null, controllersUtils.mongooseErr(res, next)

simpleCrud(router, StudentAccount, 'student_accounts', serializer, constructor)
  .destroy(assertSupervisor)
  .create([assertSupervisor, validator])
  .update([assertSupervisor, validator])
  .index(assertSupervisor)
  .show(assertSupervisor)
