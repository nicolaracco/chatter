# Connect-Assets configuration

express = require 'express'

module.exports = (server) ->
  server.on 'configure', (app) ->
    app.use require('connect-assets')
      build   : server.config.assets.compile
      src     : "app/assets"
      buildDir: "public/assets"
    css.root = '/stylesheets'
    js.root  = '/javascripts'
    app.use express.static "#{server.root}/public/assets"
    app.use express.static "#{server.root}/public/static_assets"