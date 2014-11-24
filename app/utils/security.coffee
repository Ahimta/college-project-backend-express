bcrypt = require('bcrypt')
crypto = require('crypto')
Q      = require('q')

ROUNDS = 10

module.exports.generateSecureToken = (length=100) ->
  Q.nfapply(crypto.randomBytes, [length]).then (buffer) ->
    buffer.toString('hex')

module.exports.comparePasswords = (password, passwordHash) ->
  Q.Promise (resolve, reject, notify) ->
    bcrypt.compare password, passwordHash, (err, res) ->
      if res then resolve(res)
      else reject(err)


module.exports.hash = (password) ->
  Q.nfapply(bcrypt.hash, [password, ROUNDS])
