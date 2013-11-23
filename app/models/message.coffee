_ = require 'underscore'
Schema = require('mongoose').Schema

schema = Schema
  _room:
    type    : Schema.Types.ObjectId
    required: true
    ref     : 'Room'
  at:
    type    : Date
    required: true
  username:
    type    : String
    required: true
  message:
    type    : String
    required: true
  type:
    type    : String
    required: true

schema.methods.to_json = ->
  {
    at     : @at,
    user   : @username,
    message: @message,
    type   : @type,
    room   : @_room
  }

schema.statics.last_in_room = (room_id, callback) ->
  @find(_room: room_id).sort(at: -1).limit(20).exec (err, messages) ->
    if err?
      callback err
    else
      callback null, _(messages).reverse()

module.exports = schema