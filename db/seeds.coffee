mongoose = require('mongoose')
Q        = require('q')

accountConstructor = require('../app/constructors').account

RecruiterAccount = mongoose.model('RecruiterAccount')
AdminAccount     = mongoose.model('AdminAccount')

recruiterAccount =
  username: 'recruiter'
  password: 'recruiter'

adminAccount =
  username: 'admin'
  password: 'admin'

createAccuount = (model, account) ->
  Q(accountConstructor(account))
    .then (persistableAccount) ->
      model.update({username: persistableAccount.username}, persistableAccount, {upsert: true}).exec()
    .then null, console.log

createAccuount(RecruiterAccount, recruiterAccount)
createAccuount(AdminAccount, adminAccount)