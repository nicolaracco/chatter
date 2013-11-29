_       = require 'underscore'
phantom = require 'phantom'
Server  = require '../lib/server'

class Helpers
  constructor: ->
    @server = new Server "#{__dirname}/..", 'test'
    @host   = "http://localhost:#{@server.config.server.port}"

  init_server: (done) =>
    @server.init done

  start_server: (done) =>
    @server.start done

  stop_server: (done) =>
    @server.stop done

  clear_db: (done) =>
    mongoose = require 'mongoose'
    mongoose.connection.db.dropDatabase done

  create_room: (attrs, callback) ->
    room = new models.Room attrs
    room.save (err) -> callback err, room

  create_user: (attrs, callback) ->
    user = new models.User attrs
    user.save (err) -> callback err, user

  create_message: (attrs, callback) ->
    message = new models.Message attrs
    message.save (err) -> callback err, message

  logout: (page, done) =>
    page.open "#{@host}/logout", -> done()

  login_as: (email, password, page, done) =>
    page.set 'onLoadFinished', _.after 2, ->
      page.set 'onLoadFinished', null
      done()
    page.open "#{@host}/login", ->
      page.evaluate (email, password) ->
        $('#email-input').val email
        $('#password-input').val password
        $('form').submit()
      , null, email, password

  create_user_and_login: (email, password, page, done) =>
    models.User.findOne {email}, (err, user) =>
      return done err if err?
      if user?
        @login_as email, password, page, -> done(null, user)
      else
        @create_user {email, password}, (err, user) =>
          return done err if err?
          @login_as email, password, page, -> done(null, user)

  access_room: (name, page, done) =>
    page.set 'onLoadFinished', ->
      page.set 'onLoadFinished', null
      setTimeout ->
        page.evaluate ->
          $('li.room a').first().click()
        , ->
          setTimeout done, 100
      , 100
    page.open "#{@host}"

  create_and_access_room: (name, page, done) =>
    models.Room.findOne {name}, (err, room) =>
      return done err if err?
      if room?
        @access_room name, page, -> done(null, room)
      else
        @create_room {name}, (err, room) =>
          @access_room name, page, -> done(null, room)

exports.helpers = new Helpers
exports._       = _