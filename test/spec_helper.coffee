module.exports = ->
  require('chai').should()
  root = "#{__dirname}/.."
  db_uri   = 'mongodb://localhost/chatter-test'
  mongoose = require 'mongoose'

  beforeEach (done) ->
    done = do (done) ->
      -> mongoose.connection.db.dropDatabase done
    return done() if mongoose.connection.db
    mongoose.connect db_uri, done

  after ->
    mongoose.disconnect()
  # Server = require "#{root}/server"

  # beforeEach (done) ->
  #   @server = new Server root
  #   clearDB = require('mocha-mongoose')(@server.config.db.uri, noClear: true)
  #   clearDB(done)
  # afterEach -> @server.stop()

  root