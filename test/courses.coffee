config = require('config')
logger = require config.get('paths.logger')
_      = require('lodash')

restrictedCrudSpecs = require('./shared_specs/restricted_crud')
simpleCrudSpecs     = require('./shared_specs/simple_crud')
specHelpers         = require('./support/spec_helpers')
serializer          = require(config.get('paths.serializers')).course
factories           = require(config.get('paths.factories') + '/courses')
app                 = require(config.get('paths.app'))

SupervisorAccount = require(config.get('paths.models') + '/supervisor_account')
RecruiterAccount  = require(config.get('paths.models') + '/recruiter_account')
StudentAccount    = require(config.get('paths.models') + '/student_account')
TeacherAccount    = require(config.get('paths.models') + '/teacher_account')
AdminAccount      = require(config.get('paths.models') + '/admin_account')
Course            = require(config.get('paths.models') + '/course')
agent             = require('supertest')(app)

resource = '/api/v0/courses'

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

              simpleCrudSpecs(app, resource, Course, factories, accessToken, serializer)
                .destroy()
                .create()
                .update()
                .index()
                .show()

              accountableSpecs(app, resource, Course, accessToken)
            .then null, logger.error
