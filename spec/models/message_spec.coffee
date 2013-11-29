buster = require('buster')
buster.spec.expose()
{expect} = buster
{helpers, _} = require '../helpers'

describe 'Message Model', ->
  beforeAll (done) ->
    helpers.init_server done

  before (done) ->
    @timeout = 1000 * 10
    helpers.clear_db done

  describe 'validations', ->
    it "don't pass if room is absent", (done) ->
      helpers.create_message _room: null, (err, message) ->
        expect(err.errors._room).toBeDefined()
        done()

    it "don't pass if at is absent", (done) ->
      helpers.create_message at: null, (err, message) ->
        expect(err.errors.at).toBeDefined()
        done()

    it "don't pass if username is absent", (done) ->
      helpers.create_message {username: null}, (err, message) ->
        expect(err.errors.username).toBeDefined()
        done()

    it "don't pass if message is absent", (done) ->
      helpers.create_message {message: null}, (err, message) ->
        expect(err.errors.message).toBeDefined()
        done()

    it "don't pass if type is absent", (done) ->
      helpers.create_message {type: null}, (err, message) ->
        expect(err.errors.type).toBeDefined()
        done()

    it "pass if all required attributes are present", (done) ->
      helpers.create_room name: 'foo', (err, room) =>
        throw err if err?
        attrs = { at: new Date, username: 'foo', message: 'asd', type: 'talk', _room: room.id }
        helpers.create_message attrs, (err, message) ->
          expect(err).toBeNull()
          done()

  describe 'on instance', ->
    before (done) ->
      helpers.create_room name: 'foo', (err, room) =>
        attrs = { at: new Date, username: 'foo', message: 'asd', type: 'talk', _room: room.id }
        helpers.create_message attrs, (err, @message) =>
          @json = @message.to_json()
          done()

    describe '#to_json', ->
      it 'returns an object with useful data for apis', (done) ->
        expect(_(@json).keys().length).toBe 6
        done()

      it 'returns the message id', (done) ->
        expect(@json.id).toEqual @message.id
        done()

      it 'returns the message date', (done) ->
        expect(@json.at).toEqual @message.at
        done()

      it 'returns the message author name', (done) ->
        expect(@json.user).toEqual @message.username
        done()

      it 'returns the message type', (done) ->
        expect(@json.type).toEqual @message.type
        done()

      it 'returns the message room id', (done) ->
        expect(@json.room).toEqual @message._room
        done()

    describe 'updated_at', ->
      it 'is set on save', (done) ->
        expect(@message.updated_at).toBeDefined()
        actual_updated_at = @message.updated_at
        @message.save (err) =>
          expect(@message.updated_at).not.toEqual actual_updated_at
          done()

  describe '::last_one_in_room', ->
    describe 'when there are no messages in the given room', ->
      before (done) ->
        helpers.create_room name: 'foo', (err, room) =>
          attrs = { at: new Date, username: 'foo', message: 'asd', type: 'talk', _room: room.id }
          helpers.create_message attrs, (err, message) =>
            done()

      it 'returns null', (done) ->
        helpers.create_room name: 'foo2', (err, room) ->
          models.Message.last_one_in_room room.id, (err, message) =>
            expect(err).toBeNull()
            expect(message).toBeNull()
            done()

    describe 'when there is at least one message in room', ->
      before (done) ->
        helpers.create_room name: 'foo', (err, room) =>
          attrs = { at: new Date, username: 'foo', message: 'asd', type: 'talk', _room: room.id }
          helpers.create_message attrs, (err, @last_message) =>
            attrs.at = new Date(1970)
            helpers.create_message attrs, (err, message) ->
              done()

      it 'returns the last inserted message in order of date', (done) ->
        models.Message.last_one_in_room @last_message._room, (err, message) =>
          expect(message.id).toEqual @last_message.id
          done()

  describe '::last_page_in_room', ->
    describe 'when there are no messages in the given room', ->
      before (done) ->
        helpers.create_room name: 'foo', (err, room) =>
          attrs = { at: new Date, username: 'foo', message: 'asd', type: 'talk', _room: room.id }
          helpers.create_message attrs, (err, @last_message) =>
            attrs.at = new Date 1970
            helpers.create_message attrs, (err, message) ->
              done()

      it 'returns an empty array', (done) ->
        helpers.create_room name: 'foo', (err, room) ->
          models.Message.last_page_in_room room.id, (err, messages) =>
            expect(messages.length).toBe 0
            done()

    describe 'when there are messages in the given room', ->
      before (done) ->
        helpers.create_room name: 'foo', (err,room) =>
          after_creation_callback = _.after 30, =>
            models.Message.last_one_in_room room.id, (err, @last_message) =>
              done()
          @room = room
          attrs = { at: new Date, username: 'foo', message: 'asd', type: 'talk', _room: room.id }
          for i in [0...30]
            attrs.at = new Date 1900 + i
            helpers.create_message attrs, after_creation_callback

      it 'returns the last 20 messages', (done) ->
        models.Message.last_page_in_room @room.id, (err, messages) ->
          expect(messages.length).toBe 20
          done()

      it 'returns the messages sorted by date in reverse order', (done) ->
        models.Message.last_page_in_room @room.id, (err, messages) =>
          expect(_(messages).last().id).toEqual @last_message.id
          done()

  afterAll (done) ->
    helpers.stop_server done