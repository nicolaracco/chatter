class RoomsChooser
  callbacks: {}

  constructor: ->
    @el = $('#rooms-content')
    @modal = $('#create-room-modal')
    @bind_events()

  on_create_room: (callback) =>
    @callbacks.create_room = callback

  on_join_room: (callback) =>
    @callbacks.join_room = callback

  append_room: (room) =>
    @el.find('li.room').last().after """
      <li class="room">
        <a href="#" data-room="#{room.id}">#{room.name}</a>
      </li>
    """

  bind_events: =>
    @modal.find('form').submit @on_form_submitted
    @el.on 'click', 'li.room a', (e) =>
      e.preventDefault()
      @callbacks.join_room? $(e.target).attr('data-room')

  on_form_submitted: (e) =>
    e.preventDefault()
    room_name_input = @modal.find('#room-name-input')
    room_name = room_name_input.val()
    room_name_input.val('')
    @callbacks.create_room? room_name
    @modal.modal 'hide'

class RoomView
  scroll_locked: true

  constructor: (@room, messages, users) ->
    @create_element()
    @el = $("#room-#{@room.id}")
    for message in messages
      @append message
    users_items = ("<li data-user='#{u}'>#{u}</li>" for u in users)
    @get_users_list().append users_items.join ''
    @bind_events()

  append: (data) =>
    @get_output_wrapper().append """
      <p class="message">
        <span class="time">#{data.at}</span>
        <span class="user">#{data.user}</span>
        <span class="message">#{data.message}</span>
      </p>
    """
    @scroll_to_bottom() if @scroll_locked

  user_joined: (data) =>
    @get_users_list().append """
      <li data-user="#{data.user}">#{data.user}</li>
    """
    @get_output_wrapper().append """
      <p class="joined">
        <span class="time">#{data.at}</span>
        <span class="user">#{data.user}</span>
        <span class="message">joined the room</span>
      </p>
    """

  user_left: (data) =>
    @get_users_list().find("li[data-user='#{data.user}']").remove()
    @get_output_wrapper().append """
      <p class="left">
        <span class="time">#{data.at}</span>
        <span class="user">#{data.user}</span>
        <span class="message">left the room</span>
      </p>
    """

  activate: =>
    $("#room-link-#{@room.id}").tab 'show'

  is_active: =>
    $("#room-link-#{@room.id}").parent().is '.active'

  update_size: =>
    @get_output().add(@get_users_list_container()).css
      height: window.innerHeight - @get_output().offset().top - $('#input-navbar').height()
    @scroll_to_bottom() if @scroll_locked

  get_output: =>
    @el.find('.room-output')

  get_output_wrapper: =>
    @el.find('.room-output .wrapper')

  get_users_list_container: =>
    @el.find('.users-list')

  get_users_list: =>
    @el.find('.users-list ul')

  create_element: =>
    $('#rooms_list').append """
      <li>
        <a id="room-link-#{@room.id}" data-room="#{@room.id}" href="#room-#{@room.id}" data-toggle="tab">#{@room.name}</a>
      </li>
    """
    $('.tab-content').append """
      <div id="room-#{@room.id}" data-room="#{@room.id}" class="tab-pane">
        <div class="row">
          <div class="room-output col-md-10">
            <div class="wrapper"></div>
          </div>
          <div class="users-list col-md-2">
            <ul></ul>
          </div>
        </div>
      </div>
    """

  bind_events: =>
    $(window).resize @update_size
    @get_output().scroll @on_output_scrolled

  on_output_scrolled: =>
    output = @get_output()
    max_scroll = @get_output_wrapper().height() - output.height()
    @scroll_locked = output.scrollTop() > max_scroll - 10

  scroll_to_bottom: =>
    output = @get_output()
    output.scrollTop @get_output_wrapper().height() - output.height()


class Chatter
  scroll_locked: true
  rooms_views: {}

  constructor: ->
    @socket = io.connect 'http://localhost'
    @rooms_view = new RoomsChooser
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
    $('#send-input').keyup (e) =>
      if e.keyCode is 13
        e.preventDefault()
        @socket.emit 'rooms:message', room: @active_room().room.id, message: $(e.target).val()
        $(e.target).val ''

  on_tab_shown: (e) =>
    if $(e.target).attr('id')?
      $('#input-navbar').removeClass 'hide'
      room_id = $(e.target).data('room')
      @rooms_views[room_id].update_size()
    else
      $('#input-navbar').addClass 'hide'

  on_room_message: (data) =>
    @rooms_views[data.room].append data

  on_user_joined: (data) =>
    @rooms_views[data.room].user_joined data

  on_user_left: (data) =>
    @rooms_views[data.room].user_left data

  on_room_joined: (data) =>
    @rooms_views[data.room.id] ?= new RoomView(data.room, data.messages, data.users)
    @rooms_views[data.room.id].scroll_locked = true
    @rooms_views[data.room.id].activate()

$ ->
  new Chatter() if $('#chat').length > 0