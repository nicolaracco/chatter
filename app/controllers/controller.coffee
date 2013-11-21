_ = require 'underscore'

# Base Controller class
class Controller
  constructor: (@req, @res) ->
    @name = @constructor.name.replace('Controller', '').toLowerCase()

  # shorthand function to render a view passing useful parameters
  render: (view, args = {}) =>
    base_args =
      error_messages   : @req.flash('error')
      info_messages    : @req.flash('info')
      is_authenticated : @req.isAuthenticated()
    @res.render "#{@name}/#{view}", _(base_args).extend args

  redirect_to: (url) =>
    @res.redirect url

  # class function that can be used during @setup as a middleware
  # (like in authentication controller)
  @ensure_authenticated: (req, res, next) ->
    if req.isAuthenticated()
      next()
    else
      res.redirect '/login'

module.exports = Controller