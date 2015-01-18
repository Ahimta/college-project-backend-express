config = require('config')

RecruiterAccount = require(config.get('paths.models') + '/recruiter_account')
router           = require('express').Router()

assertAuthorized2 = require('./concerns/middleware/authentication').assertAuthorized2
assertAdmin       = require('./concerns/middleware/authentication').assertAdmin

accountValidator = require('./concerns/middleware/validators').recruiterAccount
simpleCrud       = require('./concerns/shared_controllers/simple_crud')

constructor = require(config.get('paths.constructors')).recruiterAccount
serializer  = require(config.get('paths.serializers')).recruiterAccount

module.exports = (app) ->
  app.use('/api/v0/recruiter_accounts', router)

assertAdminOrRecruiterWithId = assertAuthorized2([
  {accountRole: 'admin'}
  {accountRole: 'recruiter', accountIdParam: 'id'}
])

simpleCrud(router, RecruiterAccount, 'recruiter_accounts', serializer, constructor)
  .destroy(assertAdmin)
  .create([assertAdmin, accountValidator])
  .update([assertAdmin, accountValidator])
  .index(assertAdmin)
  .show(assertAdminOrRecruiterWithId)
