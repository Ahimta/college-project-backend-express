config = require('config')

mongoose = require('mongoose')
logger   = require config.get('paths.logger')
_        = require('lodash')
Q        = require('q')

accountConstructor = require('../app/constructors').account

SupervisorAccount = mongoose.model('SupervisorAccount')
RecruiterAccount  = mongoose.model('RecruiterAccount')
StudentAccount    = mongoose.model('StudentAccount')
TeacherAccount    = mongoose.model('TeacherAccount')
AdminAccount      = mongoose.model('AdminAccount')
Course            = mongoose.model('Course')

accounts =
  supervisor:
    fullname: 'supervisor'
    username: 'supervisor'
    password: 'supervisor'

  recruiter:
    fullname: 'recruiter'
    username: 'recruiter'
    password: 'recruiter'

  student:
    fullname: 'student'
    username: 'student'
    password: 'student'

  teacher:
    fullname: 'teacher'
    username: 'teacher'
    password: 'teacher'

  admin:
    fullname: 'admin'
    username: 'admin'
    password: 'admin'

models =
  supervisor: SupervisorAccount
  recruiter:  RecruiterAccount
  student:    StudentAccount
  teacher:    TeacherAccount
  admin:      AdminAccount

createAccuount = (model, account) ->
  Q(accountConstructor(account))
    .then (persistableAccount) ->
      model.update({username: persistableAccount.username}, persistableAccount, {upsert: true})
        .exec()
    .then null, logger.error

_.forEach accounts, (account, role) ->
  model = models[role]
  createAccuount(model, account)

createAccuount models.teacher,
  fullname: 'guide'
  username: 'guide'
  password: 'guide'
  is_guide: true

course =
  name: 'Introduction to Computer Science I'
  code: 'CS50'

Course.update({code: course.code}, course, upsert: true).exec()
