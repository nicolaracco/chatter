require 'coffee-backtrace'
require('../test_helper')()
expect = require('chai').expect
Browser = require("zombie")

describe 'Home page', ->
  @timeout 10000

  before (done) ->
    @browser = new Browser
    done()

  context 'when user is logged in', ->
    beforeEach (done) ->
      user = new models.User email: 'foo@bar.com', password: 'foo'
      user.save (err) =>
        @browser.visit "http://localhost:3030/login", =>
          @browser
            .fill('Email Address', 'foo@bar.com')
            .fill('Password', 'foo')
            .pressButton 'Log In', -> done()

    it 'shows the home page', (done) ->
      @browser.visit "http://localhost:3030", =>
        @browser.location.should.not.match /login$/
        done()

    it "don't show the create room modal", (done) ->
      @browser.visit "http://localhost:3030", =>
        classNames = @browser.querySelector('#home .modal').getAttribute('class').split ' '
        classNames.indexOf('in').should.equal -1
        done()

    context 'when he clicks on the create room button', ->
      beforeEach (done) ->
        @browser.visit "http://localhost:3030", =>
          @browser.pressButton '.open-create-room', ->
            setTimeout done, 500

      it 'shows the create room modal', (done) ->
        classNames = @browser.querySelector('#home .modal').getAttribute('class').split ' '
        classNames.indexOf('in').should.not.equal -1
        done()

      context 'and user try to create a valid room', ->
        beforeEach (done) ->
          @browser.fill('#home .modal input[name="name"]', "fooo")
          @browser.pressButton 'Create Room', (e) =>
            console.dir @browser.field('#home .modal input[name="name"]').value
            room_created = (window) -> window.document.querySelector('li.room')
            @browser.wait room_created, done

        it 'the newly created room automatically appears on the page', ->
          console.dir @browser.html()
          console.dir @browser.querySelector('li.room').text()
          done()


  context 'when user is not logged in', ->
    beforeEach (done) ->
      @browser.visit "http://localhost:3030/logout", ->
        done()

    it 'redirects to the login page', (done) ->
      @browser.visit "http://localhost:3030", =>
        @browser.location.should.match /login$/
        done()