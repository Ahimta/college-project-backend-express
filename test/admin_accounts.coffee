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

    account =
      username: 'username1'
      password: 'password1'

    describe 'As recruiter', ->

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

      specHelpers.login(AdminAccount, 'admin', account)
      # specHelpers.createAdmin(account)
        .get('access_token')
        .then (accessToken) ->
          simpleCrud(app, resource, AdminAccount, factories, accessToken, serializer)
            .destroy()
            .create()
            .update()
            .index()
            .show()
