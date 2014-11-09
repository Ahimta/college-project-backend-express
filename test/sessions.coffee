mongoose = require('mongoose')
config   = require('config')
expect   = require('chai').expect
_        = require('lodash')

specHelpers = require('./support/spec_helpers')
security    = require(config.get('paths.utils') + '/security')
app         = require(config.get('paths.app'))

RecruiterAccount = require(config.get('paths.models') + '/recruiter_account')
AdminAccount     = require(config.get('paths.models') + '/admin_account')
AccessToken      = require(config.get('paths.models') + '/access_token')

accountsModels =
  recruiter: RecruiterAccount
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
          it '', (done) ->
            agent
              .post(resource)
              .send
                username: account0.username
                password: account0.password
                role: role
              .expect(201)
              .expect (response) ->
                accessToken = response.body.access_token
                accountRole = response.body.account_role
                account     = response.body.account

                expect(account.username).to.eql(account0.username)
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
          ]

          _.forEach samples, (sample, i) ->
            describe sample.description, ->
              it i, (done) ->
                agent
                  .post(resource)
                  .send
                    username: sample.account.username
                    password: sample.account.password
                    role: 'admin'
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

          it 'his request to delete his token should be granted', (done) ->
            agent
              .delete("#{resource}/#{@tokenRecord1.id}")
              .set('X-Access-Token', @tokenRecord0.access_token)
              .expect(401)
              .end(done)
