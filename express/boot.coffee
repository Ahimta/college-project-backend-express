express = require 'express'
config  = require 'config'
fs      = require 'fs'

bodyParser     = require 'body-parser'
compress       = require 'compression'
logger         = require 'morgan'
cors           = require 'cors'

module.exports = (app) ->

  corsMiddleware = cors
    credentials: true
    origin: true

  app.use logger('dev')
  app.use corsMiddleware
  app.use bodyParser.json()
  app.use compress()
  app.use express.static config.get('paths.public')

  controllersPath = config.get('paths.controllers')
  fs.readdirSync(controllersPath).forEach (file) ->
    if file.indexOf('.coffee') >= 0
      require(controllersPath + '/' + file)(app)

  # catch 404 and forward to error handler
  app.use (req, res, next) ->
    err        = new Error('Not Found')
    err.status = 404
    next(err)

  # error handlers
  app.use (err, req, res, next) ->
    res.status(err.status || 500)
    next(err)

  # development error handler
  # will print stacktrace
  if app.get('env') == 'development'
    app.use (err, req, res, next) ->
      res.send(code: err.code, name: err.name, message: err.message, status: err.status, stack: err.stack)

  # production error handler
  # no stacktraces leaked to user
  app.use (err, req, res, next) ->
    res.send(message: err.message, status: err.status)
