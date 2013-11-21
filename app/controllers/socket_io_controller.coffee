_      = require 'underscore'
models = require '../models'

# Custom controller for socket io management
# For each connection a new controller is created
class SocketIOController
  constructor: (@io, @socket) ->
    @username = @socket.handshake.user.email
    @bind_events()

  bind_events: =>
    @socket.on 'create_room',       @on_create_room
    @socket.on 'rooms:subscribe',   @on_room_subscription
    @socket.on 'rooms:unsubscribe', @on_room_unsubscription
    @socket.on 'rooms:message',     @on_room_message
    @socket.on 'disconnect',        @on_disconnection

  # when a user disconnects we notify all users subscribed to the same room
  # of the event
  on_disconnection: =>
    for id in @rooms_ids()
      message_attrs = type: 'left', message: 'left', room_id: id
      @save_message message_attrs, (message) =>
        @io.sockets.in("room-#{id}").emit 'users:left', message.to_json()

  # when the user sends a message for a certain room
  # save the message and notify
  on_room_message: (data) =>
    @find_room data.room, (room) =>
      message_attrs = type: 'talk', message: data.message, room_id: data.room
      @save_message message_attrs, (message) =>
        @io.sockets.in("room-#{room.id}").emit 'rooms:message', message.to_json()

  # when a user creates a room, it notifies all users of the new room
  on_create_room: (name) =>
    room = new models.Room {name}
    room.save (err) =>
      if err?
        msg = if err.errors.name? then 'Name already taken' else err.message
        @send_error 'Cannot send message', msg
      else
        @io.sockets.emit 'rooms:created', id: room.id, name: room.name

  # on room subscription, notifies the other user subscribed to the same room
  on_room_subscription: (id) =>
    @find_room id, (room) =>
      message_attrs = type: 'joined', message: 'joined', room_id: id
      @save_message message_attrs, (message) =>
        @io.sockets.in("room-#{id}").emit 'users:joined', message.to_json()
        @socket.join "room-#{id}"
        @find_messages_and_render room

  on_room_unsubscription: (id) =>
    if @rooms_ids().indexOf(id) >= 0
      @socket.leave "room-#{id}"
      message_attrs = type: 'left', message: 'left', room_id: id
      @save_message message_attrs, (message) =>
        @io.sockets.in("room-#{id}").emit 'users:left', message.to_json()
    else
      @send_error 'You are not subscribed to this room'

  # shortand function to save a message with the current user as subject
  # and execute a success callback
  save_message: (data, success) =>
    message = new models.Message at: new Date, username: @username, message: data.message, _room: data.room_id, type: data.type
    message.save (err) =>
      if err?
        @send_error 'Cannot send message', err
      else
        success message

  find_room: (id, success) =>
    models.Room.findOne _id: id, (err, room) =>
      if room
        success(room)
      else
        @send_error 'Cannot find room', err

  # it gets the last 20 messages of a room and send all room informations to the user
  find_messages_and_render: (room) =>
    models.Message
      .find(_room: room.id)
      .sort(at: -1)
      .limit(20)
      .exec (err, messages) =>
        messages = (m.to_json() for m in _(messages).reverse())
        @socket.emit 'rooms:joined',
          room    : room.to_json()
          messages: messages
          users   : @user_names_in("room-#{room.id}")

  # list the users subscribed in a certain room
  user_names_in: (id) =>
    (c.handshake.user.email for c in @io.sockets.clients(id))

  # returns the ids of all the subscribed rooms
  rooms_ids: =>
    rooms_ids = @io.sockets.manager.roomClients[@socket.id]
    (id.split('-')[1] for id, val of rooms_ids when id.charAt(0) is '/')

  send_error: (message, err) =>
    message = if err? then "#{message}: #{err}" else message
    @socket.emit 'generic_error', message

  @setup: (server) ->
    server.io.on 'connection', (socket) ->
      new SocketIOController(server.io, socket)

module.exports = SocketIOController