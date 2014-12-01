mongoose = require('mongoose')
config   = require('config')
expect   = require('chai').expect
logger   = require config.get('paths.logger')
_        = require('lodash')

specHelpers = require('./support/spec_helpers')
security    = require(config.get('paths.utils') + '/security')
app         = require(config.get('paths.app'))

SupervisorAccount = require(config.get('paths.models') + '/supervisor_account')
RecruiterAccount  = require(config.get('paths.models') + '/recruiter_account')
StudentAccount    = require(config.get('paths.models') + '/student_account')
TeacherAccount    = require(config.get('paths.models') + '/teacher_account')
AdminAccount      = require(config.get('paths.models') + '/admin_account')
AccessToken       = require(config.get('paths.models') + '/access_token')

accountsModels =
  supervisor: SupervisorAccount
  recruiter: RecruiterAccount
  student: StudentAccount
  teacher: TeacherAccount
  admin: AdminAccount

resource = '/api/v0/sessions'
agent    = require('supertest')(app)

describe resource, ->

  account0 = specHelpers.generateAccount()
  account1 = specHelpers.generateAccount()

  describe "POST #{resource}", ->

    _.forEach accountsModels, (model, role) ->

      describe "As #{role}", ->
        before -> specHelpers.createAccount(model, account0)

        describe 'valid', ->
          samples = [
            {
              description: 'the original username'
              username: account0.username
              password: account0.password
              role: role
            }
            {
              description: 'the upcased username'
              username: account0.username.toUpperCase()
              password: account0.password
              role: role
            }
            {
              description: 'the downcase username'
              username: account0.username.toLowerCase()
              password: account0.password
              role: role
            }
            {
              description: 'swapcased username'
              username: specHelpers.swapCase(account0.username)
              password: account0.password
              role: role
            }
          ]
          _.forEach samples, (sample, i) ->
            describe sample.description, ->
              it 'should respond with 201', (done) ->
                agent
                  .post(resource)
                  .send _.pick(sample, 'username', 'password', 'role')
                  .expect(201)
                  .expect (response) ->
                    accessToken = response.body.access_token
                    accountRole = response.body.account_role
                    account     = response.body.account

                    expect(account.username.toLowerCase()).to.eql(account0.username.toLowerCase())
                    expect(accessToken.length).to.be.above(99)
                    expect(account.password).to.be.undefined
                    expect(accountRole).to.eql(role)
                    false
                  .end(done)

        describe 'invalid', ->
          samples = [
            {
              description: 'incorrect username'
              account:
                username: (account0.username + 'x')
                password: account0.password
            }
            {
              description: 'incorrect password'
              account:
                username: account0.username
                password: (account0.password + 'xx')
            }
            {
              description: 'uppercased password'
              account:
                username: account0.username
                password: account0.password.toUpperCase()
            }
            {
              description: 'swapcased password'
              account:
                username: account0.username
                password: specHelpers.swapCase(account0.password)
            }
          ]

          _.forEach samples, (sample, i) ->
            describe sample.description, ->
              it i, (done) ->
                agent
                  .post(resource)
                  .send
                    username: sample.account.username
                    password: sample.account.password
                    role: role
                  .expect(401)
                  .end(done)


  describe "DELETE #{resource}/:id", ->

    expectCount = (accessToken, expectedCount) ->
      AccessToken.count({access_token: accessToken}).exec().then (count) ->
        expect(count).to.eql(expectedCount)

    _.forEach accountsModels, (model, role) ->

      describe "As #{role}", ->
        before ->
          specHelpers.login(model, role, account0)
            .then (tokenRecord) =>
              @tokenRecord0 = tokenRecord
            .then ->
              specHelpers.login(model, role, account1)
            .then (tokenRecord) =>
              @tokenRecord1 = tokenRecord

        before     -> expectCount(@tokenRecord0.access_token, 1)
        beforeEach -> expectCount(@tokenRecord1.access_token, 1)

        after     -> expectCount(@tokenRecord0.access_token, 0)
        afterEach -> expectCount(@tokenRecord1.access_token, 1)

        describe 'the user deleting his own token', ->

          it 'his request to delete his token should be granted', (done) ->
            agent
              .delete("#{resource}/#{@tokenRecord0.id}")
              .set('X-Access-Token', @tokenRecord0.access_token)
              .expect(200)
              .end (done)

        describe 'the user trying to delete another user token', ->

          it 'his request to delete another user token should not be granted', (done) ->
            agent
              .delete("#{resource}/#{@tokenRecord1.id}")
              .set('X-Access-Token', @tokenRecord0.access_token)
              .expect(401)
              .end(done)
