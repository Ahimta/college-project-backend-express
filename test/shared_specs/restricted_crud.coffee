supertest = require('supertest')

module.exports = (app, resource, accessToken=null) ->

  agent = supertest(app)

  self = ->
    module.exports(app, resource, accessToken)

  helper = (method, url, description) ->
    ->
      describe description, ->
        it 'should respond with HTTP status 401', (done) ->
          agent[method](url)
            .set('X-Access-Token', accessToken)
            .expect(message: 'Unauthorized', status: 401)
            .expect(401)
            .end(done)

      self()

  destroy:
    helper('delete', "#{resource}/nonesense", "DELETE #{resource}/:id")

  create:
    helper('post', resource, "POST #{resource}")

  update:
    helper('put', "#{resource}/nonesense", "PUT #{resource}/:id")

  index:
    helper('get', resource, "GET #{resource}")

  show:
    helper('get', "#{resource}/nonesense", "GET #{resource}/:id")
