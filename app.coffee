Server = require './lib/server'

server = new Server __dirname
server.start()
process.on 'SIGTERM', -> # gracefully stop the server
  console.log "Received kill signal (SIGTERM)"
  server.stop()