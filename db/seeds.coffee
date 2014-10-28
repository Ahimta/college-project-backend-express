mongoose = require('mongoose')

constructors = require('../app/constructors')

RecruiterAccount = mongoose.model('RecruiterAccount')
AdminAccount     = mongoose.model('AdminAccount')

recruiterAccount =
  username: 'recruiter'
  password: 'recruiter'

adminAccount =
  username: 'admin'
  password: 'admin'

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