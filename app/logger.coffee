winston = require('winston')
config  = require('config')

module.exports = new winston.Logger
  transports: [
    new winston.transports.File filename: config.get('paths.log')
    new winston.transports.Console()
  ]