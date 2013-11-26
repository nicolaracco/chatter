module.exports = (server) ->
  available_modules = ['assets', 'authentication', 'flash']
  server.logger.debug "Loaded initializers: "
  for module in available_modules
    require("./#{module}")(server)
    server.logger.debug "\t- #{module}"