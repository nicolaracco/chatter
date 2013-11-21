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
        @el.addClass @same_color_respect_to previous
      else
        @el.addClass @inverse_color_respect_to previous
    else
      @el.addClass @inverse_color_respect_to previous

  inverse_color_respect_to: (previous) =>
    if previous.el.hasClass 'darken'
      'lighten'
    else
      'darken'

  same_color_respect_to: (previous) =>
    if previous.el.hasClass 'darken'
      'darken'
    else
      'lighten'

class Chat.RoomView
  callbacks: {}
  scroll_locked: true
  last_received_message: null

  constructor: (room, messages, users) ->
    [@id, @name] = [room.id, room.name]
    @create_link_element()
    @create_element()
    for message in messages
      @append message
    @get_users_list().append (@user_template user for user in users).join ''
    @bind_events()

  on_close: (callback) => @callbacks.close = callback

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
      <li class="list-group-item" data-user="#{user}">
        <span class="glyphicon glyphicon-user"></span>
        #{user}
      </li>
    """

  activate: =>
    @link_el.tab 'show'

  is_active: =>
    @link_el.parent().is '.active'

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

  create_link_element: =>
    list_item_el = $ """
      <li data-room="#{@id}">
        <a id="room-link-#{@id}" href="#room-#{@id}" data-toggle="tab">
          <span class="glyphicon glyphicon-bullhorn"></span>
          #{@name}
          <button type="button" class="close close-tab" aria-hidden="true">&times;</button>
        </a>
      </li>
    """
    $('#rooms_list').append list_item_el
    @link_el = $("#room-link-#{@id}")

  create_element: =>
    @el = $ """
      <div id="room-#{@id}" data-room="#{@id}" class="tab-pane">
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
    $('.tab-content').append @el

  bind_events: =>
    $(window).resize @update_size
    @get_output().scroll @on_output_scrolled
    @link_el.find('.close-tab').click (e) =>
      e.preventDefault()
      @link_el.remove()
      @el.remove()
      @callbacks.close? @

  on_output_scrolled: =>
    output = @get_output()
    max_scroll = @get_output_wrapper().height() - output.height()
    @scroll_locked = output.scrollTop() > max_scroll - 10

  scroll_to_bottom: =>
    output = @get_output()
    output.scrollTop @get_output_wrapper().height() - output.height() + 15