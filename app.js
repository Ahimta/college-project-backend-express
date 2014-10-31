require('coffee-script/register');

var mongoose = require('mongoose'),
    express  = require('express'),
    config   = require('./config/config'),
    fs       = require('fs');


mongoose.connect(config.db);
var db = mongoose.connection;
db.on('error', function () {
  throw new Error('unable to connect to database at ' + config.db);
});

var modelsPath = __dirname + '/app/models';
fs.readdirSync(modelsPath).forEach(function (file) {
  if (/\.coffee$/.test(file)) {
    require(modelsPath + '/' + file);
  }
});

var app = module.exports = express();

require('./config/express')(app, config);

app.listen(process.env.PORT || config.port);

require('./db/seeds');
