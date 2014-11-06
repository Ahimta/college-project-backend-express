mongoose = require('mongoose')
express  = require('express')
Busboy = require('busboy')
mkdirp = require('mkdirp')
fs     = require('fs')
Q      = require('q')

JobRequest = mongoose.model('JobRequest')
router     = express.Router()

jobRequestValidator = require('./concerns/middleware/validators').jobRequestValidator
controllersUtils    = require('../utils/controllers')
assertRecruiter     = require('./concerns/middleware/authentication').assertRecruiter
simpleCrud          = require('./concerns/shared_controllers/simple_crud')

constructor = require('../constructors').jobRequest
serializer  = require('../serializers').jobRequest

UPLOADS_PATH = process.env.CLOUD_DIR || './public/uploads'

module.exports = (app) ->
  app.use('/api/v0/job_requests', router)

simpleCrud(router, JobRequest, 'job_requests', serializer, constructor)
  .destroy(assertRecruiter)
  .create([jobRequestValidator])
  .update([assertRecruiter, jobRequestValidator])
  .index(assertRecruiter)
  .show(assertRecruiter)

decide = (decision) ->
  (req, res, next) ->
    JobRequest.findByIdAndUpdate(req.params.id, status: decision).exec()
      .then (jobRequest) ->
        if jobRequest
          res.send(job_request: serializer(jobRequest))
        else
          controllersUtils.notFound(res)
      .then null, next


router.put '/:id/accept', decide('accepted')
router.put '/:id/reject', decide('rejected')

router.get '/:id/files/:fileName', (req, res, next) ->
  JobRequest.findById(req.params.id).exec()
    .then (jobRequest) ->
      if jobRequest
        res.download("#{UPLOADS_PATH}/job_requests/#{jobRequest.id}/#{req.params.fileName}")
      else
        controllersUtils.notFound(res) unless jobRequest

    .then null, (err) ->
      if err.name == 'CastError' then controllersUtils.notFound(res)
      else next(err)

router.put '/:id/files', (req, res, next) ->

  jobRequestId = req.params.id

  JobRequest.findById(jobRequestId).exec()
    .then (jobRequest) ->
      if jobRequest
        busboy = new Busboy(headers: req.headers)

        busboy.on 'file', (fieldName, file, fileName, encoding, mimeType) ->
          folderPath = "#{UPLOADS_PATH}/job_requests/#{jobRequestId}"

          Q.nfapply(mkdirp, [folderPath])
            .then (__) ->
              filePath = "#{folderPath}/#{fileName}"
              file.pipe(fs.createWriteStream(filePath))
            .then null, next

          file.on 'end', ->
            jobRequest.update({$addToSet: {files: fileName}}).exec().then null, next

        busboy.on 'finish', ->
          JobRequest.findById(jobRequestId).exec()
            .then (newJobRequest) ->
              res.send(job_request: serializer(newJobRequest))
            .then null, next

        req.pipe(busboy)
      else
        controllersUtils.notFound(res)
    .then null, (err) ->
      if err.name == 'CastError' then controllersUtils.notFound(res)
      else next(err)