require('coffee-script/register');

var child_process = require('child_process'),
    server        = require('gulp-develop-server'),
    mocha         = require('gulp-mocha'),
    gutil         = require('gulp-util'),
    gulp          = require('gulp');

DEV_SRC_GLOBS = [
  'app/{,*/}*.coffee',
  '{gulpfile,app}.js',
  'config/*.coffee'
];

TEST_SRC_GLOBS = [
  'test/{,*/}*.coffee'
];

gulp.task('server:start', function() {
  server.listen({path: 'app.js'});
});

gulp.task('server:restart', function() {
  server.restart();
});

gulp.task('test', function() {

  child_process.exec('NODE_ENV=test npm test', function (err, stdout, stderr) {
    console.log(stderr);
    console.log(stdout);
  });
});

gulp.task('watch', ['server:start', 'test'], function() {

  gulp.watch(DEV_SRC_GLOBS.concat(TEST_SRC_GLOBS), ['server:restart', 'test']);
});

gulp.task('default', ['watch']);
