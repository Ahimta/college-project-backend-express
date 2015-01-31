Immutable = require('immutable')
express   = require('express')
config    = require('config')
logger    = require(config.get('paths.logger'))
router    = express.Router()

assertAuthorized2 = require('./concerns/middleware/authentication').assertAuthorized2
assertSupervisor  = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils  = require (config.get('paths.utils') + '/controllers')
serializers       = require(config.get('paths.serializers'))
validator         = require('./concerns/middleware/validators').studentAlert

StudentAccount = require (config.get('paths.models') + '/student_account')
TeacherAccount = require (config.get('paths.models') + '/teacher_account')
StudentAlert   = require (config.get('paths.models') + '/student_alert')

module.exports = (app) ->
  app.use('/api/v0/student_alerts', router)

router
  .get '/', assertSupervisor, (req, res, next) ->
    StudentAlert.find().populate('student_id teacher_id').exec()
      .then (alerts) ->
        res.send(student_alerts: alerts.map(serializers.studentAlertExpanded))
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:id', assertSupervisor, (req, res, next) ->
    StudentAlert.findById(req.params.id).populate('student_id teacher_id').exec()
      .then (alert) ->
        if alert then res.send(student_alert: serializers.studentAlertExpanded(alert))
        else controllersUtils.notFound(res)
      .then null, controllersUtils.mongooseErr(res, next)

  .post(
    '/:teacherId/:studentId',
    assertAuthorized2([{accountRole: 'teacher', accountIdParam: 'teacherId'}]),
    validator,
    (req, res, next) ->
      TeacherAccount.findById(req.params.teacherId).exec()
        .then (teacher) ->
          return controllersUtils.notFound(res) unless teacher

          StudentAccount.findById(req.params.teacherId).exec().then (student) ->
            return controllersUtils.notFound(res) unless student

            attrs = Immutable.Map(req.form.student_alert).merge
              student_id: student._id
              teacher_id: teacher._id
            StudentAlert.create(attrs.toJSON()).then (alert) ->
              res.send
                student_alert: serializers.studentAlert(alert)
                student:       serializers.studentAccount(student)
                teacher:       serializers.studentAccount(teacher)
        .then null, controllersUtils.mongooseErr(res, next)
  )

  .put(
    '/:teacherId/:studentId/:alertId',
    assertAuthorized2([{accountRole: 'teacher', accountIdParam: 'teacherId'}]),
    validator,
    (req, res, next) ->
      TeacherAccount.findById(req.params.teacherId).exec()
        .then (teacher) ->
          return controllersUtils.notFound(res) unless teacher

          StudentAccount.findById(req.params.studentId).exec().then (student) ->
            return controllersUtils.notFound(res)

            StudentAlert.create(req.form.student_alert).then (alert) ->
              res.send
                student_alert: serializers.studentAlert(alert)
                student:       serializers.studentAccount(student)
                teacher:       serializers.studentAccount(teacher)
        .then null, controllersUtils.mongooseErr(res, next)
  )
