#= require room_chooser
#= require room_view
#= require input_widget

@Chat ?= {}

class Chat.Client
  scroll_locked: true
  rooms_views: {}

  constructor: ->
    @socket = io.connect 'http://localhost'
    @rooms_view = new Chat.RoomChooser $('#room-chooser')
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
    @rooms_view.on_create_room (name) =>
      @socket.emit 'create_room', name
    @rooms_view.on_join_room (id) =>
      @socket.emit 'rooms:subscribe', id
    @socket.on 'rooms:created', @rooms_view.append_room
    @socket.on 'rooms:joined',  @on_room_joined
    @socket.on 'rooms:message', @on_room_message
    @socket.on 'users:joined',  @on_user_joined
    @socket.on 'users:left',    @on_user_left
    @socket.on 'generic_error', @show_error
    $('#rooms_list').on 'shown.bs.tab', 'a[data-toggle="tab"]', @on_tab_shown
    @input_widget.on_message @send_message_to_active_room

  send_message_to_active_room: (msg) =>
    room_id = @active_room().room.id
    @socket.emit 'rooms:message', room: room_id, message: msg

  on_tab_shown: (e) =>
    if $(e.target).attr('id')?
      @input_widget.show()
      room_id = $(e.target).data('room')
      @rooms_views[room_id].update_size()
    else
      @input_widget.hide()

  on_room_message: (data) =>
    @rooms_views[data.room].append data

  on_user_joined: (data) =>
    @rooms_views[data.room].user_joined data

  on_user_left: (data) =>
    @rooms_views[data.room].user_left data

  on_room_joined: (data) =>
    @rooms_views[data.room.id] ?= new Chat.RoomView(data.room, data.messages, data.users)
    @rooms_views[data.room.id].scroll_locked = true
    @rooms_views[data.room.id].activate()