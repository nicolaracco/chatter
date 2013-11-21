# config file loader

fs    = require 'fs'
nconf = require 'nconf'

module.exports = (server) ->
  nconf.argv().env() # load config from ARGV and ENV variables
  if fs.existsSync "#{server.root}/config.local.json"
    nconf.file 'local', "#{server.root}/config.local.json" # load from local
  nconf.file "#{server.root}/config.json" # load from default
  server.config = nconf.load()