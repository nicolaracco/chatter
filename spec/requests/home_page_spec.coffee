buster = require('buster')
buster.spec.expose()
{expect} = buster
{helpers, _} = require '../helpers'
phantom = require 'phantom'

describe 'Home Page', ->
  beforeAll (done) ->
    @timeout = 1000 * 10
    helpers.start_server =>
      phantom.create (@browser) => done()

  before (done) ->
    helpers.clear_db =>
      @browser.createPage (@page) => done()

  describe 'when user is logged in', ->
    before (done) ->
      helpers.create_user_and_login 'foo@bar.com', 'foo', @page, done

    it 'shows the "home" page as active', (done) ->
      @page.evaluate (-> $('#home').is '.active'), (result) ->
        expect(result).toBe true
        done()

    it "don't show the create room modal by default", (done) ->
      @page.evaluate (-> $('#home .modal').is ':visible'), (result) ->
        expect(result).toBe false
        done()

    describe 'when he clicks on the create room button', ->
      before (done) ->
        @page.evaluate (-> $('.open-create-room').click()), ->
          setTimeout done, 500

      it 'shows the create room modal', (done) ->
        @page.evaluate (-> $('#home .modal').is ':visible'), (result) ->
          expect(result).toBe true
          done()

      describe 'and user tries to create a valid room', ->
        before (done) ->
          @page.evaluate ->
            $('#home .modal input[name="name"]').val 'foooo'
            $('#home .modal button[type="submit"]').click()
          , ->
            setTimeout done, 500

        it 'closes the modal', (done) ->
          @page.evaluate (-> $('#home .modal').is ':visible'), (result) ->
            expect(result).toBe false
            done()

        it 'appends the newly created room in the list', (done) ->
          @page.evaluate (-> $('#home li.room').length), (result) ->
            expect(result).toBe 1
            done()

        it 'renders the room page active', (done) ->
          models.Room.findOne {}, (err, room) =>
            @page.evaluate ->
              $(".room-page").is '.active'
            , (result) ->
              expect(result).toBe true
              done()

        it 'hides the home page', (done) ->
          @page.evaluate (-> $('#home').is '.active'), (result) ->
            expect(result).toBe false
            done()

    describe 'when a room already exists', ->
      before (done) ->
        helpers.create_room name: 'foo', (err, room) =>
          @page.open helpers.host, ->
            setTimeout done, 100

      it 'appears in the list', (done) ->
        @page.evaluate (-> $('li.room').length), (result) ->
          expect(result).toBe 1
          done()

      describe 'and the user clicks on the room', ->
        before (done) ->
          @page.evaluate (-> $('li.room a').click()), ->
            setTimeout done, 100

        it 'a room page is created', (done) ->
          @page.evaluate (-> $('.room-page').length), (result) ->
            expect(result).toBe 1
            done()

        it 'the newly created page is active', (done) ->
          @page.evaluate (-> $('.room-page').is '.active'), (result) ->
            expect(result).toBe true
            done()

  describe 'when user is not logged in', ->
    before (done) -> helpers.logout @page, done

    it 'redirects to the login page', (done) ->
      @page.open helpers.host, (status) =>
        @page.evaluate (-> window.location.href), (result) ->
          expect(result).toMatch /login$/
          done()

  after ->
    @page.close()

  afterAll (done) ->
    @browser.exit()
    helpers.stop_server done