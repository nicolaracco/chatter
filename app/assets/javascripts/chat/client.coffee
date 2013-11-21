#= require room_chooser
#= require room_view
#= require input_widget

@Chat ?= {}

class Chat.Client
  scroll_locked: true
  rooms_views: {}

  constructor: ->
    @socket = io.connect 'http://localhost'
    @room_chooser = new Chat.RoomChooser $('#room-chooser-link'), $('#room-chooser')
    @input_widget = new Chat.InputWidget
    @bind_events()

  show_error: (message) ->
    alert_div = $('#chat > .alert-warning')
    if alert_div.length > 0
      $('#chat > .alert-warning').html """<p>#{message}</p>"""
    else if alert_div.length is 0
      $('#chat').prepend """
        <div class="alert alert-warning">
          <p>#{message}</p>
        </div>
      """

  active_room: =>
    (room for id, room of @rooms_views when room.is_active())[0]

  bind_events: ->
    @room_chooser.on_create_room (name) =>
      @socket.emit 'create_room', name
    @room_chooser.on_join_room (id) =>
      @socket.emit 'rooms:subscribe', id
    @socket.on 'rooms:created', @room_chooser.append_room
    @socket.on 'rooms:joined',  @on_room_joined
    @socket.on 'rooms:message', @on_room_message
    @socket.on 'rooms:error',   @on_room_error
    @socket.on 'users:joined',  @on_user_joined
    @socket.on 'users:left',    @on_user_left
    @socket.on 'generic_error', @show_error
    $('#rooms_list').on 'shown.bs.tab', 'a[data-toggle="tab"]', @on_tab_shown
    @input_widget.on_message @send_message_to_active_room

  leave_room: (room) =>
    @rooms_views = _(@rooms_views).omit room.id
    prev_room = _(@rooms_views).values()[0]
    if prev_room?
      prev_room.activate()
    else
      @room_chooser.activate()
    @socket.emit 'rooms:unsubscribe', room.id

  send_message_to_active_room: (msg) =>
    room_id = @active_room().id
    @socket.emit 'rooms:message', room: room_id, message: msg

  on_tab_shown: (e) =>
    li = $(e.target).parent()
    if li.attr('data-room')
      @input_widget.show()
      room_id = $(e.target).parent().data('room')
      @rooms_views[room_id].update_size()
    else
      @input_widget.hide()

  on_room_message: (data) =>
    @rooms_views[data.room].append data

  on_room_error: (data) =>
    @rooms_views[data.room].append_error data

  on_user_joined: (data) =>
    @rooms_views[data.room].user_joined data

  on_user_left: (data) =>
    @rooms_views[data.room].user_left data

  on_room_joined: (data) =>
    unless @rooms_views[data.room.id]?
      @rooms_views[data.room.id] = new Chat.RoomView(data.room, data.messages, data.users)
      @rooms_views[data.room.id].on_close @leave_room
    @rooms_views[data.room.id].scroll_locked = true
    @rooms_views[data.room.id].activate()