var path = require('path');

module.exports = {
  db: 'mongodb://localhost/college-project-backend-express-development',
  port: 3001,
  paths: {
    factories: path.resolve('./test/resources/factories'),
    fixtures: path.resolve('./test/fixtures')
  }
};