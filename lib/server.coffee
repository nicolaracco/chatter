# SERVER

models     = require '../app/models'
express    = require 'express'
glob       = require 'glob'
path       = require 'path'
http       = require 'http'
SocketIO   = require 'socket.io'

class Server
  callbacks:
    start: []
    stop : []

  constructor: (@root, @env) ->
    @env   ?= process.env.NODE_ENV ? 'development'
    @load_configuration()
    @app    = express()
    @configure()

  # Scoping socket.io creation in start method
  # allow us to use the same Server class even when we don't need to start
  # the server (like in Jakefile)
  start: =>
    @server = http.createServer(@app)
    @io = SocketIO.listen @server
    callback() for callback in @callbacks.start
    @load_controllers()
    @server.listen @config.server.port
    console.log "Listening on port #{@config.server.port}"

  # simple callback management
  on: (event, callback) => @callbacks[event].push callback

  stop: =>
    # no need to stop anything if the server has not been started
    if @server?
      console.log 'Shutting down gracefully.'
      @server.close ->
        console.log "Closed out remaining connections."
        callback() for callback in @callbacks.stop
        process.exit()
      setTimeout ->
        console.error "Could not close connections in time, forcefully shutting down"
        process.exit 1
      , 10000
    else
      callback() for callback in @callbacks.stop

  # PRIVATE METHODS

  load_controllers: =>
    controllers = glob.sync "#{@root}/app/controllers/*_controller.coffee"
    for controller in controllers
      require(controller).setup(@)

  configure: =>
    @app.configure =>
      require('../config/initializers/')(@)
      @app.use @app.router



  # Load configuration files
  # Order of priority:
  # - ARGV
  # - ENV
  # - config/environments/config.NODE_ENV.local.json
  # - config/environments/config.NODE_ENV.json
  # - config/config.local.json
  # - config/config.json
  load_configuration: =>
    fs    = require 'fs'
    nconf = require 'nconf'
    nconf.argv().env() # load config from ARGV and ENV variables
    config_files = [
      "environments/config.#{@env}.local.json"
      "environments/config.#{@env}.json",
      "config.local.json",
      "config.json"
    ]
    for config_file in config_files
      path = "#{@root}/config/#{config_file}"
      nconf.file config_file, path if fs.existsSync path
    @config = nconf.load()

module.exports = Server