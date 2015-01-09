express = require('express')
config  = require('config')
router  = express.Router()
_       = require('lodash')

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
StudentAccount   = require (config.get('paths.models') + '/student_account')
TeacherAccount   = require (config.get('paths.models') + '/teacher_account')
Course           = require (config.get('paths.models') + '/course')
Class            = require (config.get('paths.models') + '/class')
serializers      = require(config.get('paths.serializers'))

module.exports = (app) ->
  app.use('/api/v0/guides', router)

addOrRemoveStudent = (isAdd) -> (req, res, next) ->
  studentId = req.params.studentId
  teacherId = req.params.id

  studentCommand = if isAdd then {guide_id: teacherId} else {$unset: {guide_id: true}}
  studentQuery   = if isAdd then {_id: studentId} else {_id: studentId, guide_id: teacherId}

  TeacherAccount.findOne(_id: teacherId, is_guide: true).exec()
    .then (guide) ->
      return controllersUtils.notFound(res) unless guide
      StudentAccount.findOneAndUpdate(studentQuery, studentCommand)
        .exec()
        .then (student) ->
          if student
            res.send
              student_account: serializers.studentAccount(student)
              teacher_account: serializers.teacherAccount(guide)
          else
            controllersUtils.notFound(res)
    .then null, controllersUtils.mongooseErr(res, next)

router
  .get '/', assertSupervisor, (req, res, next) ->
    TeacherAccount.find(is_guide: true).exec()
      .then (guides) ->
        res.send(guides: guides.map(serializers.teacherAccount))
      .then null, next

  .get '/:id', (req, res, next) ->
    TeacherAccount.findOne(_id: req.params.id, is_guide: true).exec()
      .then (guide) ->
        if guide then res.send(guide: serializers.teacherAccount(guide))
        else controllersUtils.notFound(res)
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:id/students', (req, res, next) ->
    TeacherAccount.findOne(_id: req.params.id, is_guide: true).exec()
      .then (guide) ->
        return controllersUtils.notFound(res) unless guide

        StudentAccount.find(guide_id: guide._id).exec()
          .then (students) ->
            res.send
              student_accounts: students.map(serializers.studentAccount)
              teacher_account:  serializers.teacherAccount(guide)
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:guideId/students/:studentId', (req, res, next) ->
    TeacherAccount.findOne(_id: req.params.guideId, is_guide: true).exec()
      .then (teacher) ->
        return controllersUtils.notFound(res) unless teacher
        StudentAccount.findById(req.params.studentId).exec()
          .then (student) ->
            if student
              res.send
                teacher_account: serializers.teacherAccount(teacher)
                student_account: serializers.studentAccount(student)
            else
              controllersUtils.notFound(res)
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:guideId/students/:studentId/classes', (req, res, next) ->
    TeacherAccount.findOne(_id: req.params.guideId, is_guide: true).exec()
      .then (guide) ->
        return controllersUtils.notFound(res) unless guide

        StudentAccount.findById(req.params.studentId).exec()
          .then (student) ->
            return controllersUtils.notFound(res) unless student
            Class.find('students._id': student._id)
              .populate('students._id teacher_id course_id')
              .exec()
              .then (currentCourses) ->
                res.send
                  student_account: serializers.studentAccount(student)
                  teacher_account: serializers.teacherAccount(guide)
                  classes: current: currentCourses.map (klass) ->
                    serializedKlass = serializers.class(klass)
                    studentData = _.find klass.students, (s) ->
                      s._id._id.toString() == student._id.toString()
                    studentInfo = _.pick(studentData, 'attendance', 'grades')

                    _.merge serializedKlass, studentInfo,
                      teacher: serializers.teacherAccount(klass.teacher_id)
                      course:  serializers.course(klass.course_id)
      .then null, controllersUtils.mongooseErr(res, next)

  .put '/:id/students/:studentId/remove', assertSupervisor, addOrRemoveStudent(false)
  .put '/:id/students/:studentId/add', assertSupervisor,    addOrRemoveStudent(true)
