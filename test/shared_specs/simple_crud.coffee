supertest = require('supertest')
_         = require('lodash')

expect = require('chai').expect

controllersUtils = require('../../app/utils/controllers')
specHelpers      = require('../support/spec_helpers')

expectedContentType = 'application/json; charset=utf-8'

expectCbs = specHelpers.expectCbs

#TODO: try to simplify
module.exports = (app, resource, model, samples, token=null, serializer=null, docConstructor=null) ->

  agent = supertest(app)
  resourceName  = _.last(resource.split('/'))[0...-1]

  self = ->
    module.exports(app, resource, model, samples, token, serializer, docConstructor)

  getReqOrResBody = controllersUtils.getResponseBody(resourceName)

  hooks = require('../support/hooks')(model, samples.valid[0].form[resourceName], docConstructor)

  destroy: ->
    describe "DELETE #{resource}/:id", ->

      before     -> hooks.createRecord(@)
      before     -> hooks.assingCount(@)
      beforeEach -> hooks.expectSameCount(@)

      describe 'does not exist', ->

        afterEach -> hooks.expectSameCount(@)

        it '', (done) ->
          agent
            .delete("#{resource}/nonesense")
            .set('X-Access-Token', token)
            .expect('Content-Type', expectedContentType)
            .expect(404)
            .expect(expectCbs.notFound)
            .end(done)

      describe 'exists', ->

        afterEach -> hooks.expectLessCount(@)

        it '', (done) ->
          agent
            .delete("#{resource}/#{@record.id}")
            .set('X-Access-Token', token)
            .expect('Content-Type', expectedContentType)
            .expect(200)
            .expect (response) =>
              expected = serializer(@record)
              actual   = serializer(response.body[resourceName])
              expect(actual).to.eql(expected)
              false
            .end(done)

    self()

  create: ->

    describe "POST #{resource}", ->

      before     -> hooks.assingCount(@)
      beforeEach -> hooks.expectSameCount(@)

      describe 'invalid', ->

        afterEach -> hooks.expectSameCount(@)

        _.forEach samples.invalid, (invalidRecord, i) ->
          it i, (done) ->
            agent
              .post(resource)
              .set('X-Access-Token', token)
              .send(invalidRecord.form)
              .expect('Content-Type', expectedContentType)
              .expect(400)
              .expect (response) ->
                expectCbs.badRequest(response, invalidRecord)
                false
              .end(done)

      describe 'valid', ->

        afterEach -> hooks.expectLessCount(@, -1)

        _.forEach samples.valid, (validRecord, i) ->
          it i, (done) ->
            agent
              .post(resource)
              .set('X-Access-Token', token)
              .send(validRecord.form)
              .expect('Content-Type', expectedContentType)
              .expect(201)
              .expect (response) ->
                expected = serializer(validRecord.res)
                actual   = _.omit(serializer(response.body[resourceName]), samples.blacklist)
                expect(actual).to.eql(expected)
                false
              .end(done)

    self()

  update: ->
    describe "PUT #{resource}/:id", ->

      before     -> hooks.createRecord(@)
      before     -> hooks.assingCount(@)
      beforeEach -> hooks.expectSameCount(@)

      afterEach  -> hooks.expectSameCount(@)

      describe 'invalid', ->
        sample = {'does not exist': samples.invalid, exists: samples.invalid}
        _.forEach sample, (factories, context) ->
          describe context, ->
            _.forEach factories, (record, i) ->
              it i, (done) ->
                agent
                  .put("#{resource}/#{@record._id}")
                  .set('X-Access-Token', token)
                  .send(record.form)
                  .expect('Content-Type', expectedContentType)
                  .expect(400)
                  .expect (response) ->
                    expect(response.body).to.have.keys(record.errorKeys)
                    false
                  .end(done)


      describe 'valid', ->

        describe 'does not exist', ->
          _.forEach samples.valid, (validRecord, i) ->
            it i, (done) ->
              agent
                .put("#{resource}/nonesense")
                .set('X-Access-Token', token)
                .send(validRecord.form)
                .expect('Content-Type', expectedContentType)
                .expect(404)
                .expect(expectCbs.notFound)
                .end(done)

        describe 'exists', ->
          _.forEach samples.valid, (validRecord, i) ->
            it i, (done) ->
              agent
                .put("#{resource}/#{@record._id}")
                .set('X-Access-Token', token)
                .send(validRecord.form)
                .expect('Content-Type', expectedContentType)
                .expect(200)
                .expect (response) ->
                  expected = serializer(validRecord.res)
                  actual   = _.omit(serializer(response.body[resourceName]), 'id')
                  expect(actual).to.eql(expected)
                  false
                .end(done)

    self()

  index: ->
    describe "GET #{resource}", ->

      before     -> hooks.assingCount(@)
      beforeEach -> hooks.expectSameCount(@)

      afterEach -> hooks.expectSameCount(@)

      it '', (done) ->
        agent
          .get(resource)
          .set('X-Access-Token', token)
          .expect('Content-Type', expectedContentType)
          .expect(200)
          .expect (res) =>
            expect(res.body[resourceName + 's'].length).to.eql(@count)
            false
          .end(done)

    self()

  show: ->
    describe "GET #{resource}", ->

      before     -> hooks.createRecord(@)
      before     -> hooks.assingCount(@)
      beforeEach -> hooks.expectSameCount(@)

      afterEach -> hooks.expectSameCount(@)

      it 'does not exist', (done) ->
        agent
          .get("#{resource}/nonesense")
          .set('X-Access-Token', token)
          .expect('Content-Type', expectedContentType)
          .expect(404)
          .expect(expectCbs.notFound)
          .end(done)

      it 'exists', (done) ->
        agent
          .get("#{resource}/#{@record._id}")
          .set('X-Access-Token', token)
          .expect('Content-Type', expectedContentType)
          .expect(200)
          .expect (response) =>
            expected = serializer(@record)
            actual   = serializer(response.body[resourceName])
            expect(actual).to.eql(expected)
            false
          .end(done)

    self()