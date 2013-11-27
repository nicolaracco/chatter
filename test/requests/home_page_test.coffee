require 'coffee-backtrace'
require('../test_helper')()

describe 'Home page', ->
  @timeout 10000

  context 'when user is logged in', ->
    beforeEach (done) ->
      @create_user_and_login 'foo@bar.com', 'foo', done

    it 'shows the "home" page as active', (done) ->
      @browser.evaluate (-> $('#home').is '.active'), (result) ->
        result.should.equal true
        done()

    it "don't show the create room modal by default", (done) ->
      @browser.evaluate (-> $('#home .modal').is ':visible'), (result) ->
        result.should.equal false
        done()

    context 'when he clicks on the create room button', ->
      beforeEach (done) ->
        @browser.evaluate (-> $('.open-create-room').click()), ->
          setTimeout done, 500

      it 'shows the create room modal', (done) ->
        @browser.evaluate (-> $('#home .modal').is ':visible'), (result) ->
          result.should.equal true
          done()

      context 'and user tries to create a valid room', ->
        beforeEach (done) ->
          @browser.evaluate ->
            $('#home .modal input[name="name"]').val 'foooo'
            $('#home .modal button[type="submit"]').click()
          , ->
            setTimeout done, 500

        it 'closes the modal', (done) ->
          @browser.evaluate (-> $('#home .modal').is ':visible'), (result) ->
            result.should.equal false
            done()

        it 'appends the newly created room in the list', (done) ->
          @browser.evaluate (-> $('#home li.room').length), (result) ->
            result.should.equal 1
            done()

        it 'renders the room page active', (done) ->
          models.Room.findOne {}, (err, room) =>
            @browser.evaluate ->
              $(".room-page").is '.active'
            , (result) ->
              result.should.equal true
              done()

        it 'hides the home page', (done) ->
          @browser.evaluate (-> $('#home').is '.active'), (result) ->
            result.should.equal false
            done()


  context 'when user is not logged in', ->
    beforeEach (done) ->
      @logout done

    it 'redirects to the login page', (done) ->
      @browser.open "http://localhost:3030", (status) =>
        @browser.evaluate (-> window.location.href), (result) ->
          result.should.match /login$/
          done()