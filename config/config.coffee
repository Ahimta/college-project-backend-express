path     = require 'path'
rootPath = path.normalize __dirname + '/..'
env      = process.env.NODE_ENV || 'development'

config =
  development:
    root: rootPath
    app:
      name: 'college-project-backend-express'
    port: 3000
    db: 'mongodb://localhost/college-project-backend-express-development'


  test:
    root: rootPath
    app:
      name: 'college-project-backend-express'
    port: 3001
    db: 'mongodb://localhost/college-project-backend-express-test'


  production:
    root: rootPath
    app:
      name: 'college-project-backend-express'
    port: 3000
    db: 'mongodb://localhost/college-project-backend-express-production'


module.exports = config[env]
