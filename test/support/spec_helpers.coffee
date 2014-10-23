require('../../app')

expect = require('chai').expect
_      = require('lodash')
Q      = require('q')

AccessToken = require('../../app/models/access_token')
security    = require('../../app/utils/security')

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
