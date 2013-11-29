buster = require('buster')
buster.spec.expose()
{expect} = buster
{helpers, _} = require '../helpers'

describe 'User Model', ->
  beforeAll (done) ->
    helpers.init_db done

  before (done) ->
    @timeout = 1000 * 10
    helpers.clear_db done

  describe 'validations', ->
    it "don't pass when email is absent", (done) ->
      helpers.create_user email: null, (err, user) ->
        expect(err.errors.email).toBeDefined()
        done()

    it "don't pass when password is absent", (done) ->
      helpers.create_user email: null, (err, user) ->
        expect(err.errors.password).toBeDefined()
        done()

    it 'pass when email and password are present', (done) ->
      helpers.create_user email: 'foo@bar.com', password: 'foo', (err, user) ->
        expect(err).toBeNull()
        done()

    it "don't pass when email is not valid", (done) ->
      helpers.create_user email: 'foo', (err, user) ->
        expect(err.errors.email).toBeDefined()
        done()

    it "don't pass when email is not unique", (done) ->
      helpers.create_user email: 'foo@bar.com', password: 'foo', (err, user) ->
        helpers.create_user email: user.email, password: 'foo', (err, user) ->
          expect(err.errors.email).toBeDefined()
          done()

  describe 'password', ->
    describe 'when it has been modified', ->
      it 'is handshaked with bcrypt before saving', (done) ->
        helpers.create_user email: 'foo@bar.com', password: 'foo', (err, user) ->
          expect(user.password).toMatch /^\$2a/
          done()

    describe 'when it has not been modified', ->
      it 'is not changed', (done) ->
        helpers.create_user email: 'foo@bar.com', password: 'foo', (err, user) ->
          actual_password = user.password
          user.save (err) ->
            expect(user.password).toEqual actual_password
            done()

  describe '#compare_password', ->
    before (done) ->
      helpers.create_user email: 'foo@bar.com', password: 'foo', (err, @user) =>
        done()

    describe "when passwords don't match", ->
      it "returns false", (done) ->
        @user.compare_password 'foo2', (err, match) ->
          expect(match).toBe false
          done()

    describe 'when passwords match', ->
      it "returns true", (done) ->
        @user.compare_password 'foo', (err, match) ->
          expect(match).toBe true
          done()

  afterAll (done) ->
    helpers.stop_db done