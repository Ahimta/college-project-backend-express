mongoose = require('mongoose')
Q        = require('q')

constructors = require('../app/constructors')

RecruiterAccount = mongoose.model('RecruiterAccount')
AdminAccount     = mongoose.model('AdminAccount')

recruiterAccount =
  username: 'recruiter'
  password: 'recruiter'

adminAccount =
  username: 'admin'
  password: 'admin'

createAccuount = (model, constructor, account) ->
  Q(constructor(account))
    .then (persistableAccount) ->
      model.update({username: persistableAccount.username}, account, {upsert: true}).exec()

RecruiterAccount.remove(username: recruiterAccount.username).exec()
  .then ->
    constructors.recruiterAccount(recruiterAccount)
  .then (persistableAccount) ->
    RecruiterAccount.create(persistableAccount)
  .then null, console.log

AdminAccount.remove(username: adminAccount.username).exec()
  .then ->
    constructors.adminAccount(adminAccount)
  .then (persistableAccount) ->
    AdminAccount.create(persistableAccount)
  .then null, console.log