# BundleUp configuration

bundle_up = require 'bundle-up'
express   = require 'express'

module.exports = (server) ->
  bundle_up server.app, "#{server.root}/app/assets",
    staticRoot   : "#{server.root}/public/"
    staticUrlRoot:'/'
    bundle       : server.config.assets.concat
    minifyCss    : server.config.assets.minify
    minifyJs     : server.config.assets.minify
  server.app.use express.static "#{server.root}/public/"