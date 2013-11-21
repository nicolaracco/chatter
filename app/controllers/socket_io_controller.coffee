_      = require 'underscore'
models = require '../models'

# Custom controller for socket io management
# For each connection a new controller is created
class SocketIOController
  constructor: (@io, @socket) ->
    @user = @socket.handshake.user
    @bind_events()

  get_username: => @user.email

  bind_events: =>
    @socket.on 'create_room',     @on_create_room
    @socket.on 'rooms:subscribe', @on_room_subscription
    @socket.on 'rooms:message',   @on_room_message
    @socket.on 'disconnect',      @on_disconnection

  # when a user disconnects we notify all users subscribed to the same room
  # of the event
  on_disconnection: =>
    for id in @rooms_ids()
      message_attrs = type: 'left', message: 'left', room_id: id
      @save_message message_attrs, (message) =>
        @io.sockets.in("room-#{id}").emit 'users:left', @message_handle(message)

  # returns the ids of all the subscribed rooms
  rooms_ids: =>
    rooms_ids = @io.sockets.manager.roomClients[@socket.id]
    (id.split('-')[1] for id, val of rooms_ids when id.charAt(0) is '/')

  # when the user sends a message for a certain room
  # save the message and notify
  on_room_message: (data) =>
    models.Room.findOne _id: data.room, (err, room) =>
      if room
        message_attrs = type: 'talk', message: data.message, room_id: data.room
        @save_message message_attrs, (message) =>
          @io.sockets.in("room-#{room.id}").emit 'rooms:message', @message_handle(message)
      else
        @socket.emit 'generic_error', 'Cannot find room'

  # when a user creates a room, it notifies all users of the new room
  on_create_room: (name) =>
    room = new models.Room {name}
    room.save (err) =>
      if err?
        msg = if err.errors.name?
          'Name already taken'
        else
          err.message
        @socket.emit 'generic_error', "Cannot create the room: #{msg}"
      else
        @io.sockets.emit 'rooms:created', id: room.id, name: room.name

  # on room subscription, notifies the other user subscribed to the same room
  on_room_subscription: (id) =>
    models.Room.findOne _id: id, (err, room) =>
      if room
        message_attrs = type: 'joined', message: 'joined', room_id: id
        @save_message message_attrs, (message) =>
          @io.sockets.in("room-#{id}").emit 'users:joined', @message_handle(message)
          @socket.join "room-#{id}"
          @find_messages_and_render room
      else
        @socket.emit 'generic_error', 'Cannot find room'

  # shortand function to save a message with the current user as subject
  # and execute a success callback
  save_message: (data, success) =>
    message = new models.Message at: new Date, username: @user.email, message: data.message, _room: data.room_id, type: data.type
    message.save (err) =>
      if err?
        @socket.emit 'generic_error', "Cannot send message: #{err}"
      else
        success message

  # it gets the last 20 messages of a room and send all room informations to the user
  find_messages_and_render: (room) =>
    models.Message
      .find(_room: room.id)
      .sort(at: -1)
      .limit(20)
      .exec (err, messages) =>
        messages = (@message_handle(m) for m in _(messages).reverse())
        @socket.emit 'rooms:joined',
          room: { id: room.id, name: room.name }
          messages: messages
          users: @user_names_in("room-#{room.id}")

  message_handle: (message) ->
    {
      at     : message.at,
      user   : message.username,
      message: message.message,
      type   : message.type,
      room   : message._room
    }

  # list the users subscribed in a certain room
  user_names_in: (id) =>
    (c.handshake.user.email for c in @io.sockets.clients(id))

  @setup: (server) ->
    server.io.on 'connection', (socket) ->
      new SocketIOController(server.io, socket)

module.exports = SocketIOController