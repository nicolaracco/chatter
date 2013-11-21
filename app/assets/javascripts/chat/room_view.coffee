#= require room/message_model
#= require room/messages_collection
#= require room/day_group_model
#= require room/day_groups_collection
#= require room/user_entry

@Chat ?= {}

templates =
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

    @collection = new Chat.Room.DayGroups
    @view = new Chat.Room.DayGroupsView collection: @collection
    @el.find('.row').append @view.render().$el

    for message in messages
      @append message

    @users = new Chat.Room.UserEntries
    @users_view = new Chat.Room.UserEntriesView collection: @users
    @el.find('.row').append @users_view.render().$el

    for user in users
      @users.add @users.model {user}
    @bind_events()

  on_close: (callback) => @callbacks.close = callback

  append: (data) =>
    group_id = @collection.id_from_raw_data(data)
    day_group = @collection.findWhere id: group_id
    unless day_group?
      day_group = @collection.model data
      @collection.add day_group
    message = day_group.messages.model data
    day_group.messages.add message
    @scroll_to_bottom() if @scroll_locked

  user_joined: (data) =>
    @users.add @users.model data
    @append data

  user_left: (data) =>
    @users.remove @users.findWhere(name: data.user)
    @append data

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