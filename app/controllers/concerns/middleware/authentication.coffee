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

###*
 * @param {Array.<{accountRole: string, accountIdParam: ?string}>} [reqCredentials=[]]
 * @returns Express middleware
 ###
exports.assertAuthorized2 = (reqCredentials=[]) -> (req, res, next) ->

  dbCredentials = reqCredentials.map (credential) ->
    accountIdParam = credential.accountIdParam
    q = {accountRole: credential.accountRole}
    q.accountId = req.params[accountIdParam] if accountIdParam
    q

  accessToken = req.get('X-Access-Token') || req.query.access_token
  mongodbUtils.assertAuthorized(dbCredentials, accessToken)
    .then (result) ->
      res.locals.accountRole = result.accountRole
      res.locals.accountId   = result.accountId
      next()
    .then null, (err) ->
      controllersUtils.unauthorized(res)

      logger.error(err, [reqCredentials, dbCredentials])

exports.assertAuthorized = assertAuthorizedMiddleware()

exports.assertSupervisor = exports.assertAuthorized2([{accountRole: 'supervisor'}])
exports.assertRecruiter  = exports.assertAuthorized2([{accountRole: 'recruiter'}])
exports.assertStudent    = exports.assertAuthorized2([{accountRole: 'student'}])
exports.assertTeacher    = exports.assertAuthorized2([{accountRole: 'teacher'}])
exports.assertAdmin      = exports.assertAuthorized2([{accountRole: 'admin'}])
