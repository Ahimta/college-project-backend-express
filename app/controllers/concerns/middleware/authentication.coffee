_ = require('lodash')
Q = require('q')

controllersUtils = require('../../../utils/controllers')
mongodbUtils     = require('../../../utils/mongodb')
serializers      = require('../../../serializers')
security         = require('../../../utils/security')

AccessToken = require('../../../models/access_token')

assertAuthorizedMiddleware = (role=null) ->

  (req, res, next) ->
    accessToken = req.query.access_token || req.get('X-Access-Token') || req.cookies.accessToken

    mongodbUtils.assertAccessToken(accessToken, role)
      .then (result) ->
        res.locals.tokenObject = result.tokenObject
        res.locals.account     = serializers.account(result.account)
        res.locals.role        = result.tokenObject.user_role
        next()
      .then null, (err) ->
        controllersUtils.unauthorized(res)


module.exports.loginMiddleware = (req, res, next) ->
  mongodbUtils.login(req.body.role, req.body.username, req.body.password)
    .then (result) ->
      res.locals.accessToken = result.accessToken
      res.locals.accountRole = result.accountRole
      res.locals.account     = serializers.account(result.account)
      next()
    .then null, (reason) ->
      controllersUtils.unauthorized(res)


module.exports.assertAuthorized = assertAuthorizedMiddleware()

module.exports.assertRecruiter = assertAuthorizedMiddleware('recruiter')
module.exports.assertAdmin     = assertAuthorizedMiddleware('admin')