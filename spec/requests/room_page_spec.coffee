buster = require('buster')
buster.spec.expose()
{expect} = buster
{helpers, _} = require '../helpers'
phantom = require 'phantom'

describe 'Room Page', ->
  beforeAll (done) ->
    @timeout = 1000 * 30
    helpers.start_server =>
      phantom.create (@browser) => done()

  before (done) ->
    helpers.clear_db =>
      @browser.createPage (@page) =>
        helpers.create_user_and_login 'foo@bar.com', 'bar', @page, (err, @user) =>
          throw err if err?
          done()

  describe 'after join', ->
    before (done) ->
      helpers.create_and_access_room 'test', @page, (err, @room) =>
        throw err if err?
        done()

    it 'the last message tells that the user joined the room', (done) ->
      @page.evaluate ->
        $('.room-page .log-entry:last-child').text()
      , (result) ->
        expect(result).toMatch 'foo@bar.com'
        expect(result).toMatch 'joined'
        done()

    describe 'if he writes something', ->
      before (done) ->
        @page.evaluate ->
          navbar = $('.room-page .input-navbar')
          navbar.find('input[type="text"]').val "wow wow"
          navbar.find('form').submit()
        , ->
          setTimeout done, 100

      it 'a message is added in the output', (done) ->
        @page.evaluate ->
          $('.room-page .log-entry:last-child').text()
        , (result) ->
          expect(result).toMatch 'foo@bar.com'
          expect(result).toMatch 'wow wow'
          done()

    describe 'when another user joins the room', ->
      before (done) ->
        phantom.create port: 11222, (@another_browser) =>
          @another_browser.createPage (@another_page) =>
            helpers.logout @another_page, =>
              helpers.create_user_and_login 'john@smith.com', 'bar', @another_page, (err, @user) =>
                throw err if err?
                helpers.access_room @room.name, @another_page, ->
                  setTimeout done, 10000

      it 'appears in the user list', (done) ->
        @page.evaluate ->
          $('.room-page .list-group-item:last-child').text()
        , (result) ->
          expect(result).toMatch 'john@smith.com'
          done()

      it 'a message is added in the output', (done) ->
        @page.evaluate ->
          $('.room-page .log-entry:last-child').text()
        , (result) ->
          expect(result).toMatch 'john@smith.com'
          expect(result).toMatch 'joined'
          done()

      describe 'and then he leaves the room', ->
        before (done) ->
          @another_page.evaluate ->
            $('#pages-links li.active button').click()
          , (result) ->
            setTimeout done, 100

        it 'disappears from the user list', (done) ->
          @page.evaluate ->
            $('.room-page .list-group-item').length
          , (result) ->
            expect(result).toBe 1
            done()

        it 'a message is added in the output', (done) ->
          @page.evaluate ->
            $('.room-page .log-entry:last-child').text()
          , (result) ->
            expect(result).toMatch 'john@smith.com'
            expect(result).toMatch 'left'
            done()

      describe 'and he writes something', ->
        before (done) ->
          @another_page.evaluate ->
            navbar = $('.room-page .input-navbar')
            navbar.find('input[type="text"]').val "wow wow"
            navbar.find('form').submit()
          , ->
            setTimeout done, 100

        it 'a message is added in the output', (done) ->
          @page.evaluate ->
            $('.room-page .log-entry:last-child').text()
          , (result) ->
            expect(result).toMatch 'john@smith.com'
            expect(result).toMatch 'wow wow'
            done()

      after ->
        @another_page.close()
        @another_browser.exit()

  describe 'when there were no messages', ->
    before (done) ->
      helpers.create_and_access_room 'test', @page, (err, @room) =>
        throw err if err?
        done()

    it 'there is only one message', (done) ->
      @page.evaluate ->
        $('.room-page .log-entry').length
      , (result) ->
        expect(result).toBe 1
        done()

    it 'the current user is in the user list', (done) ->
      @page.evaluate ->
        $('.room-page .list-group-item').text()
      , (result) ->
        expect(result).toMatch 'foo@bar.com'
        done()

  describe 'when there were several messages', ->
    before (done) ->
      callback = _.after 30, =>
        helpers.access_room @room.name, @page, done
      helpers.create_room name: 'test', (err, @room) =>
        for i in [0...30]
          helpers.create_message
            at      : new Date(1970 + i)
            _room   : @room.id
            username: 'foo@bar.com'
            message : "test #{i}"
            type    : 'talk'
          , (err, message) ->
              throw err if err?
              callback()

    it 'only 20 messages are shown', (done) ->
      @page.evaluate ->
        $('.room-page .log-entry').length
      , (result) ->
        expect(result).toBe 20
        done()

    it 'the first message of the listing is the earlier', (done) ->
      @page.evaluate ->
        $('.room-page .log-entry').first().text()
      , (result) ->
        expect(result).toMatch /11/
        done()

    it 'the message before the last is the most recent', (done) ->
      @page.evaluate ->
        $('.room-page .log-entry')[18].innerText
      , (result) ->
        expect(result).toMatch /29/
        done()

  after ->
    @page.close()

  afterAll (done) ->
    @browser.exit()
    helpers.stop_server done