config = require('config')

RecruiterAccount = require(config.get('paths.models') + '/recruiter_account')
router           = require('express').Router()

accountValidator = require('./concerns/middleware/validators').recruiterAccount
assertAdmin      = require('./concerns/middleware/authentication').assertAdmin
simpleCrud       = require('./concerns/shared_controllers/simple_crud')

constructor = require(config.get('paths.constructors')).recruiterAccount
serializer  = require(config.get('paths.serializers')).recruiterAccount

module.exports = (app) ->
  app.use('/api/v0/recruiter_accounts', router)

simpleCrud(router, RecruiterAccount, 'recruiter_accounts', serializer, constructor)
  .destroy(assertAdmin)
  .create([assertAdmin, accountValidator])
  .update([assertAdmin, accountValidator])
  .index(assertAdmin)
  .show(assertAdmin)