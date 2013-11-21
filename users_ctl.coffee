program  = require 'commander'
models   = require './app/models'
Server   = require './server'

program.version('0.0.1')

# $ users_ctl create john@mikamai.com johnsmith
program
  .command('create [email] [password]')
  .description('creates a user')
  .action (email, password) ->
    if email? and password?
      server = new Server __dirname
      user = new models.User email: email, password: password
      user.save (err) ->
        if err?
          console.log "Cannot create the user: #{err.message}"
        else
          console.log "User created successfully"
        server.stop()
    else
      console.log 'Email and Password are needed'

# $ users_ctl list
program
  .command('list')
  .description('list all users')
  .action ->
    server = new Server __dirname
    models.User.find (err, users) ->
      if err?
        console.log "Cannot list users: #{err.message}"
      else
        for user in users
          console.log user.email
      server.stop()

# $ users_ctl destroy john@mikamai.com
program
  .command('remove [email]')
  .description('removes a user')
  .action (email) ->
    if email?
      server = new Server __dirname
      user = models.User.findOne email: email, (err, user) ->
        if err?
          console.log "Cannot find the user: #{err.message}"
        else
          user.remove()
          console.log "User removed successfully"
        server.stop()
    else
      console.log "Email is needed"

program.parse process.argv