passport   = require 'passport'
Controller = require './controller'

class AuthenticationController extends Controller
  # /login => login form
  login: =>
    @render 'login', layout: 'not_logged_in'

  # /logout => signs out the user and redirects him to the root path
  logout: =>
    @req.logout()
    @notices.push 'Successfully logged out'
    @redirect_to '/login'

  # POST /login => authentication
  authenticate: (next) =>
    passport.authenticate('local', (err, user, info) =>
      return next err if err?
      if not user
        @alerts.push info.message
        return @redirect_to '/login'
      @req.logIn user, (err) =>
        return next err if err?
        @redirect_to '/'
    )(@req, @res, next)

  @setup: (server) ->
    app = server.app
    app.get  '/login', (req, res) ->
      new AuthenticationController(req, res).login()
    app.get '/logout', (req, res) ->
      new AuthenticationController(req, res).logout()
    app.post '/login', (req, res, next) ->
      new AuthenticationController(req, res).authenticate next

module.exports = AuthenticationController