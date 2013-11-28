global._ = require 'underscore'
global.expect = require('chai').expect

helpers =
  logout: (done) ->
    @browser.open "#{@host}/logout", -> done()

  login_as: (email, password, done) ->
    @browser.set 'onLoadFinished', _.after 2, =>
      @browser.set 'onLoadFinished', null
      done()
    @browser.open "#{@host}/login", =>
      @browser.evaluate ->
        $('#email-input').val "foo@bar.com"
        $('#password-input').val "foo"
        $('form').submit()

  create_user_and_login: (email, password, done) ->
    models.User.findOne {email}, (err, user) =>
      return done err if err?
      if user?
        @login_as email, password, done
      else
        user = new models.User {email, password}
        user.save (err) =>
          return done err if err?
          @login_as email, password, done

init_test_server = ->
  require('chai').should()
  phantom = require 'phantom'
  mongoose = require 'mongoose'
  Server = require '../lib/server'

  before (done) ->
    @server = new Server "#{__dirname}/..", 'test'
    @host = "http://localhost:#{@server.config.server.port}"
    @server.start =>
      phantom.create (@phantom) => done()
    for name, helper of helpers
      @[name] = _.bind(helper, @)

  beforeEach (done) ->
    mongoose.connection.db.dropDatabase (err) =>
      done err if err?
      @phantom.createPage (@browser) => done()

  afterEach (done) ->
    @browser.close()
    done()

  after (done) ->
    @phantom.exit()
    @server.stop => done()

  true

module.exports = (type) ->
  global.test_server_inited ?= init_test_server()