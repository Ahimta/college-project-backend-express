config = require('config')
router = require('express').Router()
logger = require config.get('paths.logger')
_      = require('lodash')

assertAuthorized = require('./concerns/middleware/authentication').assertAuthorized
sessionValidator = require('./concerns/middleware/validators').session

controllersUtils = require config.get('paths.utils') + '/controllers'
mongodbUtils     = require config.get('paths.utils') + '/mongodb'
serializers      = require config.get('paths.serializers')

AccessToken = require(config.get('paths.models') + '/access_token')

module.exports = (app) ->
  app.use('/api/v0/sessions', router)

router
  .post '/', sessionValidator, (req, res, next) ->

    mongodbUtils.login(req.form.role, req.form.username, req.form.password)
      .then (result) ->
        jsonResponse =
          access_token: result.accessToken
          account_role: result.accountRole
          account: serializers.account(result.account)

        res.status(201).send(jsonResponse)
      .then null, (err) ->
        controllersUtils.unauthorized(res)
        if err
          metadata = _.pick(req.form, 'role', 'username')
          logger.error(err, metadata)


  .delete '/current', (req, res, next) ->
    res.status(200).end()

  .delete '/:id', assertAuthorized, (req, res, next) ->

    AccessToken.findByIdAndRemove(req.params.id).exec()
      .then (tokenRecord) ->
        if tokenRecord then res.status(200).end()
        else controllersUtils.notFound(res)
      .then null, controllersUtils.mongooseErr(res, next)

  .get '/current', assertAuthorized, (req, res, next) ->
    res.send
      account_role: res.locals.role
      account: res.locals.account
