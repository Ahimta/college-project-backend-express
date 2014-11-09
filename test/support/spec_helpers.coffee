config = require('config')
expect = require('chai').expect
faker  = require('faker')
_      = require('lodash')
Q      = require('q')

app = require(config.get('paths.app'))

AdminAccount = require(config.get('paths.models') + '/admin_account')
AccessToken  = require(config.get('paths.models') + '/access_token')
security     = require(config.get('paths.utils') + '/security')

agent = require('supertest')(app)

module.exports =
  expectCbs:
    badRequest: (res, invalidRecord) ->
      expect(res.body).to.have.keys(invalidRecord.errorKeys)

    notFound: (res) ->
      expect(res.body).to.have.keys(['message', 'status'])
      false

  createAccount: (model, account) ->
    Q(model.remove({username: account.username}).exec())
      .then ->
        security.hash(account.password)
      .then (hash) ->
        record = _.merge(_.clone(account), password: hash)
        model.create(record)
      .fail console.log


  generateAccount: ->
    username: faker.name.findName()
    password: faker.internet.password()

  login: (model, role, account) ->
    @createAccount(model, account).then (createdAccount) ->
      security.generateSecureToken()
        .then (token) ->
          {accountId: createdAccount.id, token: token}
      .then (result) ->
        record =
          access_token: result.token
          user_role: role
          user_id: result.accountId

        AccessToken.create(record)
      .fail console.log

  createAdmin: (account) ->
    @login(AdminAccount, @generateAccount)
      .then (tokenRecord) ->
        Q.Promise (resolve, reject, notify) ->
          agent
            .post("/api/v0/admin_accounts")
            .set('X-Access-Token', tokenRecord.access_token)
            .send(admin_account: account)
            .end (err, res) ->
              if err then reject(err)
              else resolve(adminAccount: res.body.admin_account, tokenRecord: tokenRecord)
      .then (result) ->
        Q.Promise (resolve, reject, notify) ->
          agent
            .post('/api/v0/sessions')
            .set('X-Access-Token', result.tokenRecord.accessToken)
            .send
              username: account.username
              password: account.password
              role: 'admin'
            .end (err, res) ->
              if err then reject(err)
              else resolve(res.body.access_token)
      .fail console.log
