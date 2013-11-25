# DB Configuration

_        = require 'underscore'
mongoose = require 'mongoose'

module.exports = (server) ->
  server.on 'stop', -> mongoose.disconnect()
  mongoose.connect server.config.db.uri