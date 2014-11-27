supertest = require('supertest')
config    = require('config')
_         = require('lodash')
Q         = require('q')

controllersUtils = require (config.get('paths.utils') + '/controllers')
constructors     = require config.get('paths.constructors')
specHelpers      = require('../support/spec_helpers')

module.exports = (app, resource, mongooseModel, accessToken) ->

  resourceName    = controllersUtils.getResourceName(resource)
  getReqOrResBody = controllersUtils.getResponseBody(resourceName)

  account = specHelpers.generateAccount()
  agent   = supertest(app)

  Q(constructors.account(account))
    .then (persistableAccount) ->
      mongooseModel.update({username: account.username}, persistableAccount, upsert: true).exec()
    .then (__) ->
      specHelpers.createAccount(mongooseModel, specHelpers.generateAccount()).get('id')
    .then (accountId) ->

      describe "POST #{resource} - duplicate", ->
        it 'should response with status 409', (done) ->
          agent
            .post(resource)
            .send getReqOrResBody(account)
            .set('X-Access-Token', accessToken)
            .expect(409)
            .expect(message: 'Conflict', status: 409)
            .end(done)

      describe "PUT #{resource} - duplicate", ->
        it "should respond with status 409", (done) ->
          agent
            .put("#{resource}/#{accountId}")
            .send getReqOrResBody
              username: account.username
              password: 'hi there'
            .set('X-Access-Token', accessToken)
            .expect(409)
            .expect(message: 'Conflict', status: 409)
            .end(done)