express = require('express')
config  = require('config')
router  = express.Router()

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
TeacherAccount   = require (config.get('paths.models') + '/teacher_account')
simpleCrud       = require('./concerns/shared_controllers/simple_crud')
validator        = require('./concerns/middleware/validators').teacherAccount

constructor = require(config.get('paths.constructors')).teacherAccount
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

  .put '/:id/add_to_guides', assertSupervisor, addOrRemoveGuide(true)
  .put '/:id/remove_from_guides', assertSupervisor, addOrRemoveGuide(false)

simpleCrud(router, TeacherAccount, 'teacher_accounts', serializer, constructor)
  .destroy(assertSupervisor)
  .create([assertSupervisor, validator])
  .update([assertSupervisor, validator])
  .index(assertSupervisor)
  .show(assertSupervisor)
