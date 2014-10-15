JobRequest          = require('mongoose').model('JobRequest')
router              = require('express').Router()

jobRequestValidator = require('../middleware/validators').jobRequestValidator
simpleCrud          = require('../shared_controllers/simple_crud')

module.exports = (app) ->
  app.use('/api/v0/job_requests', router)

simpleCrud(router, JobRequest, 'job_requests')
  .destroy()
  .create(jobRequestValidator)
  .update(jobRequestValidator)
  .index()
  .show()
