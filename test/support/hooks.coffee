expect = require('chai').expect
_      = require('lodash')
Q      = require('q')

module.exports = (mongooseModel, doc, docConstructor=_.identity) ->

  expectLessCount: (that, difference=1) ->
    mongooseModel.count().exec().then (count) ->
      expect(count).to.equal(that.count - difference)

  expectSameCount: (that) ->
    mongooseModel.count().exec().then (count) ->
      expect(count).to.equal(that.count)

  assingCount: (that) ->
    mongooseModel.count().exec().then (count) ->
      that.count = count

  createRecord: (that) ->
    Q(docConstructor(doc))
      .then (validDoc) ->
        mongooseModel.remove(username: validDoc.username).exec().then ->
          mongooseModel.create(validDoc)
      .then (record) ->
        that.record = _.merge(record.toJSON(), id: record.id)