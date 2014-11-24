require('coffee-script/register');

var mongoose = require('mongoose'),
    express  = require('express'),
    config   = require('config'),
    fse      = require('fs-extra'),
    fs       = require('fs');

fse.ensureFile(config.get('paths.log'));

mongoose.connect(config.get('db'));
var db = mongoose.connection;
db.on('error', function () {
  throw new Error('unable to connect to database at ' + config.get('db'));
});

var app = module.exports = express();

require('./express/boot')(app);

app.listen(config.get('port'));

require('./db/seeds');