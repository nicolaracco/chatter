class Connection
  connect: ->
    @socket = io.connect 'http://localhost'

  on: (args...) =>
    @socket.on args...

  off: (args...) =>
    @socket.removeAllListeners args...

  emit: (args...) =>
    @socket.emit args...

@Chatter ?= {}
Chatter.connection = new Connection