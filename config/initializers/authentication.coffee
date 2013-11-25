# Passport configuration

express            = require 'express'
passport           = require 'passport'
passport_local     = require 'passport-local'
passport_socket_io = require 'passport.socketio'

module.exports = (server) ->
  strategy = new passport_local.Strategy (email, password, done) ->
    models.User.findOne email: email, (err, user) ->
      return done(err) if err?
      if user?
        user.compare_password password, (err, is_match) ->
          return done(err) if err?
          if is_match
            done null, user
          else
            done null, false, message: 'Invalid username and password'
      else
        done null, false, message: 'Invalid username and password'

  passport.use strategy
  server.app.use passport.initialize()
  server.app.use passport.session()
  passport.serializeUser (user, done) -> done null, user.id
  passport.deserializeUser (id, done) ->
    models.User.findById id, done

  # when the server starts, configure socket.io to check the auth
  server.on 'start', ->
    server.io.set 'authorization', passport_socket_io.authorize
      cookieParser: express.cookieParser
      secret      : server.config.session.secret
      store       : server.session_store
      success     : (data, accept) ->
        accept null, true
      fail        : (data, message, error, accept) ->
        throw new Error message if error
        accept null, false