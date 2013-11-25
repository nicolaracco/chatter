module.exports = (server) ->
  available_modules = ['db', 'assets', 'app', 'authentication', 'flash']
  require("./#{module}")(server) for module in available_modules