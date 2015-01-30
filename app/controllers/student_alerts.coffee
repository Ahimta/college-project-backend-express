Immutable = require('immutable')
express   = require('express')
config    = require('config')
logger    = require(config.get('paths.logger'))
router    = express.Router()

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
serializers      = require(config.get('paths.serializers'))
validator        = require('./concerns/middleware/validators').studentAlert

StudentAlert = require (config.get('paths.models') + '/student_alert')

module.exports = (app) ->
  app.use('/api/v0/student_alerts', router)

router
  .get '/', assertSupervisor, (req, res, next) ->
    StudentAlert.find().populate('student_id teacher_id').exec()
      .then (alerts) ->
        res.send(alerts: alerts.map(serializers.studentAlertExpanded))
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:id', assertSupervisor, (req, res, next) ->
    StudentAlert.findById(req.params.id).populate('student_id teacher_id').exec()
      .then (alert) ->
        if alert then res.send(alert: serializers.studentAlert(alert))
        else controllersUtils.notFound(res)
      .then null, controllersUtils.mongooseErr(res, next)

