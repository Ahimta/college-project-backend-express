form  = require('express-form').configure(dataSources: ['body'], autoTrim: true, flashErrors: false)
field = form.field

module.exports.jobRequestValidator = (->

  jobRequestForm = form(
    field('job_request.specialization').required().notEmpty(),
    field('job_request.fullname').required().notEmpty(),
    field('job_request.address').required().notEmpty(),
    field('job_request.degree').required().notEmpty(),
    field('job_request.email').required().notEmpty().isEmail(),
    field('job_request.phone').required().notEmpty()
  )

  validator = (req, res, next) ->
    if req.form.isValid then next()
    else res.status(400).send(req.form.getErrors())

  [jobRequestForm, validator]
)()

module.exports.courseValidator = (->

  courseForm = form(
    field('course.name').required().notEmpty(),
    field('course.code').required().notEmpty()
  )
)()

module.exports.accountCreateValidator = (->

  adminAccountForm = form(
    field('access_token').required().notEmpty()
    field('admin_account.username').required().notEmpty(),
    field('admin_account.password').required().notEmpty(),
    field('admin_account.email').isEmail()
  )
)()

module.exports.accountUpdateValidator = (->

  adminAccountForm = form(
    field('access_token').required().notEmpty()
    field('admin_account.username').required().notEmpty(),
    field('admin_account.email').isEmail()
  )
)()
