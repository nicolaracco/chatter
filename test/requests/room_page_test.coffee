require 'coffee-backtrace'
require('../test_helper')()

describe 'Room page', ->
  @timeout 10000

  before (done) ->
    @open_first_room = (done) ->
      @browser.open "#{@host}", =>
        setTimeout =>
          @browser.evaluate (-> $('li.room a').click()), (result) =>
            setTimeout done, 100
        , 200
    done()


  beforeEach (done) ->
    @room = new models.Room name: 'foo'
    @room.save (err) =>
      @logout =>
        @create_user_and_login 'foo@bar.com', 'foo', =>
          @open_first_room done


  context 'when the room has been just created', ->
    it 'there is only one message', (done) ->
      @browser.evaluate (-> $('.room-page .log-entry').length), (result) ->
        result.should.equal 1
        done()

    it 'appers that the current user just joined the room', (done) ->
      @browser.evaluate (-> $('.room-page .log-entry').text()), (result) ->
        result.should.match /foo\@bar\.com/
        result.should.match /joined/
        done()

    it 'the current user appears in the user list', (done) ->
      @browser.evaluate (-> $('.room-page .list-group-item').text()), (result) ->
        result.should.match /foo\@bar\.com/
        done()


  context 'when there are other messages', ->
    beforeEach (done) ->
      callback = _.after 30, => @open_first_room done
      for i in [0...30]
        msg = new models.Message at: new Date, username: 'foo@bar.com', _room: @room._id, type: 'talk', message: 'asdasd'
        msg.save callback

    it 'the last 20 messages are shown', (done) ->
      @browser.evaluate (-> $('.room-page .log-entry').length), (result) ->
        result.should.equal 20
        done()