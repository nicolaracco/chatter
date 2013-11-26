require 'coffee-backtrace'
require('../../spec_helper')()
_      = require 'underscore'
expect = require('chai').expect

describe 'User model', ->
  User = models.User

  create_user = (attrs, callback) ->
    default_attrs = { email: 'foo@bar.com', password: 'bar' }
    user = new User _(default_attrs).extend(attrs)
    user.save (err) -> callback(err, user)

  describe 'validations', ->
    it "don't pass when email is absent", (done) ->
      create_user email: null, password: null, (err, user) ->
        err.errors.should.have.property 'email'
        done()

    it "don't pass when password is absent", (done) ->
      create_user email: null, password: null, (err, user) ->
        err.errors.should.have.property 'password'
        done()

    it 'pass when email and password are present', (done) ->
      create_user {}, (err, user) ->
        expect(err).to.not.exist
        done()

    it "don't pass when email is not valid", (done) ->
      create_user email: 'foo', (err, user) ->
        err.errors.should.have.property 'email'
        done()

    it "don't pass when email is not unique", (done) ->
      create_user {}, (err, user) ->
        create_user {email: user.email}, (err, user) ->
          err.errors.should.have.property 'email'
          done()

  describe 'password', ->
    context 'when it has been modified', ->
      it 'is handshaked with bcrypt before saving', (done) ->
        create_user {}, (err, user) ->
          user.password.should.match /^\$2a/
          done()

    context 'when it has not been modified', ->
      it 'is not changed', (done) ->
        create_user {}, (err, user) ->
          actual_password = user.password
          user.save (err) ->
            user.password.should.equal actual_password
            done()

  describe '#compare_password', ->
    beforeEach (done) ->
      create_user {password: 'foo'}, (err, user) =>
        @user = user
        done()

    context "when passwords don't match", ->
      it "returns false", (done) ->
        @user.compare_password 'foo2', (err, match) ->
          match.should.equal false
          done()

    context 'when passwords match', ->
      it "returns true", (done) ->
        @user.compare_password 'foo', (err, match) ->
          match.should.equal true
          done()