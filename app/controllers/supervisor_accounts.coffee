express = require('express')
config  = require('config')
router  = express.Router()

SupervisorAccount = require (config.get('paths.models') + '/supervisor_account')
assertAdmin       = require('./concerns/middleware/authentication').assertAdmin
simpleCrud        = require('./concerns/shared_controllers/simple_crud')
validator         = require('./concerns/middleware/validators').supervisorAccount

constructor = require(config.get('paths.constructors')).supervisorAccount
serializer  = require(config.get('paths.serializers')).supervisorAccount

module.exports = (app) ->
  app.use('/api/v0/supervisor_accounts', router)

simpleCrud(router, SupervisorAccount, 'supervisor_accounts', serializer, constructor)
  .destroy(assertAdmin)
  .create([assertAdmin, validator])
  .update([assertAdmin, validator])
  .index(assertAdmin)
  .show(assertAdmin)