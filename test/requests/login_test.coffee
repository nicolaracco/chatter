require 'coffee-backtrace'
require('../test_helper')()

describe 'Login Page', ->
  @timeout 10000

  context 'when user is not logged in', ->
    beforeEach (done) ->
      @logout done

    it 'is accessible', (done) ->
      @browser.open "#{@host}/login", (status) =>
        status.should.equal 'success'
        done()

  context 'when user logs in', ->
    beforeEach (done) ->
      @create_user_and_login 'foo@bar.com', 'foo', done

    it 'redirects to the root path', (done) ->
      @browser.open "#{@host}/login", (status) =>
        @browser.evaluate (-> window.location.href), (result) ->
          result.should.not.match /login$/
          done()