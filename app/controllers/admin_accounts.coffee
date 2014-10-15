AdminAccount = require('mongoose').model('AdminAccount')
router       = require('express').Router()

accountCreateValidator = require('../middleware/validators').accountCreateValidator
accountUpdateValidator = require('../middleware/validators').accountCreateValidator
hashAccountPassword    = require('../middleware/authentication').hashAccountPassword
assertAdmin            = require('../middleware/authentication').assertAdmin
simpleCrud             = require('../shared_controllers/simple_crud')

module.exports = (app) ->
  app.use('/api/v0/admin_accounts', router)

simpleCrud(router, AdminAccount, 'admin_accounts')
  .destroy(assertAdmin)
  .create([assertAdmin, accountCreateValidator, hashAccountPassword])
  .update([assertAdmin, accountUpdateValidator, hashAccountPassword])
  .index(assertAdmin)
  .show(assertAdmin)
