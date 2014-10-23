security = require('./utils/security')
_        = require('lodash')

accountConstrouctor = (account) ->
  security.hash(account.password).then (passwordHash) ->
    x = _.merge(_.clone(account), password: passwordHash)
    console.log x
    x

module.exports =
  recruiterAccount: accountConstrouctor
  adminAccount: accountConstrouctor
  jobRequest: (jobRequest) ->
    security.generateSecureToken().then (token) ->
      _.merge(_.clone(jobRequest), token: token)
