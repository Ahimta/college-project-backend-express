config = require('config')

security = require(config.get('paths.utils') + '/security')
_        = require('lodash')

accountConstrouctor = (account) ->
  security.hash(account.password).then (passwordHash) ->
    _.merge _.clone(account),
      username: account.username.toLowerCase()
      password: passwordHash

module.exports =
  supervisorAccount: accountConstrouctor
  recruiterAccount: accountConstrouctor
  adminAccount: accountConstrouctor
  account: accountConstrouctor
  jobRequest: (jobRequest) ->
    security.generateSecureToken().then (token) ->
      _.merge(_.clone(jobRequest), token: token)