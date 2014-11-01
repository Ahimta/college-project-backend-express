form  = require('express-form').configure(dataSources: ['body'], autoTrim: true, flashErrors: false)
field = form.field

validator = (req, res, next) ->
  if req.form.isValid then next()
  else res.status(400).send(req.form.getErrors())


module.exports.jobRequestValidator = [

  form(
    field('job_request.specialization').required().notEmpty(),
    field('job_request.fullname').required().notEmpty(),
    field('job_request.address').required().notEmpty(),
    field('job_request.degree').required().notEmpty(),
    field('job_request.email').required().notEmpty().isEmail(),
    field('job_request.phone').required().notEmpty()
  ),
  validator
]

module.exports.courseValidator = [

  form(
    field('course.name').required().notEmpty(),
    field('course.code').required().notEmpty()
  ),
  validator
]

module.exports.accountValidator = [

  form(
    field('admin_account.username').required().notEmpty(),
    field('admin_account.password').required().notEmpty()
  ),
  validator
]

module.exports.recruiterAccountValidator = [

  form(
    field('recruiter_account.username').required().notEmpty(),
    field('recruiter_account.password').required().notEmpty()
  ),
  validator
]

module.exports.sessionValidator = [

  form(
    field('username').required().notEmpty(),
    field('password').required().notEmpty(),
    field('role').required().notEmpty()
  ),
  validator
]
