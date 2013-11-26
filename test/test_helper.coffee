init_test_server = ->
  require('chai').should()
  mongoose = require 'mongoose'
  Server = require '../lib/server'

  before (done) ->
    @server = new Server "#{__dirname}/..", 'test'
    @server.start done

  beforeEach (done) ->
    mongoose.connection.db.dropDatabase done

  after (done) ->
    @server.stop done

  true

module.exports = (type) ->
  GLOBAL.test_server_inited ?= init_test_server()