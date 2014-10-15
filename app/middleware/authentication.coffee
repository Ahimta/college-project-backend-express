mongoose = require('mongoose')
bcrypt   = require('bcrypt')
Q        = require('q')

AccessToken = mongoose.model('AccessToken')

BCRYPT_ROUNDS   = 100
ACCOUNTS_MODELS =
  recruiter: mongoose.model('RecruiterAccount')
  admin: mongoose.model('AdminAccount')

assertAuthorizedMiddleware = (->

  assertAuthorized = (role) ->
    (access_token) ->
      deferred = Q.defer()
      model    = ACCOUNTS_MODELS[role]

      if model
        AccessToken.findOne {access_tokens: access_token, user_role: role}, (err, tokenRecord) ->
          if (err or !tokenRecord) then deferred.reject(err)
          else
            model.findOne {_id: tokenRecord.user_id}, (err, account) ->
              if (err or !account) then deferred.reject(err)
              else deferred.resolve(account)
      else
        deferred.reject(new Error("The role: #{role} doesn't exist"))

      deferred.promise

  (role) ->
    assertF = assertAuthorized(role)

    (req, res, next) ->
      access_token = req.query.access_token || req.get('X-Access-Token')

      assertF(access_token)
        .then (account) ->
          res.locals.account = account
          res.locals.role    = role
          next()
        .fail (err) ->
          res.status(401).send(message: 'Unauthorized', status: 401).end()
)()


module.exports.hashAccountPassword = (->

  hash = (password) ->
    deferred = Q.defer()

    bcrypt.hash password, BCRYPT_ROUNDS, (err, hash) ->
      if err then deferred.reject(err)
      else deferred.resolve(hash)

    deferred.promise

  (req, res, next) ->
    account  = req.body.admin_account
    password = account.password

    if password or password != ''
      hash(password)
        .then (password_hash) ->
          account.password = password_hash
        .fail (err) ->
          next(new Error(err))
    else
      next()
)()

module.exports.assertRecruiter = assertAuthorizedMiddleware('recruiter')
module.exports.assertAdmin     = assertAuthorizedMiddleware('admin')
