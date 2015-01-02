express = require('express')
config  = require('config')
router  = express.Router()
_       = require('lodash')

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
TeacherAccount   = require (config.get('paths.models') + '/teacher_account')
simpleCrud       = require('./concerns/shared_controllers/simple_crud')
coursable        = require('./concerns/shared_controllers/coursable')
classable        = require('./concerns/shared_controllers/classable')
validator        = require('./concerns/middleware/validators').teacherAccount
Course           = require (config.get('paths.models') + '/course')
Class            = require (config.get('paths.models') + '/class')

constructor = require(config.get('paths.constructors')).teacherAccount
serializers = require(config.get('paths.serializers'))
serializer  = require(config.get('paths.serializers')).teacherAccount

module.exports = (app) ->
  app.use('/api/v0/teacher_accounts', router)

addOrRemoveGuide = (isAdd) -> (req, res, next) ->
  TeacherAccount.findByIdAndUpdate(req.params.id, {is_guide: isAdd}).exec()
    .then (teacher) ->
      if teacher then res.send(teacher_account: serializer(teacher))
      else controllersUtils.notFound(res)
    .then null, controllersUtils.mongooseErr(res, next)

router
  .get '/not_guides', assertSupervisor, (req, res, next) ->
    TeacherAccount.find({is_guide: false}).exec()
      .then (teachers) ->
        res.send
          teacher_accounts: teachers.map(serializer)
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:id/classes/:classId', (req, res, next) ->
    TeacherAccount.findById(req.params.id).exec()
      .then (teacher) ->
        return controllersUtils.notFound(res) unless teacher
        Class.findById(req.params.classId)
          .populate('students._id course_id')
          .exec()
          .then (klass) ->
            res.send
              teacher_account: serializers.teacherAccount(teacher)
              course: serializers.course(klass.course_id)
              class:  serializers.class(klass)
              students: klass.students.map (student) ->
                studentAccount = serializers.studentAccount(student._id)
                studentInfo    = _.pick(student, 'attendance', 'grades')
                _.merge studentAccount, studentInfo
      .then null, controllersUtils.mongooseErr(res, next)

  .put '/:id/classes/:classId/remove', assertSupervisor, (req, res, next) ->
    TeacherAccount.findById(req.params.id).exec()
      .then (teacher) ->
        return controllersUtils.notFound(res) unless teacher
        Class.findByIdAndUpdate(req.params.classId, {$unset: {teacher_id: teacher.id}}).exec()
          .then (klass) ->
            return controllersUtils.notFound(res) unless klass
            res.send
              teacher_account: serializers.teacherAccount(teacher)
              class:           serializers.class(klass)
      .then null, controllersUtils.mongooseErr(res, next)

  .put '/:teacherId/classes/:classId/students/:studentId', (req, res, next) ->
    command =
      $pull:
        students:
          _id: req.params.studentId

    query =
      _id: req.params.classId
      teacher_id: req.params.teacherId
      'students._id': req.params.studentId


    Class.findOneAndUpdate(query, command)
      .exec()
      .then (klass) ->
        return controllersUtils.notFound(res) unless klass
        command =
          $addToSet:
            students:
              _id: req.params.studentId
              attendance: req.body.student?.attendance
              grades:
                req.body.student?.grades
        Class.findByIdAndUpdate(req.params.classId, command).exec().then (klass) ->
          res.status(200).end()
      .then null, controllersUtils.mongooseErr(res)

  .put '/:id/remove_from_guides', assertSupervisor, addOrRemoveGuide(false)
  .put '/:id/add_to_guides', assertSupervisor, addOrRemoveGuide(true)

coursable(router, TeacherAccount, 'teacher_account', serializer: serializer)
  .write(assertSupervisor)
  .read(assertSupervisor)

classable(router, TeacherAccount, 'teacher_account', 'teacher_id', serializer: serializer)
  .write(assertSupervisor)
  .read()

simpleCrud(router, TeacherAccount, 'teacher_accounts', serializer, constructor)
  .destroy(assertSupervisor)
  .create([assertSupervisor, validator])
  .update([assertSupervisor, validator])
  .index(assertSupervisor)
  .show(assertSupervisor)
