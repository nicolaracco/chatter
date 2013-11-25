mongoose = require 'mongoose'

module.exports = GLOBAL.models ?= do ->
  User   : mongoose.model 'User',    require('./user')
  Room   : mongoose.model 'Room',    require('./room')
  Message: mongoose.model 'Message', require('./message')