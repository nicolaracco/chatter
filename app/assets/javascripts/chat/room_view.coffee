@Chat ?= {}

class Chat.RoomView
  scroll_locked: true
  last_received_day_id: null
  last_received_time_id: null

  constructor: (@room, messages, users) ->
    @create_element()
    @el = $("#room-#{@room.id}")
    for message in messages
      @append message
    @get_users_list().append (@user_template user for user in users).join ''
    @bind_events()

  append: (data) =>
    day_id = @format_date_id(data.at)
    time_id = @format_date data.at
    if day_id isnt @last_received_day_id
      @get_output_wrapper().append """
        <p class="day_header">
          <span class="time"></span>
          <span class="user"></span>
          <span class="message">#{@format_date_header data.at}</span>
        </p>
      """
      @last_received_day_id = day_id

    if data.type is 'joined'
      data.message = 'joined this room'
    else if data.type is 'left'
      data.message = 'left this room'

    time_to_show = if time_id is @last_received_time_id
      ''
    else
      @last_received_time_id = time_id

    @get_output_wrapper().append """
      <p class="#{data.type ? 'message'}">
        <span class="time">#{time_to_show}</span>
        <span class="user">#{data.user}</span>
        <span class="message">#{data.message}</span>
      </p>
    """
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

  format_date: (date) => moment(new Date date).format("HH:mm")

  format_date_id: (date) => moment(new Date date).format("YYYYMMDD")

  format_date_header: (date) => moment(new Date date).format("dddd, MMMM Do YYYY")