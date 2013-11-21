passport   = require 'passport'
Controller = require './controller'

class AuthenticationController extends Controller
  # /login => login form
  login: =>
    @render 'login'

  # /logout => signs out the user and redirects him to the root path
  logout: =>
    @req.logout()
    @req.flash 'info', 'Successfully logged out'
    @redirect_to '/'

  @setup: (server) ->
    app = server.app
    app.get  '/login', (req, res) ->
      new AuthenticationController(req, res).login()
    app.get '/logout', (req, res) ->
      new AuthenticationController(req, res).logout()
    app.post '/login', passport.authenticate 'local',
                                              successRedirect: '/'
                                              failureRedirect: '/login'
                                              failureFlash: true

module.exports = AuthenticationController