require 'coffee-backtrace'
require('../test_helper')()
_      = require 'underscore'
expect = require('chai').expect

describe 'Message model', ->
  Room    = models.Room
  Message = models.Message

  create_room = (attrs, callback) ->
    default_attrs = { name: 'foo' }
    room = new Room _(default_attrs).extend(attrs)
    room.save (err) -> callback(err, room)

  create_message = (attrs, callback) ->
    default_attrs = { at: new Date, username: 'foo', message: 'asd', type: 'talk' }
    message = new Message _(default_attrs).extend attrs
    message.save (err) -> callback(err, message)

  create_message_with_room = (attrs, callback) ->
    create_room {}, (err, room) ->
      attrs._room = room.id
      create_message attrs, callback

  describe 'validations', ->
    it "don't pass if room is absent", (done) ->
      create_message {}, (err, message) ->
        err.errors.should.have.property '_room'
        done()

    it "don't pass if at is absent", (done) ->
      create_message {at: null}, (err, message) ->
        err.errors.should.have.property 'at'
        done()

    it "don't pass if username is absent", (done) ->
      create_message {username: null}, (err, message) ->
        err.errors.should.have.property 'username'
        done()

    it "don't pass if message is absent", (done) ->
      create_message {message: null}, (err, message) ->
        err.errors.should.have.property 'message'
        done()

    it "don't pass if type is absent", (done) ->
      create_message {type: null}, (err, message) ->
        err.errors.should.have.property 'type'
        done()

    it "pass if all required attributes are present", (done) ->
      create_message_with_room {}, (err, message) ->
        expect(err).to.not.exist
        done()

  describe '#to_json', ->
    beforeEach (done) ->
      create_message_with_room {}, (err, message) =>
        @message = message
        done()

    it 'returns an object with useful data for apis', (done) ->
      json = @message.to_json()
      _(json).keys().should.have.length 6
      done()

    it 'returns the message id', (done) ->
      json = @message.to_json()
      json.id.should.equal @message.id
      done()

    it 'returns the message date', (done) ->
      json = @message.to_json()
      json.at.should.equal @message.at
      done()

    it 'returns the message author name', (done) ->
      json = @message.to_json()
      json.user.should.equal @message.username
      done()

    it 'returns the message type', (done) ->
      json = @message.to_json()
      json.type.should.equal @message.type
      done()

    it 'returns the message room id', (done) ->
      json = @message.to_json()
      json.room.should.equal @message._room
      done()

  describe 'updated_at', ->
    it 'is set on save', (done) ->
      create_message_with_room {}, (err, message) ->
        expect(message.updated_at).to.exist
        actual_updated_at = message.updated_at
        message.save (err) ->
          message.updated_at.should.not.equal actual_updated_at
          done()

  describe '::last_one_in_room', ->
    context 'when there are no messages in the given room', ->
      beforeEach (done) ->
        create_message_with_room {}, (err, message) ->
          done()

      it 'returns null', (done) ->
        create_room name: 'foo2', (err, room) ->
          Message.last_one_in_room room.id, (err, message) =>
            expect(err).to.not.exist
            expect(message).to.not.exist
            done()

    context 'when there is at least one message in room', ->
      beforeEach (done) ->
        create_message_with_room {}, (err, message) =>
          @last_message = message
          create_message _room: message._room, at: new Date(1970), (err, message) ->
            done()

      it 'returns the last inserted message in order of date', (done) ->
        Message.last_one_in_room @last_message._room, (err, message) =>
          message.id.should.equal @last_message.id
          done()

  describe '::last_page_in_room', ->
    context 'when there are no messages in the given room', ->
      beforeEach (done) ->
        create_message_with_room {}, (err, message) =>
          @last_message = message
          create_message _room: message._room, at: new Date(1970), (err, message) ->
            done()

      it 'returns an empty array', (done) ->
        create_room {}, (err, room) ->
          Message.last_page_in_room room.id, (err, messages) =>
            messages.should.have.length(0)
            done()

    context 'when there are messages in the given room', ->
      beforeEach (done) ->
        create_room {}, (err,room) =>
          after_creation_callback = _.after 30, =>
            Message.last_one_in_room room.id, (err, message) =>
              @last_message = message
              done()
          @room = room
          for i in [0...30]
            create_message _room: room.id, at: new Date(1900 + i), after_creation_callback

      it 'returns the last 20 messages', (done) ->
        Message.last_page_in_room @room.id, (err, messages) ->
          messages.should.have.length(20)
          done()

      it 'returns the messages sorted by date in reverse order', (done) ->
        Message.last_page_in_room @room.id, (err, messages) =>
          _(messages).last().id.should.equal @last_message.id
          done()