@Chatter ?= {}

class Chatter.Rooms extends Backbone.Collection
  model: (attrs, opts) =>
    new Chatter.Room attrs, opts