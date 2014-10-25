RecruiterAccount = require('mongoose').model('RecruiterAccount')
router           = require('express').Router()

accountValidator = require('./concerns/middleware/validators').recruiterAccountValidator
assertAdmin      = require('./concerns/middleware/authentication').assertAdmin
simpleCrud       = require('./concerns/shared_controllers/simple_crud')

constructor = require('../constructors').recruiterAccount
serializer  = require('../serializers').recruiterAccount

module.exports = (app) ->
  app.use('/api/v0/recruiter_accounts', router)

simpleCrud(router, RecruiterAccount, 'recruiter_accounts', serializer, constructor)
  .destroy(assertAdmin)
  .create([assertAdmin, accountValidator])
  .update([assertAdmin, accountValidator])
  .index(assertAdmin)
  .show(assertAdmin)
