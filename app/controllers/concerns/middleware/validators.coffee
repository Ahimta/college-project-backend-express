form  = require('express-form').configure(dataSources: ['body'], autoTrim: true, flashErrors: false)
field = form.field

makeValidator = (validator) ->
  [
    validator,
    (req, res, next) ->
      if req.form.isValid then next()
      else res.status(400).send(req.form.getErrors())
  ]

makeAccountable = (name, fields=[], update=false) ->
  defaultFields = [
    field(name + '.username').required().notEmpty().toLower()
    field(name + '.password')
    field(name + '.fullname')
    field(name + '.phone')
    field(name + '.email')
  ]

  allFields = defaultFields.concat(fields)
  finalForm = form(allFields...)
  makeValidator finalForm

exports.jobRequest = makeValidator form(
  field('job_request.specialization').required().notEmpty(),
  field('job_request.fullname').required().notEmpty(),
  field('job_request.address').required().notEmpty(),
  field('job_request.degree').required().notEmpty(),
  field('job_request.email').required().notEmpty().isEmail(),
  field('job_request.phone').required().notEmpty(),

  field('job_request.highschool_location').required().notEmpty(),
  field('job_request.current_location').required().notEmpty(),
  field('job_request.highschool_name').required().notEmpty(),
  field('job_request.university').required().notEmpty(),
  field('job_request.id_num').required().notEmpty(),
  field('job_request.job').required().notEmpty())

exports.class = makeValidator form(
  field('class.teacher_id').required().notEmpty(),
  field('class.course_id').required().notEmpty(),
  field('class.name').required().notEmpty())

exports.course = makeValidator form(
  field('course.name').required().notEmpty(),
  field('course.code').required().notEmpty())

exports.supervisorAccount = makeAccountable('supervisor_account')
exports.recruiterAccount  = makeAccountable('recruiter_account')
exports.studentAccount    = makeAccountable 'student_account',
  [
    field('student_account.collegial_number')
    field('student_account.specialization')
  ]
exports.teacherAccount    = makeAccountable 'teacher_account',
  [
    field('teacher_account.specialization')
    field('teacher_account.is_guide')
  ]
exports.adminAccount      = makeAccountable('admin_account')

exports.session = makeValidator form(
  field('username').required().notEmpty(),
  field('password').required().notEmpty(),
  field('role').required().notEmpty())
