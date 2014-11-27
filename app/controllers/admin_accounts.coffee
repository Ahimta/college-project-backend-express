config = require('config')

AdminAccount = require("#{config.get('paths.models')}/admin_account")
router       = require('express').Router()

assertAdmin = require('./concerns/middleware/authentication').assertAdmin
simpleCrud  = require('./concerns/shared_controllers/simple_crud')
validator   = require('./concerns/middleware/validators').adminAccount

constructor = require(config.get('paths.constructors')).adminAccount
serializer  = require(config.get('paths.serializers')).adminAccount

module.exports = (app) ->
  app.use('/api/v0/admin_accounts', router)

simpleCrud(router, AdminAccount, 'admin_accounts', serializer, constructor)
  .destroy(assertAdmin)
  .create([assertAdmin, validator])
  .update([assertAdmin, validator])
  .index(assertAdmin)
  .show(assertAdmin)
