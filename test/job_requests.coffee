process.env.NODE_ENV = 'test'

restrictedCrudSpecs = require('./shared_specs/restricted_crud')
simpleCrudSpecs     = require('./shared_specs/simple_crud')
specHelpers         = require('./support/spec_helpers')
serializer          = require('../app/serializers').jobRequest
factories           = require('./resources/job_requests')
app                 = require('../app')

RecruiterAccount = require('mongoose').model('RecruiterAccount')
AdminAccount     = require('mongoose').model('AdminAccount')
JobRequest       = require('mongoose').model('JobRequest')
expect           = require('chai').expect

resource = '/api/v0/job_requests'

describe resource, ->

  describe 'Not logged in', ->
    simpleCrudSpecs(app, resource, JobRequest, factories, null, serializer)
      .create()

    restrictedCrudSpecs(app, resource)
      .destroy()
      .update()
      .index()
      .show()

  describe 'Logged in', ->

    account =
      username: 'username31'
      password: 'passwd'

    describe 'As recruiter', ->

      specHelpers.login(RecruiterAccount, 'recruiter', account)
        .get('access_token')
        .then (accessToken) ->
          simpleCrudSpecs(app, resource, JobRequest, factories, accessToken, serializer)
            .destroy()
            .create()
            .update()
            .index()
            .show()

    describe 'As admin', ->

      specHelpers.login(AdminAccount, 'admin', account)
        .get('access_token')
        .then (accessToken) ->
          simpleCrudSpecs(app, JobRequest, factories, accessToken, serializer)
            .create()

          restrictedCrudSpecs(app, resource, accessToken, serializer)
            .destroy()
            .update()
            .index()
            .show()
