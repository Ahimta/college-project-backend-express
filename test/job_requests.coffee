process.env.NODE_ENV = 'test'

jobRequestFactories = require('./resources/job_requests')
crudSharedSpecs     = require('./shared_specs/simple_crud')
app                 = require('../app')

JobRequest = require('mongoose').model('JobRequest')
expect     = require('chai').expect

describe '/api/v0/job_requests', ->

  crudSharedSpecs(app, '/api/v0/job_requests', JobRequest, jobRequestFactories)
    .destroy()
    .create()
    .update()
    .index()
    .show()
