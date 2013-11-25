# Connect-Assets configuration

express = require 'express'

module.exports = (server) ->
  server.app.use require('connect-assets')
    build   : server.config.assets.compile
    src     : "app/assets"
    buildDir: "public/assets"
  css.root = '/stylesheets'
  js.root  = '/javascripts'
  server.app.use express.static "#{server.root}/public/assets"
  server.app.use express.static "#{server.root}/public/static_assets"