# Chatter

A simple chat application written in Node.JS with rooms management, authentication, and log persistence.


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

Now you can start the server with: `coffee app.coffee`

### TODO

- Tests of any type
- Transcript
- Admin panel for user management
- Room deletion
- Private messages
