buster = require('buster')
buster.spec.expose()
{expect} = buster
{helpers, _, server} = require '../helpers'
phantom = require 'phantom'

describe 'Login Page', ->
  beforeAll (done) ->
    @timeout = 1000 * 20
    phantom.create (@browser) =>
      done = _.after 2, done
      server.start done
      helpers.init_db done

  before (done) ->
    helpers.clear_db =>
      @browser.createPage (@page) => done()

  describe 'when user is not logged in', ->
    before (done) ->
      helpers.logout @page, done

    it 'is accessible', (done) ->
      @page.open "#{helpers.host}/login", (status) =>
        @page.evaluate (-> window.location.href), (result) ->
          expect(result).toMatch /login$/
          done()

  describe 'when user logs in', ->
    before (done) ->
      helpers.create_user_and_login 'foo@bar.com', 'foo', @page, (err, user) ->
        done()

    it 'redirects to the root path', (done) ->
      @page.open "#{helpers.host}/login", (status) =>
        @page.evaluate (-> window.location.href), (result) ->
          expect(result).not.toMatch /login$/
          done()

  after ->
    @page.close()

  afterAll (done) ->
    @browser.exit()
    done = _.after 2, done
    helpers.stop_db done
    server.stop done