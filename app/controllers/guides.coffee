express = require('express')
config  = require('config')
router  = express.Router()

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
StudentAccount   = require (config.get('paths.models') + '/student_account')
TeacherAccount   = require (config.get('paths.models') + '/teacher_account')
Course           = require (config.get('paths.models') + '/course')
Class            = require (config.get('paths.models') + '/class')
serializers      = require(config.get('paths.serializers'))

module.exports = (app) ->
  app.use('/api/v0/guides', router)

addOrRemoveStudent = (add) -> (req, res, next) ->
  studentId = req.params.studentId
  teacherId = req.params.id

  studentCommand = if add then {guide_id: teacherId} else {$unset: {guide_id: true}}
  studentQuery   = if add then {_id: studentId} else {_id: studentId, guide_id: teacherId}

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
    teacherId = req.params.id

    TeacherAccount.findOne(_id: teacherId, is_guide: true).exec()
      .then (guide) ->
        return controllersUtils.notFound(res) unless guide

        StudentAccount.find(guide_id: teacherId).exec()
          .then (students) ->
            res.send
              student_accounts: students.map(serializers.studentAccount)
              teacher_account: serializers.teacherAccount(guide)
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
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:guideId/students/:studentId/classes', (req, res, next) ->
    TeacherAccount.findOne(_id: req.params.guideId, is_guide: true).exec()
      .then (teacher) ->
        return controllersUtils.notFound(res) unless teacher
        StudentAccount.findById(req.params.studentId).exec()
          .then (student) ->
            return controllersUtils.notFound(res) unless student
            Class.find('students._id': student._id)
              .populate('students._id teacher_id course_id')
              .exec()
              .then (currentCourses) ->
                Class.find('students._id': {$ne: student._id})
                .populate('students._id teacher_id course_id')
                .exec()
                  .then (nonCurrentCourses) ->
                    res.send
                      student_account: serializers.studentAccount(student)
                      teacher_account: serializers.teacherAccount(teacher)
                      classes:
                        not_current: nonCurrentCourses.map(serializers.classExpanded)
                        current: currentCourses.map(serializers.classExpanded)
              .then null, controllersUtils.mongooseErr(res, next)
          .then null, controllersUtils.mongooseErr(res, next)
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:guideId/students/:studentId/courses', (req, res, next) ->
    TeacherAccount.findOne(_id: req.params.guideId, is_guide: true).exec()
      .then (teacher) ->
        return controllersUtils.notFound(res) unless teacher
        StudentAccount.findById(req.params.studentId).exec()
          .then (student) ->
            return controllersUtils.notFound(res) unless student
            Course.find({_id: {$in: student.courses_ids}}).exec()
              .then (currentCourses) ->
                Course.find(_id: {$nin: student.courses_ids}).exec()
                  .then (nonCurrentCourses) ->
                    res.send
                      student_account: serializers.studentAccount(student)
                      teacher_account: serializers.teacherAccount(teacher)
                      courses:
                        not_current: nonCurrentCourses.map(serializers.course)
                        current: currentCourses.map(serializers.course)
              .then null, controllersUtils.mongooseErr(res, next)
          .then null, controllersUtils.mongooseErr(res, next)
      .then null, controllersUtils.mongooseErr(res, next)

  .put '/:id/students/:studentId/remove', addOrRemoveStudent(false)
  .put '/:id/students/:studentId/add', addOrRemoveStudent(true)
