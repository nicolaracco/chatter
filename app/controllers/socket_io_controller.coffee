_      = require 'underscore'
models = require '../models'

# Custom controller for socket io management
# For each connection a new controller is created
class SocketIOController
  constructor: (@io, @socket) ->
    @username = @socket.handshake.user.email
    @bind_events()

  bind_events: =>
    @socket.on 'home:rooms',       @send_rooms_list
    @socket.on 'home:create-room', @create_room
    @socket.on 'room:join',        @join_room
    @socket.on 'room:leave',       @leave_room
    @socket.on 'room:talk',        @talk_to_room
    @socket.on 'disconnect',       @disconnect

  disconnect: =>
    for id in @rooms_ids()
      message_attrs = type: 'action', message: 'left this room', room_id: id
      @save_message message_attrs, (message) =>
        @io.sockets.in("room-#{id}").emit "room-#{id}:left", message.to_json()

  send_rooms_list: =>
    models.Room.find (err, rooms) =>
      if err?
        @send_error 'Cannot retrieve rooms list', err
      else
        @socket.emit 'home:rooms', rooms: ({id: r.id, name: r.name} for r in rooms)

  create_room: (name) =>
    room = new models.Room {name}
    room.save (err) =>
      if err?
        @socket.emit 'home:create-room:error', description: "Cannot create a room with name '#{name}'"
      else
        @socket.emit 'home:create-room:success', id: room.id, name: room.name
        @io.sockets.emit 'home:rooms:created', id: room.id, name: room.name

  join_room: (id) =>
    models.Room.findOne _id: id, (err, room) =>
      if err? or not room?
        @send_error 'Cannot find this room', err, id
      else
        message_attrs = type: 'action', message: 'joined this room', room_id: id
        @save_message message_attrs, (message) =>
          @io.sockets.in("room-#{id}").emit "room-#{id}:joined", message.to_json()
          @socket.join "room-#{id}"
          models.Message.last_page_in_room room, (err, messages) =>
            if err?
              @send_error 'Cannot fetch messages', err, id
            else
              messages = (m.to_json() for m in messages)
              @socket.emit "room-#{id}:reset",
                messages: messages
                users   : @user_names_in("room-#{id}")

  talk_to_room: (data) =>
    id = data.id
    models.Room.findOne _id: id, (err, room) =>
      if err? or not room?
        @send_error 'Cannot find this room', err, id
      else
        models.Message.last_one_in_room id, (err, message) =>
          if err?
            @send_error 'Cannot save message', err, data.room_id
          else
            moment = require 'moment'
            if (not message?) or message.type isnt 'talk' or message.username isnt @username or moment().diff(message.updated_at) > 10000
              message = new models.Message
                at      : new Date
                username: @username
                message : data.message
                _room   : id
                type    : 'talk'
            else
              message.message += "\n#{data.message}"
            message.save (err) =>
              if err?
                @send_error 'Cannot save the message', err, id
              else
                @io.sockets.in("room-#{room.id}").emit "room-#{id}:log", message.to_json()

  leave_room: (id) =>
    if @rooms_ids().indexOf(id) >= 0
      @socket.leave "room-#{id}"
      message_attrs = type: 'left', message: 'left this room', room_id: id
      @save_message message_attrs, (message) =>
        @io.sockets.in("room-#{id}").emit "room-#{id}:left", message.to_json()
    else
      @send_error 'You are not subscribed to this room', null, id

  # shortand function to save a message with the current user as subject
  # and execute a success callback
  save_message: (data, success) =>
    message = new models.Message at: new Date, username: @username, message: data.message, _room: data.room_id, type: data.type
    message.save (err) =>
      if err?
        @send_error 'Cannot save message', err, data.room_id
      else
        success message

  # list the users subscribed in a certain room
  user_names_in: (id) =>
    ({user: c.handshake.user.email} for c in @io.sockets.clients(id))

  # returns the ids of all the subscribed rooms
  rooms_ids: =>
    rooms_ids = @io.sockets.manager.roomClients[@socket.id]
    (id.split('-')[1] for id, val of rooms_ids when id.charAt(0) is '/')

  send_error: (message, err, room_id) =>
    message = if err? then "#{message}: #{err}" else message
    if room_id?
      @socket.emit "room-#{room_id}:error", room: room_id, description: message
    else
      @socket.emit 'home:error', message

  @setup: (server) ->
    server.io.on 'connection', (socket) ->
      new SocketIOController(server.io, socket)

module.exports = SocketIOController