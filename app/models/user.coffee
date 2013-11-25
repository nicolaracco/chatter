bcrypt = require 'bcrypt'
Schema = require('mongoose').Schema
salt_work_factor = 10

schema = Schema
  email:
    type    : String
    required: true
    index   :
      unique: true
  password:
    type    : String
    required: true

schema.plugin require 'mongoose-unique-validator'

schema.path('email').validate (email) ->
  if email?
    emailRegex = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/
    emailRegex.test email
, 'Email is not valid.'

# password handshaking
schema.pre 'save', (next) ->
  return next() unless @isModified('password')
  bcrypt.genSalt salt_work_factor, (err, salt) =>
    return next(err) if err?
    bcrypt.hash @password, salt, (err, hash) =>
      return next(err) if err?
      @password = hash
      next()

# password checking method
schema.methods.compare_password = (candidate_password, next) ->
  bcrypt.compare candidate_password, @password, (err, is_match) ->
    return next(err) if err?
    next null, is_match

module.exports = schema