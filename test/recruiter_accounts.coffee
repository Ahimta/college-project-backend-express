supertest = require('supertest')
mongoose  = require('mongoose')
config    = require('config')

restrictedCrud = require('./shared_specs/restricted_crud')
specHelpers    = require('./support/spec_helpers')
simpleCrud     = require('./shared_specs/simple_crud')
serializer     = require(config.get('paths.serializers')).recruiterAccount
factories      = require(config.get('paths.factories') + '/recruiter_accounts')
app            = require(config.get('paths.app'))

RecruiterAccount = require(config.get('paths.models') + '/recruiter_account')
AdminAccount     = require(config.get('paths.models') + '/admin_account')
agent            = supertest(app)

resource = '/api/v0/recruiter_accounts'

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
        .get('access_token')
        .then (accessToken) ->
          simpleCrud(app, resource, RecruiterAccount, factories, accessToken, serializer)
            .destroy()
            .create()
            .update()
            .index()
            .show()
