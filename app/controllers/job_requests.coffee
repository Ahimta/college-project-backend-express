Busboy = require('busboy')
fs     = require('fs')

JobRequest = require('mongoose').model('JobRequest')
router     = require('express').Router()

jobRequestValidator = require('./concerns/middleware/validators').jobRequestValidator
controllersUtils    = require('../utils/controllers')
assertRecruiter     = require('./concerns/middleware/authentication').assertRecruiter
simpleCrud          = require('./concerns/shared_controllers/simple_crud')

constructor = require('../constructors').jobRequest
serializer  = require('../serializers').jobRequest

module.exports = (app) ->
  app.use('/api/v0/job_requests', router)

simpleCrud(router, JobRequest, 'job_requests', serializer, constructor)
  .destroy(assertRecruiter)
  .create([jobRequestValidator])
  .update([assertRecruiter, jobRequestValidator])
  .index(assertRecruiter)
  .show(assertRecruiter)

router.put '/:id/files', (req, res, next) ->

  jobRequestId = req.params.id

  JobRequest.findById(jobRequestId).exec()
    .then (jobRequest) ->
      if jobRequest
        busboy = new Busboy(headers: req.headers)

        busboy.on 'file', (fieldName, file, fileName, encoding, mimeType) ->
          path = "./public/uploads/#{jobRequestId}/#{fieldName}"
          file.pipe(fs.createWriteStream(path))
          file.on 'end', ->
            jobRequest.update({$addToSet: {files: fieldName}}).exec()

        busboy.on 'finish', ->
          res.send(job_request: serializer(jobRequest))

        req.pipe(busboy)
      else
        controllersUtils.notFound(res)
    .then null, (err) ->
      if err.name == 'CastError' then controllersUtils.notFound(res)
      else next(err)

router.put '/x/upload', (req, res, next) ->
  console.log req.headers
  busboy = new Busboy(headers: req.headers)

  busboy.on 'file', (fieldName, file, fileName, encoding, mimeType) ->
    console.log fieldName, fileName
    path = './public/uploads/' + fileName
    file.pipe(fs.createWriteStream(path))

  busboy.on 'field', (fieldname, val, fieldnameTruncated, valTruncated) ->
    console.log fieldname, val, fieldnameTruncated, valTruncated

  busboy.on 'finish', ->
    res.send('Niceeeeeeeeeeeeeeee' + "\n")

  req.pipe(busboy)