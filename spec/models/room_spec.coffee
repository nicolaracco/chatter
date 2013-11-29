buster = require('buster')
buster.spec.expose()
{expect} = buster
{helpers, _} = require '../helpers'

describe 'Room Model', ->
  beforeAll (done) ->
    helpers.init_db done

  before (done) ->
    @timeout = 1000 * 10
    helpers.clear_db done

  describe 'validations', ->
    it "don't pass if name is absent", (done) ->
      helpers.create_room name: null, (err, room) ->
        expect(err.errors.name).toBeDefined()
        done()

    it "pass if name is present", (done) ->
      helpers.create_room name: 'foo', (err, room) ->
        expect(err).toBeNull()
        done()

    it "don't pass if name is not unique", (done) ->
      helpers.create_room name: 'foo', (err, room) ->
        throw err if err?
        helpers.create_room name: 'foo', (err, room) ->
          expect(err.errors.name).toBeDefined()
          done()

  describe '#to_json', ->
    before (done) ->
      helpers.create_room name: 'foo', (err, @room) =>
        throw err if err?
        @json = @room.to_json()
        done()

    it 'returns an object with data needed by APIs', ->
      expect(_(@json).keys().length).toEqual 2

    it 'returns the room id', ->
      expect(@json.id).toEqual @room.id

    it 'returns the room name', ->
      expect(@json.name).toEqual @room.name

  afterAll (done) ->
    helpers.stop_db done