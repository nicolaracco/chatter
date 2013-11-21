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
      @io.sockets.in("room-#{id}").emit 'users:left', room: id, at: new Date, user: @user.email

  # returns the ids of all the subscribed rooms
  rooms_ids: =>
    rooms_ids = @io.sockets.manager.roomClients[@socket.id]
    (id.split('-')[1] for id, val of rooms_ids when id.charAt(0) is '/')

  # when the user sends a message for a certain room
  # save the message and notify
  on_room_message: (data) =>
    models.Room.findOne _id: data.room, (err, room) =>
      if room
        @save_and_echo_message room, data
      else
        @socket.emit 'generic_error', 'Cannot find room'

  # save a message for a certain room and notify both the user and the
  # other users subscribed to the same room
  save_and_echo_message: (room, data) =>
    message = new models.Message at: new Date, username: @user.email, message: data.message, _room: room._id
    message.save (err) =>
      if err?
        @socket.emit 'generic_error', "Cannot send message: #{err}"
      else
        @io.sockets.in("room-#{room.id}").emit 'rooms:message',
          room   : room.id
          user   : @user.email
          message: data.message
          at     : message.at

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
        @io.sockets.in("room-#{id}").emit 'users:joined', room: id, at: new Date, user: @user.email
        @socket.join "room-#{id}"
        @find_messages_and_render room
      else
        @socket.emit 'generic_error', 'Cannot find room'

  # it gets the last 20 messages of a room and send all room informations to the user
  find_messages_and_render: (room) =>
    models.Message
      .find(_room: room.id)
      .sort(at: 'desc')
      .limit(20)
      .exec (err, messages) =>
        messages = (for m in messages
          { at: m.at, user: m.username, message: m.message }
        )
        @socket.emit 'rooms:joined',
          room: { id: room.id, name: room.name }
          messages: messages
          users: @user_names_in("room-#{room.id}")

  # list the users subscribed in a certain room
  user_names_in: (id) =>
    (c.handshake.user.email for c in @io.sockets.clients(id))

  @setup: (server) ->
    server.io.on 'connection', (socket) ->
      new SocketIOController(server.io, socket)

module.exports = SocketIOController