init_test_server = ->
  require('chai').should()
  mongoose = require 'mongoose'
  Server = require '../lib/server'

  before (done) ->
    @server = new Server "#{__dirname}/..", 'test'
    @server.init done

  beforeEach (done) ->
    mongoose.connection.db.dropDatabase done

  after ->
    @server.stop()

  true

module.exports = -> GLOBAL.test_server_inited ?= init_test_server()