@Chat ?= {}

class Chat.RoomChooser
  callbacks: {}

  constructor: (@el) ->
    @bind_events()

  get_rooms_list: => @el.find('ul.nav').first()

  get_modal: => @el.find('.modal').first()

  on_create_room: (callback) =>
    @callbacks.create_room = callback

  on_join_room: (callback) =>
    @callbacks.join_room = callback

  append_room: (room) =>
    @get_rooms_list().find('li.room').last().after """
      <li class="room">
        <a href="#" data-room="#{room.id}">#{room.name}</a>
      </li>
    """

  bind_events: =>
    @get_modal().find('form').submit @on_form_submitted
    @get_rooms_list().on 'click', 'li.room a', (e) =>
      e.preventDefault()
      @callbacks.join_room? $(e.target).attr('data-room')

  on_form_submitted: (e) =>
    e.preventDefault()
    room_name_input = @get_modal().find('#room-name-input')
    room_name = room_name_input.val()
    room_name_input.val('')
    @callbacks.create_room? room_name
    @get_modal().modal 'hide'