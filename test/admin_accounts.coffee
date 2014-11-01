restrictedCrud = require('./shared_specs/restricted_crud')
specHelpers    = require('./support/spec_helpers')
simpleCrud     = require('./shared_specs/simple_crud')
serializer     = require('../app/serializers').adminAccount
factories      = require('./resources/factories/admin_accounts')
app            = require('../app')

RecruiterAccount = require('mongoose').model('RecruiterAccount')
AdminAccount = require('mongoose').model('AdminAccount')
agent        = require('supertest')(app)

resource = '/api/v0/admin_accounts'

#TODO: test creating an account through the API and then authenticating with the account
describe resource, ->

  describe 'Not logged in', ->

    restrictedCrud(app, resource)
      .destroy()
      .create()
      .update()
      .index()
      .show()


  describe 'Logged in', ->

    describe 'As recruiter', ->

      account = specHelpers.generateAccount()

      specHelpers.login(RecruiterAccount, 'recruiter', account)
        .get('access_token')
        .then (accessToken) ->
          restrictedCrud(app, resource, accessToken)
            .destroy()
            .create()
            .update()
            .index()
            .show()


    describe 'As admin', ->

      account = specHelpers.generateAccount()

      specHelpers.login(AdminAccount, 'admin', account)
        .then (accessTokenRecord) ->
          accessToken = accessTokenRecord.access_token
          accountId   = accessTokenRecord.user_id

          simpleCrud(app, resource, AdminAccount, factories, accessToken, serializer)
            .destroy()
            .create()
            .update()
            .index()
            .show()

          describe '409', ->
            it 'should response with status 409', (done) ->
              agent
                .post(resource)
                .send(admin_account: account)
                .set('X-Access-Token', accessToken)
                .expect(409)
                .expect(message: 'Conflict', status: 409)
                .end(done)
