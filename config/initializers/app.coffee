# Session and plugin configuration

express    = require 'express'
partials   = require 'express-partials'

module.exports = (server) ->
  RedisStore = require('connect-redis')(express)
  server.session_store = new RedisStore
  server.on 'stop', -> # close the redis connection on quit
    server.session_store.client.quit()

  app = server.app
  app.use partials()
  app.use express.cookieParser()
  app.use express.json()
  app.use express.urlencoded()
  app.use express.methodOverride()
  app.use express.session
    store : server.session_store
    secret: server.config.session.secret
  app.set 'views',       './app/views'
  app.set 'view engine', 'jade'
  app.set 'layout',      'layout'