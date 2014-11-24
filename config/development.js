var path = require('path');

module.exports = {
  db: 'mongodb://localhost/college-project-backend-express-development',
  port: 3000,
  paths: {
    log: path.resolve('./log/test.log')
  }
};