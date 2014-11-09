config = require('config')

security = require(config.get('paths.utils') + '/security')
_        = require('lodash')

accountConstrouctor = (account) ->
  security.hash(account.password).then (passwordHash) ->
    _.merge(_.clone(account), password: passwordHash)

module.exports =
  recruiterAccount: accountConstrouctor
  adminAccount: accountConstrouctor
  account: accountConstrouctor
  jobRequest: (jobRequest) ->
    security.generateSecureToken().then (token) ->
      _.merge(_.clone(jobRequest), token: token)