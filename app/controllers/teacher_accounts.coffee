express = require('express')
config  = require('config')
logger  = require(config.get('paths.logger'))
router  = express.Router()
_       = require('lodash')

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
simpleCrud       = require('./concerns/shared_controllers/simple_crud')
validator        = require('./concerns/middleware/validators').teacherAccount

TeacherAccount = require (config.get('paths.models') + '/teacher_account')
Course         = require (config.get('paths.models') + '/course')
Class          = require (config.get('paths.models') + '/class')

constructor = require(config.get('paths.constructors')).teacherAccount
serializers = require(config.get('paths.serializers'))

module.exports = (app) ->
  app.use('/api/v0/teacher_accounts', router)

addOrRemoveGuide = (isAdd) -> (req, res, next) ->
  TeacherAccount.findByIdAndUpdate(req.params.id, {is_guide: isAdd}).exec()
    .then (teacher) ->
      if teacher then res.send(teacher_account: serializers.teacherAccount(teacher))
      else controllersUtils.notFound(res)
    .then null, controllersUtils.mongooseErr(res, next)

addOrRemoveClass = (isAdd) -> (req, res, next) ->
  TeacherAccount.findById(req.params.id).exec()
    .then (teacher) ->
      return controllersUtils.notFound(res) unless teacher

      command = if isAdd then {teacher_id: teacher._id} else {$unset: {teacher_id: true}}
      Class.findByIdAndUpdate(req.params.classId, command).exec()
        .then (klass) ->
          return controllersUtils.notFound(res) unless klass
          res.send
            teacher_account: serializers.teacherAccount(teacher)
            class:           serializers.class(klass)
    .then null, controllersUtils.mongooseErr(res, next)

router
  .put '/:id/remove_from_guides', assertSupervisor, addOrRemoveGuide(false)
  .put '/:id/add_to_guides',      assertSupervisor, addOrRemoveGuide(true)

  .put '/:id/classes/:classId/remove', assertSupervisor, addOrRemoveClass(false)
  .put '/:id/classes/:classId/add',    assertSupervisor, addOrRemoveClass(true)

  .get '/not_guides', assertSupervisor, (req, res, next) ->
    TeacherAccount.find({is_guide: false}).exec()
      .then (teachers) ->
        res.send
          teacher_accounts: teachers.map(serializers.teacherAccount)
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:id/classes', (req, res, next) ->
    TeacherAccount.findById(req.params.id).exec()
      .then (teacher) ->
        Class.find({teacher_id: teacher._id})
          .populate('students._id teacher_id course_id')
          .exec()
          .then (currentClasses) ->
            Class.find({teacher_id: {$ne: teacher._id}})
              .populate('students._id teacher_id course_id')
              .exec()
              .then (notCurrentClasses) ->
                res.send
                  teacher_account: serializers.teacherAccount(teacher)
                  classes:
                    not_current: notCurrentClasses.map(serializers.classExpanded)
                    current:     currentClasses.map(serializers.classExpanded)
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:id/classes/:classId', (req, res, next) ->
    TeacherAccount.findById(req.params.id).exec()
      .then (teacher) ->
        return controllersUtils.notFound(res) unless teacher
        Class.findOne({_id: req.params.classId, teacher_id: req.params.id})
          .populate('students._id course_id')
          .exec()
          .then (klass) ->
            if klass
              res.send
                teacher_account: serializers.teacherAccount(teacher)
                students:        klass.students.map(serializers.classStudent)
                course:          serializers.course(klass.course_id)
                class:           serializers.class(klass)
            else
              controllersUtils.notFound(res)
      .then null, controllersUtils.mongooseErr(res, next)

  .put '/:teacherId/classes/:classId/students/:studentId', (req, res, next) ->
    command =
      'students.$':
        _id: req.params.studentId
        attendance: req.body.student?.attendance
        grades:
          req.body.student?.grades

    query =
      _id: req.params.classId
      teacher_id: req.params.teacherId
      'students._id': req.params.studentId

    Class.findOneAndUpdate(query, command)
      .populate('teacher_id')
      .exec()
      .then (klass) ->
        if klass and klass.teacher_id
          res.status(200).end()
        else
          controllersUtils.notFound(res)
      .then null, controllersUtils.mongooseErr(res)

simpleCrud(router, TeacherAccount, 'teacher_accounts', serializers.teacherAccount, constructor)
  .destroy(assertSupervisor)
  .create([assertSupervisor, validator])
  .update([assertSupervisor, validator])
  .index(assertSupervisor)
  .show(assertSupervisor)
