course = require('mongoose').model('Course')
router = require('express').Router()

courseValidator = require('../middleware/validators').courseValidator
simpleCrud      = require('../shared_controllers/simple_crud')

module.exports = (app) ->
  app.use('/api/v0/courses', router)
