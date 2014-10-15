supertest = require('supertest')
_         = require('lodash')

expect = require('chai').expect

expectedContentType = 'application/json; charset=utf-8'

expectCbs =
  badRequest: (response, invalidRecord) ->
    expect(response.body).to.have.keys(invalidRecord.errorKeys)

  notFound: (response) ->
    expect(response.body).to.have.keys(['message', 'status'])
    ''

module.exports = (app, resource, model, samples, token=null) ->

  agent = supertest(app)
  name  = _.last(resource.split('/'))[0...-1]

  self  = ->
    module.exports(app, resource, model, samples)

  getRequestBody = (obj) ->
    requestBody       = {}
    requestBody[name] = obj

    requestBody

  getResponseCollection = (collection) ->
    responseBody             = {}
    responseBody[name + 's'] = collection

    responseBody

  hooks =
    resetCollection: (done) ->
      model.collection.remove(done)

    expectLessCount: (that, done) ->
        model.count (err, count) ->
          expect(count).to.equal(that.count - 1)
          done()

    expectSameCount: (that, done) ->
        model.count (err, count) ->
          expect(count).to.equal(that.count)
          done()

    assingCount: (that, done) ->
      model.count (err, count) ->
        that.count = count
        done()

    create: (that, done) ->
      model.create samples.valid[0][name], (err, record) ->
        if err then throw err
        else
          that.record = _.merge(record.toJSON(), _id: record._id.toString())
          done()

  destroy: ->
    describe "DELETE #{resource}/:id", ->

      before hooks.resetCollection

      before (done) ->
        hooks.create(@, done)

      before (done) ->
        hooks.assingCount(@, done)

      before (done) ->
        hooks.expectSameCount(@, done)

      after hooks.resetCollection

      describe 'does not exist', ->
        after (done) ->
          hooks.expectSameCount(@, done)

        it '', (done) ->
          agent
            .delete('#{resource}/nonesense')
            .expect('Content-Type', expectedContentType)
            .expect(404)
            .expect(expectCbs.notFound)
            .end(done)

      describe 'exists', ->
        after (done) ->
          hooks.expectLessCount(@, done)

        it '', (done) ->
          agent
            .delete("#{resource}/#{@record._id}")
            .expect('Content-Type', expectedContentType)
            .expect(200)
            .expect (response) =>
              expect(response.body[name]).to.eql(@record)
              ""
            .end(done)

    self()

  create: ->

    describe "POST #{resource}", ->
      before hooks.resetCollection
      after  hooks.resetCollection

      describe 'invalid', ->
        _.forEach samples.invalid, (invalidRecord, i) ->
          it i, (done) ->
            agent
              .post(resource)
              .send(getRequestBody(invalidRecord[name]))
              .expect('Content-Type', expectedContentType)
              .expect(400)
              .expect (response) ->
                expectCbs.badRequest(response, invalidRecord)
                ''
              .end(done)

      describe 'valid', ->
        _.forEach samples.valid, (validRecord, i) ->
          it i, (done) ->
            agent
              .post(resource)
              .send(getRequestBody(validRecord[name]))
              .expect('Content-Type', expectedContentType)
              .expect(200)
              .expect (response) ->
                actual   = _.omit(response.body[name], '__v', '_id')
                expect(actual).to.eql(validRecord[name])
                ""
              .end(done)

    self()

  update: ->
    describe 'PUT', ->

      before hooks.resetCollection
      before (done) ->
        hooks.create(@, done)

      after hooks.resetCollection

      describe 'invalid', ->
        sample = {'does not exist': samples.invalid, exists: samples.invalid}
        _.forEach sample, (factories, context) ->
          describe context, ->
            _.forEach factories, (record, i) ->
              it i, (done) ->
                agent
                  .put("#{resource}/#{@record._id}")
                  .send(getRequestBody(record[name]))
                  .expect('Content-Type', expectedContentType)
                  .expect(400)
                  .expect (response) ->
                    expect(response.body).to.have.keys(record.errorKeys)
                    ""
                  .end(done)


      describe 'valid', ->

        describe 'does not exist', ->
          _.forEach samples.valid, (record, i) ->
            it i, (done) ->
              agent
                .put("#{resource}/nonesense")
                .send(getRequestBody(record[name]))
                .expect('Content-Type', expectedContentType)
                .expect(404)
                .expect(expectCbs.notFound)
                .end(done)

        describe 'exists', ->
          _.forEach samples.valid, (validrecord, i) ->
            it i, (done) ->
              agent
                .put("#{resource}/#{@record._id}")
                .send(getRequestBody(validrecord[name]))
                .expect('Content-Type', expectedContentType)
                .expect(200)
                .expect (response) ->
                  actual = _.omit(response.body[name], ['__v', '_id'])
                  expect(actual).to.eql(validrecord[name])
                  ""
                .end(done)

    self()

  index: ->
    describe "GET #{resource}", ->

      before hooks.resetCollection

      before (done) ->
        hooks.assingCount(@, done)

      before (done) ->
        hooks.expectSameCount(@, done)

      after (done) ->
        hooks.expectSameCount(@, done)

      after  hooks.resetCollection

      describe 'empty', ->
        it '', (done) ->
          agent
            .get(resource)
            .expect('Content-Type', expectedContentType)
            .expect(200)
            .expect(getResponseCollection([]))
            .end(done)

    self()

  show: ->
    describe "GET #{resource}", ->

      before hooks.resetCollection
      before (done) ->
        hooks.create(@, done)

      after hooks.resetCollection

      it 'does not exist', (done) ->
        agent
          .get("#{resource}/nonesense")
          .expect('Content-Type', expectedContentType)
          .expect(404)
          .expect(expectCbs.notFound)
          .end(done)

      it 'exists', (done) ->
        agent
          .get("#{resource}/#{@record._id}")
          .expect('Content-Type', expectedContentType)
          .expect(200)
          .expect (response) =>
            expect(response.body[name]).to.eql(@record)
            ""
          .end(done)
