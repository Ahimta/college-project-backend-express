Immutable = require('immutable')
express   = require('express')
config    = require('config')
logger    = require(config.get('paths.logger'))
router    = express.Router()
_         = require('lodash')

assertAuthorized2 = require('./concerns/middleware/authentication').assertAuthorized2
assertAccessToken = assertAuthorized2()
controllersUtils  = require (config.get('paths.utils') + '/controllers')
serializers       = require(config.get('paths.serializers'))
validator         = require('./concerns/middleware/validators').studentAlert

StudentAccount = require (config.get('paths.models') + '/student_account')
TeacherAccount = require (config.get('paths.models') + '/teacher_account')
StudentAlert   = require (config.get('paths.models') + '/student_alert')

module.exports = (app) ->
  app.use('/api/v0/student_accounts', router)

router
  .get '/:studentId/alerts', assertAccessToken, (req, res, next) ->

    StudentAccount.findById(req.params.studentId).exec()
      .then (student) ->

        return controllersUtils.notFound(res) unless student

        TeacherAccount.findOne({_id: student.guide_id, is_guide: true}).exec().then (teacher) ->

          StudentAlert.find({student_id: student._id})
            .populate('student_id teacher_id')
            .exec()
            .then (alerts) ->

              {accountRole, accountId} = res.locals
              isAuthorizedStudent = accountRole == 'student' and accountId == student._id
              isAuthorizedTeacher = teacher and accountRole == 'teacher' and _.isEqual(accountId, teacher._id)
              isSupervisor        = accountRole == 'supervisor'
              console.log(teacher._id, accountId)

              if isAuthorizedStudent or isAuthorizedTeacher or isSupervisor
                res.send
                  student_account: serializers.studentAccount(student)
                  student_alerts: alerts.map(serializers.studentAlertExpanded)
              else
                controllersUtils.unauthorized(res)

      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:studentId/alerts/:id', assertAccessToken, (req, res, next) ->

    StudentAccount.findById(req.params.studentId).exec()
      .then (student) ->
        return controllersUtils.notFound(res) unless student

        TeacherAccount.findOne({_id: student.guide_id, is_guide: true}).exec().then (teacher) ->

          StudentAlert.findOne({_id: req.params.id, student_id: student._id})
            .populate('student_id teacher_id')
            .exec()
            .then (alert) ->

              {accountRole, accountId} = res.locals
              isAuthorizedStudent = accountRole == 'student' and accountId == student.id
              isAuthorizedTeacher = teacher and accountRole == 'teacher' and _.isEqual(accountId, teacher._id)
              isSupervisor        = accountRole == 'supervisor'

              if isAuthorizedStudent or isAuthorizedTeacher or isSupervisor
                res.send
                  student_account: serializers.studentAccount(student)
                  student_alert:   serializers.studentAlertExpanded(alert)
              else
                controllersUtils.unauthorized(res)

      .then null, controllersUtils.mongooseErr(res, next)

  .post '/:studentId/alerts/', assertAccessToken, validator, (req, res, next) ->

    StudentAccount.findById(req.params.studentId).exec()
      .then (student) ->

        return controllersUtils.notFound(res) unless student

        TeacherAccount.findOne({_id: student.guide_id, is_guide: true}).exec().then (teacher) ->

          {accountRole, accountId} = res.locals
          isAuthorizedTeacher = teacher and accountRole == 'teacher' and _.isEqual(accountId, teacher._id)

          return controllersUtils.unauthorized(res) unless isAuthorizedTeacher

          attrs = Immutable.Map(req.form.student_alert).merge
            student_id: student._id
            teacher_id: teacher._id

          StudentAlert.create(attrs.toJS()).exec().then (alert) ->
            res.send
              student_account: serializers.studentAccount(student)
              teacher_account: serializers.teacherAccount(teacher)
              student_alert:   serializers.studentAlert(alert)

      .then null, controllersUtils.mongooseErr(res, next)

  .put '/:studentId/alerts/:id', assertAccessToken, validator, (req, res, next) ->

    StudentAccount.findById(req.params.studentId).exec()
      .then (student) ->

        return controllersUtils.notFound(res) unless student

        TeacherAccount.findOne({_id: student.guide_id, is_guide: true}).exec().then (teacher) ->

          {accountRole, accountId} = res.locals
          isAuthorizedTeacher = teacher and accountRole == 'teacher' and _.isEqual(accountId, teacher._id)

          return controllersUtils.unauthorized(res) unless isAuthorizedTeacher

          attrs = Immutable.Map(req.form.student_alert).merge
            student_id: student._id
            teacher_id: teacher._id

          StudentAlert.findByIdAndUpdate(req.params.id, attrs.toJS()).exec().then (alert) ->
            res.send
              student_account: serializers.studentAccount(student)
              teacher_account: serializers.teacherAccount(teacher)
              student_alert:   serializers.studentAlert(alert)

      .then null, controllersUtils.mongooseErr(res, next)

  .delete '/:studentId/alerts/:id', assertAccessToken, (req, res, next) ->

    StudentAccount.findById(req.params.studentId).exec()
      .then (student) ->

        return controllersUtils.notFound(res) unless student

        TeacherAccount.findOne({_id: student.guide_id, is_guide: true}).exec().then (teacher) ->

          {accountRole, accountId} = res.locals
          isAuthorizedTeacher = teacher and accountRole == 'teacher' and _.isEqual(accountId, teacher._id)

          return controllersUtils.unauthorized(res) unless isAuthorizedTeacher

          StudentAlert.findByIdAndRemove(req.params.id).exec().then (alert) ->
            res.send
              student_account: serializers.studentAccount(student)
              teacher_account: serializers.teacherAccount(teacher)
              student_alert:   serializers.studentAlert(alert)

      .then null, controllersUtils.mongooseErr(res, next)
