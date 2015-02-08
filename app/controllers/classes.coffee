express = require('express')
config  = require('config')
logger  = require config.get('paths.logger')
router  = express.Router()
_       = require('lodash')

assertSupervisor = require('./concerns/middleware/authentication').assertSupervisor
controllersUtils = require (config.get('paths.utils') + '/controllers')
simpleCrud       = require('./concerns/shared_controllers/simple_crud')
validator        = require('./concerns/middleware/validators').class

Teacher = require (config.get('paths.models') + '/teacher_account')
Student = require (config.get('paths.models') + '/student_account')
Class   = require (config.get('paths.models') + '/class')

constructor = require(config.get('paths.constructors')).class
serializers = require(config.get('paths.serializers'))

module.exports = (app) ->
  app.use('/api/v0/classes', router)

router
  .get '/', (req, res, next) ->
    return next() unless req.query.expand
    Class.find().populate('teacher_id course_id students._id').exec()
      .then (classes) ->
        res.send
          classes: classes.map(serializers.classExpanded)
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:id', assertSupervisor, (req, res, next) ->
    return next() unless req.query.expand
    Class.findById(req.params.id)
      .populate('students._id teacher_id course_id')
      .exec()
      .then (klass) ->
        if klass and klass.teacher_id and klass.course_id
          res.send
            students: klass.students.map(serializers.classStudent)
            teacher:  serializers.teacherAccount(klass.teacher_id)
            course:   serializers.course(klass.course_id)
            class:    serializers.class(klass)
        else
          controllersUtils.notFound(res)
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:id/teacher', assertSupervisor, (req, res, next) ->
    Class.findById(req.params.id).exec()
      .then (klass) ->
        return controllersUtils.notFound(res) unless klass
        Teacher.findById(klass.teacher_id).exec()
          .then (teacher) ->
            if teacher
              res.send
                teacher_account: serializers.teacherAccount(teacher)
                class:           serializers.class(klass)
            else
              controllersUtils.notFound(res)
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/:id/students', assertSupervisor, (req, res, next) ->
    Class.findById(req.params.id)
      .populate('students._id')
      .exec()
      .then (klass) ->
        return controllersUtils.notFound(res) unless klass

        studentsIds = _.map klass.students, (student) ->
          student._id._id.toString()
        currentStudents = klass.students

        Student.find(_id: {$nin: studentsIds}).exec()
          .then (notCurrentStudents) ->
            console.log klass
            res.send
              class: serializers.class(klass)
              students:
                not_current: notCurrentStudents.map(serializers.studentAccount)
                current:     currentStudents.map(serializers.classStudent)
      .then null, controllersUtils.mongooseErr(res, next)

simpleCrud(router, Class, 'classes', serializers.class, constructor)
  .destroy(assertSupervisor)
  .create([assertSupervisor, validator])
  .update([assertSupervisor, validator])
  .index(assertSupervisor)
  .show(assertSupervisor)
