module.exports = (server) ->
  server.app.use (req, res, next) ->
    messages = req.session.messages ?= { notices: [], alerts: [] }
    res.locals
      notices    : messages.notices
      alerts     : messages.alerts
      has_notices: messages.notices?.length > 0
      has_alerts : messages.alerts?.length > 0
    req.session.messages = { notices: [], alerts: [] }
    next()