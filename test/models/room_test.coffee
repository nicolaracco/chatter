require 'coffee-backtrace'
require('../test_helper')()
_      = require 'underscore'
expect = require('chai').expect

describe 'Room model', ->
  Room = models.Room

  create_room = (attrs, callback) ->
    default_attrs = { name: 'foo' }
    room = new Room _(default_attrs).extend(attrs)
    room.save (err) -> callback(err, room)

  describe 'validations', ->
    it "don't pass if name is absent", (done) ->
      create_room {name: null}, (err, room) ->
        err.errors.should.have.property 'name'
        done()

    it 'pass if name is present', (done) ->
      create_room {}, (err, room) ->
        expect(err).to.not.exist
        done()

    it "don't pass if name is not unique", (done) ->
      create_room {}, (err, room) ->
        create_room {name: room.name}, (err, room) ->
          err.errors.should.have.property 'name'
          done()

  describe '#to_json', ->
    beforeEach (done) ->
      create_room {}, (err, room) =>
        @room = room
        done()

    it 'returns an object with useful data for apis', (done) ->
      json = @room.to_json()
      _(json).keys().should.have.length 2
      done()

    it 'returns the room id', (done) ->
      json = @room.to_json()
      json.id.should.equal @room.id
      done()

    it 'returns the room name', (done) ->
      json = @room.to_json()
      json.name.should.equal @room.name
      done()