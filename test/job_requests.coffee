supertest = require('supertest')
mongoose  = require('mongoose')
chai      = require('chai')
_         = require('lodash')

restrictedCrudSpecs = require('./shared_specs/restricted_crud')
simpleCrudSpecs     = require('./shared_specs/simple_crud')
specHelpers         = require('./support/spec_helpers')
constructor         = require('../app/constructors').jobRequest
serializer          = require('../app/serializers').jobRequest
factories           = require('./resources/factories/job_requests')
app                 = require('../app')

RecruiterAccount = mongoose.model('RecruiterAccount')
AdminAccount     = mongoose.model('AdminAccount')
JobRequest       = mongoose.model('JobRequest')
expect           = chai.expect
agent            = supertest(app)

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

    before (done) ->
      agent
        .put("#{resource}/#{@jobRequest.id}/files")
        .attach('avatar', 'test/fixtures/avatar.jpg')
        .expect(200)
        .end(done)

    it '', (done) ->
      agent
        .put("#{resource}/#{@jobRequest.id}/files")
        .attach('avatar', 'test/fixtures/avatar.jpg')
        .expect(200)
        .end (err, res) ->
          expect(res.body.job_request.files).to.eql(['avatar.jpg'])
          done(err)

    it '', (done) ->
      agent
        .get("#{resource}/#{@jobRequest.id}/files/avatar.jpg")
        .expect(200)
        .expect('Content-Disposition', 'attachment; filename="avatar.jpg"')
        .expect('Content-Type', 'image/jpeg')
        .end(done)