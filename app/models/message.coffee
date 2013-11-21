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

module.exports = schema