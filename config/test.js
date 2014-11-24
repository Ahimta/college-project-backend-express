var path = require('path');

module.exports = {
  db: 'mongodb://localhost/college-project-backend-express-test',
  port: 3001,
  paths: {
    factories: path.resolve('./test/resources/factories'),
    fixtures: path.resolve('./test/fixtures'),
    log: path.resolve('./log/test.log')
  }
};