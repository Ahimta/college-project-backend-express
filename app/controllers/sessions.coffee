router = require('express').Router()

assertAuthorized = require('./concerns/middleware/authentication').assertAuthorized
sessionValidator = require('./concerns/middleware/validators').sessionValidator
loginMiddleware  = require('./concerns/middleware/authentication').loginMiddleware

AccessToken = require('../models/access_token')

module.exports = (app) ->
  app.use('/api/v0/sessions', router)

router
  .post '/', sessionValidator, loginMiddleware, (req, res, next) ->

    locals = res.locals

    response =
      account_role: locals.accountRole
      access_token: locals.accessToken
      account: locals.account

    res.cookie('accessToken', locals.accessToken)
    res.status(201).send(response)

  .delete '/:id', assertAuthorized, (req, res, next) ->
    AccessToken.findByIdAndRemove(req.params.id).exec()
      .then (tokenRecord) ->
        if tokenRecord
          res.clearCookie('accessToken')
          res.status(200).end()
        else res.status(404).send(message: 'Not Found', status: 404)
      .then null, next

    .delete '/', (req, res, next) ->
      res.clearCookie('accessToken')
      res.status(200).end()
