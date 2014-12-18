config = require('config')
logger = require config.get('paths.logger')
_      = require('lodash')

restrictedCrudSpecs = require('./shared_specs/restricted_crud')
simpleCrudSpecs     = require('./shared_specs/simple_crud')
specHelpers         = require('./support/spec_helpers')
serializer          = require(config.get('paths.serializers')).class
factories           = require(config.get('paths.factories') + '/classes')
app                 = require(config.get('paths.app'))

SupervisorAccount = require(config.get('paths.models') + '/supervisor_account')
RecruiterAccount  = require(config.get('paths.models') + '/recruiter_account')
StudentAccount    = require(config.get('paths.models') + '/student_account')
TeacherAccount    = require(config.get('paths.models') + '/teacher_account')
AdminAccount      = require(config.get('paths.models') + '/admin_account')
Class             = require(config.get('paths.models') + '/class')
agent             = require('supertest')(app)

resource = '/api/v0/classes'

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
        student: StudentAccount
        teacher: TeacherAccount
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

              simpleCrudSpecs(app, resource, Class, factories, accessToken, serializer)
                .destroy()
                .create()
                .update()
                .index()
                .show()
            .then null, logger.error
