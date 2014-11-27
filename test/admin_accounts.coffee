config = require('config')
logger = require config.get('paths.logger')

restrictedCrudSpecs = require('./shared_specs/restricted_crud')
accountableSpecs    = require('./shared_specs/accountable')
simpleCrudSpecs     = require('./shared_specs/simple_crud')
specHelpers         = require('./support/spec_helpers')
serializer          = require(config.get('paths.serializers')).adminAccount
factories           = require(config.get('paths.factories') + '/admin_accounts')
app                 = require(config.get('paths.app'))

RecruiterAccount = require(config.get('paths.models') + '/recruiter_account')
AdminAccount     = require(config.get('paths.models') + '/admin_account')
agent            = require('supertest')(app)

resource = '/api/v0/admin_accounts'

#TODO: test creating an account through the API and then authenticating with the account
describe resource, ->

  describe 'Not logged in', ->

    restrictedCrudSpecs(app, resource)
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
          restrictedCrudSpecs(app, resource, accessToken)
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

          simpleCrudSpecs(app, resource, AdminAccount, factories, accessToken, serializer)
            .destroy()
            .create()
            .update()
            .index()
            .show()

          accountableSpecs(app, resource, AdminAccount, accessToken)
        .then null, logger.error
