JobRequest = require('mongoose').model('JobRequest')
router     = require('express').Router()

jobRequestValidator = require('./concerns/middleware/validators').jobRequestValidator
assertRecruiter     = require('./concerns/middleware/authentication').assertRecruiter
simpleCrud          = require('./concerns/shared_controllers/simple_crud')

constructor = require('../constructors').jobRequest
serializer  = require('../serializers').jobRequest

module.exports = (app) ->
  app.use('/api/v0/job_requests', router)

simpleCrud(router, JobRequest, 'job_requests', serializer, constructor)
  .destroy(assertRecruiter)
  .create([jobRequestValidator])
  .update([assertRecruiter, jobRequestValidator])
  .index(assertRecruiter)
  .show(assertRecruiter)
