_       = require 'underscore'
phantom = require 'phantom'
Server  = require '../lib/server'

class ServersHelpers
  constructor: ->
    @callbacks = []

  start: (done) =>
    @callbacks.start = done
    @create_test_server()
    @bind_events()

  stop: (done) =>
    @callbacks.stop = done
    @test_server.kill 'SIGKILL'

  # PRIVATE METHODS
  create_test_server: =>
    fork = require('child_process').fork
    @test_server = fork 'app.coffee', [],
      cwd     : "#{__dirname}/.."
      execPath: './node_modules/coffee-script/bin/coffee'

  bind_events: =>
    @test_server.on 'message', @on_server_message

  on_server_message: (data) =>
    if data.status is 'started'
      @callbacks.start?()
    else if data.status is 'stopped'
      @callbacks.stop?()

class Helpers
  constructor: ->
    process.env.NODE_ENV = 'test'
    @server = new Server "#{__dirname}/..", debug: false
    @host   = "http://localhost:#{@server.config.server.port}"

  init_db: (done) =>
    @server.init_db done

  stop_db: (done) =>
    @server.stop_db done

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
exports.server  = new ServersHelpers
exports._       = _
