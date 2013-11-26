# SERVER
_          = require 'underscore'
Logger     = require './logger'
models     = require '../app/models'
express    = require 'express'
glob       = require 'glob'
http       = require 'http'
SocketIO   = require 'socket.io'
mongoose   = require 'mongoose'

class Server
  inited: false
  callbacks:
    configure: []
    start    : []
    stop     : []

  constructor: (@root, @env) ->
    @logger = new Logger
    @env   ?= process.env.NODE_ENV ? 'development'
    @logger.debug "--- ENV: #{@env} ---"
    @load_configuration()
    require("#{@root}/config/initializers/") @

  init: (done) =>
    callback = _.after 2, =>
      @inited = true
      done?()
    @init_db callback
    @init_session_store callback

  on: (event, callback) => @callbacks[event].push callback

  # Scoping socket.io creation in start method
  # allow us to use the same Server class even when we don't need to start
  # the server (like in Jakefile)
  start: (done) =>
    if @inited
      @logger.debug "Starting ..."
      @init_app()
      @server = http.createServer(@app)
      @io     = SocketIO.listen @server
      @fire_callbacks 'start'
      @load_controllers()
      @server.listen @config.server.port
      @logger.debug "Listening on port #{@config.server.port}"
      done?()
    else
      @logger.debug "Server not inited. Initing now ..."
      @init => @start done

  # Callback is called with true if stop is done gracefully
  # or with false if the server cannot be stopped gracefully
  # If no callback is given and the server cannot be stopped gracefully
  # it will exit with code 1
  stop: (done) =>
    callback = _.after 2, =>
      @fire_callbacks 'stop'
      if @server?
        @logger.debug "Closing connections"
        s.close() for s in @io.sockets
        @server.close()
        done?()
      else
        done?()
    @stop_session_store callback
    @stop_db callback
    setTimeout =>
      @logger.error "Cannot stop the server in time. Forcing quit"
      if done? then done(new Error 'Cannot stop gracefully') else process.exit(1)
    , 10000

  # PRIVATE METHODS

  load_controllers: =>
    controllers = glob.sync "#{@root}/app/controllers/*_controller.coffee"
    @logger.debug "Loading controllers:"
    for controller in controllers
      @logger.debug "\t- #{controller}"
      require(controller).setup(@)

  init_app: =>
    @app = express()
    @app.configure =>
      @app.use require('express-partials')()
      @app.use express.cookieParser()
      @app.use express.json()
      @app.use express.urlencoded()
      @app.use express.methodOverride()
      @app.use express.session
        store : @session_store
        secret: @config.session.secret
      @app.set 'views',       './app/views'
      @app.set 'view engine', 'jade'
      @app.set 'layout',      'layout'
      @fire_callbacks 'configure', @app
      @app.use @app.router

  fire_callbacks: (event, args...) =>
    @logger.debug "TRIGGERING #{event}"
    callback(args...) for callback in @callbacks[event]

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
    @logger.debug "Configuration loaded from: "
    for config_file in config_files
      path = "#{@root}/config/#{config_file}"
      nconf.file config_file, path if fs.existsSync path
      @logger.debug "\t- #{path}"
    @config = nconf.load()

  init_db: (callback) =>
    mongoose.connect @config.db.uri, =>
      @logger.debug "Initialized Mongoose (URI: #{@config.db.uri})"
      callback()

  stop_db: (callback) =>
    mongoose.disconnect =>
      @logger.debug "Stopped Mongoose"
      callback()

  init_session_store: (callback) =>
    RedisStore = require('connect-redis')(express)
    @session_store = new RedisStore
    @session_store.on 'connect', =>
      @logger.debug "Initialized Redis Store"
      callback()

  stop_session_store: (callback) =>
    @session_store.client.quit()
    @logger.debug "Stopped Redis Store"
    callback()

module.exports = Server