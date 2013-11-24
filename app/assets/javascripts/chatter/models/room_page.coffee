@Chatter ?= {}

class Chatter.RoomPage extends Chatter.Page
  constructor: ->
    @messages = new Chatter.Messages
    @users    = new Chatter.Users
    super

  is_removable: => true

  initialize: =>
    super
    do (conn = Chatter.connection) =>
      conn.on "room-#{@id}:reset", @reset
      conn.on "room-#{@id}:error", (error) =>
        @error.set 'description', error.description
        @error.set 'active', true
      conn.on "room-#{@id}:log", (data) =>
        @messages.process_log data
      conn.on "room-#{@id}:joined", (data) =>
        @messages.add data
      conn.on "room-#{@id}:left", (data) =>
        @messages.add data
      conn.emit 'room:join', @id
      conn.on 'reconnect', =>
        conn.emit 'room:join', @id

  destroy: =>
    do (conn = Chatter.connection) =>
      conn.off "room-#{@id}:reset"
      conn.off "room-#{@id}:error"
      conn.off "room-#{@id}:log"
      conn.off "room-#{@id}:joined"
      conn.off "room-#{@id}:left"
      conn.emit 'room:leave', @id
    @trigger 'destroy', @

  reset: (data) =>
    @messages.reset data.messages
    @users.reset    data.users, parse: true

  send_message: (message) =>
    Chatter.connection.emit 'room:talk', { id: @id, message }

class Chatter.RoomInputView extends Backbone.View
  tagName: 'navbar'
  className: 'navbar navbar-fixed-bottom navbar-default'

  template: """
    <div class="container">
      <form class="navbar-form navbar-left">
        <div class="form-group"><div class="input-group">
          <span class="input-group-addon">
            <span class="glyphicon glyphicon-comment"></span>
          </span>
          <input class="form-control" type="text" required="true" placeholder="Say something ..." />
        </div></div>
      </form>
    </div>
  """

  events:
    'submit form' : 'send_message'

  render: =>
    @$el.html @template
    @

  disable: =>
    @message_el().attr 'disabled', 'disabled'

  enable: =>
    @message_el().removeAttr 'disabled'

  send_message: (e) =>
    e.preventDefault()
    @trigger 'send_message', @message_el().val()
    @message_el().val ''

  message_el: => @$el.find('input[type="text"]')

  gain_focus: =>
    setTimeout =>
      @message_el().focus()
    , 200

class Chatter.RoomPageView extends Chatter.PageView
  template: """
    <div class="alert alert-warning hide"></div>
    <div class="row">
      <div class="col-md-9 main-scroller">
        <div class="log-output"></div>
      </div>
      <div class="col-md-3 main-scroller">
        <ul class="list-group users-list"></ul>
      </div>
    </div>
    <nav class="input-navbar navbar navbar-fixed-bottom navbar-default"></nav>
  """

  initialize: =>
    super
    @messages_view = new Chatter.MessagesView
      collection: @model.messages
      el: @log_output_el()
    @users_view = new Chatter.UsersView
      collection: @model.users
      el: @users_list_el()
    @input_view = new Chatter.RoomInputView
    @error_view = new Chatter.ErrorView model: @model.error

    @listenTo @model, 'error', @add_error
    @listenTo @model, 'change:active', @set_scroll_locked
    @listenTo @model.error, 'change:active', @show_disconnect_error
    @input_view.on 'send_message', @send_message

  add_error: (error) => @messages_view.add_error error

  show_disconnect_error: (error) =>
    if error.get('active')
      @input_view.disable()
    else
      @input_view.enable()

  render: =>
    @$el.html @template
    @error_view.setElement(@$el.find('.alert')).render()
    @messages_view.setElement(@log_output_el()).render()
    @users_view.setElement(@users_list_el()).render()
    @input_view.setElement(@$el.find('.input-navbar')).render()
    super
    @input_view.gain_focus() if @$el.hasClass 'active'
    @set_scroll_locked()
    @

  log_output_el: => @$el.find('.log-output')

  users_list_el: => @$el.find('.users-list')

  send_message: (message) => @model.send_message message

  set_scroll_locked: =>
    @messages_view.attributes.scroll_locked = true
    @messages_view.scroll_to_bottom()
