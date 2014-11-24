config = require('config')

serializers = require config.get('paths.serializers')
logger      = require config.get('paths.logger')
fse         = require('fs-extra')

module.exports.jobRequest =
  afterRemove: (jobRequest) ->
    folderPath = "#{config.get('paths.uploads')}/job_requests/#{jobRequest.id}"
    fse.remove folderPath, (err) ->
      logger.error err, serializers.jobRequest(jobRequest) if err