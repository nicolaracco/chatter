@Chat ?= {}

class Chat.RoomView
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