var config = module.exports;

config["Chatter Tests"] = {
  environment: "node",
  rootPath   : "../",
  tests      : [
    "spec/**/*_spec.coffee"
  ],
  extensions : [
    require("buster-coffee")
  ]
};