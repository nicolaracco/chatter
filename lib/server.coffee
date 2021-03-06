# SERVER
_          = require 'underscore'
models     = require '../app/models'
express    = require 'express'
glob       = require 'glob'
http       = require 'http'
SocketIO   = require 'socket.io'
mongoose   = require 'mongoose'
winston    = require 'winston'

class Server
  inited: false
  callbacks:
    configure: []
    start    : []
    stop     : []

  constructor: (@root, options = {}) ->
    @app = express()
    @load_configuration()
    @logger = new winston.Logger
      transports: [
        new winston.transports.Console level: @config.log.console
        new winston.transports.File    level: @config.log.file, filename: "log/#{@app.get 'env'}.log"
      ]
    @logger.setLevels debug: 0, info: 1, warn: 2, error: 3
    @logger.debug "--- ENV: #{@app.get 'env'} ---"
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
      @io     = SocketIO.listen @server, logger: @logger
      @fire_callbacks 'start'
      @load_controllers()
      @server.listen @config.server.port
      @logger.info "Started on port #{@config.server.port}"
      process.send? status: 'started'
      done?()
    else
      @logger.debug "Server not inited. Initing now ..."
      @init => @start done

  # This method should be called for graceful shutdown
  # but there is an issue in Socket.IO preventing the server to be closed
  # correctly. So we close only what we can close and we exit
  stop: =>
    callback = _.after 2, =>
      @fire_callbacks 'stop'
      process.send? status: 'stopped'
      process.exit() if @server?
    @stop_session_store callback
    @stop_db callback

  # PRIVATE METHODS

  force_quit: (done) =>
    @logger.error "Cannot stop the server in time. Forcing quit"
    if done? then done(new Error 'Cannot stop gracefully') else process.exit(1)

  load_controllers: =>
    controllers = glob.sync "#{@root}/app/controllers/*_controller.coffee"
    @logger.debug "Loading controllers:"
    for controller in controllers
      @logger.debug "\t- #{controller}"
      require(controller).setup(@)

  init_app: =>
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
      "environments/config.#{@app.get 'env'}.local.json"
      "environments/config.#{@app.get 'env'}.json",
      "config.local.json",
      "config.json"
    ]
    for config_file in config_files
      path = "#{@root}/config/#{config_file}"
      nconf.file config_file, path if fs.existsSync path
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
