module.exports = (server) ->
  available_modules = ['configuration', 'db', 'assets', 'app', 'authentication']
  require("./#{module}")(server) for module in available_modules