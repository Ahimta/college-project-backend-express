app = require('../../app')

expect = require('chai').expect
_      = require('lodash')
Q      = require('q')

AdminAccount = require('../../app/models/admin_account')
AccessToken  = require('../../app/models/access_token')
security     = require('../../app/utils/security')

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

  createAdmin: (account) ->
    @login(AdminAccount, 'admin', username: 'uuuu0', password: 'passwd')
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
            .set('X-Access-Token', result.accessToken)
            .send
              username: result.adminAccount.username
              password: result.adminAccount.password
              role: 'admin'
            .end (err, res) ->
              if err then reject(err)
              else resolve(res.body.access_token)
