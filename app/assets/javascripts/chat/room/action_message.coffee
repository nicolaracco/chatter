@Chat ?= {}
Chat.Room ?= {}

class Chat.Room.ActionMessage extends Chat.Room.Message
  constructor: (attributes) ->
    super attributes

  create_el_tag: =>
    super highlight_mode: "#{@highlight_mode()} action #{@get 'type'}"

class Chat.Room.JoinMessage extends Chat.Room.ActionMessage
  constructor: (attributes) ->
    attributes = _({}).extend attributes,
      type   : 'joined'
      message: 'joined this room'
    super attributes

class Chat.Room.LeftMessage extends Chat.Room.ActionMessage
  constructor: (attributes) ->
    attributes = _({}).extend attributes,
      type   : 'left'
      message: 'left this room'
    super attributes