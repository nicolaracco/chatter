#= require room/message
#= require room/action_message
#= require room/talk_message
#= require room/error_message
#= require room/collection
#= require room/message_group

@Chat ?= {}

templates =
  user_entry: """
    <li class="list-group-item" data-user="<%= id %>">
      <span class="glyphicon glyphicon-user"></span>
      <%= name %>
    </li>
  """
  tab_link: """
    <li data-room="<%= id %>">
      <a id="room-link-<%= id %>" href="#room-<%= id %>" data-toggle="tab">
        <span class="glyphicon glyphicon-bullhorn"></span>
        <%= name %>
        <button type="button" class="close close-tab" aria-hidden="true">&times;</button>
      </a>
    </li>
  """
  tab_pane: """
    <div id="room-<%= id %>" data-room="<%= id %>" class="tab-pane">
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

class Chat.RoomView
  callbacks: {}
  scroll_locked: true

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
    @collection ?= new Chat.Room.Collection @get_output_wrapper()
    message = @build_message data
    if @collection.last()?.message_can_stay message
      @collection.last().add message
    else
      group = new Chat.Room.MessageGroup message
      @collection.add group
      group.add message
    @scroll_to_bottom() if @scroll_locked

  build_message: (data) =>
    data.username = data.user
    Klass = switch data.type
      when 'error'  then Chat.Room.ErrorMessage
      when 'joined' then Chat.Room.JoinMessage
      when 'left'   then Chat.Room.LeftMessage
      else Chat.Room.TalkMessage
    new Klass data

  user_joined: (data) =>
    @get_users_list().append @user_template data.user
    @append data

  user_left: (data) =>
    @get_users_list().find("li[data-user='#{data.user}']").remove()
    @append data

  user_template: (user) => _(templates.user_entry).template id: user, name: user

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
    list_item_el = $ _(templates.tab_link).template id: @id, name: @name
    $('#rooms_list').append list_item_el
    @link_el = list_item_el.children 'a'

  create_element: =>
    @el = $ _(templates.tab_pane).template id: @id
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