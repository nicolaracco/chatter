@Chat ?= {}

class Chat.RoomChooser
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