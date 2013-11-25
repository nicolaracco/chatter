Schema = require('mongoose').Schema

schema = Schema
  name:
    type    : String
    required: true
    index   :
      unique: true
  messages: [{
    type: Schema.Types.ObjectId
    ref : 'Message'
  }]

schema.plugin require 'mongoose-unique-validator'

schema.methods.to_json = ->
  { id: @id, name: @name }

module.exports = schema