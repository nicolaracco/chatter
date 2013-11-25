# Chatter

A chat application written in Node.JS with rooms management, authentication, and log persistence.

It's an express.js application that uses mongoose as ORM, passport for managing the authentication and redis as a session store.

Server/Client messaging communication is handled by socket.io, which shares the session with express.js to verify users authentication.


### How to use

#### Requirements

- redis (for session management)
- mongodb
- node.js
- coffee-script: Remember to install it with `npm install -g coffee-script`. This way you'll have the executable in your path
- jake: Remember to install it with `npm install -g jake`. This way you'll have the executable in your path

#### Install

Clone it and install the needed packages:

```bash
git clone git@github.com:nicolaracco/chatter.git
cd chatter
npm install
```

#### Configure

The default configuration is in `config/config.json`. In `config/environments` there is one config file for each environment (each of these takes precedence upon the default configuration).

If you need to change the configuration and you don't want git to track your changes, you can overwrite each file creating a `.local.json` file: `config/config.local.json` to overwrite the default configuration, `config/environments/config.test.local.json` to overwrite the test configuration, and so on.

E.g.

```
# config/environments/config.production.local.json

{
  "server": {
    "port": 80 # server port
  },
  "session": {
    "secret": "sdkjbcsjdbc23h23exn832e2,jsbdcjsbcjsb" # session secret
  },
  "db": {
    "uri": "mongodb://localhost:27017/chatter" # mongodb uri
  },
  "assets": {
    "compile": true # concatenate and minify assets
  }
}
```

#### Create a user

Use Jake script to manage your users:

```bash
jake users:list     # List all users
jake users:create   # Create a new user. E.g. jake users:create[john@mikamai.com,password]
jake users:remove   # Removes a user. E.g. jake users:remove[john@mikamai.com]
```

#### Ready!

Now you can start the server with: `coffee app.coffee`.

### Specs

Run `jake` without arguments, or `npm test`.

### TODO

- Integration Tests on web pages and socket.io
- Transcript
- Admin panel for user management
- Room deletion
- Private messages
