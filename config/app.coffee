# Session and plugin configuration

express    = require 'express'
partials   = require 'express-partials'

module.exports = (server) ->
  RedisStore = require('connect-redis')(express)
  server.sessionStore = new RedisStore
  server.on 'stop', -> # close the redis connection on quit
    server.sessionStore.client.quit()

  app = server.app
  app.use partials()
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.session
    store : server.sessionStore
    secret: server.config.session.secret
  app.set 'views',       './app/views'
  app.set 'view engine', 'jade'
  app.set 'layout',      'layout'