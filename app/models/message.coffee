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

module.exports = schema