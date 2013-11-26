util = require 'util'

class Logger
  log: (message) ->
    console.log message

  debug: (message) ->
    util.debug message

  error: (message) ->
    console.error message

module.exports = Logger