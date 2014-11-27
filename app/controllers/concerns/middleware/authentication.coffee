config = require('config')
logger = require config.get('paths.logger')
_      = require('lodash')
Q      = require('q')

utilsPath = config.get('paths.utils')

controllersUtils = require("#{utilsPath}/controllers")
mongodbUtils     = require("#{utilsPath}/mongodb")
serializers      = require(config.get('paths.serializers'))
security         = require("#{utilsPath}/security")

AccessToken = require("#{config.get('paths.models')}/access_token")

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
        logger.error(err, role: role) if err

module.exports.assertAuthorized = assertAuthorizedMiddleware()

module.exports.assertRecruiter = assertAuthorizedMiddleware('recruiter')
module.exports.assertAdmin     = assertAuthorizedMiddleware('admin')