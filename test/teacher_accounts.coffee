config = require('config')
logger = require config.get('paths.logger')
_      = require('lodash')

restrictedCrudSpecs = require('./shared_specs/restricted_crud')
accountableSpecs    = require('./shared_specs/accountable')
simpleCrudSpecs     = require('./shared_specs/simple_crud')
specHelpers         = require('./support/spec_helpers')
serializer          = require(config.get('paths.serializers')).teacherAccount
factories           = require(config.get('paths.factories') + '/teacher_accounts')
app                 = require(config.get('paths.app'))

SupervisorAccount = require(config.get('paths.models') + '/supervisor_account')
RecruiterAccount  = require(config.get('paths.models') + '/recruiter_account')
StudentAccount    = require(config.get('paths.models') + '/student_account')
TeacherAccount    = require(config.get('paths.models') + '/teacher_account')
AdminAccount      = require(config.get('paths.models') + '/admin_account')
agent             = require('supertest')(app)

resource = '/api/v0/teacher_accounts'

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

    describe 'Unauthorized', ->

      samples =
        recruiter: RecruiterAccount
        admin: AdminAccount

      _.forEach samples, (model, role) ->

        describe ('As ' + role), ->

          specHelpers.login(model, role, specHelpers.generateAccount())
            .get('access_token')
            .then (accessToken) ->
              restrictedCrudSpecs(app, resource, accessToken)
                .destroy()
                .create()
                .update()
                .index()
                .show()

            .then null, (err) ->
              logger.error(err, filename: module.filename)

    describe 'Authorized', ->

      samples =
        supervisor: SupervisorAccount

      _.forEach samples, (model, role) ->

        describe ('As ' + role), ->

          specHelpers.login(model, role, specHelpers.generateAccount())
            .get('access_token')
            .then (accessToken) ->

              simpleCrudSpecs(app, resource, TeacherAccount, factories, accessToken, serializer)
                .destroy()
                .create()
                .update()
                .index()
                .show()

              accountableSpecs(app, resource, TeacherAccount, accessToken)
            .then null, logger.error
