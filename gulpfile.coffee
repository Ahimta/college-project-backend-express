child_process = require('child_process')
server        = require('gulp-develop-server')
mocha         = require('gulp-mocha')
gutil         = require('gulp-util')
gulp          = require('gulp')

globs = [
  'app/**/*.coffee'
  '*.{coffee,json,js}'
  'config/*.coffee'
  'test/**/*.coffee'
]

gulp.task 'server:start', ->
  server.listen(path: 'app.js')

gulp.task 'server:restart', ->
  server.restart()

gulp.task 'test', ->

  child_process.exec 'npm test', (err, stdout, stderr) ->
    console.log(stderr)
    console.log(stdout)

gulp.task 'watch', ['server:start', 'test'], ->

  gulp.watch(globs, ['server:restart', 'test'])

gulp.task('default', ['watch'])
