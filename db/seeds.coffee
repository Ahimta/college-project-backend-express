config = require('config')

mongoose = require('mongoose')
logger   = require config.get('paths.logger')
_        = require('lodash')
Q        = require('q')

accountConstructor = require('../app/constructors').account

SupervisorAccount = mongoose.model('SupervisorAccount')
RecruiterAccount  = mongoose.model('RecruiterAccount')
StudentAccount    = mongoose.model('StudentAccount')
AdminAccount      = mongoose.model('AdminAccount')

accounts =
  supervisor:
    username: 'supervisor'
    password: 'supervisor'

  recruiter:
    username: 'recruiter'
    password: 'recruiter'

  student:
    username: 'student'
    password: 'student'

  admin:
    username: 'admin'
    password: 'admin'

models =
  supervisor: SupervisorAccount
  recruiter: RecruiterAccount
  student: StudentAccount
  admin: AdminAccount

createAccuount = (model, account) ->
  Q(accountConstructor(account))
    .then (persistableAccount) ->
      model.update({username: persistableAccount.username}, persistableAccount, {upsert: true}).exec()
    .then null, logger.error

_.forEach accounts, (account, role) ->
  model = models[role]
  createAccuount(model, account)