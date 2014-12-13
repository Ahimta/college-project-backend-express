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
  studentAccount: accountConstrouctor
  teacherAccount: accountConstrouctor
  adminAccount: accountConstrouctor
  account: accountConstrouctor
  course: _.identity
  jobRequest: (jobRequest) ->
    security.generateSecureToken().then (token) ->
      _.merge(_.clone(jobRequest), token: token)