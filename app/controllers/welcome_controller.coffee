models     = require '../models'
Controller = require './controller'

class WelcomeController extends Controller
  index: =>
    models.Room.find (err, rooms) =>
      if err?
        throw new Error err
      else
        @render 'index', rooms: rooms

  @setup: (server) ->
    app = server.app
    app.get '/', @ensure_authenticated, (req, res) ->
      new WelcomeController(req, res).index()

module.exports = WelcomeController