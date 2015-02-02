express = require('express')
config  = require('config')
logger  = require config.get('paths.logger')
router  = express.Router()
_       = require('lodash')

assertAuthorized2 = require('./concerns/middleware/authentication').assertAuthorized2
assertSupervisor  = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils  = require (config.get('paths.utils') + '/controllers')
simpleCrud        = require('./concerns/shared_controllers/simple_crud')
validator         = require('./concerns/middleware/validators').studentAccount

StudentAccount   = require (config.get('paths.models') + '/student_account')
TeacherAccount   = require (config.get('paths.models') + '/teacher_account')
StudentAlert     = require (config.get('paths.models') + '/student_alert')
Class            = require (config.get('paths.models') + '/class')

constructor = require(config.get('paths.constructors')).studentAccount
serializers = require(config.get('paths.serializers'))
serializer  = require(config.get('paths.serializers')).studentAccount

module.exports = (app) ->
  app.use('/api/v0/student_accounts', router)

addOrRemoveClass = (isAdd) -> (req, res, next) ->
  StudentAccount.findById(req.params.id).exec()
    .then (student) ->
      return controllersUtils.notFound(res) unless student

      classCommand = if isAdd then {$addToSet: {students: {_id: student._id}}}
      else {$pull: {students: {_id: student._id}}}

      Class.findByIdAndUpdate(req.params.classId, classCommand).exec()
        .then (klass) ->
          if klass
            res.send
              student_account: serializers.studentAccount(student)
              class: serializers.class(klass)
          else
            controllersUtils.notFound(res)
    .then null, controllersUtils.mongooseErr(res, next)

router
  .get '/', assertSupervisor, (req, res, next) ->
    if req.query.expand
      StudentAccount.find().populate('guide_id').exec()
        .then (students) ->
          if students
            res.send
              student_accounts: students.map (student) ->
                if student.guide_id
                  _.merge serializers.studentAccount(student),
                    guide: serializers.teacherAccount(student.guide_id)
                else
                  serializers.studentAccount(student)
          else
            controllersUtils.notFound(res)
        .then null, controllersUtils.mongooseErr(res, next)
    else
      next()

  .get '/without_guide', assertSupervisor, (req, res, next) ->
    StudentAccount.find(guide_id: {$exists: false}).exec()
      .then (students) ->
        res.send(student_accounts: students.map(serializer))
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:id/guide', assertAuthorized2([{accountRole: 'supervisor'}, {accountRole: 'student', accountIdParam: 'id'}]), (req, res, next) ->
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

  .get '/:id/classes', (req, res, next) ->
    StudentAccount.findById(req.params.id).exec()
      .then (student) ->
        return controllersUtils.notFound(res) unless student

        Class.find({'students._id': student._id})
          .populate('students._id teacher_id course_id')
          .exec()
          .then (current) ->
              Class.find('students._id': {$ne: student._id})
                .populate('students._id teacher_id course_id')
                .exec()
                .then (notCurrent) ->
                  res.send
                    student_account: serializers.studentAccount(student)
                    classes:
                      not_current: notCurrent.map(serializers.classExpanded)
                      current: current.map(serializers.classExpanded).map (klass) ->
                        currentStudent = _.find klass.students, (s) ->
                          s.id == student._id.toString()
                        _.merge klass, _.pick(currentStudent, 'attendance', 'grades')
      .then null, controllersUtils.mongooseErr(res, next)


  .put('/:id/classes/:classId/remove',
    assertAuthorized2([{accountRole: 'supervisor'}, {accountRole: 'student', accountIdParam: 'id'}]),
    addOrRemoveClass(false))
  .put('/:id/classes/:classId/add',
    assertAuthorized2([{accountRole: 'supervisor'}, {accountRole: 'student', accountIdParam: 'id'}]),
    addOrRemoveClass(true))

simpleCrud(router, StudentAccount, 'student_accounts', serializer, constructor)
  .destroy(assertSupervisor)
  .create([assertSupervisor, validator])
  .update([assertSupervisor, validator])
  .index(assertSupervisor)
  .show(assertSupervisor)
