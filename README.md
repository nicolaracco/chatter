# Chatter

A simple chat application written in Node.JS with rooms management, authentication, and log persistence.


### How to use

#### Requirements

- redis (for session management)
- mongodb
- node.js

#### Install

Clone it and install the needed packages:

```bash
git clone git@github.com:nicolaracco/chatter.git
cd chatter
npm install
```

#### Configure

Then check the configuration file and if you don't like it, create a `config.local.json` file (in the root path) when you can customize the settings:

```
# config.local.json

# sample configuration for a production environment
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
    "concat": true, # concatenate assets
    "minify": true  # minify assets
  }
}
```

#### Create a user

Use the `users_ctl` script to manage your users:

```bash
coffee users_ctl.coffee create john@mikamai.com johnsmith # create a user
coffee users_ctl.coffee list # list created users
coffee users_ctl.coffee destroy john@mikamai.com # removes a user
coffee users_ctl.coffee --help # prints help
```

#### Ready!

Now you can start the server with: `coffee app.coffee`

### TODO

- Tests of any type
- Transcript
- Admin panel for user management
- Room deletion
- Room unsubscription
