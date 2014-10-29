restrictedCrudSpecs = require('./shared_specs/restricted_crud')
simpleCrudSpecs     = require('./shared_specs/simple_crud')
specHelpers         = require('./support/spec_helpers')
constructor         = require('../app/constructors').jobRequest
serializer          = require('../app/serializers').jobRequest
factories           = require('./resources/factories/job_requests')
app                 = require('../app')

RecruiterAccount = require('mongoose').model('RecruiterAccount')
AdminAccount     = require('mongoose').model('AdminAccount')
JobRequest       = require('mongoose').model('JobRequest')
expect           = require('chai').expect
agent            = require('supertest')(app)

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

    describe 'As recruiter', ->

      account = specHelpers.generateAccount()

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

      account = specHelpers.generateAccount()

      specHelpers.login(AdminAccount, 'admin', account)
        .get('access_token')
        .then (accessToken) ->
          simpleCrudSpecs(app, resource, JobRequest, factories, accessToken, serializer)
            .create()

          restrictedCrudSpecs(app, resource, accessToken, serializer)
            .destroy()
            .update()
            .index()
            .show()


  describe 'files', ->

    before ->
      constructor(factories.valid[0].form.job_request)
        .then (persistableJobRequest) ->
          JobRequest.create(persistableJobRequest)
        .then (jobRequest) =>
          @jobRequest = jobRequest
        .then null, console.log

    it '', (done) ->
      agent
        .put("#{resource}/#{@jobRequest.id}/files")
        .attach('avatar', 'test/fixtures/avatar.jpg')
        .expect(200)
        .end (err, res) ->
          console.log res.body
          done()