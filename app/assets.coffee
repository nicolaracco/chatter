module.exports = (assets) ->
  assets.root = __dirname
  assets.addCss 'assets/stylesheets/bootstrap.css'
  assets.addCss 'assets/stylesheets/bootstrap-theme.css'
  assets.addCss 'assets/stylesheets/chatter.css'

  assets.addJs 'assets/javascripts/jquery-2.0.3.js'
  assets.addJs 'assets/javascripts/bootstrap.js'
  assets.addJs 'assets/javascripts/chatter.coffee'