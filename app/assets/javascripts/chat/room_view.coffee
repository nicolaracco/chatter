@Chat ?= {}

class Chat.RoomView
  scroll_locked: true
  last_received_day_id: null

  constructor: (@room, messages, users) ->
    @create_element()
    @el = $("#room-#{@room.id}")
    for message in messages
      @append message
    @get_users_list().append (@user_template user for user in users).join ''
    @bind_events()

  append: (data) =>
    console.dir data.at
    day_id = @format_date_id(data.at)
    if day_id isnt @last_received_day_id
      @get_output_wrapper().append """
        <p class="day_header">
          <span class="time"></span>
          <span class="user"></span>
          <span class="message">#{@format_date_header data.at}</span>
        </p>
      """
      @last_received_day_id = day_id
    @get_output_wrapper().append """
      <p class="message">
        <span class="time">#{@format_date data.at}</span>
        <span class="user">#{data.user}</span>
        <span class="message">#{data.message}</span>
      </p>
    """
    @scroll_to_bottom() if @scroll_locked

  user_joined: (data) =>
    @get_users_list().append @user_template data.user
    @get_output_wrapper().append """
      <p class="joined">
        <span class="time">#{@format_date data.at}</span>
        <span class="user">#{data.user}</span>
        <span class="message">joined the room</span>
      </p>
    """

  user_left: (data) =>
    @get_users_list().find("li[data-user='#{data.user}']").remove()
    @get_output_wrapper().append """
      <p class="left">
        <span class="time">#{@format_date data.at}</span>
        <span class="user">#{data.user}</span>
        <span class="message">left the room</span>
      </p>
    """

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
    output.scrollTop @get_output_wrapper().height() - output.height()

  format_date: (date) => moment(new Date date).format("HH:mm:ss")

  format_date_id: (date) => moment(new Date date).format("YYYYMMDD")

  format_date_header: (date) => moment(new Date date).format("dddd, MMMM Do YYYY")