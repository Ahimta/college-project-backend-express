form  = require('express-form').configure(dataSources: ['body'], autoTrim: true, flashErrors: false)
field = form.field

makeValidator = (validator) ->
  [
    validator,
    (req, res, next) ->
      if req.form.isValid then next()
      else res.status(400).send(req.form.getErrors())
  ]

makeAccountable = (name, fields=[]) ->
  defaultFields = [
    field(name + '.username').required().notEmpty().toLower()
    field(name + '.password').required().notEmpty()
  ]

  allFields = defaultFields.concat(fields)
  finalForm = form(allFields...)
  makeValidator finalForm

module.exports.jobRequest = makeValidator form(
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

module.exports.course = makeValidator form(
  field('course.name').required().notEmpty(),
  field('course.code').required().notEmpty())

module.exports.supervisorAccount = makeAccountable('supervisor_account')
module.exports.recruiterAccount  = makeAccountable('recruiter_account')
module.exports.studentAccount    = makeAccountable('student_account')
module.exports.adminAccount      = makeAccountable('admin_account')

module.exports.session = makeValidator form(
  field('username').required().notEmpty(),
  field('password').required().notEmpty(),
  field('role').required().notEmpty())
