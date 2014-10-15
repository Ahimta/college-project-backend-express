supertest = require('supertest')
_         = require('lodash')

module.exports = (app, resource, access_token=null) ->

  agent = supertest(app)

  self = ->
    module.exports(app, resource, access_token)

  helper = (method, url, description) ->
    ->
      describe description, ->
        it '', (done) ->
          agent[method](url)
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
