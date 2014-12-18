config = require('config')
logger = require config.get('paths.logger')

security = require(config.get('paths.utils') + '/security')
_        = require('lodash')

accountConstrouctor = (account) ->
  if account.password
    security.hash(account.password).then (passwordHash) ->
      _.merge _.clone(account),
        username: account.username.toLowerCase()
        password: passwordHash
  else
    _.omit(_.clone(account), 'password')

module.exports =
  supervisorAccount: accountConstrouctor
  recruiterAccount: accountConstrouctor
  studentAccount: accountConstrouctor
  teacherAccount: accountConstrouctor
  adminAccount: accountConstrouctor
  account: accountConstrouctor
  course: _.identity
  class: _.identity
  jobRequest: (jobRequest) ->
    security.generateSecureToken().then (token) ->
      _.merge(_.clone(jobRequest), token: token)