# config file loader

fs    = require 'fs'
nconf = require 'nconf'

module.exports = (server) ->
  nconf.argv().env() # load config from ARGV and ENV variables
  env = process.env.NODE_ENV ? 'development'
  config_files = [
    "environments/config.#{env}.local.json"
    "environments/config.#{env}.json",
    "config.local.json",
    "config.json"
  ]
  for config_file in config_files
    path = "#{server.root}/config/#{config_file}"
    nconf.file config_file, path if fs.existsSync path
  server.config = nconf.load()