@Chat ?= {}

class Message
  constructor: (@data) ->
    @data.at     = new Date @data.at
    @data.type  ?= 'message'
    @day_id      = moment(@data.at).format 'YYYYMMDD'
    @date_header = moment(@data.at).format("dddd, MMMM Do YYYY")
    @time_id     = moment(@data.at).format 'HH:mm'
    @username    = @data.user
    @create_element()

  get_message: =>
    if @data.type is 'joined'
      'joined this room'
    else if @data.type is 'left'
      'left this room'
    else
      @data.message

  create_element: =>
    @el = $ """
      <p class="#{@data.type}">
        <span class="time">#{@time_id}</span>
        <span class="user">#{@username}</span>
        <span class="message">#{@get_message()}</span>
      </p>
    """

  style_respect_to_previous: (previous) =>
    if previous.time_id is @time_id
      @el.find('.time').text('')
      if @data.type is previous.data.type and previous.username is @username
        @el.find('.user').text('')
      else
        @el.addClass @inverse_color_respect_to previous
    else
      @el.addClass @inverse_color_respect_to previous

  inverse_color_respect_to: (previous) =>
    if previous.el.hasClass 'darken'
      @el.addClass 'lighter'
    else
      @el.addClass 'darken'

class Chat.RoomView
  scroll_locked: true
  last_received_message: null

  constructor: (@room, messages, users) ->
    @create_element()
    @el = $("#room-#{@room.id}")
    for message in messages
      @append message
    @get_users_list().append (@user_template user for user in users).join ''
    @bind_events()

  append: (data) =>
    message = new Message data
    if message.day_id isnt @last_received_message?.day_id
      @get_output_wrapper().append """
        <p class="day_header">
          <span class="time"></span>
          <span class="user"></span>
          <span class="message">#{message.date_header}</span>
        </p>
      """
    message.style_respect_to_previous @last_received_message if @last_received_message?
    @last_received_message = message
    @get_output_wrapper().append message.el
    @scroll_to_bottom() if @scroll_locked

  user_joined: (data) =>
    @get_users_list().append @user_template data.user
    @append data

  user_left: (data) =>
    @get_users_list().find("li[data-user='#{data.user}']").remove()
    @append data

  user_template: (user) =>
    """
      <li class="list-group-item" data-user="#{user}">#{user}</li>
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
            <ul class="list-group"></ul>
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
    output.scrollTop @get_output_wrapper().height() - output.height() + 15