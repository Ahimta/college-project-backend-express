config = require('config')
logger = require config.get('paths.logger')

controllersUtils = require (config.get('paths.utils') + '/controllers')
mongodbUtils     = require (config.get('paths.utils') + '/mongodb')
serializers      = require config.get('paths.serializers')
security         = require (config.get('paths.utils') + '/security')

AccessToken = require (config.get('paths.models') + '/access_token')

assertAuthorizedMiddleware = (role=null, userId=null) -> (req, res, next) ->
  accessToken = req.get('X-Access-Token') || req.query.access_token

  mongodbUtils.assertAccessToken(accessToken, role, userId)
    .then (result) ->
      res.locals.tokenObject = result.tokenObject
      res.locals.account     = serializers.account(result.account)
      res.locals.role        = result.tokenObject.user_role
      next()
    .then null, (err) ->
      controllersUtils.unauthorized(res)
      logger.error(err, role: role)

module.exports.assertAuthorized = assertAuthorizedMiddleware()

module.exports.assertSupervisor = assertAuthorizedMiddleware('supervisor')
module.exports.assertRecruiter  = assertAuthorizedMiddleware('recruiter')
module.exports.assertStudent    = assertAuthorizedMiddleware('student')
module.exports.assertTeacher    = assertAuthorizedMiddleware('teacher')
module.exports.assertAdmin      = assertAuthorizedMiddleware('admin')
