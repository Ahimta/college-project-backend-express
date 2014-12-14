path = require('path');

module.exports = {
  db: {
    database: 'college-project-backend-express-development',
    url: 'mongodb://localhost'
  },
  root: path.resolve('./'),
  ip: 'localhost',
  paths: {
    constructors: path.resolve('./app/constructors'),
    controllers: path.resolve('./app/controllers'),
    serializers: path.resolve('./app/serializers'),
    uploads: path.resolve('./public/uploads'),
    logger: path.resolve('./app/logger'),
    models: path.resolve('./app/models'),
    public: path.resolve('./public'),
    utils: path.resolve('./app/utils'),
    app: path.resolve('./app')
  },
  app: {
    name: 'college-project-backend-express'
  },
  port: 3000
};