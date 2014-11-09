require('coffee-script/register');

var mongoose = require('mongoose'),
    express  = require('express'),
    config   = require('config')
    fs       = require('fs');


mongoose.connect(config.get('db'));
var db = mongoose.connection;
db.on('error', function () {
  throw new Error('unable to connect to database at ' + config.get('db'));
});

var app = module.exports = express();

require('./express/boot')(app, config);

app.listen(process.env.PORT || config.port);

require('./db/seeds');
