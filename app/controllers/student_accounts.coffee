express = require('express')
config  = require('config')
logger  = require config.get('paths.logger')
router  = express.Router()

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
StudentAccount   = require (config.get('paths.models') + '/student_account')
TeacherAccount   = require (config.get('paths.models') + '/teacher_account')
simpleCrud       = require('./concerns/shared_controllers/simple_crud')
coursable        = require('./concerns/shared_controllers/coursable')
classable        = require('./concerns/shared_controllers/classable')
validator        = require('./concerns/middleware/validators').studentAccount

constructor = require(config.get('paths.constructors')).studentAccount
serializers = require(config.get('paths.serializers'))
serializer  = require(config.get('paths.serializers')).studentAccount

module.exports = (app) ->
  app.use('/api/v0/student_accounts', router)

router
  .get '/without_guide', assertSupervisor, (req, res, next) ->
    StudentAccount.find(guide_id: {$exists: false}).exec()
      .then (students) ->
        res.send(student_accounts: students.map(serializer))
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:id/guide', assertSupervisor, (req, res, next) ->
    StudentAccount.findOne({_id: req.params.id, guide_id: {$exists: true}}).exec()
      .then (student) ->
        return controllersUtils.notFound(res) unless student
        TeacherAccount.findOne(_id: student.guide_id, is_guide: true).exec()
          .then (guide) ->
            if guide
              res.send
                student_account: serializers.studentAccount(student)
                guide: serializers.teacherAccount(guide)
            else
              controllersUtils.notFound(res)
          .then null, controllersUtils.mongooseErr(res, next)
        .then null, controllersUtils.mongooseErr(res, next)

coursable(router, StudentAccount, 'student_account', serializer: serializer)
  .write(assertSupervisor)
  .read(assertSupervisor)

classable(router, StudentAccount, 'student_account', 'students._id', serializer: serializer, isStudent: true)
  .write(assertSupervisor)
  .read(assertSupervisor)

simpleCrud(router, StudentAccount, 'student_accounts', serializer, constructor)
  .destroy(assertSupervisor)
  .create([assertSupervisor, validator])
  .update([assertSupervisor, validator])
  .index(assertSupervisor)
  .show(assertSupervisor)
